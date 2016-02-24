package utils.storage;

import java.nio.ByteBuffer;
import java.nio.IntBuffer;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class FileHashMap {

    void putTrigger(){

    }

    public FileStorage fs = FileStorage.getInstance();
    public int storageID;

    public FileHashMap() {
        this.storageID = 0;
    }

    public FileHashMap(String path) {
        String RootID = Root.getInstance().get(path);
        if (RootID == null){
            storageID = fs.allocate(Integer.BYTES * blockSize);
            Root.getInstance().put(path, String.valueOf(storageID));
            RootID = Root.getInstance().get(path);
            System.out.println(RootID);
        }
        else
            storageID = Integer.valueOf(RootID);
    }

    int hash(String str) {
        //LY hash
        int hash = 1;
        for (int i = 0; i < str.length(); i++)
            hash = (hash * 1664525) + str.charAt(i) + 1013904223;
        return hash;
    }

    final int linksCount = 16;
    public final int blockSize = 19;
    final int keyIndex = 16;
    final int valueIndex = 17;
    final int nextIndex = 18;
    final int entryKeyIndex = 0;
    final int entryValueIndex = 1;
    final int entryNextIndex = 2;

    public String get(String key) {
        return get(hash(key), key);
    }

    String get(int hash, String key) {
        String hashstr = String.format("%08X", hash);
        if (storageID == 0)
            return null;
        int thisBlock = storageID;
        for (int i = 0; i < hashstr.length(); i++) {
            int index = Integer.parseInt("" + hashstr.charAt(i), 16);
            int nextBlock = fs.getInt(thisBlock, index);
            if (nextBlock == 0) {
                return null;
            }
            thisBlock = nextBlock;
            if (i == hashstr.length() - 1) {

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

    public Map<String, String> get(int hash) {
        if (storageID == 0)
            return null;
        Map<String, String> result = new HashMap<>();
        String hashstr = String.format("%08X", hash);
        int thisBlock = storageID;
        for (int i = 0; i < hashstr.length(); i++) {
            //первый раз читать сразу блок из 8 метаданных
            int index = Integer.parseInt("" + hashstr.charAt(i), 16);
            int nextBlock = fs.getInt(thisBlock, index);
            if (nextBlock == 0) {
                return null;
            }
            thisBlock = nextBlock;
            if (i == hashstr.length() - 1) {

                byte[] lastBlock = fs.getBytes(thisBlock);
                IntBuffer intBuffer = ByteBuffer.wrap(lastBlock).asIntBuffer();
                int keyLink = intBuffer.get(keyIndex);
                int valueLink = intBuffer.get(valueIndex);
                int nextLink = intBuffer.get(nextIndex);
                if (keyLink == 0) {
                    return null;
                } else {
                    result.put(fs.get(keyLink), fs.get(valueLink));
                    if (nextLink != 0) {
                        int thisEntryLink = nextLink;
                        while (true) {
                            byte[] getEntry = fs.getBytes(thisEntryLink);
                            IntBuffer entryIntBuffer = ByteBuffer.wrap(getEntry).asIntBuffer();
                            keyLink = entryIntBuffer.get(entryKeyIndex);
                            valueLink = entryIntBuffer.get(entryValueIndex);
                            nextLink = entryIntBuffer.get(entryNextIndex);

                            result.put(fs.get(keyLink), fs.get(valueLink));

                            if (nextLink == 0) {
                                return result;
                            }
                            thisEntryLink = nextLink;
                        }
                    }
                }
            }
        }
        return result;
    }

    public void put(String key, String value) {
        put(hash(key), key, value);
    }
    //put first 8byte is type of var
    //array string int

    //save the history
    public void put(int hash, String key, String value) {
        String hashstr = String.format("%08X", hash);
        if (storageID == 0)
            storageID = fs.allocate(Integer.BYTES * blockSize);
        int thisBlock = storageID;
        for (int i = 0; i < hashstr.length(); i++) {
            int index = Integer.parseInt("" + hashstr.charAt(i), 16);
            int nextBlock = fs.getInt(thisBlock, index);
            if (nextBlock == 0) {
                int childBlock = fs.allocate(Integer.BYTES * blockSize);
                fs.setInt(thisBlock, index, childBlock);
                nextBlock = childBlock;
            }
            thisBlock = nextBlock;
            if (i == hashstr.length() - 1) {
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


    int next(int hash) {
        if (storageID == 0)
            return 0;
        String hashstr = String.format("%08X", hash);
        IntBuffer[] path = new IntBuffer[hashstr.length()];
        int thisBlock = storageID;
        for (int i = 0; i < hashstr.length(); i++) {
            int index = Integer.parseInt("" + hashstr.charAt(i), 16);
            path[i] = fs.getBuffer(thisBlock).asIntBuffer();
            int nextBlock = path[i].get(index);
            thisBlock = nextBlock;
            if (i == hashstr.length() - 1 || thisBlock == 0) {

                String resultStr = null;
                int goUpBlock = 0;
                for (; i >= 0 && goUpBlock == 0; i--)
                    for (int k = Integer.parseInt("" + hashstr.charAt(i), 16) + 1; k < linksCount && goUpBlock == 0; k++)
                        if (path[i].get(k) != 0) {
                            goUpBlock = path[i].get(k);
                            resultStr = hashstr.substring(0, i) + Integer.toHexString(k);
                        }
                if (goUpBlock == 0)
                    return 0;


                IntBuffer intBuffer = fs.getBuffer(goUpBlock).asIntBuffer();
                for (int j = 0; j < linksCount; j++) {
                    if (intBuffer.get(j) != 0) {
                        intBuffer = fs.getBuffer(intBuffer.get(j)).asIntBuffer();
                        resultStr += Integer.toHexString(j);
                        j = -1;
                    }
                }

                return Integer.parseInt(resultStr, 16);
            }
        }
        return 0;
    }

    int prev(int hash) {
        if (storageID == 0)
            return 0;
        String hashstr = String.format("%08X", hash);
        IntBuffer[] path = new IntBuffer[hashstr.length()];
        int thisBlock = storageID;
        for (int i = 0; i < hashstr.length(); i++) {
            int index = Integer.parseInt("" + hashstr.charAt(i), 16);
            path[i] = fs.getBuffer(thisBlock).asIntBuffer();
            int nextBlock = path[i].get(index);
            if (nextBlock == 0)
                return 0;
            thisBlock = nextBlock;
            if (i == hashstr.length() - 1) {

                String resultStr = null;
                int goUpBlock = 0;
                for (; i >= 0 && goUpBlock == 0; i--)
                    for (int k = Integer.parseInt("" + hashstr.charAt(i), 16) - 1; k >= 0 && goUpBlock == 0; k--)
                        if (path[i].get(k) != 0) {
                            goUpBlock = path[i].get(k);
                            resultStr = hashstr.substring(0, i) + Integer.toHexString(k);
                        }

                if (goUpBlock == 0)
                    return 0;

                IntBuffer intBuffer = fs.getBuffer(goUpBlock).asIntBuffer();
                for (int j = linksCount - 1; j >= 0; j--) {
                    if (intBuffer.get(j) != 0) {
                        intBuffer = fs.getBuffer(intBuffer.get(j)).asIntBuffer();
                        resultStr += Integer.toHexString(j);
                        j = linksCount;
                    }
                }

                return Integer.parseInt(resultStr, 16);
            }
        }
        return 0;
    }

    public List<Integer> interval(int begin, int end) {
        List<Integer> result = new ArrayList<>();
        int min = Math.min(begin, end);
        int max = Math.max(begin, end);
        int now = min;
        while (now != 0 && now <= max){
            if (get(now) != null)
                result.add(now);
            now = next(now);
        }
        return result;
    }

}
