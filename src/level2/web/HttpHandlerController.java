package level2.web;

import utils.Http;

import java.io.File;
import java.io.IOException;

public class HttpHandlerController {

    // поиск файлов со строкой implements HttpHandle и добавление в контент

    public HttpHandlerController() {
        System.out.println(new File("").getAbsolutePath());
        try {
            Http.findHttpHandlers();
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
