package templates.utils;

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
}
