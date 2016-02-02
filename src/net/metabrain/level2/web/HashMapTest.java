package net.metabrain.level2.web;

import com.google.gson.Gson;
import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;
import net.metabrain.level2.storage.FileHashMap;
import net.metabrain.level2.utils.Http;

import java.io.IOException;
import java.io.OutputStream;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class HashMapTest implements HttpHandler {

    FileHashMap events = new FileHashMap("events");

    @Override
    public void handle(HttpExchange httpExchange) throws IOException {
        String query = httpExchange.getRequestURI().getQuery();
        Map<String, String> map = Http.getQueryMap(query);
        int begin = Integer.parseInt(map.get("begin"), 16);
        int end = Integer.parseInt(map.get("end"), 16);
        String response = "";
        if (begin != 0 && end != 0){
            Map<String , String> result = new HashMap<>();
            List<Integer> interval = events.interval(begin, end);
            for (int i = 0; i < interval.size(); i++) {
                int hash = interval.get(i);
                Map<String, String> hashMap = events.get(hash);
                for (String key: hashMap.keySet()){
                    result.put(key, hashMap.get(key));
                }
            }
            response = new Gson().toJson(result);
        }
        httpExchange.sendResponseHeaders(200, response.length());
        OutputStream os = httpExchange.getResponseBody();
        os.write(response.getBytes());
        os.close();
    }
}