package net.metabrain.level2.controllers;

import com.google.gson.JsonObject;
import net.metabrain.level2.consolidator.Consolidator;
import net.metabrain.level2.planer.Planer;

import java.util.HashMap;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;

public class Controllers {

    static Map<String, Controller> indexators = new HashMap<>(); //генерация
    static Map<String, Summator> summators = new HashMap<>(); //настроение

    Timer updateTimer;
    public Controllers() {
        indexators.put(UsageController.class.getName(), new UsageController());
        summators.put(UsageController.class.getName(), new Summator(100, 0, 0, 0, 50));
        updateTimer.schedule(new UpdateTimerTask(), 100);
    }

    public static void index(String path, JsonObject eventObject) {
        Controller controller = indexators.get(path);
        double index = controller.index(path, eventObject);

        JsonObject json = new JsonObject();
        json.addProperty("groupID", controller.getClass().getName());
        json.addProperty("value", index);
        Consolidator.event(json);

        Summator summator = summators.get(path);
        summator.add(index);
    }

    class UpdateTimerTask extends TimerTask{

        @Override
        public void run() {

            Map<String, String> order = new HashMap<>();
            for (String key: summators.keySet()){
                Summator summator = summators.get(key);
                if (summator.now >= summator.border){
                    order.put(key, "" + (summator.border - summator.now));
                }

            }
            Planer.order(order);
        }
    }
}
