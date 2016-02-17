package net.metabrain.level2.consolidator;

import java.util.*;

public class Consolidator {

    public Map<String, Arrays> arrays = new HashMap<>();//group ->  arrays
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


    Timer consolidateTimer;
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
