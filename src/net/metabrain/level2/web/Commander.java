package net.metabrain.level2.web;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;

import java.io.IOException;
import java.io.OutputStream;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Paths;

public class Commander implements HttpHandler {
    static String readFile(String path, Charset encoding)
            throws IOException {
        byte[] encoded = Files.readAllBytes(Paths.get(path));
        return new String(encoded, encoding);
    }

    @Override
    public void handle(HttpExchange httpExchange) throws IOException {
        String path = httpExchange.getRequestURI().getPath();
        String response = readFile("src/net/metabrain" + path, Charset.defaultCharset());
        OutputStream os = httpExchange.getResponseBody();
        httpExchange.sendResponseHeaders(200, response.length());
        os.write(response.getBytes());
        os.close();
    }
}
