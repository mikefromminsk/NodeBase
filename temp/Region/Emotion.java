package brain;

import java.util.Random;

public class Emotion {
    Random rand = new Random();

    double count, time, max, min, avg, maxdist, now, one, step, id, factor;

    Emotion(){
        step  = 10;
        factor= -1;
        count = 0;
        time  = 0;
        max   = 20;
        min   = 0;
        avg   = (max-min)/2;
        maxdist  = 50;
        now   = 0;
        one   = 0;
        id    = 0;
    }

    void setAttr(Neuron neuron){

        id  = id + 1;

        count = (double)rand.nextInt(10);
        time  = (double)rand.nextInt(360000);
        if (count == 0) time = 0;

        double dist = Math.min(maxdist, id);

        avg = avg - avg/dist + time/dist;
        avg = avg == 0 ? 1 : avg;

        one = (step/(count == 0 ? 1 : count))*((time==0 ? 1 : time/avg) + (max-now)/(max-min));
        now = now + one + factor;
    }

}