package net.metabrain.level2.planing.properties;

import net.metabrain.level2.consolidator.Consolidator;

import java.util.Map;

public class Correction {

    public static void correction(String activeUnion, String orderUnion, Map<String, String> orderList) {
        Map<String, String> activeUnionGroupsArrays = Consolidator.getInstance().getUnionGroupsArrays(activeUnion);
        Map<String, String> orderUnionGroupsArrays = Consolidator.getInstance().getUnionGroupsArrays(activeUnion);

    }
}
