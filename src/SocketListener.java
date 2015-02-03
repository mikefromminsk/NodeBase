import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.ServerSocket;
import java.net.Socket;

public class SocketListener implements Runnable {

    public void run() {
        try {
            ServerSocket ss = new ServerSocket(8080);
            while (true) {
                Socket s = ss.accept();
                new Thread(new SocketSendResponse(s)).start();
            }
        } catch (Throwable e) {
            System.out.println("8080 port used");
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