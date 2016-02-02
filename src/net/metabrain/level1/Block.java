package net.metabrain.level1;

import java.io.Serializable;
import java.util.ArrayList;

class Block implements Serializable {
    Integer ID;
    String mac;
    Long endTime;
    ArrayList<FuncID> result = new ArrayList<FuncID>();
    Long threadID = 0L;
    Boolean threadEnd = false;
}


