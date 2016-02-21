package net.metabrain.level2.web;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;
import net.metabrain.level2.executor.Executor;

import java.io.IOException;

public class RegistryApi implements HttpHandler {
    @Override
    public void handle(HttpExchange httpExchange) throws IOException {
        //json
        //groupID
        //ip:port
        //functions
            //paramName:paramType
        Executor.regystry(httpExchange.getRequestBody());
    }
}
