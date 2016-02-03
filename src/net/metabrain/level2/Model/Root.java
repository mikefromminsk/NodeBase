package net.metabrain.level2.Model;


import net.metabrain.level2.storage.FileHashMap;

public class Root{

    static FileHashMap root;

    public static FileHashMap getInstance() {
        if (root == null) {
            root = new FileHashMap();
            String RootID = root.fs.settings.getProperty("RootID");
            if (RootID == null){
                RootID = String.valueOf(root.fs.allocate(Integer.BYTES * root.blockSize));
                root.fs.setSetting("RootID", RootID);
            }
            root.storageID = Integer.valueOf(RootID);

        }
        return root;
    }



}
