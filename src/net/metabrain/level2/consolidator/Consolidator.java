package net.metabrain.level2.consolidator;

import com.google.gson.JsonObject;
import net.metabrain.level2.controllers.Controllers;

import java.util.*;

public class Consolidator {

    public static Map<String, Permutation> permutations = new HashMap<>();
    public static Map<String, Sequences> sequences = new HashMap<>();
    public static Map<String, Properties> properties = new HashMap<>();

    public static Map<String, Group> groups = new HashMap<>();


    static ArrayList<String> JsonArrayToStringArray(JsonObject array){
        return new ArrayList<>();
    }


    static void recursivePermutationPut(JsonObject eventObject, String path){

        //for  in (eventObject)
        //recursivePermutationPut(eventObject.get(key), path + "/" + key)
        Permutation permutation = permutations.get(path);
        permutation.put(JsonArrayToStringArray(eventObject));

        Sequences sequence = sequences.get(path);
        sequence.put(JsonArrayToStringArray(eventObject));

        // for in eventObject inside params
        {
            Properties properties = Consolidator.properties.get(path);
            properties.update(eventObject.get("key").getAsString());
        }
    }

    public static Sequences eventConsolidator = new Sequences();
    static ArrayList<String> eventBlock = new ArrayList<>();
    static long lastEventTime = 0;

    public static void event(JsonObject eventObject){
        String group = eventObject.get("group").getAsString();
        recursivePermutationPut(eventObject, group);
        eventBlock.add(sequences.get(group).last());
        Controllers.index(group, eventObject);
        lastEventTime = new Date().getTime();
    }

    Timer consolidateTimer;
    public Consolidator() {
        consolidateTimer.schedule(new consolidateTimerTask(), 100);
    }

    public void getTimeLineLocalTime(int i) {

    }

    class consolidateTimerTask extends TimerTask {

        @Override
        public void run() {
            if ( new Date().getTime() - lastEventTime > 1000){
                eventConsolidator.put(eventBlock);
                eventBlock.clear();
            }
        }
    }

}
