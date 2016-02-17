package net.metabrain.level2;

import net.metabrain.level2.consolidator.Consolidator;
import net.metabrain.level2.web.HttpHandlerController;

public class StartClass {

    public static void main(String[] args) {
        for (int i = 0; i <10; i++) {
            Consolidator.getInstance().actions.eventsGroup.arrayCountersCash.put("actionID" + i, Double.valueOf(i));
        }
        HttpHandlerController httpHandlerController = new HttpHandlerController();

    }
}
