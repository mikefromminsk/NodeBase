package net.metabrain.level2.consolidator;

import java.util.*;

public class Mining {
    //groupName/groupID
    public Integer groupId = 0;
    public Map<String, ArrayList<String>> allGroups = new HashMap<String, ArrayList<String>>();
    public Map<String, ArrayList<String>> allSortGroups = new HashMap<String, ArrayList<String>>();
    public Map<String, ArrayList<String>> allObjects = new HashMap<String, ArrayList<String>>(); //link objectid to groupid

    public ArrayList<String> groups(List<String> input) {
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

    public Map<String, Double> likePermutations(ArrayList<String> input) {
        ArrayList<String> sortInput = (ArrayList<String>) input.clone();
        java.util.Collections.sort(sortInput);
        ArrayList<String> groups = groups(sortInput);
        Map<String, Double> likes = new HashMap<String, Double>();
        for (int k = 0; k < groups.size(); k++) {
            ArrayList<String> objects = allSortGroups.get(groups.get(k));
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


    public Map<String, Double> likeSequences(ArrayList<String> input) {
        ArrayList<String> groups = groups(input);
        Map<String, Double> likes = new HashMap<String, Double>();
        for (int k = 0; k < groups.size(); k++) {
            ArrayList<String> objects = allGroups.get(groups.get(k));
            double count = 0;
            for (int i = 0; i < objects.size(); i++)
                if (objects.get(i) == null || objects.get(i).equals(input.get(i)))
                    count++;
            likes.put(groups.get(k), count / input.size());
        }
        return likes;
    }

    public String max(Map<String, Double> likes) {
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
        Map<String, Double> permutation = likePermutations(input); //likePermutations включает в себя поиск по likeSequences
        String groupName = max(permutation);
        //update group
        if (groupName == null || permutation.get(groupName) != 1.0) {
            groupName = newGroupName;
            allGroups.put(groupName, (ArrayList<String>) input.clone());
            ArrayList<String> sortInput = (ArrayList<String>) input.clone();
            java.util.Collections.sort(sortInput);
            allSortGroups.put(groupName, sortInput);
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
        String newGroupName = "" + (groupId + 1);
        String group = put(newGroupName, input);
        if (newGroupName.equals(group))
            groupId++;
        return group;
    }


    public ArrayList<ArrayList<String>> templatesOfPermutation(ArrayList<String> input) {
        ArrayList<ArrayList<String>> list = new ArrayList<ArrayList<String>>();
        Map<String, Double> permutation = likePermutations(input);
        for (String groupId : permutation.keySet()) {
            if (permutation.get(groupId) != 1.0) { //получаем список похожих кроме себя
                ArrayList<String> perGroup = allSortGroups.get(groupId);
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
        Map<String, Double> sequences = likeSequences(input);
        for (String groupId : sequences.keySet()) {
            if (sequences.get(groupId) != 1.0) {
                ArrayList<String> seqGroup = allGroups.get(groupId);
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
        String id = put(objectBuffer, timeBuffer);
        objectBuffer.clear();
        return id;
    }


    //end sequences and permutation code

    public String put(ArrayList<String> inputData, ArrayList<Long> dataTime) {
        return null;
    }

    public String put(String groupName, ArrayList<String> inputData, ArrayList<Long> dataTime) {
        return null;
    }


    Map<Integer, String> events = new HashMap<>();
    Map<Integer, String> intervals = new HashMap<>();

    public Object get(long time){
        return null;
    }

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

    public static void main(String[] args) {

        //test of find likes
        Mining mining = new Mining();
        ArrayList<String> data = new ArrayList<String>();
        data.add("1");
        data.add("2");
        data.add("3");
        mining.put(data);
        data.set(2, "5");
        mining.put(data);
        System.out.println(mining.allGroups);
        data.add("4");
        System.out.println("new " + data);
        System.out.println("per" + mining.likePermutations(data) + "=" + mining.allGroups.get(mining.max(mining.likePermutations(data))));
        System.out.println("seq" + mining.likeSequences(data) + "=" + mining.allGroups.get(mining.max(mining.likeSequences(data))));
    }

}
