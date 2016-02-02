package net.metabrain.level2.web;

import net.metabrain.level2.utils.Http;

import java.io.File;
import java.io.IOException;

public class Controller {


    public static void main(String[] args) {
        System.out.println(new File("").getAbsolutePath());
        try {
            Http.serverContent.put("/help", new RegistryApi());
            Http.serverContent.put("/registryapi", new RegistryApi());
            Http.serverContent.put("/event", new Event());
            Http.serverContent.put("/hashmaptest", new HashMapTest());
            Http.serverContent.put("/", new Explorer());
            //add "/" context like root tree
            Http.open(8080);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
