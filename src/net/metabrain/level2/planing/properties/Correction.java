package net.metabrain.level2.planing.properties;

import net.metabrain.level2.consolidator.Consolidator;
import net.metabrain.level2.consolidator.GroupID;

import java.util.ArrayList;
import java.util.Map;

public class Correction {

    public static void correction(String activeUnionID, String orderUnionID, Map<String, String> orderList) {
        Map<GroupID, ArrayList<String>> activeUnion = Consolidator.getInstance().getUnionGroupsArrays(activeUnionID);
        Map<GroupID, ArrayList<String>> orderUnion = Consolidator.getInstance().getUnionGroupsArrays(orderUnionID);



    }
}
