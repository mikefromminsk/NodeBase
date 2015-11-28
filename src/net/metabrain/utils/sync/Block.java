package net.metabrain.utils.sync;

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


