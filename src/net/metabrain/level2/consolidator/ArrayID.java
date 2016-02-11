package net.metabrain.level2.consolidator;

public class ArrayID {
    public String groupName;
    public String arrayID;

    public ArrayID(String groupName, String arrayID) {
        this.groupName = groupName;
        this.arrayID = arrayID;
    }

    public ArrayID(String unionID) {
        String[] groupIdAndArrayID = unionID.split(",");
        groupName = groupIdAndArrayID[0];
        arrayID = groupIdAndArrayID[1];
    }

    @Override
    public String toString() {
        return groupName + "," + arrayID;
    }
}
