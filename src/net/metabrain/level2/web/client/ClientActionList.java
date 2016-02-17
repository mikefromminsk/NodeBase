package net.metabrain.level2.web.client;

import com.google.gson.Gson;
import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;
import net.metabrain.level2.consolidator.Consolidator;
import net.metabrain.level2.utils.Http;

import java.io.IOException;

public class ClientActionList implements HttpHandler {
    @Override
    public void handle(HttpExchange httpExchange) throws IOException {
        Http.Response(httpExchange, new Gson().toJson(Consolidator.getInstance().actions.eventsGroup.arrayCountersCash));
    }
}
