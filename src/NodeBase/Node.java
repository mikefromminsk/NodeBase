package NodeBase;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;




class Link
{
	public Node parent;
	public Node node;
	public ArrayList<Node> nodes;
	
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
		}
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
	IndexTree Index;
	
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
	
	Node(IndexTree index)
	{
		this.Index = index;
	}
	
	/*public void setIndex(IndexTree index) {
		Index = index;
	}*/
	
	public String getIndex() {
		return null;
	}
	
	public String getAttr(String key) {
		if (Attr == null)
			return null;
		return Attr.get(key);
	}
	
	public void setAttr(String key, String value) {
		if (Attr == null)
			Attr = new HashMap<String, String>();
		Attr.put(key, value);
	}


	public String getNodeType() {
		return getAttr(Const.naType);
	}
	
	public void setNodeType(String type) {
		setAttr(Const.naType, type);
	}
	
	public Link getComment() {
		return Comment;
	}
	
	public void setComment(Link comment) {
		Comment = comment;
	}

	public Node getSource() {
		return Source.node;
	}
	
	public void setSource(Node node) {
		Source.node = node;
	}
	
	public Node getType() {
		return Type.node;
	}
	
	public void setType(Node node) {
		Type.node = node;
	}
	
	public Node getParam() {
		return Params.node;
	}
	
	public void setParam(Node params) {
		Params.node = params;
	}
	
	public Node getValue() {
		return Value.node;
	}
	
	public void setValue(Node node) {
		Value.node = node;
	}
	
	public String getData() {
		return Data;
	}
	
	public void setData(String data) {
		Data = data;
	}
	
	public Node getTrue() {
		return True.node;
	}
	
	public void setTrue(Node node) {
		True.node = node;
	}
	
	public Node getElse() {
		return Else.node;
	}
	
	public void setElse(Node node) {
		Else.node = node;
	}
	
	public Node getNext() {
		return Next.node;
	}
	
	public void setNext(Node next) {
		Next.node = next;
		if (next != null)
			next.Next.parent = this;
	}
	
	/*public Link getLocals() {
		return Locals;
	}*/

	public void setLocal(Node local) {
		if (Locals.nodes.indexOf(local) != -1)
			Locals.nodes.add(local);
	}

	public String getBody() 
	{
		String result = null;

		if (Comment != null)
			result += Const.sComment + Comment.node.getIndex();
		if (Source != null)
			result += Const.sSource + Source.node.getIndex();
		
		if (Attr != null)
		{
			String str = null;
			for (Map.Entry entry: Attr.entrySet()) { 
				if (str != null)
					str += Const.sAnd;
				str += (String) entry.getKey() + Const.sEqual + (String) entry.getValue();
			} 
			result += Const.sAttr + str;
		}
		if (Type != null)
			result += Const.sType + Type.node.getIndex();
		if (Params != null)
		{
			String str = null;
			for (int i=0; i<Params.nodes.size(); i++)
			{
				if (str != null)
					str += Const.sAnd;
				str += Params.nodes.get(i).getIndex();
			}
			result += Const.sParams + str;
		}
		if (Value != null)
			result += Const.sValue + Value.node.getIndex();
		if (True != null)
			result += Const.sTrue + True.node.getIndex();
		if (Else != null)
			result += Const.sElse + Else.node.getIndex();
		if (Next != null)
			result += Const.sNext + Next.node.getIndex();
		if (Locals != null)
			for (int i=0; i<Locals.nodes.size(); i++)
				result += Const.sLocals + Locals.nodes.get(i).getIndex();
		return result;
	}

}
