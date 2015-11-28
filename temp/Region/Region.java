package brain;

import java.util.ArrayList;
import java.util.List;

public abstract class Region implements Runnable {

    public String indexDir = null;
    public void Region(String indexDir) { this.indexDir = indexDir; }

    public List<Object> inputData = new ArrayList<Object>();
    public void InputInterface(Object data) {inputData.add(data);}
    public abstract Neuron Indexing(Object data);
    public abstract void SetAttrAndLink(Object input, Neuron neuron);
    public List<Neuron> outputData = new ArrayList<Neuron>();
    public void OutputInterface(Neuron data) {outputData.add(data);}

    public Neuron current = null;

    @Override
    public void run() {
        for (int i = 0; i < inputData.size(); i++) {
            Object input = inputData.get(i);
            Neuron neuron = Indexing(input);
            SetAttrAndLink(input, neuron);
            current = neuron;
            OutputInterface(neuron);
            inputData.remove(i);
        }
    }
}
