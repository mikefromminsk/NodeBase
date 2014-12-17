package NodeBase;

import java.util.ArrayList;

public class IndexNode
{
	String index;
	Node node;
	IndexNode parent;
	ArrayList<IndexNode> childs = new ArrayList<IndexNode>();

	public IndexNode getSubNode(String index)
	{
		String[] indexes = index.split(Const.FileDelimeter);
		if (indexes.length == 1)
		{
			indexes = new String[index.length()];
			for (int i=0; i<index.length(); i++)
				indexes[i] = "" + index.charAt(i);
		}
		
		IndexNode node = this;
		for (int i=0; i<indexes.length; i++)
		{
			int subIndexPos = -1;
			for (int j=0; j<node.childs.size(); j++)
				if (node.childs.get(j).index.equals(indexes[i]))
				{
					subIndexPos = j;
					break;
				}
			if (subIndexPos == -1)
			{
				node.childs.add(new IndexNode());
				node.childs.get(node.childs.size() - 1).parent = node;
				node = node.childs.get(node.childs.size() - 1);
				node.index = indexes[i];
			}
			else
				node = node.childs.get(subIndexPos);
		}
		return node;
	}
	
	public ArrayList<String> toStrings()
	{
		IndexNode node = this;
		ArrayList<String> result = new ArrayList<String>();
		while (node.parent != null)
		{
			result.add(node.index);
			node = node.parent;
		}
		return result;
	}
	
	
	public String getIndex() 
	{
		ArrayList<String> indexes = toStrings();
		
		String delimeter = "";
		for (int i=0; i<indexes.size(); i++)
			if (indexes.get(i).length() > 1)
			{
				delimeter = Const.FileDelimeter;
				break;
			}
		
		String result = null;
		for (int i=0; i<indexes.size(); i++) 
		{
			if (result == null)
				result = index;
			else
				result = indexes.get(i) + delimeter + result;
		}
		return result;
	}

	public String getIndexFileName() 
	{
		ArrayList<String> indexes = toStrings();
		String result = "";
		//percent encoding
		for (int i=0; i<indexes.size(); i++) 
		{
			String index = indexes.get(i);
			if (index.length() == 1)
			{
				if (!(															 // if not
						((index.charAt(0) >= 48) && (index.charAt(0) <= 57)) ||  //numbers
						((index.charAt(0) >= 65) && (index.charAt(0) <= 90)) ||  //eng uppercase
						((index.charAt(0) >= 97) && (index.charAt(0) <= 122))    //eng lowercase
					))
					index = String.format("%02X", index.charAt(0));
			}
			else
			{
				for (int j=0; j<Const.IllegalFileNames.length; j++)
					if (index == Const.IllegalFileNames[j])
						index = index + '1'; //recode
			}
			result = index + Const.FileDelimeter + result;
		}
		return result + Const.NodeFileName;
	}
	
	
}