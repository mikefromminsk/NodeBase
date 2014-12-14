package NodeBase;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;




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
	IndexTree indexNode;
	
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
		this.indexNode = index;
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

	public Link getSource() {
		return Source;
	}
	
	public void setSource(Link source) {
		Source = source;
	}
	
	public Link getType() {
		return Type;
	}
	
	public void setType(Link type) {
		Type = type;
	}
	
	public Link getParams() {
		return Params;
	}
	
	public void setParams(Link params) {
		Params = params;
	}
	
	public Link getValue() {
		return Value;
	}
	
	public void setValue(Link value) {
		Value = value;
	}
	
	public Link getTrue() {
		return True;
	}
	
	public void setTrue(Link true1) {
		True = true1;
	}
	
	public Link getElse() {
		return Else;
	}
	
	public void setElse(Link else1) {
		Else = else1;
	}
	
	public Link getNext() {
		return Next;
	}
	
	public void setNext(Link next) {
		Next = next;
	}
	
	public Link getLocals() {
		return Locals;
	}
	
	public void setLocals(Link locals) {
		Locals = locals;
	}

}
