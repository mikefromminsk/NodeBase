package net.metabrain.level2.utils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Sequences {

    public Integer groupId = 0;
    public Map<String, ArrayList<String>> allGroups = new HashMap<String, ArrayList<String>>();
    public Map<String, ArrayList<String>> allObjects = new HashMap<String, ArrayList<String>>();
    public ArrayList<String> buffer = new ArrayList<String>();

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


    public Map<String, Double> sequences(ArrayList<String> input) {
        ArrayList<String> groups = groups(input);
        Map<String, Double> likes = new HashMap<String, Double>();
        for (int k = 0; k < groups.size(); k++) {
            ArrayList<String> objects = allGroups.get(groups.get(k));
            if (input.size() == objects.size()) {
                double count = 0;
                for (int i = 0; i < objects.size(); i++)
                    if (objects.get(i) == null || objects.get(i).equals(input.get(i)))
                        count++;
                likes.put(groups.get(k), count / input.size());
            }
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
        return max(sequences(input));
    }

    public String put(ArrayList<String> input) {
        //update group
        Map<String, Double> likes = sequences(input);
        String group = max(likes);
        if (group == null || likes.get(group) != 1.0) {
            group = String.valueOf(++groupId);
            allGroups.put(group, (ArrayList<String>) input.clone());
        }
        //update allObjects
        for (int i = 0; i < input.size(); i++) {
            String objName = input.get(i);
            ArrayList<String> object = allObjects.get(input.get(i));
            if (object == null) {
                object = new ArrayList<String>();
                allObjects.put(objName, object);
            }
            if (object.indexOf(group) == -1)
                object.add(group);
        }

        ArrayList<ArrayList<String>> list = like(input);
        /*for (int i = 0; i < list.size(); i++)
            allTemplates.put(list.get(i));*/

        return group;
    }


    public ArrayList<ArrayList<String>> like(ArrayList<String> input){
        ArrayList<ArrayList<String>> list = new ArrayList<ArrayList<String>>();
        Map<String, Double> sequences = sequences(input);
        for (String groupId: sequences.keySet()) {
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

    /*
    *
    *         SequencesWithTemplates templates = new SequencesWithTemplates();
        ArrayList<String> data = new ArrayList<String>();
        data.add("1");
        data.add("2");
        data.add("3");
        templates.put(data);
        data.set(2, "5");
        templates.put(data);
        data.set(2, "6");
        data.add("7");
        templates.put(data);
        data.set(3, "6");
        templates.put(data);
        System.out.println(templates.allTemplates.allGroups);
        */

}
