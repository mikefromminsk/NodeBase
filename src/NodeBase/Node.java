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
	IndexTree Index;
	
	String Path;
	String Data;
	Map<String, String>	Attr;
	private Link 
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
	}
	
	/*public Link getLocals() {
		return Locals;
	}*/

	public void setLocal(Node local) {
		if (Locals.nodes.indexOf(local) != -1)
			Locals.nodes.add(local);
	}

}
