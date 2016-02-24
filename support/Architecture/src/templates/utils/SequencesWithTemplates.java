package templates.utils;

import java.util.ArrayList;
import java.util.Map;

public class SequencesWithTemplates extends Sequences {

    public Sequences allTemplates = new Sequences();

    public ArrayList<ArrayList<String>> templateList(ArrayList<String> input){
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

    @Override
    public String put(ArrayList<String> input) {
        String group = super.put(input);
        ArrayList<ArrayList<String>> list = templateList(input);
        for (int i = 0; i < list.size(); i++)
            allTemplates.put(list.get(i));
        return group;
    }
/*
    public static void main(String[] args){
        SequencesWithTemplates templates = new SequencesWithTemplates();
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
        System.out.println(templates.allTemplates.allArrays);
    }*/
}
