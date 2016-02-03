package net.metabrain.level2.indexator;

public class Summator {

    double begin;
    double end;
    double now;
    double factor;
    double border;

    public Summator(double begin, double end, double now, double factor, double border) {
        this.begin = begin;
        this.end = end;
        this.now = now;
        this.factor = factor;
        this.border = border;
    }

    void add(double value){
        now += value;
    }
}
