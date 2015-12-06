package net.metabrain.utils;

import java.io.Serializable;
import java.nio.Buffer;
import java.nio.ByteBuffer;
import java.nio.IntBuffer;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

public class FileHashMap {

    static FileStorage fs;
    static int storageID;

    public FileHashMap(FileStorage fileStorage) {
        this.fs = fileStorage;
        this.storageID = 0;
    }

    public FileHashMap(FileStorage fileStorage, int storageID) {
        this.fs = fileStorage;
        this.storageID = storageID;
    }

    static int HashLy(String str) {
        int hash = 1;
        for (int i = 0; i < str.length(); i++)
            hash = (hash * 1664525) + str.charAt(i) + 1013904223;
        return hash;
    }

    static final int blockSize = 19;
    static final int keyIndex = 16;
    static final int valueIndex = 17;
    static final int nextIndex = 18;
    static final int entryKeyIndex = 0;
    static final int entryValueIndex = 1;
    static final int entryNextIndex = 2;

    String get(String key) {
        String hash = Integer.toHexString(HashLy(key));
        if (storageID == 0)
            return null;
        int thisBlock = storageID;
        for (int i = 0; i < hash.length(); i++) {
            int index = Integer.parseInt("" + hash.charAt(i), 16);
            int nextBlock = fs.getInt(thisBlock, index);
            if (nextBlock == 0) {
                return null;
            }
            thisBlock = nextBlock;
            if (i == hash.length() - 1) {

                byte[] lastBlock = fs.getBytes(thisBlock);
                IntBuffer intBuffer = ByteBuffer.wrap(lastBlock).asIntBuffer();
                int keyLink = intBuffer.get(keyIndex);
                int valueLink = intBuffer.get(valueIndex);
                int nextLink = intBuffer.get(nextIndex);
                if (keyLink == 0) {
                    return null;
                } else {
                    if (fs.get(keyLink).equals(key)) {
                        return fs.get(valueLink);
                    } else if (nextLink == 0) {
                        return null;
                    } else {
                        int thisEntryLink = nextLink;
                        while (true) {
                            byte[] getEntry = fs.getBytes(thisEntryLink);
                            IntBuffer entryIntBuffer = ByteBuffer.wrap(getEntry).asIntBuffer();
                            keyLink = entryIntBuffer.get(entryKeyIndex);
                            valueLink = entryIntBuffer.get(entryValueIndex);
                            nextLink = entryIntBuffer.get(entryNextIndex);

                            if (fs.get(keyLink).equals(key)) {
                                return fs.get(valueLink);
                            } else if (nextLink == 0) {
                                return null;
                            }
                            thisEntryLink = nextLink;
                        }
                    }
                }
            }
        }
        return null;
    }

    public static void put(String key, String value) {
        String hash = Integer.toHexString(HashLy(key));
        if (storageID == 0)
            storageID = fs.allocate(Integer.BYTES * blockSize);
        int thisBlock = storageID;
        for (int i = 0; i < hash.length(); i++) {
            int index = Integer.parseInt("" + hash.charAt(i), 16);
            int nextBlock = fs.getInt(thisBlock, index);
            if (nextBlock == 0) {
                int childBlock = fs.allocate(Integer.BYTES * blockSize);
                fs.setInt(thisBlock, index, childBlock);
                nextBlock = childBlock;
            }
            thisBlock = nextBlock;
            if (i == hash.length() - 1) {
                byte[] lastBlock = fs.getBytes(thisBlock);
                IntBuffer intBuffer = ByteBuffer.wrap(lastBlock).asIntBuffer();
                int keyLink = intBuffer.get(keyIndex);
                int valueLink = fs.put(value);
                int nextLink = intBuffer.get(nextIndex);
                if (keyLink == 0) {
                    keyLink = fs.put(key);
                    fs.setInt(thisBlock, keyIndex, keyLink);
                    fs.setInt(thisBlock, valueIndex, valueLink);
                } else {
                    if (fs.get(keyLink).equals(key)) {
                        fs.setInt(thisBlock, valueIndex, valueLink);
                    } else if (nextLink == 0) {
                        keyLink = fs.put(key);
                        byte[] newEntry = fs.newBuffer(keyLink, valueLink, 0);
                        int entryLink = fs.put(newEntry);
                        fs.setInt(thisBlock, nextIndex, entryLink);
                    } else {
                        int thisEntryLink = nextLink;
                        while (true) {
                            byte[] getEntry = fs.getBytes(thisEntryLink);
                            IntBuffer entryIntBuffer = ByteBuffer.wrap(getEntry).asIntBuffer();
                            keyLink = entryIntBuffer.get(entryKeyIndex);
                            nextLink = entryIntBuffer.get(entryNextIndex);

                            if (fs.get(keyLink).equals(key)) {
                                fs.setInt(thisEntryLink, entryValueIndex, valueLink);
                                break;
                            } else if (nextLink == 0) {
                                keyLink = fs.put(key);
                                byte[] newEntry = fs.newBuffer(keyLink, valueLink, 0);
                                int entryLink = fs.put(newEntry);
                                fs.setInt(thisEntryLink, entryNextIndex, entryLink);
                                break;
                            }
                            thisEntryLink = nextLink;
                        }
                    }
                }
            }
        }
    }


    public static void main(String[] args) {
        FileHashMap map = new FileHashMap(FileStorage.getInstance());
        map.put("1", "2");
        map.put("2", "3");
        map.put("3", "4");
        System.out.println(map.get("1"));
        System.out.println(map.get("2"));
        System.out.println(map.get("3"));
    }
}
