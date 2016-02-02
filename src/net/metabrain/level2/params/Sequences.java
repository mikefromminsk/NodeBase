package net.metabrain.level2.params;

import java.util.Map;

public class Sequences {

    class PropOfProp {
        int count;
        int power;

        public PropOfProp(int count, int power) {
            this.count = count;
            this.power = power;
        }
    }

   void run( Map<String, PropOfProp> counters, Map<String, String> prevProp, Map<String, String> nextProp){
        for(String keyPrev: prevProp.keySet()){
            String valuePrev = prevProp.get(keyPrev);
            for (String keyNext: nextProp.keySet()){
                String valueNext = nextProp.get(keyNext);
                PropOfProp propOfProp = counters.get(valueNext);
                if (propOfProp == null)
                    propOfProp = new PropOfProp(0, 0);

                if (valueNext.equals(valuePrev) && propOfProp.power == 0){
                    propOfProp.count++;
                }
            }
        }
    }
}
