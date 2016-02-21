package level2.web.client;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;
import level2.consolidator.Action;
import level2.executor.Executor;
import utils.Http;

import java.io.IOException;

public class ClientActionExecute implements HttpHandler {

    @Override
    public void handle(HttpExchange httpExchange) throws IOException {
        String actionID = Http.Params(httpExchange).get("actionID");
        Executor.getInstance().exec(new Action(actionID));
    }
}
