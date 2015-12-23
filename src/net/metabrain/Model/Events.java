package net.metabrain.Model;

import net.metabrain.utils.FileHashMap;

public class Events {
    static FileHashMap events = new FileHashMap("events");

    public static void main(String[] args)
    {
        events.put(0x123, "1", "2");
        events.put(0x132, "2", "2sd");
        events.put(0x500, "3", "sdfsdf");
    }
}
