package brain;

import java.util.ArrayList;

public class IndexTree
{
	String index;
	IndexTree parent;
	ArrayList<IndexTree> childs = new ArrayList<IndexTree>();
    Neuron neuron;

	public IndexTree(String index) {
		this.index = index;
	}

    public IndexTree root(){
        IndexTree root = this;
        while (root.parent != null)
            root = root.parent;
        return root;
    }

	public Neuron getNeuron(String[] indexes)
	{
		if (indexes.length == 1)
		{
			indexes = new String[index.length()];
			for (int i=0; i<index.length(); i++)
				indexes[i] = "" + index.charAt(i);
		}
		
		IndexTree node = this;
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
				node.childs.add(new IndexTree(indexes[i]));
				node.childs.get(node.childs.size() - 1).parent = node;
				node = node.childs.get(node.childs.size() - 1);
			}
			else
				node = node.childs.get(subIndexPos);
		}
        if (node.neuron == null)
            node.neuron = new Neuron(node);
        return node.neuron;
	}
	
	public ArrayList<String> toStrings()
	{
		IndexTree node = this;
		ArrayList<String> result = new ArrayList<String>();
		while (node != null)
		{
			result.add(node.index);
			node = node.parent;
		}
		return result;
	}


	public String toString()
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