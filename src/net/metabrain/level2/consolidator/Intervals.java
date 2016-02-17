package net.metabrain.level2.consolidator;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

public class Intervals {

    public Map<Long, String> events = new HashMap<>(); // time -> ArrayID
    public Map<Long, ArrayList<Long>> intervals = new HashMap<>(); //time -> event arrray
    public Arrays eventsGroup = new Arrays();

    long beginInterval = 0;
    long lastInterval = 0;

    void put(String eventID){
        long eventTime = new Date().getTime();
        //save event time
        if (beginInterval == 0) {
            beginInterval = eventTime;
            intervals.put(beginInterval, new ArrayList<Long>());
        }
        //events
        events.put(eventTime, eventID);
        //intervals
        ArrayList<Long> eventsList = intervals.get(beginInterval);
        eventsList.add(eventTime);
        lastInterval = eventTime;
    }

    String getEvent(Long time){
        return events.get(time);
    }



    String stopInterval(int afterLastMilliseconds) {
        //interval
        //using next interval from FileHashMap
        if (new Date().getTime() - lastInterval >= afterLastMilliseconds){
            ArrayList<Long> eventsList = intervals.get(beginInterval);
            ArrayList<String> eventsIds = new ArrayList<>();
            for (int i = 0; i < eventsList.size(); i++)
                eventsIds.add(events.get(eventsList.get(i)));
            String intervalID = eventsGroup.put(eventsIds);
            beginInterval = 0;
            return intervalID;
        }
        return null;
    }


    public String getLastInterval() {
        return null;
    }
}
