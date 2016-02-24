package app.VK;

import com.google.gson.Gson;
import level2.consolidator.EventData;
import level2.consolidator.InputConsolidator;
import utils.Http;

import java.io.IOException;
import java.util.*;

public class Main {

    static VkApi vkApi;

    private static Timer mTimer;
    private static MyTimerTask mMyTimerTask;

    static class MyTimerTask extends TimerTask {

        @Override
        public void run() {
        }
    }

    public Main() throws IOException {
        vkApi = new VkApi("4941994", "820cf71db53f1ca411439e21fd6c26e31b11eea1c44d73e8e3980e21d4c0ca76f39152b61829c8e897a21");
        /*mMyTimerTask = new MyTimerTask();
        mTimer.schedule(mMyTimerTask, 1000);*/
        Wall wall = (Wall)vkApi.invoke("wall.get", VkApi.Params.create().add("filter", "owner").add("count", "100"), Wall.class);

        List<EventData> events = new ArrayList<>();
        for (int i = 0; i < wall.response.items.size(); i++) {
            Wall.Item item = wall.response.items.get(i);
            List<String> data = new ArrayList<>();
            data.add(String.valueOf(item.id));
            Map<String, String> controls = new HashMap<>();
            controls.put("likes", String.valueOf(item.likes.count));
            events.add(new EventData("wall", data));
        }
        InputConsolidator inputConsolidator = new InputConsolidator(events);
        Http.Post("localhost:8080\\level2.consolidator", new Gson().toJson(inputConsolidator).toString());
    }

    public static void main(String[] args) throws IOException {
        Main main = new Main();
    }
}
