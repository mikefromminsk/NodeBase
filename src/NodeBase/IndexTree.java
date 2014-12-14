package NodeBase;

import java.util.ArrayList;

public class IndexTree
{
	String IndexName;
	IndexTree parent;
	ArrayList<IndexTree> Childs = new ArrayList<IndexTree>();

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
			for (int j=0; j<indexNode.Childs.size(); i++)
				if (indexNode.Childs.get(j).IndexName == indexes[i])
				{
					subIndexPos = j;
					break;
				}
			if (subIndexPos == -1)
			{
				indexNode.Childs.add(new IndexTree());
				indexNode.Childs.get(indexNode.Childs.size() - 1).parent = indexNode;
				indexNode = indexNode.Childs.get(indexNode.Childs.size() - 1);
				indexNode.IndexName = indexes[i];
			}
			else
				indexNode = indexNode.Childs.get(subIndexPos);
		}
		if (indexNode.node == null)
			indexNode.node = new Node(indexNode);
		return indexNode.node;
	}
	
	
	Node node;
}