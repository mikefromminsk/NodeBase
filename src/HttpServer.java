/*
import javax.xml.transform.*;
import java.awt.event.FocusEvent;
import java.io.*;
import java.net.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Scanner;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import com.sun.javafx.collections.MappingChange;
import com.sun.org.apache.xerces.internal.parsers.DOMParser;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

*
 * Created by yar 09.09.2009


public class HttpServer {


    static class Block {
        String mac;
        ArrayList<FuncID> result = new ArrayList<FuncID>();
    }

    static class GenerateBlock {
        String mac;
        long endTime;
        ArrayList<FuncID> result = new ArrayList<FuncID>();
    }

    static class ThreadID {
        int blockID;
        Thread thread;

        ThreadID(int blockID, Thread thread) {
            this.blockID = blockID;
            this.thread = thread;
        }
    }

    static class HostData {
        static String outFile = "Blocks.xml";
        int blockSize = 200;
        String mac;
        String url;
        int lastBlock;
        static HashMap<Integer, Block> blockList = new HashMap<Integer, Block>();
        static HashMap<Integer, Block> waitList = new HashMap<Integer, Block>();
        static HashMap<Integer, GenerateBlock> generateList = new HashMap<Integer, GenerateBlock>();
        static HashMap<String, HostData> hostList = new HashMap<String, HostData>();
    }


    static ArrayList<ThreadID> threadList = new ArrayList<ThreadID>();

    static HostData data = new HostData();

    public static void main(String[] args) {
        try {
            InetAddress ip = InetAddress.getLocalHost();
            NetworkInterface network = NetworkInterface.getByInetAddress(ip);
            data.mac = network.getHardwareAddress().toString();
            data.url = "http://192.168.1.30:8080";


            new Thread(new SocketListener()).start();

            int processorCount = Runtime.getRuntime().availableProcessors();
            for (int i = 0; i < processorCount - 1; i++)
                threadList.add(new ThreadID(i, new Thread()));

            while (true) {
                for (int i = 0; i < processorCount; i++) {
                    ThreadID threadID = threadList.get(i);
                    if (!threadID.thread.isAlive()) {

                        int lastID = data.lastBlock;


                        for (int j = 0; j < data.generateList.size(); j++) {
                            GenerateBlock generateBlock = data.generateList.get(j);
                            if (generateBlock.blockID == threadID.blockID) {

                                Block block = new Block();
                                block.blockID = generateBlock.blockID;
                                block.mac = generateBlock.mac;
                                block.result = generateBlock.result;

                                if (data.lastBlock + 1 == block.blockID) {
                                    data.blockList.add(block);
                                    data.lastBlock++;
                                    for (int k = 0; k < data.waitList.size(); k++) {
                                        Block block1 = data.waitList.get(k);
                                        if (data.lastBlock + 1 == block1.blockID) {
                                            data.blockList.add(block1);
                                            data.waitList.remove(block1);
                                        }
                                    }
                                } else
                                    data.waitList.add(block);
                                data.generateList.remove(generateBlock);
                                break;
                            }
                        }

                        for (int j = 0; j < data.generateList.size(); j++) {
                            GenerateBlock generateBlock = data.generateList.get(j);
                            if (generateBlock.endTime < System.currentTimeMillis())
                                data.generateList.remove(generateBlock);
                        }

                        int prevBlockID = data.lastBlock;
                        int nextBlockID = data.lastBlock + 1;
                        while (nextBlockID != prevBlockID) {
                            prevBlockID = nextBlockID;
                            for (int j = 0; j < data.generateList.size(); j++) {
                                GenerateBlock generateBlock = data.generateList.get(j);
                                if (generateBlock.blockID == nextBlockID)
                                    nextBlockID++;
                            }
                        }
                        GenerateBlock generateBlock = new GenerateBlock();
                        generateBlock.mac = data.mac;
                        generateBlock.blockID = nextBlockID;
                        generateBlock.endTime = System.currentTimeMillis() + 120000;

                        data.generateList.add(generateBlock);

                        threadID.thread = new Thread(new Generator(nextBlockID));
                        threadID.thread.start();


                        String xmlData = getXmlData();
                        FileWriter fw = new FileWriter(data.outFile);
                        fw.write(xmlData);
                        fw.close();

                        for (int j = 0; j < data.hostList.size(); j++) {
                            HostData hostData = data.hostList.get(j);
                            sendRequest(hostData.url);
                        }


                    }
                }
                Thread.sleep(1000);
            }


        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static String getXmlData() {
        try {
            DocumentBuilderFactory docFactory = DocumentBuilderFactory.newInstance();
            DocumentBuilder docBuilder = docFactory.newDocumentBuilder();
            Document doc = docBuilder.newDocument();

            Element localhost = doc.createElement("localhost");
            localhost.setAttribute("mac", data.mac);
            localhost.setAttribute("lastBlock", "" + data.lastBlock);
            doc.appendChild(localhost);

            Element hosts = doc.createElement("hosts");
            localhost.appendChild(hosts);
            for (int i = 0; i < data.hostList.size(); i++) {
                HostData hostData = data.hostList.get(i);
                Element host = doc.createElement("host");
                host.setAttribute("mac", hostData.mac);
                host.setAttribute("url", hostData.url);
                host.setAttribute("lastBlock", "" + hostData.lastBlock);
                hosts.appendChild(host);
            }

            Element blocks = doc.createElement("blocks");
            localhost.appendChild(blocks);

            for (int i = 0; i < data.blockList.size(); i++) {
                if (data.blockList.get(i).result.size() == 0) continue;
                Element block = doc.createElement("block");
                block.setAttribute("blockID", "" + data.blockList.get(i).blockID);
                blocks.appendChild(block);
                // +data.waitList
                Block newBlock = data.blockList.get(i);
                for (int j = 0; j < newBlock.result.size(); j++) {
                    FuncID funcID = newBlock.result.get(j);
                    Element func = doc.createElement("func");
                    func.setAttribute("timeIndex", "" + funcID.timeIndex);
                    func.setAttribute("funcIndex", "" + funcID.funcIndex);
                    func.setAttribute("linkIndex", "" + funcID.linkIndex);
                    func.setAttribute("trueIndex", "" + funcID.trueIndex);
                    func.setAttribute("resultIndex", "" + funcID.resultIndex);
                    block.appendChild(func);
                }
            }

            Element generateBlocks = doc.createElement("generateBlocks");
            localhost.appendChild(blocks);

            for (int i = 0; i < data.generateList.size(); i++) {
                Element generateBlock = doc.createElement("generateBlock");
                generateBlock.setAttribute("blockID", "" + data.generateList.get(i).blockID);
                generateBlock.setAttribute("mac", "" + data.generateList.get(i).mac);
                generateBlock.setAttribute("endTime", "" + data.generateList.get(i).endTime);
                blocks.appendChild(generateBlock);
            }

            TransformerFactory transformerFactory = TransformerFactory.newInstance();
            Transformer transformer = transformerFactory.newTransformer();
            DOMSource source = new DOMSource(doc);
            StringWriter writer = new StringWriter();
            StreamResult result = new StreamResult(writer);
            transformer.transform(source, result);
            return writer.getBuffer().toString();
        } catch (ParserConfigurationException pce) {
            pce.printStackTrace();
        } catch (TransformerException tfe) {
            tfe.printStackTrace();
        }
        return null;
    }

    public static HostData sendRequest(String targetURL) {
        String request = getXmlData();

        StringBuffer response = null;
        URL url;
        HttpURLConnection conn = null;
        try {
            //Create connection
            url = new URL(targetURL);
            conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setRequestProperty("Content-Type",
                    "application/x-www-form-urlencoded");

            conn.setRequestProperty("Content-Length", "" +
                    Integer.toString(request.getBytes().length));
            conn.setRequestProperty("Content-Language", "en-US");

            conn.setUseCaches(false);
            conn.setDoInput(true);
            conn.setDoOutput(true);

            //Send request
            DataOutputStream wr = new DataOutputStream(
                    conn.getOutputStream());
            wr.writeBytes(request);
            wr.flush();
            wr.close();

            //Get HostData
            InputStream is = conn.getInputStream();
            BufferedReader rd = new BufferedReader(new InputStreamReader(is));
            String line;
            response = new StringBuffer();
            while ((line = rd.readLine()) != null) {
                response.append(line);
                response.append('\r');
            }
            rd.close();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        } finally {
            if (conn != null)
                conn.disconnect();
        }

        try {
            DOMParser parser = new DOMParser();
            parser.parse(new InputSource(new StringReader(response.toString())));
            Document doc = parser.getDocument();
            Element host = doc.getDocumentElement();

            HostData res = new HostData();
            res.mac = host.getAttribute("mac");
            res.url = targetURL;
            res.lastBlock = Integer.parseInt(host.getAttribute("lastBlock"));

            int pos = -1;
            for (int i = 0; i < data.hostList.size(); i++)
                if (data.hostList.get(i).mac == res.mac) {
                    data.hostList.set(i, res);
                    pos = i;
                }
            if (pos == -1)
                data.hostList.add(res);


            Element block = (Element) doc.getElementsByTagName("blocks").item(0);
            int pos2 = -1;
            for (int i = 0; i < data.blockList.size(); i++)
                if (data.blockList.get(i).blockID == Double.parseDouble(block.getAttribute("blockID"))) {
                    pos2 = i;
                    break;
                }
            if (pos2 == -1) {
                Block block2 = new Block();
                block2.blockID = Integer.parseInt(block.getAttribute("blockID"));
                NodeList funcs = block.getElementsByTagName("func");
                for (int i = 0; i < funcs.getLength(); i++) {
                    Node funcNode = funcs.item(i);
                    if (funcNode.getNodeType() == Node.ELEMENT_NODE) {
                        Element funcElement = (Element) funcNode;
                        FuncID funcID = new FuncID();
                        funcID.timeIndex = Double.parseDouble(funcElement.getAttribute("timeIndex"));
                        funcID.funcIndex = Double.parseDouble(funcElement.getAttribute("funcIndex"));
                        funcID.linkIndex = Double.parseDouble(funcElement.getAttribute("linkIndex"));
                        funcID.trueIndex = Double.parseDouble(funcElement.getAttribute("trueIndex"));
                        funcID.resultIndex = Double.parseDouble(funcElement.getAttribute("resultIndex"));
                        block2.result.add(funcID);
                    }
                }
                if (data.lastBlock + 1 == block2.blockID) {
                    data.blockList.add(block2);
                    data.lastBlock++;
                    for (int k = 0; k < data.waitList.size(); k++) {
                        Block block1 = data.waitList.get(k);
                        if (data.lastBlock + 1 == block1.blockID) {
                            data.blockList.add(block1);
                            data.waitList.remove(block1);
                        }
                    }
                } else
                    data.waitList.add(block2);
            }

            NodeList generateBlocksList = doc.getElementsByTagName("genereteBlock");
            for (int i = 0; i < generateBlocksList.getLength(); i++) {
                Node gNode = generateBlocksList.item(i);
                if (gNode.getNodeType() == Node.ELEMENT_NODE) {
                    Element generate = (Element) gNode;
                    GenerateBlock newBlock = new GenerateBlock();
                    newBlock.mac = generate.getAttribute("mac");
                    newBlock.endTime = Integer.parseInt(generate.getAttribute("endTime"));
                    newBlock.blockID = Integer.parseInt(generate.getAttribute("blockID"));

                    int pos3 = -1;
                    for (int j = 0; j < data.generateList.size(); j++) {
                        GenerateBlock block2 = data.generateList.get(j);
                        if (block2.blockID == newBlock.blockID) {
                            if (block2.mac == data.mac) {
                                data.generateList.set(j, newBlock);
                                for (int k = 0; k < threadList.size(); k++) {
                                    ThreadID threadID = threadList.get(k);
                                    if (threadID.blockID == newBlock.blockID)
                                        threadID.thread.stop();
                                }
                            }
                            break;
                        }
                    }
                    if (pos3 == -1)
                        data.generateList.add(newBlock);
                }
            }


            NodeList hosts = doc.getElementsByTagName("host");
            for (int i = 0; i < hosts.getLength(); i++) {
                Node gNode = hosts.item(i);
                if (gNode.getNodeType() == Node.ELEMENT_NODE) {
                    Element hostElement = (Element) gNode;
                    HostData newHost = new HostData();
                    newHost.mac = hostElement.getAttribute("mac");
                    newHost.url = hostElement.getAttribute("url");
                    newHost.lastBlock = Integer.parseInt(hostElement.getAttribute("lastBlock"));

                    int pos3 = -1;
                    for (int j = 0; j < data.hostList.size(); j++) {
                        HostData hostData = data.hostList.get(j);
                        if (hostData.mac == newHost.mac) {
                            data.hostList.set(i, newHost);
                            break;
                        }
                    }
                    if (pos3 == -1)
                        data.hostList.add(newHost);
                }
            }


            return res;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;


    }

    static class SocketListener implements Runnable {

        public void run() {
            try {
                ServerSocket ss = new ServerSocket(8080);
                while (true) {
                    Socket s = ss.accept();
                    System.err.println("Client accepted");
                    new Thread(new SocketSendResponse(s)).start();
                }
            } catch (Throwable e) {
                System.out.println("занят порт 8080");
            }
        }
    }

    static class SocketScanner implements Runnable {

        public void run() {
            while (data.hostList.size() == 0) {
                for (int i = 0; i < 256; i++) {
                    String toIP = "localhost";
                    HostData response = sendRequest("http://" + toIP + ":8080");
                    if (response != null) {

                        boolean find = false;
                        for (int j = 0; j < data.hostList.size(); j++)
                            if (data.hostList.get(j).mac == response.mac) {
                                find = true;
                                break;
                            }

                    }

                }
                try {
                    Thread.sleep(60000);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    static class SocketSendResponse implements Runnable {

        private Socket s;
        private InputStream is;
        private OutputStream os;

        private SocketSendResponse(Socket s) throws Throwable {
            this.s = s;
            this.is = s.getInputStream();
            this.os = s.getOutputStream();
        }

        public void run() {
            String response = "HTTP/1.1 200 OK\r\n" +
                    "Server: YarServer/2009-09-09\r\n" +
                    "Content-Type: text/html\r\n" +
                    "Content-Length: " + s.length() + "\r\n" +
                    "Connection: close\r\n\r\n";
            String result = response + s;
            os.write(result.getBytes());
            os.flush();
        }

        private void writeResponse(String s) throws Throwable {

        }


    }




}
*/
