package sync;


import java.io.*;
import java.net.*;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.logging.Logger;

/**
 * Created by IntelliJ IDEA.
 * User: Admin
 * Date: 05.02.15
 * Time: 4:46
 * To change this template use File | Settings | File Templates.
 */
public class Sync {


    static Host data = new Host();

    public static synchronized Object hostDataFromString(String s) {
        byte[] data = Base64.decode(s);
        ObjectInputStream ois = null;
        Object o = null;
        try {
            ois = new ObjectInputStream(new ByteArrayInputStream(data));
            o = ois.readObject();
            ois.close();
        } catch (IOException e) {
            e.printStackTrace();
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
        return o;
    }


    public static synchronized String hostDataToString(Serializable o) {
        ByteArrayOutputStream baos = null;

        try {
            baos = new ByteArrayOutputStream();
            ObjectOutputStream oos = new ObjectOutputStream(baos);
            oos.writeObject(o);
            oos.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return new String(Base64.encode(baos.toByteArray()));
    }

    public static String getHTML(String urlToRead) {
        URL url;
        HttpURLConnection conn;
        BufferedReader rd;
        String line;
        String result = "";
        try {
            url = new URL(urlToRead);
            conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setConnectTimeout(2000);
            rd = new BufferedReader(new InputStreamReader(conn.getInputStream()));
            while ((line = rd.readLine()) != null) {
                result += line;
            }
            rd.close();
        } catch (java.net.ConnectException e) {
            //e.printStackTrace();
        }catch (java.net.SocketTimeoutException e) {
            //e.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    static synchronized void setResult(int id) {

    }


    static ArrayList<Thread> threads = new ArrayList<Thread>();

    synchronized static Block getBlockByThreadID(Long ID) {
        for (int i = 0; i < data.blocks.size(); i++) {
            Block block = data.blocks.get(i);
            if (block.threadID.equals(ID))
                return block;
        }
        return null;
    }

    synchronized static Thread getThread(Long ID) {
        for (int i = 0; i < threads.size(); i++) {
            Thread thread = threads.get(i);
            if (thread.getId() == ID)
                return thread;
        }
        return null;
    }

    public static String getMac(InetAddress localIP) throws SocketException {
        byte[] mac = NetworkInterface.getByInetAddress(localIP).getHardwareAddress();
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < mac.length; i++)
            sb.append(String.format("%02X%s", mac[i], (i < mac.length - 1) ? "-" : ""));
        return sb.toString();
    }
    public static Logger log = Logger.getLogger(Sync.class.getName());

    public static InetAddress getCurrentIp() {
        try {
            Enumeration<NetworkInterface> networkInterfaces = NetworkInterface
                    .getNetworkInterfaces();
            while (networkInterfaces.hasMoreElements()) {
                NetworkInterface ni = (NetworkInterface) networkInterfaces
                        .nextElement();
                Enumeration<InetAddress> nias = ni.getInetAddresses();
                while(nias.hasMoreElements()) {
                    InetAddress ia= (InetAddress) nias.nextElement();
                    if (!ia.isLinkLocalAddress()
                            && !ia.isLoopbackAddress()
                            && ia instanceof Inet4Address) {
                        return ia;
                    }
                }
            }
        } catch (SocketException e) {
            //LOG.error("unable to get current IP " + e.getMessage(), e);
        }
        return null;
    }

    public static void main(String[] args) {

        InetAddress localIP = null;
        try {

            new Thread(new HttpServer()).start();
            Thread.sleep(10);
        } catch (Exception e) {
            e.printStackTrace();
        }
        //testing in real
        try {
            localIP = getCurrentIp();
            data.ip = localIP.getHostAddress();
            data.mac = getMac(localIP);
        } catch (Exception e) {
            e.printStackTrace();
        }

        data.hosts.add("192.168.1.10:8080");
        data.hosts.add("192.168.1.10:8081");
        data.hosts.add("192.168.1.8:8080");


        while (true) {
            try {
                for (int j = 0; j < data.hosts.size(); j++) {
                    String ip = data.hosts.get(j);
                    if (ip.equals(data.ip + ":" + data.port))
                        continue;
                    //get remote host data
                    String s = getHTML("http://" + ip);
                    if ("".equals(s))
                        continue;
                    Host host = (Host) hostDataFromString(s);
                    if (host == null || host.mac.equals(data.mac))
                        continue;

                    //delete from exists blocks
                    for (int i = 0; i < data.blocks.size(); i++) {
                        Block localBlock = data.blocks.get(i);
                        Block remoteBlock = host.getBlock(localBlock.ID);

                        if ((localBlock.ID > data.lastID &&
                                (localBlock.endTime <= System.currentTimeMillis() && localBlock.threadEnd == false &&
                                        !localBlock.mac.equals(data.mac)))
                                ||
                                (localBlock.ID > data.lastID && localBlock.ID <= host.lastID &&
                                        (remoteBlock == null) ||
                                        (remoteBlock != null && !remoteBlock.mac.equals(data.mac)))
                                ||
                                (localBlock.ID > data.lastID && localBlock.ID > host.lastID &&
                                        (remoteBlock != null &&
                                                ((remoteBlock.threadEnd == true) ||
                                                        (remoteBlock.threadEnd == false && !remoteBlock.mac.equals(data.mac))))
                                )) {
                            if (localBlock.mac.equals(data.mac)) {
                                Thread thread = getThread(localBlock.threadID);
                                if (thread != null && thread.isAlive())
                                    thread.interrupt();
                            }
                            data.removeBlock(localBlock);
                            i--;
                        }
                    }

                    //add remote block
                    for (int i = 0; i < host.blocks.size(); i++) {
                        Block remoteBlock = host.blocks.get(i);
                        if ((remoteBlock.ID > data.lastID) && (!remoteBlock.mac.equals(data.mac)))
                            data.putBlock(remoteBlock);
                    }

                    if (data.lastID < host.lastID)
                        data.lastID = host.lastID;

                    log.info("merge host " + ip + " id " + host.lastID);
                }


                //delete stop tread
                for (int i = 0; i < threads.size(); i++) {
                    Thread thread = threads.get(i);
                    if (!thread.isAlive()) {
                        threads.remove(thread);
                        i--;
                    }
                }

                //inc lastID
                while (true) {
                    Block block = data.getBlock(data.lastID + 1);
                    if ((block != null) && (block.threadEnd == true)) {
                        if (block.result.size() == 0)
                            data.removeBlock(block);
                        data.lastID++;
                    } else
                        break;
                }

                //start new thread
                for (int j = threads.size() - 1; j < data.processorCount - 1; j++) {

                    //new generate id
                    int newGenerationID = data.lastID + 1;
                    while (true) {
                        Block block = data.getBlock(newGenerationID);
                        if (block == null)
                            break;
                        newGenerationID++;
                    }

                    //create thread id
                    Thread newThread = new Thread(new Generator(newGenerationID));
                    threads.add(newThread);

                    //add new block
                    Block block = new Block();
                    block.ID = newGenerationID;
                    block.endTime = System.currentTimeMillis() + 60000;
                    block.mac = data.mac;
                    block.threadID = newThread.getId();
                    data.putBlock(block);

                    //start generate thread
                    newThread.start();
                }

                Thread.sleep(2000);

            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}
