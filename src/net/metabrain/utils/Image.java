package net.metabrain.utils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class Image {

    public static Double borderValue = 5.0;
    public static Double borderLength = 1.0;
    public static Map<String, Map<String, Double>> space = new HashMap<String, Map<String, Double>>();
    public static Map<String, Double> accumulator = new HashMap<String, Double>();

    public static void setSpace(String from, String to, Double length) {
        Map<String, Double> links = space.get(from);
        if (links == null)
            space.put(from, links = new HashMap<String, Double>());
        links.put(to, length);
        links = space.get(to);
        if (links == null)
            space.put(to, links = new HashMap<String, Double>());
        links.put(from, length);
    }

    public static Map<String, Double> getChanges(Map<String, Double> data){
        for (String key : data.keySet())
            if (data.get(key).equals(accumulator.get(key)))
                data.remove(key);
            else
                accumulator.put(key, data.get(key));
        Map<String, Double> changes = new HashMap<String, Double>();
        changes.putAll(data);
        return changes;
    }

    public static Map<Integer, ArrayList<String>> getRegions(Map<String, Double> changes) {
        Integer regionId = 0;
        Map<String, Integer> regions = new HashMap<String, Integer>();
        for (String from : changes.keySet()) {
            Double fromValue = changes.get(from);
            Map<String, Double> links = space.get(from);
            Map<String, Integer> besideRegions = new HashMap<String, Integer>();
            for (String to : links.keySet()) {
                Double toLength = links.get(to);
                Double toValue = changes.get(to);
                Integer toRegion = regions.get(to);
                if (Math.abs(fromValue - toValue) / toLength < borderValue / borderLength)
                    if (toRegion != null)
                        besideRegions.put(to, toRegion);
            }
            Integer mergeRegion = null;
            for (String to2 : besideRegions.keySet())
                if (besideRegions.get(to2) != null) {
                    mergeRegion = besideRegions.get(to2);
                    break;
                }
            if (mergeRegion == null)
                mergeRegion = ++regionId;
            else
                for (String point : besideRegions.keySet()) {
                    Integer besideRegion = besideRegions.get(point);
                    for (String point2 : regions.keySet())
                        if (regions.get(point2).equals(besideRegion))
                            regions.put(point2, mergeRegion);
                }
            regions.put(from, mergeRegion);


        }
        Map<Integer, ArrayList<String>> result = new HashMap<Integer, ArrayList<String>>();
        for (String key: regions.keySet()){
            Integer region = regions.get(key);
            ArrayList<String> regionPoints = result.get(region);
            if (regionPoints == null)
                result.put(region, regionPoints = new ArrayList<String>());
            regionPoints.add(key);
        }
        return result;
    }

    public static void main(String[] args) {
        for (int i = 0; i < 10; i++) {
            for (int j = 0; j < 10; j++) {
                String from = "" + (i * 10 + j);
                if (i - 1 >= 0)
                    setSpace(from, "" + ((i - 1) * 10 + j), 1.0);
                if (i + 1 < 10)
                    setSpace(from, "" + ((i + 1) * 10 + j), 1.0);
                if (j - 1 >= 0)
                    setSpace(from, "" + (i * 10 + j - 1), 1.0);
                if (j + 1 < 10)
                    setSpace(from, "" + (i * 10 + j + 1), 1.0);
            }
        }
        Map<String, Double> data = new HashMap<String, Double>();
        for (int i = 0; i < 100; i++)
            data.put("" + i, i < 50 ? 5.0 : 10.0);
        Map<String, Double> changes = getChanges(data);
        Map<Integer, ArrayList<String>> regions = getRegions(changes);


        for (int i = 0; i < 10; i++) {
            for (int j = 0; j < 10; j++)
                System.out.print(" " + accumulator.get("" + (i * 10 + j)));
            System.out.println();
        }
        System.out.println();

    }
}
