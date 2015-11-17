package templates;
import java.util.HashMap;
import java.util.Map;

abstract public class SystemModule {

    public abstract DataModule unique();
    public DataModule text(){return unique();}
    public DataModule video(){return unique();}
    public DataModule audio(){return unique();}

    //assoclink
    public Map<String, DataModule> modules =  new HashMap<String, DataModule>();
    public void main() {
        modules.put("text", text());
        modules.put("video", video());
        modules.put("audio", audio());

/*
        for (String name: modules.keySet()){
            DataModule dataModule = modules.get(name);
            dataModule.run();
        }
*/
    }
}
