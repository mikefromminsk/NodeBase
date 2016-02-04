package net.metabrain.level2.consolidator;

import com.google.gson.JsonObject;
import net.metabrain.level2.controllers.Controllers;

import java.util.*;

public class Consolidator {

    Map<String, Mining> groups = new HashMap<>();
    Mining actions = new Mining();

    void put(String groupName, JsonObject object){
        Mining groupMining = groups.get(groupName);
        //object
        String objectID = groupMining.put();
        actions.putToBuffer(objectID);
    }

    ArrayList<String> likeActions(String actionID){ //to planning

    }

    Timer consolidateTimer;
    public Consolidator() {
        consolidateTimer.schedule(new consolidateTimerTask(), 100);
    }

    class consolidateTimerTask extends TimerTask {

        @Override
        public void run() {
            if ( new Date().getTime() - lastEventTime > 1000){
                String consolidationID = actions.saveBuffer();
            }
        }
    }







    public static Map<String, Mining> permutations = new HashMap<>();
    public static Map<String, Sequences> sequences = new HashMap<>();
    public static Map<String, net.metabrain.level2.planing.Properties> properties = new HashMap<>();



    static ArrayList<String> JsonArrayToStringArray(JsonObject array){
        return new ArrayList<>();
    }


    static void recursivePermutationPut(JsonObject eventObject, String path){

        //for  in (eventObject)
        //recursivePermutationPut(eventObject.get(key), path + "/" + key)
        Mining permutation = permutations.get(path);
        permutation.put(JsonArrayToStringArray(eventObject));

        Sequences sequence = sequences.get(path);
        sequence.put(JsonArrayToStringArray(eventObject));

        // for in eventObject inside params
        {
            net.metabrain.level2.planing.Properties properties = Consolidator.properties.get(path);
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

}
