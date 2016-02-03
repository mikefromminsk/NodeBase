package net.metabrain.level2.indexator;

import com.google.gson.JsonObject;
import net.metabrain.level2.consolidator.Consolidator;

import java.util.HashMap;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;

public class Indexator {

    static Map<String, Controller> indexators = new HashMap<>(); //генерация
    static Map<String, Summator> summators = new HashMap<>(); //настроение

    Timer updateTimer;
    public Indexator() {
        indexators.put("processList", new UsageController());
        summators.put("processList", new Summator(100, 0, 0, 0, 50));
        updateTimer.schedule(new UpdateTimerTask(), 100);

    }

    public static void index(String path, JsonObject eventObject) {
        Controller controller = indexators.get(path);
        double index = controller.index(path, eventObject);
        JsonObject json = new JsonObject();
        json.addProperty("groupID", controller.getClass().toString());
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
        }
    }
}
