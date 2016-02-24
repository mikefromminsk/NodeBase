package level2.consolidator;

import java.util.List;
import java.util.Map;

public class EventData{
    public String groupID;
    public List<String> data;

    public EventData(String groupID, List<String> data) {
        this.groupID = groupID;
        this.data = data;
    }
}