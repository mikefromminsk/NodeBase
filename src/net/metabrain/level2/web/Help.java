package net.metabrain.level2.web;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;

import java.io.IOException;

public class Help implements HttpHandler {
    @Override
    public void handle(HttpExchange httpExchange) throws IOException {
        //return; pages/help.html
    }
}
