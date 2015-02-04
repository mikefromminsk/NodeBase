import jdk.nashorn.internal.ir.ReturnNode;

/**
 * Created by IntelliJ IDEA.
 * User: Admin
 * Date: 03.02.15
 * Time: 6:33
 * To change this template use File | Settings | File Templates.
 */
public class LanScaner implements Runnable {

    public void run() {

        while (true) {

            if (!Synchronizer.data.mac.equals("8080"))
            if (Synchronizer.getHostData("http://localhost:8080")) return;
/*            if (!Synchronizer.data.mac.equals("8081"))
            if (Synchronizer.sendHostData("http://localhost:8081")) return;*/
/*
            for (int i = 0; i < 255; i++) {
                for (int j = 0; j < 255; j++) {
                    i = 1;
                    j = 30;
                    if (Synchronizer.sendHostData("http://192.168." + i + "." + j + ":8080"))
                        return;
                }
            }*/

            try {
                Thread.sleep(30000);
            } catch (InterruptedException e) {
            }
        }
    }
}
