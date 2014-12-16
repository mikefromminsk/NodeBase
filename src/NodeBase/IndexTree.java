package NodeBase;

import java.util.ArrayList;

public class IndexTree
{
	String IndexName;
	IndexTree parent;
	ArrayList<IndexTree> nodes = new ArrayList<IndexTree>();

	Node newSubIndex(String index)
	{

		String[] indexes = index.split("/");
		if (indexes.length == 1)
		{
			indexes = new String[index.length()];
			for (int i=0; i<index.length(); i++)
				indexes[i] = "" + index.charAt(i);
		}
		
		IndexTree indexNode = this;
		for (int i=0; i<indexes.length; i++)
		{
			int subIndexPos = -1;
			for (int j=0; j<indexNode.nodes.size(); i++)
				if (indexNode.nodes.get(j).IndexName == indexes[i])
				{
					subIndexPos = j;
					break;
				}
			if (subIndexPos == -1)
			{
				indexNode.nodes.add(new IndexTree());
				indexNode.nodes.get(indexNode.nodes.size() - 1).parent = indexNode;
				indexNode = indexNode.nodes.get(indexNode.nodes.size() - 1);
				indexNode.IndexName = indexes[i];
			}
			else
				indexNode = indexNode.nodes.get(subIndexPos);
		}
		if (indexNode.node == null)
			indexNode.node = new Node(indexNode);
		return indexNode.node;
	}
	
	public String getIndex() 
	{
		String result = null;
		IndexTree indexNode = this;
		while (indexNode.parent != null)
		{
			result = indexNode.IndexName + result;
			indexNode = indexNode.parent;
		}
		return result;
	}
	
	Node node;
}