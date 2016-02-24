package level2.consolidator;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;
import utils.Http;

import java.io.IOException;
import java.util.*;

public class Consolidator implements HttpHandler{

    public Map<String, Arrays> arrays = new HashMap<>();//group ->  arrays
    //arrays group как многоканальный звук
    public Map<String, Intervals> intervals = new HashMap<>(); //group ->  intervals
    public Intervals actions = new Intervals(); //arrayID -> ArrayList<groupID:IntervalID>


    public static Consolidator consolidator = new Consolidator();
    public static Consolidator getInstance() {
        return consolidator;
    }


    void put(String groupName, ArrayList<String> arrayData) {
        Arrays arrays = this.arrays.get(groupName);
        String arrayID = arrays.put(arrayData);
        actions.put(new ArrayID(groupName, arrayID).toString());
    }

    void put(JsonObject query) {
        String groupName= query.get("groupName").getAsString();
        Arrays arrays = this.arrays.get(groupName);
        String arrayID = arrays.put(query);
        actions.put(new ArrayID(groupName, arrayID).toString());
    }


    Timer consolidateTimer;

    @Override
    public void handle(HttpExchange httpExchange) throws IOException {
        InputConsolidator inputConsolidator = new Gson().fromJson(Http.Body(httpExchange), InputConsolidator.class);
        inputConsolidator

    }

    class consolidateTimerTask extends TimerTask {

        @Override
        public void run() {

            for (String groupName : arrays.keySet()) {
                Intervals intervals = Consolidator.this.intervals.get(groupName);
                String intervalID = intervals.stopInterval(100);
                if (intervalID != null){
                    actions.put(intervalID);
                }
            }

            String unionIntervalID = actions.stopInterval(1000);
            if (unionIntervalID != null) {

                //Dependencies
//                Map<ArrayID, ArrayList<String>> newUnionGroups = getUnionGroupsArrays(newUnionID);
//                Dependencies.getInstance().put(newUnionGroups);
            }
        }
    }











}
