package level2.consolidator;

import java.util.ArrayList;
import java.util.Map;

public class Action {

    Consolidator co = Consolidator.getInstance();
    public Boolean real = true;
    public String actionID;
    public ArrayList<String> actionArray;
    public Map<String, ArrayList<String>> intervalArrays;
    public Map<String, ArrayList<String>> groupArrays;

    public Action(){
        real = false;
    }

    public Action(String actionID) {
        this.actionID = actionID;
        actionArray = co.actions.eventsGroup.getArray(actionID);
        for (int i = 0; i < actionArray.size(); i++) {
            ArrayID intervalID = new ArrayID(actionArray.get(i));
            Intervals intervals = co.intervals.get(intervalID.groupName);
            ArrayList<String> interval = intervals.eventsGroup.getArray(intervalID.arrayID);
            intervalArrays.put(intervalID.toString(), interval);
            for (int j = 0; j < interval.size(); j++) {
                ArrayID arrayID = new ArrayID(interval.get(i));
                Arrays arrays = co.arrays.get(intervalID.groupName);
                ArrayList<String> array = arrays.getArray(arrayID.arrayID);
                groupArrays.put(arrayID.toString(), array);
            }
        }
    }

}
