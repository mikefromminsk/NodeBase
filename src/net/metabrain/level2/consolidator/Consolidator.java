package net.metabrain.level2.consolidator;

import com.google.gson.JsonObject;
import net.metabrain.level2.indexator.Indexator;
import net.metabrain.level2.utils.Sequences;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class Consolidator {

    public static Map<String, Permutation> permutations = new HashMap<>();
    public static Map<String, Sequences> sequences = new HashMap<>();
    public static Map<String, Properties> properties = new HashMap<>();


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

    public static void event(JsonObject eventObject){
        String type = "get";
        String group = eventObject.get("group").getAsString();
        recursivePermutationPut(eventObject, type + "/" + group);

        Indexator.index(eventObject, type + "/" + group);
    }

    void selectPlans(){


    }
}
