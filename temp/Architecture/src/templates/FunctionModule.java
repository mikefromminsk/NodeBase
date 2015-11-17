package templates;

import templates.utils.AvgValue;
import templates.utils.Permutation;
import templates.utils.Sequences;

import java.util.*;

public abstract class FunctionModule {
    public Permutation permutation = new Permutation();
    public Sequences sequences = new Sequences();

    public List<Object> result = new ArrayList<Object>();
    public List<String> hash = new ArrayList<String>();
    public Map<String, Object> cache = new HashMap<String, Object>();
    public Map<String, Map<String, String>> meta = new HashMap<String, Map<String, String>>();
    public Map<String, AvgValue> avgMeta = new HashMap<String, AvgValue>();


    public Object input(List<Object> inputs) {
        /*if (plan.isNotEnd or plan.isError) {
            inputMapping();
            permutation / objs(); //
            sequence / objs(); //video fragment
            borders();
            objects();
            repair();
            template();
            group();
            position();
            speed();
            acceleration();
            traectory();
            planing / tactic();
            choice / task();
            run();
        } else {
            permutation / blocks();
            sequence / blocks(); // video film
            template / tact();
            borders / pause();
            objects / words();
            repair();
            group / sentense();
            position / triangylation();
            speed();
            acceleration();
            planing / strategy();
            choice / task / money();
            run();
        }*/
        return null;
    }

    private void createCache() {
        for (int i = 0; i < result.size(); i++)
            cache.put(hash.get(i), result.get(i));
    }

    void createStatistics() {
        for (Map.Entry<String, Map<String, String>> entry : meta.entrySet()) {
            Map<String, String> metaData = entry.getValue();
            for (Map.Entry<String, String> metaEntry : metaData.entrySet()) {
                //statistics.createStat(metaEntry.getKey(), metaEntry.getValue());
            }
        }
    }


    public double getAvgMeta(String key, double value) {
        AvgValue avgValue = avgMeta.get(key);
        if (avgValue == null) {
            avgValue = new AvgValue(value, 5);
            avgMeta.put(key, avgValue);
        }
        return avgValue.add(value);
    }

    public void pause() {
        sequences.put(sequences.buffer);
        sequences.buffer.clear();
    }
}
