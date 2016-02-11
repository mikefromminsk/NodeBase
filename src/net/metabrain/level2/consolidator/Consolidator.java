package net.metabrain.level2.consolidator;

import com.google.gson.JsonObject;
import net.metabrain.level2.planer.Dependencies;

import java.util.*;

public class Consolidator {

    public Map<String, Group> groups = new HashMap<>();
    public Group unions = new Group();

    static Consolidator consolidator = new Consolidator();
    public static Consolidator getInstance() {
        return consolidator;
    }


    void putEvent(String groupName, JsonObject object) {
        Group groupGroup = groups.get(groupName);
        groupGroup.putToArrayBuffer(object.getAsString());
        lastEventTime = new Date().getTime();
    }

    Timer consolidateTimer;
    private long lastEventTime;

    public Map<ArrayID, ArrayList<String>> getUnionGroupsArrays(String unionID){
        ArrayList<String> unionArray = unions.getArray(unionID);
        Map<ArrayID, ArrayList<String>> unionArrays = new HashMap<>();
        for (int i = 0; i < unionArray.size(); i++) {
            ArrayID arrayID = new ArrayID(unionID);
            Group group = groups.get(arrayID.groupName);
            unionArrays.put(arrayID, group.getArray(arrayID.arrayID));
        }
        return unionArrays;
    }

    class consolidateTimerTask extends TimerTask {

        @Override
        public void run() {
            if (new Date().getTime() - lastEventTime > 1000) {
                for (String groupName : groups.keySet()) {
                    Group group = groups.get(groupName);
                    String arrayID = group.saveArrayBuffer();
                    if (arrayID != null) {
                        unions.putToArrayBuffer(groupName + "," + arrayID);
                    }
                }
                String newUnionID = unions.saveArrayBuffer();
                //Dependencies
                Map<ArrayID, ArrayList<String>> newUnionGroups = getUnionGroupsArrays(newUnionID);
                Dependencies.getInstance().put(newUnionGroups);
                //templates create
                unions.stopInterval(newUnionID);
                for (String groupName : groups.keySet()) {
                    Group group = groups.get(groupName);
                    group.stopInterval(newUnionID);
                    //перенести в group
                }
            }
        }
    }



    public Map<String, Double> findUnions(String unionID) { //to planning
        ArrayList<String> groupsIDAndArrayIDInUnion = unions.getArray(unionID);

        Map<String, ArrayList<String>> groupsDataArrays = new HashMap<>();
        for (int i = 0; i < groupsIDAndArrayIDInUnion.size(); i++) {
            ArrayID arrayID = new ArrayID(groupsIDAndArrayIDInUnion.get(i));
            Group group = groups.get(arrayID.groupName);
            groupsDataArrays.put(arrayID.groupName, group.getArray(arrayID.arrayID));
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




    void template(String unionID){

    }




}
