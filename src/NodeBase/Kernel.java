package NodeBase;

	/*
	 *  Autor: Haiduk Michail
	 *  2014
	 */

import java.util.ArrayList;
import java.util.Iterator;
import java.util.Map;

public class Kernel
{
	IndexTree rootIndex;
	Node
		root,
		prev,
		unit;
	
	public Kernel() 
	{
		rootIndex = new IndexTree();
		rootIndex.node = new Node(rootIndex);
		root = rootIndex.node;
		root.Attr = Utils.slice(Utils.LoadFromFile(Const.RootFileName), "\n");
		if (root.getAttr(Const.naLastID) == null)
			root.setAttr(Const.naLastID, "0");
		root.setNodeType(Const.ntRoot);
	}
	
	String NextID()
	{
		root.setAttr(Const.naLastID, Utils.Inc(Const.naLastID));
		return root.getAttr(Const.naLastID);
	}
	
	void LoadNode(Node node)
	{
		node.setNodeType(Const.ntLoad);
		IndexTree indexNode = node.Index;

		ArrayList<String> indexes = new ArrayList<String>();
		while (indexNode != null)
		{
			indexes.add(indexNode.IndexName);
			indexNode = indexNode.parent;
		}
		String path = Utils.toFileSystemName(indexes) + Const.NodeFileName;
		indexes.clear();
		
		String body = Utils.LoadFromFile(path);
		if (body != null)
			setNode(body);
	}	

	
	Node newNode(TextNode textNode) 
	{
		Node result = null;
		
		
		if (textNode.ID != null)
		{
			result = rootIndex.newSubIndex(Const.sID + textNode.ID);
			if (result.getNodeType() == null)
				LoadNode(result);
		}
		
		if (textNode.Comment != null)
		{
			//SetName(Result, Link.Name);
			
			if (result.getNodeType() != Const.ntLoad)
			{
				switch (textNode.Comment.charAt(0)) {
				case '/': result.setNodeType(Const.ntFile);    break;
				case '!': result.setNodeType(Const.ntString);  break;
				case '0': case '1': case '2': case '3': case '4': 
				case '5': case '6': case '7': case '8': case '9': 
						  result.setNodeType(Const.ntNumber);  break;
				default:  result.setNodeType(Const.ntComment); break;
				}
				
				/*if (result.getNodeType() == Const.ntComment)
					result.setSource(FindSource());*/
				if (result.getNodeType() == Const.ntNumber)
					result.setData(textNode.Comment);
				if (result.getNodeType() == Const.ntString)
					result.setData(textNode.Comment.substring(1));
			}	
		}
		
		if (result == null) return null;
		
		if (textNode.Source != null)
		{
			if ((result.getNodeType() == Const.ntComment) && 
				(result.getNodeType() != Const.ntLoad))
			{
				result.getSource().setSource(newNode(textNode.Source));
				result = result.getSource();
			}
			else
				result.setSource(newNode(textNode.Source));
		}
		
		if (textNode.Attr != null)
		{
			Iterator it = textNode.Attr.entrySet().iterator();
		    while (it.hasNext()) 
		    {
		        Map.Entry pairs = (Map.Entry)it.next();
		        result.setAttr((String)pairs.getKey(), (String)pairs.getValue());
		    }
		}
		
		if (textNode.Type != null)
			result.setType(newNode(textNode.Type));
		
		if (textNode.Params != null)
			for (int i=0; i<textNode.Params.size(); i++)
				result.setParam(newNode(textNode.Params.get(i)));

		if (textNode.Value != null)
			if (textNode.Value.Comment.charAt(0) == Const.sData.charAt(0))
				result.setData(Utils.decodeStr(textNode.Value.Comment.substring(2)));
			else
				result.setValue(newNode(textNode.Value));
		
		if (textNode.Else != null)
			result.setElse(newNode(textNode.Else));
		if (textNode.True != null)
			result.setTrue(newNode(textNode.True));					
		if (textNode.Next != null)
			result.setNext(newNode(textNode.Next));
		
		for (int i=0; i<textNode.Locals.size(); i++)
			result.setLocal(newNode(textNode.Locals.get(i)));
		
		return result;
	}

	
	/*String GetNodeBody(Node node)
	{
		
	}*/

	Node getNode()
	{
		return null;
	}
	
	Node setNode(String code)
	{
		TextNode node = new TextNode(code).UserParse();
		return newNode(node);
	}

	Node runNode()
	{
		return null;
	}
	
	
	
	
}
