package net.metabrain.level2.indexator;

import com.google.gson.JsonObject;

public class UsageController implements Controller {

    @Override
    public double index(String path, JsonObject eventObject) {

        //or sum = getProperties.get("sumValue")
        //Consolidator.put(Controllers/usageController, sum)

    /*{
    groupID: "processList",
    address: "localhost:8080",
    processList: [
            "paint":"10",
            "word": "15",
            "virus": "45"
        [
    }*/
        return 10;
    }



}
