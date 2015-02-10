package sync;


import java.io.Serializable;
import java.util.ArrayList;
import java.util.Iterator;

class Host implements Serializable {
    String outFile = "c:\\HostData.class";
    Integer blockSize = 200;
    Integer processorCount = Runtime.getRuntime().availableProcessors();
    String mac = "";
    String url = "localhost";
    Integer lastID = 0;
    Long mergeTime;

    public ArrayList<Block> blocks = new ArrayList<Block>();

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


    public ArrayList<Host> hosts = new ArrayList<Host>();

    synchronized public void putHostList(Host newData) {
        for (int i = 0; i < hosts.size(); i++) {
            Host hostData = hosts.get(i);
            if (hostData.mac.equals(newData.mac)) {
                if (newData.mergeTime > hostData.mergeTime)
                    hosts.set(i, hostData);
                return;
            }
        }
        hosts.add(newData);
    }

    synchronized public void removeBlock(Block remove) {
        for (Iterator<Block> it = blocks.iterator(); it.hasNext(); ) {
            Block block = it.next();
            if (block == remove)
                it.remove();
        }
    }
}