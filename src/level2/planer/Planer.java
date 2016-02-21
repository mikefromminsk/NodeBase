package level2.planer;

import level2.consolidator.Action;
import level2.consolidator.ArrayID;
import level2.consolidator.Arrays;
import level2.consolidator.Consolidator;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class Planer {

    Consolidator co = Consolidator.getInstance();



    void createPlan(Map<String, ArrayList<String>> orderArrays){

        Map<String, Double> findActions = findActions(orderArrays);
        String findActionID = Arrays.max(findActions);

        Action findAction = new Action(findActionID);
        Action lastAction = new Action(co.actions.getLastInterval());
        Action execAction = new Action();


        setVariables(findAction, lastAction, execAction);
    }

    Map<String, Double> findLikeActions(){
        return null;
    }

    void setVariables(Action findAction, Action lastAction, Action execAction){
        for (String intervalStrID: findAction.intervalArrays.keySet()){
            ArrayID intervalID = new ArrayID(intervalStrID);
            ArrayList<String> intervalArray = findAction.intervalArrays.get(intervalStrID);
            Map<String, Double> equalsSequences = Arrays.equalsSequences(intervalArray, lastAction.intervalArrays);
            String maxEqualsInterval = Arrays.max(equalsSequences);
            ArrayList<String> maxFindInterval = lastAction.intervalArrays.get(maxEqualsInterval);
            ArrayList<Integer> fuzzyArray = Arrays.fuzzyEqualsArray(intervalArray, maxFindInterval);
            ArrayList<String> execIntervalArray = new ArrayList<>();
            for (int i = 0; i < intervalArray.size(); i++) {
                if (intervalArray.get(i) == null) {
                    int positionReplace = fuzzyArray.get(i);
                    execIntervalArray.add(maxFindInterval.get(positionReplace));
                }
            }
            execAction.intervalArrays.put(intervalID.groupName, execIntervalArray);
        }
    }
















    public Map<String, Double> findActions(Map<String, ArrayList<String>> groupsDataArrays) { //to planning

        ArrayList<String> findMaxLikeGroups = new ArrayList<>();
        for (String groupName: groupsDataArrays.keySet()){

            Arrays arrays = co.arrays.get(groupName);
            ArrayList<String> dataArray = groupsDataArrays.get(groupName);
            //Ищем похожие данные в группах
            Map<String, Double> findPermutation = arrays.findPermutations(dataArray);
            Map<String, Double> findSequences = arrays.findSequences(dataArray);
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
            String findArrayID = Arrays.max(findsMerge);
            findMaxLikeGroups.add(groupName + "," + findArrayID);
        }

        Map<String, Double> findUnions = co.actions.eventsGroup.findPermutations(findMaxLikeGroups);
        return findUnions;
    }




}
