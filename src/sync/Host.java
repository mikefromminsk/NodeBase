package sync;


import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

class Host implements Serializable {

    String ip = "localhost";
    String port = "8080";
    String mac = "";

    Integer lastID = 0;
    public ArrayList<Block> blocks = new ArrayList<Block>();
    Integer processorCount = Runtime.getRuntime().availableProcessors();
    Long mergeTime = 0L;


    public Host(String ip, String port) {
        this.ip = ip;
        this.port = port;
    }

    public Host() {
    }

    synchronized Block getBlock(int ID) {
        for (int i = 0; i < blocks.size(); i++) {
            Block block = blocks.get(i);
            if (block.ID.equals(ID))
                return block;
        }
        return null;
    }

    synchronized void putBlock(Block putBlock) {
        for (int i = 0; i < blocks.size(); i++) {
            Block block = blocks.get(i);
            if (block.ID.equals(putBlock.ID)) {
                blocks.set(i, putBlock);
                return;
            }
        }
        blocks.add(putBlock);
    }


    public Map<String, String> hosts = new HashMap<String, String>();



    synchronized public void removeBlock(Block remove) {
        for (Iterator<Block> it = blocks.iterator(); it.hasNext(); ) {
            Block block = it.next();
            if (block == remove)
                it.remove();
        }
    }
}