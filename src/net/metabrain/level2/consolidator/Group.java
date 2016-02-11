package net.metabrain.level2.consolidator;

import java.util.*;

public class Group {
    //groupName/groupID
    public Integer arrayLastID = 0;
    public Map<String, ArrayList<String>> allArrays = new HashMap<>();
    public Map<String, ArrayList<String>> allSortArrays = new HashMap<>();
    public Map<String, ArrayList<String>> allObjects = new HashMap<>(); //link objectid to groupid
    public Map<Long, String> events = new HashMap<>(); // time -> ArrayID
    public Map<Long, String> intervals = new HashMap<>(); //time -> intervalName




    public Map<String, Integer> allObjectsCounters = new HashMap<>();
    public Map<String, ArrayList<String>> allObjectsCash = new HashMap<>();
    int objectCashSize = 20;
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

    ArrayList<String> objectBuffer = new ArrayList<>();

    void putToArrayBuffer(String object) {
        objectBuffer.add(object);
    }

    String saveArrayBuffer() {
        String arrayID = put(objectBuffer);
        objectBuffer.clear();
        return arrayID;
    }

    long beginInterval = 0;
    long lastEvent = 0;
    ArrayList<String> lastTemplate = null;


    public String put(ArrayList<String> input) {
        long eventTime = new Date().getTime();

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
                object = new ArrayList<String>();
                allObjects.put(objName, object);
            }
            if (object.indexOf(arrayID) == -1)
                object.add(arrayID);
        }

        //save event time
        if (beginInterval == 0)
            beginInterval = eventTime;
        events.put(eventTime, arrayID);


        //template
        if (lastEvent != 0) {
            ArrayList<String> lastArray;
            if (lastTemplate == null) {
                lastArray = getArray(getEvent(lastEvent));
            } else {
                lastArray = lastTemplate;
            }
            ArrayList<String> nowArray = getArray(arrayID);
            lastTemplate = template(lastArray, nowArray);
        }
        lastEvent = eventTime;


        return arrayID;
    }


    void stopInterval(String intervalName) {
        //interval
        Long endInterval = new Date().getTime();
        intervals.put(beginInterval, intervalName);
        intervals.put(endInterval, intervalName);
        beginInterval = 0;


        //template
        lastEvent = 0;
        put(lastTemplate);
        lastEvent = 0;


        lastTemplate = null;
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
        Group group = new Group();
        ArrayList<String> data = new ArrayList<String>();
        data.add("1");
        data.add("2");
        data.add("3");
        group.put(data);
        data.set(2, "5");
        group.put(data);
        System.out.println(group.allArrays);
        data.add("4");
        System.out.println("new " + data);
        System.out.println("per" + group.findPermutations(data) + "=" + group.allArrays.get(group.max(group.findPermutations(data))));
        System.out.println("seq" + group.findSequences(data) + "=" + group.allArrays.get(group.max(group.findSequences(data))));
    }

}
