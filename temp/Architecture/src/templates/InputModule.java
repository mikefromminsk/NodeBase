package templates;



import templates.utils.Permutation;
import templates.utils.Sequences;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

abstract public class InputModule {

    public Map<String, Map<String, Object>> storage = new HashMap<String, Map<String, Object>>();
    public Permutation permutation = new Permutation();
    public Sequences sequences = new Sequences();

    public abstract List<Object> listData(Object data);

    public abstract Map<String, Object> dataToPoints(Object data);

    public abstract String hashObject(Object object);

    public void findShapes(Map<String, Object> points){

    }

    public void input(Object data){
        Map<String, Object> points = dataToPoints(data);
        for (String inputId: points.keySet()){
            Map<String, Object> inputData = storage.get(inputId);
            if (inputData == null)
                storage.put(inputId, inputData = new HashMap<String, Object>());
            inputData.put(hashObject(points.get(inputId)), points.get(inputId));
        }
        findShapes(points);
        sequences.buffer.add(permutation.put((ArrayList<String>) points.keySet()));

    }

    public void pause(){
        sequences.put(sequences.buffer);
        sequences.buffer.clear();
    }
}
