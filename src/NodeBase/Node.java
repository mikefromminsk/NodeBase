package NodeBase;

import java.util.ArrayList;
import java.util.Map;

class IndexNode
{
	String IndexName;
	ArrayList<IndexNode> Childs = new ArrayList<IndexNode>();
	Node node;
	
	IndexNode(String index)
	{
		IndexName = index;
	}
}


class Link
{
	Node parent;
	Node node;
	ArrayList<Node> nodes;
	
	Link(Node node, Node parent)
	{
		this.node = node;
		this.parent = parent;
	}
	
	void add(Node node)
	{
		if (nodes == null)
		{
			nodes = new ArrayList<Node>();
			nodes.add(this.node);
			nodes.add(node);
		}
		else
			nodes.add(node);
	}
	
	Node get(int i)
	{
		if (nodes == null)
			return null;
		return nodes.get(i);
	}
}


public class Node
{
	String Path;
	String Data;
	Map<String, String>	Attr;
	Link 
		Comment,
		Source,
		Type,
		Params,
		Value,
		True,
		Else,
		Next,
		Locals;
}
