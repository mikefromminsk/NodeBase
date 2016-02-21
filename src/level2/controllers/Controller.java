package level2.controllers;

import com.google.gson.JsonObject;

public interface Controller {
        double index(String path, JsonObject eventObject);
}
