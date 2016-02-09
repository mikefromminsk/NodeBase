package net.metabrain.level2.planing.properties;

import com.google.gson.JsonObject;

import java.net.MalformedURLException;
import java.net.URL;
import java.util.HashMap;
import java.util.Map;

public class Analyser {

    Map<String, String> getProperties(String str) {
        Map<String, String> result = new HashMap<String, String>();
        result.put("value", str);

        try {
            double value = Double.valueOf(str);
            result.put("type", "number");
            result.put("int", ((int) value) - value == 0.0 ? "true" : "false");
            result.put("div2", value % 2 == 0.0 ? "true" : "false");
            //Разница с предыдущим 4 -> 1 = -3
        } catch (NumberFormatException e) {

        }

        if (result.get("type") == null) {
            try {
                URL url = new URL(str);
                result.put("type", "object");
                JsonObject obj = new JsonObject();
                obj.addProperty("file", url.getFile());

                JsonObject params = new JsonObject();
                String[] pairs = url.getQuery().split("&");
                for (String pair : pairs) {
                    int idx = pair.indexOf("=");
                    params.addProperty(pair.substring(0, idx), pair.substring(idx + 1));
                }
                obj.add("consolidator", params);

            } catch (MalformedURLException e) {

            }
        }


        if (result.get("type") == null) {
            result.put("type", "string");
        }

        return result;
    }


    class PropOfProp {
        int count;
        int multiplier; //!!
        int power;

        public PropOfProp(int count, int power) {
            this.count = count;
            this.power = power;
            //counter1,2,3 power1,2,3
        }
    }
    Map<String, String> prevProp = new HashMap<>();
    Map<String, PropOfProp> counters = new HashMap<>();

    /*Map<String, String> stableProperties(){
        Map<String, String> result = new HashMap<>();
        //for in counters where propofprop.counters >= 3
        {
            result.put("key", "counter");
        }
        return result;
    }*/

    // analysis PropertiesValue likePermutation type=number -> type=string or length=3 -> length=4
   void update(String value){

       Map<String, String> nextProp = getProperties(value);

        for(String prevKey: prevProp.keySet()){
            String prevValue = prevProp.get(prevKey);
            for (String nextKey: nextProp.keySet()){
                String nextValue = nextProp.get(nextKey);
                PropOfProp propOfProp = counters.get(nextValue);
                if (propOfProp == null)
                    propOfProp = new PropOfProp(0, 0);

                try {
                    double prevDoubleValue = Double.parseDouble(prevValue);
                    double nextDoubleValue = Double.parseDouble(nextValue);
                    // prev 3 next 9 power 2 count 3 -> count 4
                    // prev 3 next 9 power 3 count 3 -> count 1
                    for (int i = 1; i < 3; i++) {
                        if (Math.pow(prevDoubleValue, i) == nextDoubleValue){
                            if (propOfProp.power == i){
                                propOfProp.count++;
                            }else
                            {
                                propOfProp.power = i;
                                propOfProp.count = 1;
                            }
                            break;
                        }
                    }

                } catch (NumberFormatException e) {

                    if (nextValue.equals(prevValue) && propOfProp.power == 0){
                        propOfProp.count++;
                    }

                }



            }
        }
       prevProp = nextProp;
    }
}
