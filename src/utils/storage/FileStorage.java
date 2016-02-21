package utils.storage;

import java.io.*;
import java.nio.ByteBuffer;
import java.nio.IntBuffer;
import java.util.Properties;

public class FileStorage {

    static FileStorage instance;

    public static FileStorage getInstance(){
        if (instance == null)
            instance = new FileStorage();
        return instance;
    }

    public Properties settings = new Properties();
    static int lastID;
    File metafile;
    File datafile;
    RandomAccessFile metaraf;
    RandomAccessFile dataraf;
    final int MetaDataLength = Integer.BYTES * 2;

    public FileStorage() {
        this(null);
    }

    File settingsFile;
    String getSetting(String key){
        return settings.getProperty(key);
    }

    String getSetting(String key, String defaultValue){
        return settings.getProperty(key, defaultValue);
    }

    public void setSetting(String key, String value){
        settings.setProperty(key, value);
        try {
            settings.store(new FileOutputStream(settingsFile), null);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public FileStorage(String settingsPath) {
        try {
            if (settingsPath == null || settingsPath.equals(""))
                settingsPath = "storage.prop";
            settingsFile = new File(settingsPath);
            if (!settingsFile.exists())
                settingsFile.createNewFile();
            System.out.println(settingsFile.getAbsolutePath());
            settings.load(new FileInputStream(settingsFile));
            metafile = new File(getSetting("metafile", "storage.meta"));
            datafile = new File(getSetting("datafile", "storage.data"));
            System.out.println(metafile.getAbsolutePath());
            System.out.println(datafile.getAbsolutePath());
            setSetting("metafile", metafile.getAbsolutePath());
            setSetting("datafile", datafile.getAbsolutePath());

            if (!metafile.exists())
                metafile.createNewFile();
            if (!datafile.exists())
                datafile.createNewFile();

            metaraf = new RandomAccessFile(metafile, "rw");
            dataraf = new RandomAccessFile(datafile, "rw");

            lastID = (int) (metafile.length() / MetaDataLength);

            String testStr = "test";
            String testInt = get(0);
            if (testInt == null)
            {
                Integer testID = put(testStr);
                if (testID == null)
                    throw new Exception();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    public static byte[] newBuffer(Integer... args) {
        ByteBuffer byteBuffer = ByteBuffer.allocate(args.length * Integer.BYTES);
        IntBuffer intBuffer = byteBuffer.asIntBuffer();
        for (int i : args)
            intBuffer.put(i);
        return byteBuffer.array();
    }

    class MetaData{
        int begin;
        int length;

        public MetaData(int begin, int length) {
            this.begin = begin;
            this.length = length;
        }

        public  byte[] getBytes(){
            return newBuffer(begin, length);
        }
    }

    void setMeta(MetaData meta, int id){
        try {
            metaraf.seek(id * MetaDataLength);
            byte[] buf = meta.getBytes();
            metaraf.write(buf);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    MetaData getMeta(int id){
        try {
            if (id <= 0 || id > lastID)
                return null;
            byte[] buffer = new byte[MetaDataLength];
            metaraf.seek(id * MetaDataLength);
            metaraf.read(buffer, 0, MetaDataLength);
            IntBuffer intBuffer = ByteBuffer.wrap(buffer).asIntBuffer();
            int begin = intBuffer.get(0);
            int length = intBuffer.get(1);
            return new MetaData(begin, length);
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
    }

    Integer length(int id){
        MetaData metaData = getMeta(id);
        if (metaData == null)
            return null;
        return metaData.length;
    }

    void setData(byte[] data, int begin, int length){
        try {
            dataraf.seek(begin);
            dataraf.write(data, 0, length);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    Integer put(String data){
        return put(data.getBytes());
    }

    Integer put(byte[] data){
        try {
            int dataFileLength = (int) dataraf.length();
            setMeta(new MetaData(dataFileLength, data.length), lastID);
            setData(data, dataFileLength, data.length);
            return lastID++;
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
    }

    void set(String data, int id){
        int newID = put(data);
        MetaData metaData = getMeta(newID);
        if (metaData == null)
            return;
        setMeta(metaData, id);
    }

    public int allocate(int size){
        StringBuffer sb = new StringBuffer();
        sb.setLength(size);
        return put(sb.toString());
    }

    byte[] getData(int begin, int length) {
        byte[] buffer = new byte[length];
        try {
            dataraf.seek(begin);
            dataraf.read(buffer, 0, length);
            return buffer;
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
    }

    byte[] getBytes(int id) {
        MetaData metaData = getMeta(id);
        if (metaData == null)
            return null;
        return getData(metaData.begin, metaData.length);
    }

    Integer getInt(int id, int index) {
        MetaData metaData = getMeta(id);
        if (metaData == null)
            return null;
        if (index * Integer.BYTES + Integer.BYTES > metaData.length)
            return null;
        int begin = metaData.begin + index * Integer.BYTES;
        return ByteBuffer.wrap(getData(begin, Integer.BYTES)).getInt();
    }

    ByteBuffer getBuffer(int id) {
        return ByteBuffer.wrap(getBytes(id));
    }


    void setInt(int id, int index, int value) {
        ByteBuffer b = ByteBuffer.allocate(MetaDataLength);
        b.putInt(value);
        MetaData metaData = getMeta(id);
        if (metaData == null)
            return;
        if (index * Integer.BYTES + Integer.BYTES > metaData.length)
            return;
        int begin = metaData.begin + index * Integer.BYTES;
        setData(b.array(), begin, Integer.BYTES);
    }

    String get(int storageID){
        try {
            byte[] buffer = getBytes(storageID);
            return new String(buffer, "UTF8");
        } catch (Exception e) {
            return null;
        }
    }


    public Integer put(Object object) {
        try {
            ByteArrayOutputStream bos = new ByteArrayOutputStream();
            ObjectOutput out = new ObjectOutputStream(bos);
            out.writeObject(object);
            byte[] buffer = bos.toByteArray();
            return put(buffer);
        } catch (Exception e){
            e.printStackTrace();
            return null;
        }
    }

    public Object getObject(int id) {
        try {
            byte[] buffer = getBytes(id);
            ByteArrayInputStream bis = new ByteArrayInputStream(buffer);
            ObjectInput in = new ObjectInputStream(bis);
            return in.readObject();
        } catch (Exception e){
            e.printStackTrace();
            return null;
        }
    }

    public static void main(String[] args) {
        FileStorage storage = FileStorage.getInstance();
        storage.set("sd2efes", 7);
        System.out.println(storage.get(7));
        System.out.println(7);
    }
}
