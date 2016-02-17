package net.metabrain.level2.consolidator;

import java.util.*;

public class Arrays {
    //groupName/groupID
    public Integer arrayLastID = 0;
    public Map<String, ArrayList<String>> allArrays = new HashMap<>();
    public Map<String, ArrayList<String>> allSortArrays = new HashMap<>();
    public Map<String, ArrayList<String>> allObjects = new HashMap<>(); //link objectid to groupid

    public Map<String, Double> arrayCounters = new HashMap<>();
    final int arrayCountersCashSize = 20;
    public Map<String, Double> arrayCountersCash = new HashMap<>();


    //нечеткий поиск по значениям


    public ArrayList<String> getArray(String groupID) {
        return allArrays.get(groupID);
    }

    public ArrayList<String> arrays(List<String> input) {
        ArrayList<String> result = new ArrayList<String>();
        for (int i = 0; i < input.size(); i++) {
            ArrayList<String> groups = allObjects.get(input.get(i));
            if (groups != null)
                for (int j = 0; j < groups.size(); j++)
                    if (result.indexOf(groups.get(j)) == -1)
                        result.add(groups.get(j));
        }
        return result;
    }

    public Map<String, Double> findPermutations(ArrayList<String> input) {
        ArrayList<String> sortInput = (ArrayList<String>) input.clone();
        java.util.Collections.sort(sortInput);
        ArrayList<String> groups = arrays(sortInput);
        Map<String, Double> likes = new HashMap<String, Double>();
        for (int k = 0; k < groups.size(); k++) {
            ArrayList<String> objects = allSortArrays.get(groups.get(k));
            double count = 0;
            for (int i = 0; i < objects.size(); i++) {
                String object = objects.get(i);
                for (int j = 0; j < sortInput.size(); j++)
                    if (object.equals(sortInput.get(j)))
                        count++;
            }
            likes.put(groups.get(k), count / sortInput.size());
        }
        return likes;
    }


    public Map<String, Double> findSequences(ArrayList<String> input) {
        ArrayList<String> groups = arrays(input);
        Map<String, Double> likes = new HashMap<String, Double>();
        for (int k = 0; k < groups.size(); k++) {
            ArrayList<String> objects = allArrays.get(groups.get(k));
            double count = 0;
            for (int i = 0; i < objects.size(); i++)
                if (objects.get(i) == null || objects.get(i).equals(input.get(i)))
                    count++;
            likes.put(groups.get(k), count / input.size());
        }
        return likes;
    }

    public static String max(Map<String, Double> likes) {
        double max = 0;
        String result = null;
        for (String groupId : likes.keySet()) {
            if (likes.get(groupId) > max) {
                result = groupId;
                max = likes.get(groupId);
            }
        }
        return result;
    }

    public static String min(Map<String, Double> array) {
        double min = Double.POSITIVE_INFINITY;
        String result = null;
        for (String groupId : array.keySet()) {
            if (array.get(groupId) < min) {
                result = groupId;
                min = array.get(groupId);
            }
        }
        return result;
    }

    ArrayList<String> objectBuffer = new ArrayList<>();

    void putToArrayBuffer(String object) {
        objectBuffer.add(object);
    }

    String saveArrayBuffer() {
        String arrayID = put(objectBuffer);
        objectBuffer.clear();
        return arrayID;
    }

    String prevArrayID = null;
    ArrayList<String> lastTemplate = null;

    public String put(ArrayList<String> input) {


        Map<String, Double> permutation = findPermutations(input); //findPermutations включает в себя поиск по findSequences
        String arrayID = max(permutation);
        //update group
        if (arrayID == null || permutation.get(arrayID) != 1.0) {
            arrayID = "" + arrayLastID++;
            allArrays.put(arrayID, (ArrayList<String>) input.clone());
            ArrayList<String> sortInput = (ArrayList<String>) input.clone();
            java.util.Collections.sort(sortInput);
            allSortArrays.put(arrayID, sortInput);
        }


        //update allObjects
        for (int i = 0; i < input.size(); i++) {
            String objName = input.get(i);
            ArrayList<String> object = allObjects.get(input.get(i));
            if (object == null) {
                object = new ArrayList<>();
                allObjects.put(objName, object);
            }
            if (object.indexOf(arrayID) == -1)
                object.add(arrayID);
        }


        //template
        //using last event from FileHashMap
        if (prevArrayID != null) {
            ArrayList<String> prevArray = getArray(prevArrayID);
            ArrayList<String> thisArray = getArray(arrayID);
            lastTemplate = template(prevArray, thisArray);
        }


        prevArrayID = arrayID;

        //counters
        Double arrayCounter = arrayCounters.get(arrayID);
        if (arrayCounter == null)
            arrayCounter = 0.0;
        arrayCounters.put(arrayID, arrayCounter + 1);

        //arrayCountersCash
        arrayCountersCash.put(arrayID, arrayCounter);
        if (arrayCountersCash.size() > arrayCountersCashSize)
        {
            String minCounter = min(arrayCountersCash);
            arrayCountersCash.remove(minCounter);
        }

        return arrayID;
    }


