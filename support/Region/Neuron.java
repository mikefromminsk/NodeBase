package brain;

import java.util.HashMap;
import java.util.Map;

public class Neuron {
    public IndexTree index;
    Map<String, String> attrs = new HashMap<String, String>();
    Map<String, Neuron> links = new HashMap<String, Neuron>();

    public Neuron(IndexTree index) {
        this.index = index;
        String path = index.toString();
        String fileData = Utils.LoadFromFile(path + Const.NodeFileName);
        if (fileData != null) {
            String[] lines = fileData.split("\n");
            for (int i = 0; i < lines.length; i++) {
                String[] var = lines[i].split("=");
                setAttr(var[0], var[1]);
            }
        }
    }

    public void setAttr(String key, String value) {
        if (key.length() > 1) {
            if (key.charAt(0) == '-') {
                setLink(key.substring(1), value);
            } else {
                attrs.put(key, value);
            }
        }
    }

    public String getAttr(String key) {
        return attrs.get(key);
    }

    public void setLink(String key, String value) {
        links.put(key, null);
    }

    public Neuron getLink(String key) {
        return links.get(key);
    }

    public String toString() {
        String bodyData = "";
        for (String key : attrs.keySet())
            bodyData += key + "=" + attrs.get(key);
        for (String key : links.keySet())
            bodyData += key + "=" + links.get(key).index.toString();
        return bodyData;
    }

    public void saveToFile() {

        Utils.SaveToFile(index.getIndexFileName(), toString());
    }
}
