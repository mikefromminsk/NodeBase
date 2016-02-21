package utils;


import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TimeMap {

    static String readFile(String path, Charset encoding)
            throws IOException {
        byte[] encoded = Files.readAllBytes(Paths.get(path));
        return new String(encoded, encoding);
    }

    static class SumNode {
        HashMap<String, Integer> toLink = new HashMap<>();
        HashMap<String, Integer> sumLinks = new HashMap<>();
    }

    static HashMap<String, SumNode> list = new HashMap<>();

    static class Node {
        String name;

        public Node(String name) {
            this.name = name;
        }
    }

    static class Edge {
        String src;
        String dest;
        String data;

        public Edge(String src, String dest, String data) {
            this.src = src;
            this.dest = dest;
            this.data = data;
        }
    }

    static class Graph {
        List<Node> nodes = new ArrayList<>();
        List<Edge> edges = new ArrayList<>();
    }

    private static final Map<String, String> letters = new HashMap<String, String>();
    static {
        letters.put("А", "A");
        letters.put("Б", "B");
        letters.put("В", "V");
        letters.put("Г", "G");
        letters.put("Д", "D");
        letters.put("Е", "E");
        letters.put("Ё", "E");
        letters.put("Ж", "ZH");
        letters.put("З", "Z");
        letters.put("И", "I");
        letters.put("Й", "I");
        letters.put("К", "K");
        letters.put("Л", "L");
        letters.put("М", "M");
        letters.put("Н", "N");
        letters.put("О", "O");
        letters.put("П", "P");
        letters.put("Р", "R");
        letters.put("С", "S");
        letters.put("Т", "T");
        letters.put("У", "U");
        letters.put("Ф", "F");
        letters.put("Х", "H");
        letters.put("Ц", "C");
        letters.put("Ч", "CH");
        letters.put("Ш", "SH");
        letters.put("Щ", "SH");
        letters.put("Ъ", "'");
        letters.put("Ы", "Y");
        letters.put("Ъ", "'");
        letters.put("Э", "E");
        letters.put("Ю", "U");
        letters.put("Я", "YA");
        letters.put("а", "a");
        letters.put("б", "b");
        letters.put("в", "v");
        letters.put("г", "g");
        letters.put("д", "d");
        letters.put("е", "e");
        letters.put("ё", "e");
        letters.put("ж", "zh");
        letters.put("з", "z");
        letters.put("и", "i");
        letters.put("й", "i");
        letters.put("к", "k");
        letters.put("л", "l");
        letters.put("м", "m");
        letters.put("н", "n");
        letters.put("о", "o");
        letters.put("п", "p");
        letters.put("р", "r");
        letters.put("с", "s");
        letters.put("т", "t");
        letters.put("у", "u");
        letters.put("ф", "f");
        letters.put("х", "h");
        letters.put("ц", "c");
        letters.put("ч", "ch");
        letters.put("ш", "sh");
        letters.put("щ", "sh");
        letters.put("ъ", "'");
        letters.put("ы", "y");
        letters.put("ъ", "'");
        letters.put("э", "e");
        letters.put("ю", "u");
        letters.put("я", "ya");
    }


    static int max = 0;
    static void addList(String word) {


        for (int i = 0; i < word.length(); i++) {
            SumNode sumNode = list.get("" + word.charAt(i));
            if (sumNode == null) {
                sumNode = new SumNode();
                list.put("" + word.charAt(i), sumNode);
            }
            for (int j = 0; j < word.length(); j++) {
                if (i != j) {
                    Integer sum = sumNode.toLink.get("" + word.charAt(j));
                    sum = sum == null ? 1 : sum + 1;
                    sumNode.toLink.put("" + word.charAt(j), sum);
                    if (max < sum)
                        max = sum;
                    Integer sumLink = sumNode.sumLinks.get("" + word.charAt(j));
                    if (sumLink == null){
                        int min = Integer.MAX_VALUE;
                        String minKey = "";
                        for (String key: sumNode.sumLinks.keySet()){
                            if (sumNode.sumLinks.get(key) < min) {
                                min = sumNode.sumLinks.get(key);
                                minKey = key;
                            }
                        }
                        if (min != Integer.MAX_VALUE && min < sum && sumNode.sumLinks.keySet().size() > 3){
                            sumNode.sumLinks.remove(minKey);
                        }
                    }
                    if (sumNode.sumLinks.keySet().size() <= 3)
                    sumNode.sumLinks.put("" + word.charAt(j), sum);
                }
            }
        }

    }

    public static void main(String[] args) {
        try {
            String file = readFile("test.txt", Charset.forName("cp1251"));
            String word = "";
            for (int i = 0; i < 100000; i++) {
                if (file.charAt(i) == ' ') {
                    addList(word);
                    word = "";
                } else {
                    if (file.charAt(i) >= 'а' && file.charAt(i) <= 'я')
                    word += file.charAt(i);
                }
            }

            Graph graph = new Graph();
            for (String key : list.keySet())
                if (key.charAt(0) >= 'а' && key.charAt(0) <= 'я')
                    graph.nodes.add(new Node(key));
            for (String fromKey : list.keySet()) {
                SumNode sumNode = list.get(fromKey);

                for (String toKey : sumNode.sumLinks.keySet())
                    if (fromKey.charAt(0) >= 'а' && fromKey.charAt(0) <= 'я')
                        if (toKey.charAt(0) >= 'а' && toKey.charAt(0) <= 'я')
                            if (fromKey.charAt(0) != toKey.charAt(0))
                                if (letters.get(String.valueOf((char)(fromKey.charAt(0)))) != null)
                                if (letters.get(String.valueOf((char)(toKey.charAt(0)))) != null)
                            if (sumNode.sumLinks.get(toKey) > 1000) {
                                //graph.edges.add(new Edge(fromKey, toKey, "" + sumNode.toLink.get(toKey)));
                                System.out.println(
                                        "graph.addLink('" + letters.get(String.valueOf((char) (fromKey.charAt(0)))) + "', '" + letters.get(String.valueOf((char) (toKey.charAt(0)))) + "', { connectionStrength: "
                                                + (double) ((max - 1000) - (sumNode.sumLinks.get(toKey) - 1000)) / (double) (max - 1000) + " });"
                                );
                                list.get("" + toKey.charAt(0)).sumLinks.remove("" + fromKey.charAt(0));
                            }
            }

            //System.out.println(new Gson().toJsonTree(graph));


        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
