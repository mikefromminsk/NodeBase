package templates.utils;

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
        return group;
    }
}
