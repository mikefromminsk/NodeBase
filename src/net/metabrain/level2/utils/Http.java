package net.metabrain.level2.utils;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpServer;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.net.URL;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Http {


    public static Map<String, HttpHandler> serverContent = new HashMap<>();


    public static Map<String, String> getQueryMap(String query)
    {
        Map<String, String> map = new HashMap<String, String>();
        if (query != null) {
            String[] params = query.split("&");
            for (String param : params) {
                String name = param.split("=")[0];
                String value = param.split("=")[1];
                map.put(name, value);
            }
        }
        return map;
    }

    public static Map<String, String> Params(HttpExchange httpExchange)
    {
        return getQueryMap(httpExchange.getRequestURI().getQuery());
    }

    static HttpServer server;
    public static void open(int port) throws IOException {
        server = HttpServer.create(new InetSocketAddress(port), 0);
        for (String key: serverContent.keySet())
            server.createContext(key, serverContent.get(key));
        server.setExecutor(null);
        server.start();
        System.out.println("Open HTTP port " + port);
    }

    List<Socket> SocketList;

    public Socket Close(int port){
        return null;
    }


    public static InputStream GetStream(String url) {
        try {
            URL obj = new URL(url);
            HttpURLConnection con = (HttpURLConnection) obj.openConnection();
            con.setRequestMethod("GET");
            con.setRequestProperty("User-Agent", "Mozilla/5.0");
            return con.getInputStream();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }


    public static String Get(String url) {
        try {
            BufferedReader in = new BufferedReader(new InputStreamReader(GetStream(url)));
            String inputLine;
            StringBuffer response = new StringBuffer();
            while ((inputLine = in.readLine()) != null)
                response.append(inputLine);
            in.close();
            return response.toString();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public static void Response(HttpExchange httpExchange, String response) throws IOException {
        OutputStream os = httpExchange.getResponseBody();
        httpExchange.sendResponseHeaders(200, response.length());
        os.write(response.getBytes());
        os.close();
    }
}
