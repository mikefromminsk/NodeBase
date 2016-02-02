package net.metabrain.level2.indexator;

import net.metabrain.level2.storage.FileStorage;

import java.io.*;
import java.util.Date;

public class Curiosity {

    public static class Avg {
        double avg;
        double countNumbersToAvg;

        public Avg(double startValue, double countNumbersToAvg) {
            avg = startValue * countNumbersToAvg;
            this.countNumbersToAvg = countNumbersToAvg;
        }

        public double add(double value) {
            avg = avg - (avg / countNumbersToAvg);
            avg += value;
            return avg / countNumbersToAvg;
        }
    }


    FileStorage fs;
    public Curiosity(FileStorage fileStorage) {
        fs = fileStorage;
    }

    static class MoodData implements Serializable{
        double max, min, now, step, factor, countNumbersToAvg;
        long lastUpdateTime;
        public MoodData() {
            now   = 0;
            step  = 10;
            factor= -1;
            max   = 20;
            min   = 0;
            countNumbersToAvg  = 50;
        }
    }

    static class EmotionData implements Serializable{
        double count, avgTime;
        long updateTime;
        public EmotionData() {
            count = 0;
            avgTime = 0;
            updateTime = 0;
        }
    }

    static double get(MoodData md, EmotionData ed){
        long nowTime = new Date().getTime();
        double one = md.step;
        if (ed.updateTime != 0){
            long time = nowTime - ed.updateTime;
            ed.avgTime = new Avg(ed.avgTime, Math.min(ed.count, md.countNumbersToAvg)).add(time);
            double stabilizer = (md.max - md.now)/(md.max - md.min);
            double factor =  md.factor * ((nowTime - md.lastUpdateTime) / 1000);
            one = (md.step / ed.count)*((time / ed.avgTime) + stabilizer) + factor;
        }
        md.now += one;
        ed.count++;
        ed.updateTime = nowTime;
        md.lastUpdateTime = nowTime;
        return one;
    }

    public static void main(String[] args) throws IOException {
        MoodData md = new MoodData();
        EmotionData ed = new EmotionData();

        BufferedReader bufferRead = new BufferedReader(new InputStreamReader(System.in));
        String s = "123";
        while (!s.equals("1")){
            System.out.println(get(md, ed));
            System.out.println(md.now);
            s = bufferRead.readLine();
        }
    }

}