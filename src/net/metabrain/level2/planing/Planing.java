package net.metabrain.level2.planing;

import net.metabrain.level2.Main;
import net.metabrain.level2.consolidator.Consolidator;
import net.metabrain.level2.consolidator.Group;
import net.metabrain.level2.executor.Executor;
import net.metabrain.level2.planing.properties.Analyser;
import net.metabrain.level2.planing.properties.Correction;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class Planing {

    Group plans = new Group();
    Group templates = new Group();
    Analyser properties = new Analyser();


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

        Map<String, Double> findUnions = Consolidator.getInstance().findUnions(convertOrderList);

        //dependencies должен работать в консолидаторе
        String findUnion = Group.max(findUnions);
        String activeUnion = "";//Consolidator.getInstance().getActiveUnion();
        Correction.correction(activeUnion/*Что сейчас происходит*/, findUnion/*что хотим что бы произошло*/, orderList/*сила желания хотения*/);






        //choose findSequences or pemutation
        //get time seequences or findPermutations from timeline
        long timeOfPermutationOrSequences = 1;
        //select from consolidator timeline consolidator
        Consolidator consolidator = (Consolidator) Main.consolidatorTimeLine.getBlockByTime(timeOfPermutationOrSequences);

        //Где то тут идёт анализ зависимостей данных и их корректировка
        //И создание новых консолидаторов потом они передаюся на выполнение
        Executor.addExecConsolidator(consolidator);
    }
}
