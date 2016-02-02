package net.metabrain.level2.web;

import com.google.gson.JsonObject;
import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;
import net.metabrain.level2.consolidator.Consolidator;

import java.io.IOException;

public class Event implements HttpHandler {

    String getBody(HttpExchange httpExchange){
        return "";
    }

    @Override
    public void handle(HttpExchange httpExchange) throws IOException {
        //json
        //groupID
        //processList
        JsonObject json = new JsonObject(/*from getBody*/);
        Consolidator.event(json);
    }
}
