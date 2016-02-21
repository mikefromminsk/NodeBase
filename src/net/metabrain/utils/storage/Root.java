package net.metabrain.utils.storage;

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

    //если нету в storage data искать в файловой системе
    //таким образом можно будет динамически редактировать storage.data и видеть файлы проекта
    //и в FileDownload можно будет скачать любую переменную storage.data


}
