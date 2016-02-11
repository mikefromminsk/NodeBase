package net.metabrain.level2.consolidator;

import net.metabrain.level2.planer.Dependencies;

import java.util.*;

public class Consolidator {

    public Map<String, Group> groups = new HashMap<>();
    public Map<String, Interval> intervals = new HashMap<>();
    public Interval unions = new Interval();


    static Consolidator consolidator = new Consolidator();
    public static Consolidator getInstance() {
        return consolidator;
    }


    void put(String groupName, ArrayList<String> arrayData) {
        Group group = groups.get(groupName);
        group.put(arrayData);
    }

    Timer consolidateTimer;

    public Map<ArrayID, ArrayList<String>> getUnionGroupsArrays(String unionID){
        /*ArrayList<String> unionArray = unions.getArray(unionID);
        Map<ArrayID, ArrayList<String>> unionArrays = new HashMap<>();
        for (int i = 0; i < unionArray.size(); i++) {
            ArrayID arrayID = new ArrayID(unionID);
            Group group = groups.get(arrayID.groupName);
            unionArrays.put(arrayID, group.getArray(arrayID.arrayID));
        }
        return unionArrays;*/
    }

    class consolidateTimerTask extends TimerTask {

        @Override
        public void run() {

            for (String groupName : groups.keySet()) {
                Interval interval = intervals.get(groupName);
                String intervalID = interval.stopInterval(100);
                if (intervalID != null){
                    unions.put(intervalID);
                }
            }

            String unionIntervalID = unions.stopInterval(1000);
            if (unionIntervalID != null) {

                //Dependencies
                Map<ArrayID, ArrayList<String>> newUnionGroups = getUnionGroupsArrays(newUnionID);
                Dependencies.getInstance().put(newUnionGroups);
                //templates create
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
