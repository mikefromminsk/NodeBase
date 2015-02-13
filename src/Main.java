import sync.Sync;

public class Main {
    public static void main(String[] args) {
        new Thread(new Sync()).start();
    }
}
