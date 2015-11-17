import java.io.*;
import java.net.ServerSocket;
import java.net.Socket;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Scanner;

public class HttpServer implements Runnable {

    static String modulesDir = null;

    HttpServer(String modulesDir) {
        this.modulesDir = modulesDir;
    }

    @Override
    public void run() {
        try {
            ServerSocket ss = new ServerSocket(8080);
            while (true) {
                Socket s = ss.accept();
                new Thread(new SocketProcessor(s)).start();
            }
        } catch (Exception e) {
            e.printStackTrace();
        } catch (Throwable throwable) {
            throwable.printStackTrace();
        }
    }

    private static class SocketProcessor implements Runnable {

        private Socket s;
        private String headers;
        private InputStream is;
        private OutputStream os;

        private SocketProcessor(Socket s) throws Throwable {
            this.s = s;
            this.is = s.getInputStream();
            this.os = s.getOutputStream();
        }


        public void run() {

            String response = "";
            HttpParser httpParser = new HttpParser(is);
            try {
                httpParser.parseRequest();
                byte[] body = null;
                String url = httpParser.getRequestURL();
                if (url.equals("/")) {
                    File myFolder = new File(modulesDir);
                    File[] files = myFolder.listFiles();
                    for (int i = 0; i < files.length; i++) {
                        File file = files[i];
                        response += file.getAbsolutePath() + "\n";
                        body = response.getBytes();
                    }
                } else {
                    body = Files.readAllBytes(Paths.get(url.substring(1)));
                }
                writeResponse(body);
                System.err.println("GET " + url);

            } catch (Throwable throwable) {
                throwable.printStackTrace();
            }
        }

        private void writeResponse(byte[] body) throws Throwable {
            String response = "HTTP/1.1 200 OK\r\n" +
                    "Server: YarServer/2009-09-09\r\n" +
                    "Content-Type: application/octet-stream\r\n" +
                    "Content-Length: " + body.length + "\r\n" +
                    "Connection: close\r\n\r\n";
            String result = response;
            os.write(result.getBytes());
            os.write(body);
            os.flush();
        }
    }
}