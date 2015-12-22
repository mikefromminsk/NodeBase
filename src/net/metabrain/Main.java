package net.metabrain;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;
import net.metabrain.utils.Http;

import java.io.IOException;
import java.io.OutputStream;
import java.util.Map;

public class Main implements HttpHandler {


    @Override
    public void handle(HttpExchange httpExchange) throws IOException {
        Map<String, String> map = Http.getQueryMap(httpExchange.getRequestURI().getQuery());
        String response = map.get("ss");
        httpExchange.sendResponseHeaders(200, response.length());
        OutputStream os = httpExchange.getResponseBody();
        os.write(response.getBytes());
        os.close();
    }


    static Main main;
    static Main getInstance(){
        if (main == null)
            main = new Main();
        return main;
    }

    public static void main(String[] args) {
        try {
            Http.serverContent.put("/hello", getInstance());
            Http.open(8082);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
