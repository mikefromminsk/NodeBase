package net.metabrain;

import com.google.gson.Gson;
import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;
import net.metabrain.utils.FileHashMap;
import net.metabrain.utils.Http;

import java.io.File;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Console {

    static class EventsView implements HttpHandler {

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

    static String readFile(String path, Charset encoding)
            throws IOException
    {
        byte[] encoded = Files.readAllBytes(Paths.get(path));
        return new String(encoded, encoding);
    }

    static class FileDownload implements HttpHandler {

        @Override
        public void handle(HttpExchange httpExchange) throws IOException {
            String path = httpExchange.getRequestURI().getPath();
            String response = readFile("src/net/metabrain" + path, Charset.defaultCharset());
            OutputStream os = httpExchange.getResponseBody();
            httpExchange.sendResponseHeaders(200, response.length());
            os.write(response.getBytes());
            os.close();
        }
    }

    public static void main(String[] args) {
        System.out.println(new File("").getAbsolutePath());
        try {
            Http.serverContent.put("/events", new EventsView());
            Http.serverContent.put("/view", new FileDownload());
            Http.open(8080);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
