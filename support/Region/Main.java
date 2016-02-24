package brain;

import brain.system.Text;

public class Main {

    static Text text = new Text();

    public static void main(String[] args) {

        text.InputInterface("text data");
        text.run();

        System.out.println(text.current.index.toString());
    }
}
