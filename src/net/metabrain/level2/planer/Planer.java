package net.metabrain.level2.planer;

import net.metabrain.level2.consolidator.ArrayID;
import net.metabrain.level2.consolidator.Consolidator;
import net.metabrain.level2.consolidator.Group;
import net.metabrain.level2.executor.Executor;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class Planer {

    Group plans = new Group();
    //то чего не произошло
    Map<String, Group> groups = new HashMap<>();
    Group unions = new Group();



    public static Map<ArrayID, ArrayList<String>> newUnion(String activeUnionID, String findUnionID) {

        Map<ArrayID, ArrayList<String>> activeUnion = Consolidator.getInstance().getUnionGroupsArrays(activeUnionID);
        Map<ArrayID, ArrayList<String>> findUnion = Consolidator.getInstance().getUnionGroupsArrays(findUnionID);
        Map<String, ArrayList<String>> findTemplate;
        Map<String, ArrayList<String>> newUnion;

        //find to template
        //equals unions
        //replare ==
        //depen correct in replace
        return null;
    }

    void correction(String activeUnion, String orderUnion){

    }

    void order(Map<String, String> orderList){
        //convert Map<String, String> to Map<String, Array<String>> for Consolidator.findUnions
        Map<String, ArrayList<String>> convertOrderList = new HashMap<>();
        for (String key: orderList.keySet()){
            ArrayList<String> list = new ArrayList();
            list.add(orderList.get(key));
            convertOrderList.put(key, list);
        }

        Consolidator consolidator = Consolidator.getInstance();
        Map<String, Double> findUnions = consolidator.findUnions(convertOrderList);

        //dependencies должен работать в консолидаторе
        String findUnion = Group.max(findUnions);
        ArrayList<String> findGroups = consolidator.unions.getArray(findUnion);
        String activeUnion = "";//Consolidator.getInstance().getActiveUnion();
        /*newUnion(activeUnion*//*Что сейчас происходит*//*,
                findUnion*//*что хотим что бы произошло*//*,
                orderList*//*сила желания хотения*//*);*/






        //choose findSequences or pemutation
        //get time seequences or findPermutations from timeline
        long timeOfPermutationOrSequences = 1;
        //select from consolidator timeline consolidator

        //Где то тут идёт анализ зависимостей данных и их корректировка
        //И создание новых консолидаторов потом они передаюся на выполнение
        Executor.addExecConsolidator(consolidator);
    }
}
