package net.metabrain.utils;

import java.io.*;
import java.nio.DoubleBuffer;
import java.util.Date;
import java.util.Random;

public class Emotion {

    public class AvgValue {
        double avg;
        double countNumbersToAvg;

        public AvgValue(double startValue, double countNumbersToAvg) {
            avg = startValue * countNumbersToAvg;
            this.countNumbersToAvg = countNumbersToAvg;
        }

        public double add(double value) {
            avg = avg - (avg / countNumbersToAvg);
            avg += value;
            return avg / countNumbersToAvg;
        }

        public double add(double value, long time) {
            avg = avg - (avg / countNumbersToAvg) + (time / countNumbersToAvg);
            avg += value;
            return avg / countNumbersToAvg;
        }


    }


    FileStorage fs;
    public Emotion(FileStorage fileStorage) {
        fs = fileStorage;
    }

    class EmotionData implements Serializable{
        double count, max, min, avg, countNumbersToAvg, now, step, factor;
        long lastTime;
        public EmotionData() {
            now   = 0;
            step  = 10;
            factor= -1;
            count = 0;
            max   = 20;
            min   = 0;
            avg   = (max - min) / 2;
            countNumbersToAvg  = 50;
        }
    }


    double get(int storageID, double value){
        EmotionData ed = (EmotionData) fs.getObject(storageID);
        long nowTime = new Date().getTime();
        long time = nowTime - ed.lastTime;
        double avg = new AvgValue(ed.avg, ed.countNumbersToAvg).add(time);
        double one = (ed.step / (ed.count == 0 ? 1 : ed.count))*((time == 0 ? 1 : time / avg) + (ed.max - ed.now)/(ed.max - ed.min));
        ed.now += one + ed.factor;
        ed.count++;
        ed.lastTime = nowTime;
    }



    public static void main(String[] args) {
        byte[] buffer = convertToBytes(new Test());


        count = (double)rand.nextInt(10);
        time  = (double)rand.nextInt(360000);
        if (count == 0) time = 0;

        double dist = Math.min(maxdist, id);
        avg = avg - avg/dist + time/dist;
        avg = avg == 0 ? 1 : avg;

    }

}