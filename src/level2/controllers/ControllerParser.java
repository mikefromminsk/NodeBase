package net.metabrain.level2.controllers;

import java.util.HashMap;
import java.util.Map;
import java.util.Scanner;

public class ControllerParser {

    static Map<String, String> map = new HashMap<>();

    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        while (true){
            String str = scanner.nextLine();
            System.out.println(str);
            String[] splitStr = str.split("\n");
            for (int i = 0; i <splitStr.length; i++) {
                String string = splitStr[i];
                int begin = string.indexOf('(');
                int end = string.indexOf(')');
                int tire = string.indexOf('–');
                if (begin != -1 && tire != -1){
                    String substring = string.substring(begin + 1, end);
                    map.put(substring, "sdf");
                }
            }
            for (String key: map.keySet()){
                System.out.println(key);
            }
            System.out.println(map.keySet().size());
        }
    }
}
