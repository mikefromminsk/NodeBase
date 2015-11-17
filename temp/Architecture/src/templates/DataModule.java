package templates;

import java.util.*;


abstract public class DataModule{

    public abstract FunctionModule split();
    public abstract FunctionModule repair();
    public abstract FunctionModule group();
    public abstract FunctionModule mapping();
    public abstract FunctionModule analysis();
    public abstract FunctionModule choice();

    public Object inputData;
    public void run(Object inputData) {
        this.inputData = inputData;
        split();
        group();
        mapping();
        analysis();
        choice();
    }

    public static Map<String, FunctionModule> modules = new HashMap<String, FunctionModule>();
    public static List<Object> sequencesActivations = new ArrayList<Object>();

    public void init(){
        modules.put("split", split());
        modules.put("group", group());
        modules.put("analysis", analysis());
        modules.put("mapping", mapping());
        modules.put("choice", choice());
        sequencesActivations.add(modules.get("mapping")); //по вермени / карта времени
        sequencesActivations.add(modules.get("split")); //по времени
        sequencesActivations.add(modules.get("group")); // по времени
        sequencesActivations.add(modules.get("analysis")); //по прошлому
        sequencesActivations.add(modules.get("choice")); //по анализу

        while (true) {
            for (int i = 0; i < sequencesActivations.size(); i++) {
                FunctionModule funcModule = (FunctionModule) sequencesActivations.get(i);
                /*funcModule.run();*/
            }
        }
    }

}
