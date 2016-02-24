package templates;

import java.util.HashMap;
import java.util.Map;

abstract public class RootModule {

    public abstract InputModule ear();
    public abstract InputModule eye();
    public abstract InputModule feel();
    public abstract InputModule temperature();
    public abstract InputModule accelerometer();

    public abstract SystemModule reliable();

    public abstract SystemModule abstracts();

    public abstract SystemModule neurolan();

    public abstract SystemModule logic();

    public abstract SystemModule unique();

    Object globalPlan;

    void activation() {
        // выполнение скрипта действий для реализации плана
                        /*
                        * выход если произошло несоответсвие
                        * */


    }

    public Map<String, SystemModule> modules = new HashMap<String, SystemModule>();


    void getRequest(String dataType, String Data) {
        for (String moduleName : modules.keySet()) {
            SystemModule module = modules.get(dataType);

        }

    }

    public static void main(String[] args) {


    }

}
