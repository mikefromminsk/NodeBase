package brain.system;

import brain.IndexTree;
import brain.Neuron;
import brain.Region;

import java.util.Date;

public class Text extends Region {

    IndexTree tree = new IndexTree(getClass().getName().toLowerCase());

    @Override
    public Neuron Indexing(Object input) {
        String data = (String)input;
        String[] indexes = data.split(".");
        return tree.getNeuron(indexes);
    }

    @Override
    public void SetAttrAndLink(Object input, Neuron neuron) {
        neuron.setAttr("InputTime", new Date().toString());
    }
}
