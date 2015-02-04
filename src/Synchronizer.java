import java.io.*;
import java.net.*;
import java.util.*;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;

/**
 * Created by IntelliJ IDEA.
 * User: Admin
 * Date: 03.02.15
 * Time: 5:48
 * To change this template use File | Settings | File Templates.
 */
public class Synchronizer {

    static class Block implements Serializable {
        Integer ID;
        String mac;
        Long endTime;
        ArrayList<FuncID> result = new ArrayList<FuncID>();
        Long threadID = 0L;
        Boolean threadEnd = false;
    }

    static class HostData implements Serializable {
        String outFile = "c:\\HostData.class";
        Integer blockSize = 200;
        Integer processorCount = Runtime.getRuntime().availableProcessors();
        String mac = "";
        String url = "localhost";
        Integer lastID = 0;
        Long mergeTime;

        public ArrayList<Block> blockList = new ArrayList<Block>();

        Block getBlock(int ID) {
            for (int i = 0; i < blockList.size(); i++) {
                Block block = blockList.get(i);
                if (block.ID == ID)
                    return block;
            }
            return null;
        }

        void putBlock(Block putBlock) {
            for (int i = 0; i < blockList.size(); i++) {
                Block block = blockList.get(i);
                if (block.ID == putBlock.ID) {
                    blockList.set(i, putBlock);
                    return;
                }
            }
            blockList.add(putBlock);
        }


        public ArrayList<HostData> hostList = new ArrayList<HostData>();

        public void putHostList(HostData newData) {
            for (int i = 0; i < hostList.size(); i++) {
                HostData hostData = hostList.get(i);
                if (hostData.mac == newData.mac) {
                    if (newData.mergeTime > hostData.mergeTime)
                        hostList.set(i, hostData);
                    return;
                }
            }
            hostList.add(newData);
        }

        public void removeBlock(Block remove) {
            for (Iterator<Block> it = data.blockList.iterator(); it.hasNext(); ) {
                    Block block = it.next();
                    if (block == remove)
                        it.remove();
                }
        }
    }


    static HostData data;

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
        new Thread(new HttpServer()).start();

        Thread.sleep(10);
        //start net scan
        if (data.hostList.size() == 0)
            new Thread(new LanScaner()).start();

        //start generate threads
        while (true) {

            //thread end then send message to host list

            for (int i = 0; i < data.hostList.size(); i++) {
                HostData hostData = data.hostList.get(i);
                getHostData(hostData.url);
            }

            runGenerateThreads();


            Thread.sleep(500);
            //save optioins
            FileWriter fw = new FileWriter(data.outFile);
            fw.write(hostDataToString(data));
            fw.close();
        }
    }

    public static boolean getHostData(String targetURL) {
        String request = null;
        URL url;
        HttpURLConnection conn = null;
        try {
            //get host data
            url = new URL(targetURL);
            HttpURLConnection con = (HttpURLConnection) url.openConnection();
            con.setRequestMethod("GET");
            BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()));
            String inputLine;
            StringBuffer response = new StringBuffer();
            while ((inputLine = in.readLine()) != null)
                response.append(inputLine);
            in.close();

            //merge data
            String res = response.toString();
            mergeData(res);
            return true;

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (conn != null)
                conn.disconnect();
        }
        return false;
    }

    void stopThread(Long id) {
        for (int j = 0; j < threadList.size(); j++) {
            Thread thread = threadList.get(j);
            if (thread.getId() == id)
                thread.stop();
        }
    }

    static Block getBlockByThreadID(Long ID) {
        for (int i = 0; i < data.blockList.size(); i++) {
            Block block = data.blockList.get(i);
            if (block.threadID == ID)
                return block;
        }
        return null;
    }


    public static boolean mergeData(String strHostData) {


        HostData newHostData = (HostData) hostDataFromString(strHostData);

        if (newHostData.mac.equals(data.mac))
            return false;

        //stop thread where id <  data last id
        for (int i = 0; i < threadList.size(); i++) {
            Thread thread = threadList.get(i);
            Block threadBlock = getBlockByThreadID(thread.getId());
            if (threadBlock == null) continue;
            Block remoteBlock = newHostData.getBlock(threadBlock.ID);
            if ((threadBlock.ID <= newHostData.lastID) || ((remoteBlock != null) && (remoteBlock.mac != data.mac))) {
                thread.stop();
                data.removeBlock(threadBlock);
            }
        }

        //delete local block
        for (int i = 0; i < data.blockList.size(); i++) {
            Block block = data.blockList.get(i);
            if ((block.ID > data.lastID) && (block.ID <= newHostData.lastID)) {
                data.removeBlock(block);
                i--;
            }
        }

        //add remote block
        for (int i = 0; i < newHostData.blockList.size(); i++) {
            Block remoteBlock = newHostData.blockList.get(i);
            if ((remoteBlock.ID > data.lastID) && (remoteBlock.mac != data.mac))
                data.putBlock(remoteBlock);
        }

        if (data.lastID < newHostData.lastID)
            data.lastID = newHostData.lastID;


        //merge hostList
        newHostData.mergeTime = System.currentTimeMillis();
        data.putHostList(newHostData);
        for (int i = 0; i < data.hostList.size(); i++) {
            HostData hostData = data.hostList.get(i);
            if (hostData.mac != data.mac)
                data.putHostList(hostData);
        }

        //run new thread
        runGenerateThreads();

        return true;
    }


    public static Object hostDataFromString(String s) {
        byte[] data = Base64.getDecoder().decode(s.getBytes());
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

    private static void runGenerateThreads() {

        //delete stop tread
        for (int i = 0; i < threadList.size(); i++) {
            Thread thread = threadList.get(i);
            if (!thread.isAlive()) {
                threadList.remove(i);
                i--;
            }
        }

        //delete other dead block
        for (int i = 0; i < data.blockList.size(); i++) {
            Block block = data.blockList.get(i);
            if ((block.endTime <= System.currentTimeMillis()) && (block.mac != data.mac)) {
                data.removeBlock(block);
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
        for (int j = threadList.size() - 1; j < data.processorCount - 1; j++) {


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
}
