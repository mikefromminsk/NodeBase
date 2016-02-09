package net.metabrain.level2.consolidator;

import com.google.gson.JsonObject;
import net.metabrain.level2.planing.properties.Analyser;
import net.metabrain.level2.planing.properties.Dependencies;

import java.util.*;

public class Consolidator {


    static Consolidator consolidator = new Consolidator();
    public static Consolidator getInstance() {
        return consolidator;
    }

    Map<String, Group> groups = new HashMap<>();
    Group unions = new Group();

    void putEvent(String groupName, JsonObject object) {
        Group groupGroup = groups.get(groupName);
        groupGroup.putToBuffer(object.getAsString());
        lastEventTime = new Date().getTime();
    }

    Timer consolidateTimer;
    private long lastEventTime;

    public Map<String, String> getUnionGroupsArrays(String unionID){
        return null;
    }

    class consolidateTimerTask extends TimerTask {

        @Override
        public void run() {
            if (new Date().getTime() - lastEventTime > 1000) {
                for (String groupName : groups.keySet()) {
                    Group group = groups.get(groupName);
                    String arrayID = group.saveBuffer();
                    if (arrayID != null) {
                        unions.putToBuffer(groupName + "," + arrayID);
                    }
                }
                String newUnion = unions.saveBuffer();
                Map<String, String> newUnionGroups = getUnionGroupsArrays(newUnion);
                Dependencies.getInstance().put(newUnionGroups);
            }
        }
    }



    public Map<String, Double> findUnions(String unionID) { //to planning
        ArrayList<String> groupsIDAndArrayIDInUnion = unions.getArray(unionID);

        Map<String, ArrayList<String>> groupsDataArrays = new HashMap<>();
        for (int i = 0; i < groupsIDAndArrayIDInUnion.size(); i++) {
            String[] groupIdAndArrayID = groupsIDAndArrayIDInUnion.get(i).split(",");
            String groupName = groupIdAndArrayID[0];
            String arrayID = groupIdAndArrayID[1];
            Group group = groups.get(groupName);
            groupsDataArrays.put(groupName, group.getArray(arrayID));
        }
        return findUnions(groupsDataArrays);
    }

    public Map<String, Double> findUnions(Map<String, ArrayList<String>> groupsDataArrays) { //to planning

        ArrayList<String> findMaxLikeGroups = new ArrayList<>();
        for (String groupName: groupsDataArrays.keySet()){

            Group group = groups.get(groupName);
            ArrayList<String> dataArray = groupsDataArrays.get(groupName);
            //Ищем похожие данные в группах
            Map<String, Double> findPermutation = group.findPermutations(dataArray);
            Map<String, Double> findSequences = group.findSequences(dataArray);
            //объединяем найденные данные по максимальной похожести
            Map<String, Double> findsMerge = new HashMap<>();
            for (String permutationArrayID : findPermutation.keySet()) {
                Double permutationLike = findPermutation.get(permutationArrayID);
                Double sequencesLike = findSequences.get(permutationArrayID);
                findsMerge.put(permutationArrayID, permutationLike + sequencesLike);
            }
            //наверно это не нужно
            for (String sequencesArrayID : findSequences.keySet()) {
                if (findsMerge.get(sequencesArrayID) == null) {
                    findsMerge.put(sequencesArrayID, findSequences.get(sequencesArrayID));
                }
            }
            //ищем в объединенном массиве максимальный и добавляем найденную
            String findArrayID = Group.max(findsMerge);
            findMaxLikeGroups.add(groupName + "," + findArrayID);
        }

        Map<String, Double> findUnions = unions.findPermutations(findMaxLikeGroups);
        return findUnions;
    }








    Analyser analyser = new Analyser();

    Map<String, Map<String, String>> prorerties = new HashMap<>();
    //Map<group,array togroup,array>
    //Map<from,to properties>
    //Map<properties listProperties>




}
