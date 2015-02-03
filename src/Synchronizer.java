import com.sun.org.apache.xpath.internal.operations.Bool;

import java.io.*;
import java.net.*;
import java.util.*;
import java.util.logging.FileHandler;
import java.util.logging.Level;
import java.util.logging.Logger;


/**
 * Created by IntelliJ IDEA.
 * User: Admin
 * Date: 03.02.15
 * Time: 5:48
 * To change this template use File | Settings | File Templates.
 */
public class Synchronizer {

    public static boolean sendHostData(String targetURL) {
        String request = null;
        URL url;
        HttpURLConnection conn = null;
        try {
            //create send host data
            request = hostDataToString(data);

            //Create connection
            url = new URL(targetURL);
            conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
            conn.setRequestProperty("Content-Length", "" + Integer.toString(request.getBytes().length));
            conn.setRequestProperty("Content-Language", "en-US");

            conn.setUseCaches(false);
            conn.setDoInput(true);
            conn.setDoOutput(true);
            conn.setConnectTimeout(1000);


            //Send request
            DataOutputStream wr = new DataOutputStream(conn.getOutputStream());
            wr.writeBytes(request);
            wr.flush();
            wr.close();

            // get host data
            InputStream is = conn.getInputStream();
            Scanner s = new Scanner(is).useDelimiter("\\A");
            String strHostData = s.hasNext() ? s.next() : "";





            return true;
        } catch (Exception e) {
//            e.printStackTrace();
        } finally {
            if (conn != null)
                conn.disconnect();
        }
        return false;
    }

    static class Block implements Serializable {
        Integer ID;
        String mac;
        Long endTime;
        ArrayList<FuncID> result = new ArrayList<FuncID>();
        Long threadID;
    }

    static class HostData implements Serializable {
        String outFile = "c:\\HostData.class";
        Integer blockSize = 200;
        Integer processorCount = Runtime.getRuntime().availableProcessors();
        String mac = "";
        String url = "localhost";
        Integer lastID = 0;

        public ArrayList<Block> blockList = new ArrayList<Block>();

        Block getBlock(int key) {
            for (int i = 0; i < blockList.size(); i++) {
                Block block = blockList.get(i);
                if (block.ID == key)
                    return block;
            }
            return null;
        }

        void putBlock(int key, Block putBlock) {
            for (int i = 0; i < blockList.size(); i++) {
                Block block = blockList.get(i);
                if (block.ID == key) {
                    blockList.set(i, putBlock);
                    return;
                }
            }
            blockList.add(putBlock);
        }


        public ArrayList<HostData> hostList = new ArrayList<HostData>();
    }

    static HostData data;


    public static Object hostDataFromString(String s) throws IOException,
            ClassNotFoundException {
        byte[] data = Base64.getDecoder().decode(s.getBytes());
        ObjectInputStream ois = new ObjectInputStream(
                new ByteArrayInputStream(data));
        Object o = ois.readObject();
        ois.close();
        return o;
    }


    public static String hostDataToString(Serializable o) {
        ByteArrayOutputStream baos = null;

        try {
            baos = new ByteArrayOutputStream();
            ObjectOutputStream oos = new ObjectOutputStream(baos);

            oos.writeObject(o);

            oos.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return new String(Base64.getEncoder().encode(baos.toByteArray()));
    }

    static ArrayList<Thread> threadList = new ArrayList<Thread>();

    public static void main(String[] args) throws IOException, SocketException, ClassNotFoundException, InterruptedException {

        //load host data
        /*try {
            String strHostData = new Scanner(new File(data.outFile)).useDelimiter("\\Z").next();
            data = (HostData) hostDataFromString(strHostData);
        } catch (FileNotFoundException e)*/
        {
            //init
            data = new HostData();
            InetAddress ip = InetAddress.getLocalHost();
            NetworkInterface network = NetworkInterface.getByInetAddress(ip);
            data.mac = network.getHardwareAddress().toString();
            data.url = "http://192.168.1.30:8080";
        }

        //start http server
        new Thread(new SocketListener()).start();

        //start net scan
        if (data.hostList.size() == 0)
            new Thread(new NetScan()).start();

        //start generate threads
        while (true) {

            //delete stop tread
            for (int i = 0; i < threadList.size(); i++) {
                Thread thread = threadList.get(i);
                if (!thread.isAlive()) {
                    threadList.remove(i);
                    i--;
                }
            }

            //start new thread
            for (int i = threadList.size() - 1; i < data.processorCount - 1; i++)
                createNewGenerateThread();

            Thread.sleep(500);
            //save optioins
            FileWriter fw = new FileWriter(data.outFile);
            fw.write(hostDataToString(data));
            fw.close();
        }
    }

    private static void createNewGenerateThread() {
        //delete other dead thread
        for (int i = 0; i < data.blockList.size(); i++) {
            Block block = data.blockList.get(i);
            if ((block.endTime <= System.currentTimeMillis()) && (block.mac != data.mac)) {
                data.blockList.remove(i);
                i--;
            }
        }

        //inc lastID
        while (true) {
            Block block = data.getBlock(data.lastID + 1);
            if ((block != null) && (block.threadID == 0)) {
                if (block.result.size() == 0)
                    data.blockList.remove(block);
                data.lastID++;
            } else
                break;
        }

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
        threadList.add(newThread);

        //add new block
        Block block = new Block();
        block.ID = newGenerationID;
        block.endTime = System.currentTimeMillis() + 60000;
        block.mac = data.mac;
        block.threadID = newThread.getId();
        data.blockList.add(block);

        //start generate thread
        newThread.start();

    }
}
