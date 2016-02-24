package app.ImageFind;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;
import level3.image.ImageStorage;

import java.io.IOException;

public class PutImage implements HttpHandler {

    ImageStorage imageStorage = ImageStorage.getInstance();
    @Override
    public void handle(HttpExchange httpExchange) throws IOException {

    }
}