    ArrayList<String> template(ArrayList<String> from, ArrayList<String> to) {
        ArrayList<String> result = (ArrayList<String>) to.clone();
        for (int i = 0; i < from.size(); i++)
            if (i >= to.size()) {
                result.add(i, from.get(i));
            } else {
                if ((from.size() < i + 1) || (to.size() < i + 1) || !from.get(i).equals(to.get(i)))
                    //изменение -1
                    //добавление -2
                    //удаление -3
                    result.set(i, null);
            }
        return result;
    }


    public static ArrayList<Integer> fuzzyEqualsArray(ArrayList<String> from, ArrayList<String> to) {
        //1 2 n 4 5
        //1 2 3 4 5 6
        //result
        //0 1 2 3 4 5
        return null;
    }

    static Double fuzzyEquals(ArrayList<String> from, ArrayList<String> to) {
        ArrayList<Integer> fuzzy =  fuzzyEqualsArray(from, to);
        double equalsCounter = 0;
        for (int i = 0; i < fuzzy.size(); i++) {
            // -1 -2 -3
            if (fuzzy.get(i) == null){
                equalsCounter++;
            }
        }
        return equalsCounter / fuzzy.size();
    }


    public static Map<String, Double> equalsSequences(ArrayList<String> interval, Map<String, ArrayList<String>> arrays) {
        Map<String, Double> result = new HashMap<>();
        for (String arrayID: arrays.keySet()){
            ArrayList<String> array = arrays.get(arrayID);
            result.put(arrayID, fuzzyEquals(interval, array));
        }
        return result;
    }

/*
    static void recursivePermutationPut(JsonObject eventObject, String path) {
    }
*/


    public ArrayList<ArrayList<String>> templatesOfPermutation(ArrayList<String> input) {
        ArrayList<ArrayList<String>> list = new ArrayList<ArrayList<String>>();
        Map<String, Double> permutation = findPermutations(input);
        for (String groupId : permutation.keySet()) {
            if (permutation.get(groupId) != 1.0) { //получаем список похожих кроме себя
                //походу придутся убрать
                ArrayList<String> perGroup = allSortArrays.get(groupId);
                ArrayList<String> temGroup = (ArrayList<String>) perGroup.clone();
                for (int i = 0; i < perGroup.size(); i++)
                    if ((perGroup.size() < i + 1) || (input.size() < i + 1) || !perGroup.get(i).equals(input.get(i)))
                        temGroup.set(i, null);
                list.add(temGroup);
            }
        }
        return list;
    }

    public ArrayList<ArrayList<String>> templatesOfSequences(ArrayList<String> input) {
        ArrayList<ArrayList<String>> list = new ArrayList<ArrayList<String>>();
        Map<String, Double> sequences = findSequences(input);
        for (String groupId : sequences.keySet()) {
            if (sequences.get(groupId) != 1.0) {
                ArrayList<String> seqGroup = allArrays.get(groupId);
                ArrayList<String> temGroup = (ArrayList<String>) seqGroup.clone();
                for (int i = 0; i < temGroup.size(); i++)
                    if (!temGroup.get(i).equals(input.get(i)))
                        temGroup.set(i, null);
                list.add(temGroup);
            }
        }
        return list;
    }


    Map<Integer, String> tacts = new HashMap<>(); //Такты

    //Поиск зависимостей в событиях

    public Object getInterval(long time) {
        return null;
    }

    public Object putInterval(long begin, long end) {
        return null;
    }

    public Object selectEvents(long begin, long end) {
        return null;
    }

    public String lastEvent() {
        return null;
    }


    public String nextEvent(long time) {
        return null;
    }

    public String getEvent(long time) {
        return null;
    }


    public static void main(String[] args) {

        //test of find likes
        Arrays arrays = new Arrays();
        ArrayList<String> data = new ArrayList<String>();
        data.add("1");
        data.add("2");
        data.add("3");
        arrays.put(data);
        data.set(2, "5");
        arrays.put(data);
        System.out.println(arrays.allArrays);
        data.add("4");
        System.out.println("new " + data);
        System.out.println("per" + arrays.findPermutations(data) + "=" + arrays.allArrays.get(arrays.max(arrays.findPermutations(data))));
        System.out.println("seq" + arrays.findSequences(data) + "=" + arrays.allArrays.get(arrays.max(arrays.findSequences(data))));
    }

}
