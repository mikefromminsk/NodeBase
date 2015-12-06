package net.metabrain.utils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Permutation {

    public Integer groupId = 0;
    public Map<String, ArrayList<String>> allGroups = new HashMap<String, ArrayList<String>>();
    public Map<String, ArrayList<String>> allSortGroups = new HashMap<String, ArrayList<String>>();
    public Map<String, ArrayList<String>> allObjects = new HashMap<String, ArrayList<String>>();

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

    public Map<String, Double> permutation(ArrayList<String> input) {
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

    public String max(Map<String, Double> likes) {
        double max = 0;
        String result = null;
        for (String groupId: likes.keySet()){
            if (likes.get(groupId) > max){
                result = groupId;
                max = likes.get(groupId);
            }
        }
        return result;
    }

    public String get(ArrayList<String> input){
        return max(permutation(input));
    }

    public  String put(String newGroupName, ArrayList<String> input) {
        Map<String, Double> permutation = permutation(input);
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

    public  String put(ArrayList<String> input) {
        String newGroupName = "" + groupId + 1;
        String group = put(newGroupName, input);
        if (newGroupName.equals(group))
            groupId++;
        ArrayList<ArrayList<String>> list = like(input);
        /*for (int i = 0; i < list.size(); i++)
            allTemplates.put(list.get(i));*/
        return group;
    }

    public ArrayList<ArrayList<String>> like(ArrayList<String> input){
        ArrayList<ArrayList<String>> list = new ArrayList<ArrayList<String>>();
        Map<String, Double> permutation = permutation(input);
        for (String groupId: permutation.keySet()) {
            if (permutation.get(groupId) != 1.0) {
                ArrayList<String> perGroup = allSortGroups.get(groupId);
                ArrayList<String> temGroup = new ArrayList<String>();
                for (int i = 0; i < perGroup.size(); i++)
                    if ((perGroup.size() < i+1)|| (input.size() < i+1) || !perGroup.get(i).equals(input.get(i)))
                        temGroup.set(i, null);
                list.add(temGroup);
            }
        }
        return list;
    }

    /*public void main(String[] args) {
        AssociativeArray analysing = new AssociativeArray();
        ArrayList<String> data = new ArrayList<String>();
        data.add("1");
        data.add("2");
        data.add("3");
        analysing.put(data);
        data.set(2, "5");
        analysing.put(data);
        System.out.println(analysing.allGroups);
        data.add("4");
        System.out.println("new " + data);
        System.out.println("per" + analysing.permutation(data) + "=" + analysing.allGroups.get(analysing.max(analysing.permutation(data))));
        System.out.println("seq" + analysing.sequences(data) + "=" + analysing.allGroups.get(analysing.max(analysing.sequences(data))));

        data.add(0, "5");


                PermutationWithTemplates templates = new PermutationWithTemplates();
        ArrayList<String> data = new ArrayList<String>();
        data.add("1");
        data.add("2");
        data.add("3");
        templates.put(data);
        data.add("5");
        templates.put(data);
        data.set(2, "6");
        data.add("7");
        templates.put(data);
        data.set(3, "6");
        templates.put(data);
        System.out.println(templates.allTemplates.allGroups);
    }*/
}
