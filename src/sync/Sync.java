package sync;


import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
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
            rd = new BufferedReader(new InputStreamReader(conn.getInputStream()));
            while ((line = rd.readLine()) != null) {
                result += line;
            }
            rd.close();
        } catch (java.net.ConnectException e) {
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

    private static Logger log = Logger.getLogger(Sync.class.getName());

    public static void main() throws InterruptedException {

        log.info("get started");
        new Thread(new HttpServer()).start();
        Thread.sleep(10);



        while (true) {
            try {

                String s = getHTML("http://localhost:8080");
                Host host = (Host) hostDataFromString(s);
                if (host == null || host.mac.equals(data.mac)) {
                    s = getHTML("http://localhost:8081");
                    if (!"".equals(s))
                        host = (Host) hostDataFromString(s);
                }

                if (!host.mac.equals(data.mac)) {

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

                    //merge hosts
                    host.mergeTime = System.currentTimeMillis();
                    data.putHostList(host);
                    for (int i = 0; i < data.hosts.size(); i++) {
                        Host hostData = data.hosts.get(i);
                        if (!hostData.mac.equals(data.mac))
                            data.putHostList(hostData);
                    }
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
            } catch (Exception e) {
                e.printStackTrace();
            }

            Thread.sleep(2000);
        }
    }
}
