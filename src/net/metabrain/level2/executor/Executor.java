package net.metabrain.level2.executor;

import com.google.gson.JsonObject;
import net.metabrain.level2.Main;
import net.metabrain.level2.consolidator.Consolidator;
import net.metabrain.level2.utils.Http;

import java.io.InputStream;
import java.util.*;

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


    static Consolidator execConsolidator;
    static long beginStart;
    public static void addExecConsolidator(Consolidator consolidator){
        execConsolidator = consolidator;
        beginStart = new Date().getTime();
    }


    Timer execTimer;
    class execTimerTask extends TimerTask {

        @Override
        public void run() {
            Consolidator lastConsolidator = (Consolidator) Main.consolidatorTimeLine.lastObject();
            execConsolidator.getTimeLineLocalTime(100);
            //Провести сравнение консолидаторов по времени и по последовательсноти и по пермутейшенам
            //equals time block
            //оценка выполненыз работ и награда за соответсвие предыдущему разу
            //эту оценку нужно учитывать в планировании
        }
    }

    public Executor() {
        execTimer.schedule(new execTimerTask(), 100);
    }


}
