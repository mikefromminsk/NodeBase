package net.metabrain.level2.planing.properties;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class Dependencies {


    Map<String, Double> prevValueIds = new HashMap<>();
    Map<String, Double> valueIds = new HashMap<>();
    Map<Double, ArrayList<String>> valueValues = new HashMap<>();
    Map<String, Double> subIds = new HashMap<>();
    Map<Double, ArrayList<String>> subValues = new HashMap<>();
    Map<String, Double> prevSubIds = new HashMap<>();
    Map<Double, ArrayList<String>> prevSubValues = new HashMap<>();
    Map<String, Double> speedSubIds = new HashMap<>();
    Map<Double, ArrayList<String>> speedValues = new HashMap<>();
    //add replase and concat  dependencies
    Map<String, Double> dependenciesIds = new HashMap<>();
    Map<Double, ArrayList<String>> dependenciesValues = new HashMap<>();

    Map<String, Integer> dependenciesCounters = new HashMap<>();

    public static Dependencies dependencies;

    public static Dependencies getInstance() {
        if (dependencies == null)
            dependencies = new Dependencies();
        return dependencies;
    }

    String sortAndMergeIds(ArrayList<String> ids) {
        String result = "";
        java.util.Collections.sort(ids);
        for (int i = 0; i < ids.size(); i++) {
            result += ids.get(i) + ",";
        }
        return result;
    }

    void toDependencies(String id, Double value) {
        ArrayList<String> dependenciesArray = dependenciesValues.get(value);
        if (dependenciesArray == null)
            dependenciesValues.put(value, dependenciesArray = new ArrayList<String>());
        dependenciesArray.add(id);
        dependenciesIds.put(id, value);
    }

    void findProperty(String id, Double value) {

        //id -> value
        valueIds.put(id, value);

        //value -> array id
        ArrayList<String> valueArr = valueValues.get(value);
        if (valueArr == null)
            valueValues.put(value, valueArr = new ArrayList<String>());
        valueArr.add(id);


        Double prevValue = prevValueIds.get(id);
        Double thisSub = value - prevValue;
        ArrayList<String> subArray = subValues.get(thisSub);
        if (subArray == null)
            subValues.put(thisSub, subArray = new ArrayList<String>());
        subArray.add(id);
        subIds.put(id, thisSub);

        Double prevSub = prevSubIds.get(id);
        Double speedSub = thisSub - prevSub;
        ArrayList<String> speedArray = speedValues.get(speedSub);
        if (speedArray == null)
            speedValues.put(speedSub, speedArray = new ArrayList<String>());
        speedArray.add(id);
        speedSubIds.put(id, speedSub);


        for (Double val : valueValues.keySet()) {
            String valueId = "value-" + sortAndMergeIds(valueValues.get(val));
            toDependencies(valueId, val);
        }
        for (Double sub : subValues.keySet()) {
            String subId = "sub-" + sortAndMergeIds(subValues.get(sub));
            toDependencies(subId, sub);
        }

        for (Double speed : speedValues.keySet()) {
            String speedId = "speed-" + sortAndMergeIds(speedValues.get(speed));
            toDependencies(speedId, speed);
        }

        for (Double dependenciesValue : dependenciesValues.keySet()) {
            ArrayList<String> ids = dependenciesValues.get(dependenciesValue);
            String dependenciesID = sortAndMergeIds(ids);
            Integer counter = dependenciesCounters.get(dependenciesID);
            if (counter == null)
                counter = 0;
            dependenciesCounters.put(dependenciesID, counter + 1);
        }


    }

    public void put(Map<String, String> groupsData) { // from groupNameArrayID -> arrayData
        for (String dataID : groupsData.keySet()) {
            findProperty(dataID, Double.valueOf(groupsData.get(dataID)));
        }
        prevValueIds = valueIds;
        prevSubValues = subValues;
        prevSubIds = subIds;
    }

    public static void main(String[] args) {

    }


}
