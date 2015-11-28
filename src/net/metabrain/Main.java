package net.metabrain;

import net.metabrain.utils.Http;
import org.w3c.dom.*;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

public class Main {

    public static void main(String[] args) throws Exception {
        DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
        DocumentBuilder db = dbf.newDocumentBuilder();
        Document doc = db.parse(Http.GetStream("http://localhost:8080"));

        doc.getDocumentElement();
        NodeList processList = doc.getElementById("list").getChildNodes();
        for (int i = 0; i < processList.getLength(); i++) {
            NodeList processParams = processList.item(i).getChildNodes();
            for (int j = 0; j < processParams.getLength(); j++) {
                Node param = processParams.item(j);
                String id = param.getAttributes().getNamedItem("id").getNodeValue();
                if (id.equals("pid")) {

                } else if (id.equals("using")) {

                } else if (id.equals("cmd")){

                }


            }

        }

        visit(doc, 0);
    }

    public static void visit(Node node, int level) {
        NodeList list = node.getChildNodes();
        for (int i = 0; i < list.getLength(); i++) {
            Node childNode = list.item(i);
            if (childNode.getNodeType() == Node.TEXT_NODE)
                System.out.println(childNode.getAttributes().getLength());
            visit(childNode, level + 1);
        }
    }
}
