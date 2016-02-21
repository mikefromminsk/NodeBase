package net.metabrain.level2.web;

import net.metabrain.utils.Http;

import java.io.File;
import java.io.IOException;

public class HttpHandlerController {

    // поиск файлов со строкой implements HttpHandle и добавление в контент

    public HttpHandlerController() {
        System.out.println(new File("").getAbsolutePath());


        Http.findHttpHandlers();
        try {/*
            Http.serverContent.put("/help", new RegistryApi());
            Http.serverContent.put("/registryapi", new RegistryApi());
            Http.serverContent.put("/hashmaptest", new HashMapTest());

            Http.serverContent.put("/" + ClientAction.class.getSimpleName(), new ClientAction());
            Http.serverContent.put("/" + ClientActionList.class.getSimpleName(), new ClientActionList());
            Http.serverContent.put("/" + ClientActionExecute.class.getSimpleName(), new ClientActionExecute());
            //add "/" context likePermutation root tree*/
            Http.serverContent.put("/", new Explorer());
            Http.open(8080);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static void main(String[] args) {
        HttpHandlerController httpHandlerController = new HttpHandlerController();
    }
}
