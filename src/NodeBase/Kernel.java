package NodeBase;

	/*
	 *  Autor: Haiduk Michail
	 *  2014
	 */

import java.util.ArrayList;
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
	


	
	
	Node LoadNode(Node node)
	{
		node.setNodeType(Const.ntLoad);
		IndexTree indexNode = node.indexNode;

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
			
		
		return result;
	}
	/*
	
	function TKernel.LoadNode(Node: TNode): TNode;
	var
	  Indexes: AString;
	  Body, Path: String;
	begin
	  if Node = nil then Exit;
	  Node.FType := ntLoad;

	  SetLength(Indexes, 0);
	  while Node <> nil do
	  begin
	    SetLength(Indexes, Length(Indexes) + 1);
	    Indexes[High(Indexes)] := Node.IndexName;
	    Node := Node.ParentIndex;
	  end;
	  Path := ToFileSystemName(Indexes) + NodeFileName;
	  SetLength(Indexes, 0);

	  Body := LoadFromFile(Path);
	  if Body <> '' then
	    NewNode(Body);
	end;*/
	

	Node newNode(TextNode node) 
	{
		Node result = null;
		
		
		if (node.ID != null)
		{
			result = Index(Const.sID + node.ID);
			
			if (result.getNodeType() == null)
				result = LoadNode(result);
		}
		
		
		
		return result;
	}

	
	

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
