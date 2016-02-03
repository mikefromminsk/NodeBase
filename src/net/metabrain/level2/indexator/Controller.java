package net.metabrain.level2.indexator;

import com.google.gson.JsonObject;

public interface Controller {
        double index(String path, JsonObject eventObject);
}
