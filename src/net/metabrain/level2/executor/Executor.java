package net.metabrain.level2.executor;

import com.google.gson.JsonObject;
import net.metabrain.level2.consolidator.Consolidator;
import net.metabrain.level2.utils.Http;

import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;

public class Executor {

    static Map<String, String> groupAddress = new HashMap<>();
    static Map<String, JsonObject> groupApi = new HashMap<>();

    public static void regystry(InputStream requestBody) {
        //Json Parse
        JsonObject json = new JsonObject();
        groupAddress.put(json.get("groupID").getAsString(), json.get("address").getAsString());
        groupApi.put(json.get("groupID").getAsString(), json.get("api").getAsJsonObject());
    }

    boolean EqualsTypes(String groupID, JsonObject Params){
        return true;
    }

    void exec(String groupID, JsonObject Params){
        if (EqualsTypes(groupID, Params)){
            JsonObject response = new JsonObject();
            /*to response*/Http.Get(groupAddress.get(groupID));
            Consolidator.event(response);
        }
    }



}
