import java.util.ArrayList;

/**
 * Author: x29a100
 * 19.01.2015
 */


public class GG {


    static class Time
    {
        float func;
        float param1;
        float param2;
        float trueto;
        float result;
    }

    static class TimeID
    {
        float timeIndex;
        float funcIndex;
        float linkIndex;
        float trueIndex;
        float resultIndex;

    }



    public static void main(String[] args) {

        float[] inputVars = {1, 0, 6};
        float funcCount = 8;
        float timeIndex = 0;
        ArrayList<TimeID> rightFuncs = new ArrayList<TimeID>();
        while (true)
        {

            timeIndex++;



            ArrayList<Time> timeLine = new ArrayList<Time>();
            for (int i = 0; i < timeIndex; i++)
                timeLine.add(new Time());

            for (int funcIndex = 0; funcIndex < Math.pow(funcCount, timeIndex); funcIndex++) {

                float funcIndex2 = funcIndex;
                for (int i = 0; i < timeLine.size(); i++) {
                    Time time =  timeLine.get(i);
                    int razm = (int)Math.pow(funcCount, i + 1);
                    time.func = (int) ((funcIndex2 % razm) / Math.pow(funcCount, i));
                    funcIndex2 = funcIndex2 - funcIndex2 % razm;
                }

                ArrayList<Double> maxIndex = new ArrayList<Double>();
                ArrayList<Double> values = new ArrayList<Double>();
                for (int i = 0; i < timeLine.size(); i++){
                    maxIndex.add(Math.pow(inputVars.length + i, 2));
                    values.add(0.0);
                }


                Double sum = 0.0;
                for (int i = 0; i < maxIndex.size(); i++)
                    sum +=  maxIndex.get(i);


                for (int linkIndex = 0; linkIndex < sum; linkIndex++) {

                    float linkIndex2 = linkIndex;

                    for (int i = 0; i < values.size(); i++)
                    {
                        Double val = values.get(i);

                        int razm = 1;
                        for (int j = i + 1; j < maxIndex.size(); j++) {
                            int maxIndex1 = maxIndex.get(j).intValue();
                            razm *= maxIndex1;
                        }
                        values.set(i, (double) (int) (linkIndex2 / razm));
                        int val2 = val.intValue();
                        linkIndex2 -= val * razm;

                    }

                    for (int i = 0; i < values.size(); i++) {
                        float val =  values.get(i).floatValue();
                        Time time = timeLine.get(i);
                        time.param1 = (float)(val % Math.sqrt(maxIndex.get(i)));
                        time.param2 = (float)(int)(val / Math.sqrt(maxIndex.get(i)));
                    }

                    ArrayList<Double> equals = new ArrayList<Double>();
                    for (int i = 0; i < timeLine.size(); i++)
                        if (timeLine.get(i).func > 3)
                            equals.add((double)i);

                    for (int trueIndex = 0; trueIndex < Math.pow(timeLine.size() - 1, equals.size()); trueIndex++)
                    {
                        float trueIndex2 = trueIndex;

                        for (int i = 0; i < equals.size(); i++) {
                            Time time = timeLine.get(equals.get(i).intValue());
                            int razm = (int)Math.pow(timeLine.size() - 1, i + 1);
                            time.trueto = (float) (int) (trueIndex2 / razm);
                            trueIndex2 -= time.trueto * razm;
                            if (time.trueto >= equals.get(i))
                                time.trueto++;
                        }


                        //run

                        long maxRunTime = 200;
                        long runTime = 0;


                        int i=0;
                        while (i != timeLine.size())
                        {
                            runTime++;
                            if (runTime > maxRunTime)
                                break;
                            Time time = timeLine.get(i);

                            switch ((int)time.func){
                                case 0: time.result = time.param1 + time.param2; break;
                                case 1: time.result = time.param1 - time.param2; break;
                                case 2: time.result = time.param1 * time.param2; break;
                                case 3: time.result = time.param1 / time.param2; break;
                                case 4: time.result = (time.param1 == time.param2) ? 1 : 0; break;
                                case 5: time.result = (time.param1 != time.param2) ? 1 : 0; break;
                                case 6: time.result = (time.param1 > time.param2) ? 1 : 0; break;
                                case 7: time.result = (time.param1 < time.param2) ? 1 : 0; break;
                            }
                            if (time.func > 3)
                                if (time.result == 1)
                                {
                                    i = (int)time.trueto;
                                    continue;
                                }

                            i++;
                        }

                        double rightResult = 3.14;

                        if (runTime <= maxRunTime)
                        {
                            for (int resultIndex = 0; resultIndex < timeLine.size(); resultIndex++) {
                                Time time = timeLine.get(resultIndex);
                                double roundResult = Math.round(time.result * 100.0) / 100.0;
                                if (roundResult == rightResult)
                                {
                                    TimeID timeID = new TimeID();
                                    timeID.timeIndex = timeIndex;
                                    timeID.funcIndex = funcIndex;
                                    timeID.linkIndex = linkIndex;
                                    timeID.trueIndex = trueIndex;
                                    timeID.resultIndex = resultIndex;
                                    rightFuncs.add(timeID);
                                    System.out.println(rightFuncs.size());
                                }

                            }
                        }

                    }
                }
            }
        }
    }
}
