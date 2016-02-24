package templates.utils;

import java.util.ArrayList;
import java.util.Map;

public class PermutationWithTemplates extends Permutation{

    public Permutation allTemplates = new Permutation();

    public ArrayList<ArrayList<String>> templateList(ArrayList<String> input){
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

    @Override
    public String put(ArrayList<String> input) {
        String group = super.put(input);
        ArrayList<ArrayList<String>> list = templateList(input);
        for (int i = 0; i < list.size(); i++)
            allTemplates.put(list.get(i));
        return group;
    }

    public static void main(String[] args) {
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
    }
}
