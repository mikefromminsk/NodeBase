import jdk.nashorn.internal.ir.Block;

import java.io.*;
import java.net.ServerSocket;
import java.net.Socket;

public class HttpServer implements Runnable {

    public void run() {
        int port = 8080;
        while (true) {
            try {
                ServerSocket ss = new ServerSocket(port);
                System.out.println("open " + port + " port");
                Synchronizer.data.mac = "" + port;
                while (true) {
                    Socket s = ss.accept();
                    new Thread(new SocketSendResponse(s)).start();
                }
            } catch (Throwable e) {
                port++;
            }
        }
    }


    static class SocketSendResponse implements Runnable {

        private Socket s;
        private InputStream is;
        private OutputStream os;

        private SocketSendResponse(Socket s) throws Throwable {
            this.s = s;
            this.is = s.getInputStream();
            this.os = s.getOutputStream();
        }

        public void run() {
            try {
                //Synchronizer.HostData hostData = new Synchronizer.HostData();
                //System.out.println( s.getRemoteSocketAddress().toString());

                String s = Synchronizer.hostDataToString(Synchronizer.data);
                String response = "HTTP/1.1 200 OK\r\n" +
                        "Server: YarServer/2009-09-09\r\n" +
                        "Content-Type: text/html\r\n" +
                        "Content-Length: " + s.length() + "\r\n" +
                        "Connection: close\r\n\r\n"
                        + s;
                os.write(response.getBytes());
                os.flush();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }


    }
}