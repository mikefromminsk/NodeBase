package net.metabrain.level2.consolidator;

import java.util.*;

public class Group {
    //groupName/groupID
    public Integer arrayID = 0;
    public Map<String, ArrayList<String>> allArrays = new HashMap<String, ArrayList<String>>();
    public Map<String, ArrayList<String>> allSortArrays = new HashMap<String, ArrayList<String>>();
    public Map<String, ArrayList<String>> allObjects = new HashMap<String, ArrayList<String>>(); //link objectid to groupid

    //нечеткий поиск по значениям

    ArrayList<String> getArray(String groupID){
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

    public String put(String newGroupName, ArrayList<String> input) {
        Map<String, Double> permutation = findPermutations(input); //findPermutations включает в себя поиск по findSequences
        String groupName = max(permutation);
        //update group
        if (groupName == null || permutation.get(groupName) != 1.0) {
            groupName = newGroupName;
            allArrays.put(groupName, (ArrayList<String>) input.clone());
            ArrayList<String> sortInput = (ArrayList<String>) input.clone();
            java.util.Collections.sort(sortInput);
            allSortArrays.put(groupName, sortInput);
        }


        //update allObjects
        for (int i = 0; i < input.size(); i++) {
            String objName = input.get(i);
            ArrayList<String> object = allObjects.get(input.get(i));
            if (object == null) {
                object = new ArrayList<String>();
                allObjects.put(objName, object);
            }
            if (object.indexOf(groupName) == -1)
                object.add(groupName);
        }
        return groupName;
    }

    public String put(ArrayList<String> input) {
        String newArrayID = "" + (arrayID + 1);
        String arrayID = put(newArrayID, input);
        if (newArrayID.equals(arrayID))
            this.arrayID++;
        return arrayID;
    }


/*
    static void recursivePermutationPut(JsonObject eventObject, String path) {

        //for  in (eventObject)
        //recursivePermutationPut(eventObject.get(key), path + "/" + key)
        Group permutation = permutations.get(path);
        permutation.put(JsonArrayToStringArray(eventObject));

        Sequences sequence = sequences.get(path);
        sequence.put(JsonArrayToStringArray(eventObject));

        // for in eventObject inside params
        {
            net.metabrain.level2.consolidator.properties properties = Consolidator.properties.get(path);
            properties.update(eventObject.get("key").getAsString());
        }
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


    ArrayList<String> objectBuffer = new ArrayList<>();
    ArrayList<Long> timeBuffer = new ArrayList<>();
    void putToBuffer(String object){
        objectBuffer.add(object);
        timeBuffer.add(new Date().getTime());
    }

    String saveBuffer(){
        String arrayID = put(objectBuffer, timeBuffer);
        objectBuffer.clear();
        return arrayID;
    }


    //end sequences and permutation code

    public String put(ArrayList<String> inputData, ArrayList<Long> dataTime) {
        return put(inputData);
    }

    public String put(String groupName, ArrayList<String> inputData, ArrayList<Long> dataTime) {
        return null;
    }


    Map<Integer, String> events = new HashMap<>(); //События
    Map<Integer, String> intervals = new HashMap<>(); //Интервалы
    Map<Integer, String> tacts = new HashMap<>(); //Такты

    //Поиск зависимостей в событиях

    public Object getInterval(long time){
        return null;
    }
    public Object putInterval(long begin, long end) {
        return null;
    }
    public Object selectEvents(long begin, long end) {
        return null;
    }

    public String lastEvent(){
        return null;
    }

    public String prevEvent(){
        return null;
    }

    public String nextEvent(long time){
        return null;
    }
    public String getEvent(long time){
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
