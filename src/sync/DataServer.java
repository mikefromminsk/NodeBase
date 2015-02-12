package sync;


import java.io.*;
import java.net.ServerSocket;
import java.net.Socket;

public class DataServer implements Runnable {

    public void run() {
        int port = 8080;
        while (true) {
            try {
                ServerSocket ss = new ServerSocket(port);
                Sync.log.info("ssds open " + port + " port");
                Sync.data.port = "" + port;
                Sync.data.mac = "" + port;
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
                readInputHeaders();
                writeResponse(Sync.hostDataToString(Sync.data));
            } catch (Throwable t) {
            } finally {
                try {
                    s.close();
                } catch (Throwable t) {
                }
            }
        }

        private void writeResponse(String s) throws Throwable {
            String response = "HTTP/1.1 200 OK\r\n" +
                    "Server: YarServer/2009-09-09\r\n" +
                    "Content-Type: text/html\r\n" +
                    "Content-Length: " + s.length() + "\r\n" +
                    "Connection: close\r\n\r\n";
            String result = response + s;
            os.write(result.getBytes());
            os.flush();
        }

        private void readInputHeaders() throws Throwable {
            BufferedReader br = new BufferedReader(new InputStreamReader(is));
            while(true) {
                String s = br.readLine();
                if(s == null || s.trim().length() == 0) {
                    break;
                }
            }
        }


    }
}