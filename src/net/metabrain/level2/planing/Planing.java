package net.metabrain.level2.planing;

import net.metabrain.level2.Main;
import net.metabrain.level2.consolidator.Consolidator;
import net.metabrain.level2.consolidator.TimeLine;
import net.metabrain.level2.executor.Executor;

import java.util.Map;

public class Planing {

    TimeLine newConsolidators = new TimeLine();

    public static void order(Map<String, String> ord){

        for (String controllerName: ord.keySet()){
            String controllerValue = ord.get(controllerName);
            //select permutations
            //select sequences

        }


        //choose sequences or pemutation
        //get time seequences or permutation from timeline
        long timeOfPermutationOrSequences = 1;
        //select from consolidator timeline consolidator
        Consolidator consolidator = (Consolidator) Main.consolidatorTimeLine.getBlockByTime(timeOfPermutationOrSequences);

        //Где то тут идёт анализ зависимостей данных и их корректировка
        //И создание новых консолидаторов потом они передаюся на выполнение
        Executor.addExecConsolidator(consolidator);
    }
}
