import java.io.Serializable;
import java.util.ArrayList;

class FuncID implements Serializable {
    Double timeIndex;
    Double funcIndex;
    Double linkIndex;
    Double trueIndex;
    Double resultIndex;
}

public class Generator implements Runnable {


    static class Time {
        double func;
        double par1;
        double par2;
        double trueto;
        double result;
    }

    int blockID;

    ArrayList<FuncID> result = new ArrayList<FuncID>();

    Generator(int blockID) {
        this.blockID = blockID;
    }

    public void run() {

        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
        }
        Synchronizer.Block generateBlock = Synchronizer.data.getBlock(blockID);
        if (generateBlock.ID == 100)
        {
            FuncID funcID  = new FuncID();
            funcID.funcIndex = (double )generateBlock.ID;
            result.add(funcID);
        }
        generateBlock.result = result;
        generateBlock.threadEnd = true;


        if (true)
            return;

        double funcRun = 0;
        double[] inputVars = {1, 6, 3};


        //set time
        double timeIndex = 3;

        long beginTime = System.currentTimeMillis();
        while (true) {
            timeIndex++;
            //timeIndex =4;

//				+funcINdexBegin
//				+funcindexend

            ArrayList<Time> timeLine = new ArrayList<Time>();
            for (double i = 0; i <= timeIndex; i++)
                timeLine.add(new Time());

            //set function
            double funcCount = 8;

            for (double funcIndex = 0; funcIndex < Math.pow(funcCount, timeIndex); funcIndex++) {


                funcRun++;

                if (funcRun % 200 == 0) {
                    System.out.println(timeIndex + " line " + funcRun + " count " + (System.currentTimeMillis() - beginTime) + " ms");
                    beginTime = System.currentTimeMillis();
                }

                double funcIndex2 = funcIndex;
                /*0 * Math.pow(funcCount, 0) + //add
           1 * Math.pow(funcCount, 1) + //sub
           4 * Math.pow(funcCount, 2) + //==
           5 * Math.pow(funcCount, 3) + //!=
           2 * Math.pow(funcCount, 4); //mul */

                for (double i = 0; i < timeLine.size(); i++) {
                    Time time = timeLine.get((int) i);
                    double razm = Math.pow(funcCount, i + 1);
                    time.func = (funcIndex2 % razm) / Math.pow(funcCount, i);
                    funcIndex2 -= funcIndex2 % razm;
                }


                //prepare to params generate


                ArrayList<Double> maxIndex = new ArrayList<Double>();
                for (double i = 0; i < timeLine.size(); i++)
                    maxIndex.add(Math.pow(inputVars.length + i, 2));
                Double maxIndexSum = 0.0;
                for (double i = 0; i < maxIndex.size(); i++)
                    maxIndexSum += maxIndex.get((int) i);
                ArrayList<Double> valIndex = new ArrayList<Double>();
                for (double i = 0; i < maxIndex.size(); i++)
                    valIndex.add(0.0);


                //set params
                for (double parIndex = 0; parIndex < maxIndexSum; parIndex++) {

                    double parIndex2 = parIndex;
                    /*(0 + 2 * Math.sqrt(maxIndex.get(0))) * 1 +
                   (3 + 2 * Math.sqrt(maxIndex.get(1))) * 1 * maxIndex.get(1) +
                   (0 + 0 * Math.sqrt(maxIndex.get(2))) * 1 * maxIndex.get(1) * maxIndex.get(2) +
                   (5 + 5 * Math.sqrt(maxIndex.get(3))) * 1 * maxIndex.get(1) * maxIndex.get(2) * maxIndex.get(3) +
                   (6 + 1 * Math.sqrt(maxIndex.get(4))) * 1 * maxIndex.get(1) * maxIndex.get(2) * maxIndex.get(3) * maxIndex.get(4);
                    */
                    for (double i = 0; i < valIndex.size(); i++) {
                        double razm = 1;
                        for (double j = 1; j < maxIndex.size() - i; j++)
                            razm *= maxIndex.get((int) j);
                        double val = (double) (int) (parIndex2 / razm);
                        valIndex.set((int) (maxIndex.size() - i - 1), val);
                        parIndex2 -= val * razm;

                        if (val == 15) {
                            double x = 1;
                        }
                        /*double razm = Math.pow(funcCount, i + 1);
                        time.func = (funcIndex2 % razm) / Math.pow(funcCount, i);
                        funcIndex2 -= funcIndex2 % razm;
                        */
                    }

                    for (double i = 0; i < valIndex.size(); i++) {
                        double val = valIndex.get((int) i);
                        Time time = timeLine.get((int) i);
                        double razm = Math.pow(funcCount, i + 1);
                        time.par1 = (int) (val % Math.sqrt(maxIndex.get((int) i)));
                        time.par2 = (int) (val / Math.sqrt(maxIndex.get((int) i)));
                    }


                    //set trueto
                    ArrayList<Double> equalsFuncIndexes = new ArrayList<Double>();
                    for (double i = 0; i < timeLine.size(); i++)
                        if (timeLine.get((int) i).func > 3)
                            equalsFuncIndexes.add((double) i);

                    for (double trueIndex = 0; trueIndex < Math.pow(timeLine.size() - 1, equalsFuncIndexes.size()); trueIndex++) {
                        double trueIndex2 = trueIndex;
                        // 1 + 3 * Math.pow(timeLine.size() - 1, 1);

                        for (double i = 0; i < equalsFuncIndexes.size(); i++) {
                            Time time = timeLine.get((int) equalsFuncIndexes.get((int) i).doubleValue());
                            double razm = Math.pow(timeLine.size() - 1, i + 1);
                            time.trueto = (trueIndex2 % razm) / Math.pow(timeLine.size() - 1, i);
                            trueIndex2 -= trueIndex2 % razm;
                            if (time.trueto >= equalsFuncIndexes.get((int) i))
                                time.trueto++;
                        }


                        //run


                        double maxRunTime = 10000;
                        double runTime = 0;
                        double i = 0;
                        while ((i < timeLine.size()) & (runTime < maxRunTime)) {
                            runTime++;
                            Time time = timeLine.get((int) i);

                            double par1 = 0;
                            if (time.par1 < inputVars.length)
                                par1 = inputVars[(int) time.par1];
                            else
                                par1 = timeLine.get((int) time.par1 - inputVars.length).result;

                            double par2 = 0;
                            try {
                                if (time.par2 < inputVars.length)
                                    par2 = inputVars[(int) time.par2];
                                else
                                    par2 = timeLine.get((int) time.par2 - inputVars.length).result;
                            } catch (IndexOutOfBoundsException e) {
                                e.printStackTrace();
                            }

                            switch ((int) time.func) {
                                case 0:
                                    time.result = par1 + par2;
                                    break;
                                case 1:
                                    time.result = par1 - par2;
                                    break;
                                case 2:
                                    time.result = par1 * par2;
                                    break;
                                case 3:
                                    time.result = par1 / par2;
                                    break;
                                case 4:
                                    time.result = (par1 == par2) ? 1 : 0;
                                    break;
                                case 5:
                                    time.result = (par1 != par2) ? 1 : 0;
                                    break;
                                case 6:
                                    time.result = (par1 > par2) ? 1 : 0;
                                    break;
                                case 7:
                                    time.result = (par1 < par2) ? 1 : 0;
                                    break;
                            }
                            if (time.func > 3)
                                if (time.result == 1) {
                                    i = (double) time.trueto;
                                    continue;
                                }

                            i++;
                        }


                        double rightResult = 3.14;
                        if (runTime < maxRunTime) {
                            for (double resultIndex = 0; resultIndex < timeLine.size(); resultIndex++) {
                                Time time = timeLine.get((int) resultIndex);
                                double roundResult = Math.round(time.result * 100.0) / 100.0;
                                if (roundResult == rightResult) {
                                    FuncID funcID = new FuncID();
                                    funcID.timeIndex = timeIndex;
                                    funcID.funcIndex = funcIndex;
                                    funcID.linkIndex = parIndex;
                                    funcID.trueIndex = trueIndex;
                                    funcID.resultIndex = resultIndex;
//
//                                    for (int j = 0; j < data.generateList.size(); j++)
//                                        if (data.generateList.get(j).blockID == blockID)
//                                            data.generateList.get(j).result.add(funcID);

                                }

                            }
                        }

                    }
                }
            }
        }
    }
}