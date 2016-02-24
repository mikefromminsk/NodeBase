package utils;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpServer;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Http {

    public static Map<String, HttpHandler> serverContent = new HashMap<>();

    static ArrayList<File> searchFiles(File topDirectory) {
        ArrayList<File> result = new ArrayList<>();
        search(topDirectory, result);
        return result;
    }

    private static void search(File topDirectory, ArrayList<File> res) {
        File[] list = topDirectory.listFiles();
        for (int i = 0; i < list.length; i++) {
            if (list[i].isDirectory())
                search(list[i], res);
            else if (list[i].getName().indexOf(".java") != -1)
                res.add(list[i]);
        }
    }

    static String packageName(File file) {
        File srcRoot = new File("src");
        String packageName = file.getName().substring(0, file.getName().indexOf('.'));
        File dir = file.getParentFile();
        while (true) {
            packageName = dir.getName() + "." + packageName;
            if (dir.getParentFile().getAbsolutePath().equals(srcRoot.getAbsolutePath()))
                break;
            dir = dir.getParentFile();
        }
        return packageName;
    }

    public static void findHttpHandlers() {
        ArrayList<File> searchFiles = searchFiles(new File("src"));
        for (int i = 0; i < searchFiles.size(); i++) {
            File file = searchFiles.get(i);
            String packageName = packageName(file);
            try {
                Class c = Class.forName(packageName);
                Class[] interfaces = c.getInterfaces();
                for(Class cInterface : interfaces) {
                    if (cInterface.getName().equals("com.sun.net.httpserver.HttpHandler")){

                        try {
                            Object obj = c.newInstance();
                            HttpHandler handler = (HttpHandler) obj;
                            String path = "/" + c.getName().replace('.', '/');
                            serverContent.put(path, handler);
                        } catch (InstantiationException e) {
                            e.printStackTrace();
                        } catch (IllegalAccessException e) {
                            e.printStackTrace();
                        }
                    }
                }
            } catch (ClassNotFoundException e) {
                e.printStackTrace();
            }
        }
    }

    public static Map<String, String> getQueryMap(String query) {
        Map<String, String> map = new HashMap<>();
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

    public static Map<String, String> Params(HttpExchange httpExchange) {
        return getQueryMap(httpExchange.getRequestURI().getQuery());
    }

    static HttpServer server;

    public static void open(int port) throws IOException {
        server = HttpServer.create(new InetSocketAddress(port), 0);
        for (String key : serverContent.keySet())
            server.createContext(key, serverContent.get(key));
        server.setExecutor(null);
        server.start();
        System.out.println("Open HTTP port " + port);
    }

    List<Socket> SocketList;

    public Socket Close(int port) {
        return null;
    }

    public static void Post(String url, String body) {
        try {
            URL obj = new URL(url);
            HttpURLConnection conn = (HttpURLConnection) obj.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("User-Agent", "Mozilla/5.0");
            conn.setReadTimeout(10000);
            conn.setConnectTimeout(15000);
            conn.setDoInput(true);
            conn.setDoOutput(true);

            OutputStream os = conn.getOutputStream();
            BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(os, "UTF-8"));
            writer.write(body);
            writer.flush();
            writer.close();
            os.close();

            conn.connect();
        } catch (Exception e) {
            e.printStackTrace();
        }
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
            InputStream inputStream = GetStream(url);
            BufferedReader in = new BufferedReader(new InputStreamReader(inputStream));
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
        Response(httpExchange, response.getBytes());
    }

    public static void Response(HttpExchange httpExchange, byte[] response) throws IOException {
        OutputStream os = httpExchange.getResponseBody();
        httpExchange.sendResponseHeaders(200, response.length);
        os.write(response);
        os.close();
    }

    public static String Body(HttpExchange httpExchange) {
        java.util.Scanner s = new java.util.Scanner(httpExchange.getRequestBody()).useDelimiter("\\A");
        return s.hasNext() ? s.next() : "";
    }
}
