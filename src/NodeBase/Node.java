package NodeBase;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;




class Link
{
	public Node parent;
	public ArrayList<Node> nodes = new ArrayList<Node>();
	
	Link(Node parent, Node node){
		this.parent = parent;
		add(node);
	}
	
	void add(Node node){
		nodes.add(node);
	}
	
	Node getNode(){
		return nodes.get(0);
	}
	
	Node getNode(int i){
		return nodes.get(i);
	}
}




public class Node
{
	Index index;
	String path;
	Object data;
	Map<String, String>	attr;
	Link[] links = new Link[Const.LinksCount];
	
	Node(Index index)
	{
		setIndex(index);
	}
	
	ArrayList<Node> getLinks(int linkId){
		return links[linkId] != null? links[linkId].nodes : null;
	}
	
	Node getLink(int linkId){
		return links[linkId] != null? links[linkId].getNode() : null;
	}
	
	void setLink(int linkId, int index, Node node){
		if (links[linkId] == null)
			links[linkId] = new Link(this, node);
		links[linkId].nodes.set(0, node);
	}
	
	void setLink(int linkId, Node node){
		setLink(linkId, 0, node);
	}
	
	Node getComment(){
		return getLink(Const.iComment);
	}
	
	void setComment(Node node){
		setLink(Const.iComment, node);
	}

	Node getSource(){
		return getLink(Const.iSource);
	}
	
	void setSource(Node node){
		setLink(Const.iSource, node);
	}
	
	Node getType(){
		return getLink(Const.iType);
	}
	
	void setType(Node node){
		setLink(Const.iType, node);
	}
	
	Node getValue(){
		return getLink(Const.iValue);
	}
	
	void setValue(Node node){
		setLink(Const.iValue, node);
	}
	
	Node getTrue(){
		return getLink(Const.iTrue);
	}
	
	void setTrue(Node node){
		setLink(Const.iTrue, node);
	}
	
	Node getElse(){
		return getLink(Const.iElse);
	}
	
	void setElse(Node node){
		setLink(Const.iElse, node);
	}
	
	Node getNext(){
		return getLink(Const.iNext);
	}
	
	void setNext(Node node){
		setLink(Const.iNext, node);
	}
	
	ArrayList<Node> getParams(){
		return getLinks(Const.iParams);
	}
	
	void setParam(int index, Node node){
		setLink(Const.iParams, index, node);
	}
	
	ArrayList<Node> getLocals(){
		return getLinks(Const.iLocals);
	}
	
	void setLocals(int index, Node node){
		setLink(Const.iLocals, index, node);
	}
	
	public String getAttr(String key) {
		if (attr == null)
			return null;
		return attr.get(key);
	}
	
	void setAttr(String key, String value) {
		if (attr == null)
			attr = new HashMap<String, String>();
		attr.put(key, value);
	}
	
	String getIndex() {
		return index.getIndex();
	}
	
	void setIndex(Index index) {
		this.index = index;
	}
	
	Object getData() {
		return data;
	}
	
	void setData(Object data) {
		this.data = data;
	}
	
	// end getters and setters
	
	public String getNodeType() {
		return getAttr(Const.naType);
	}
	
	public void setNodeType(String type) {
		setAttr(Const.naType, type);
	}
	
	
	/*

	public Node getSource() {
		Node result = this;
		while (result.Source != null)
			result = result.Source.node;
		return result;
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
	
	public void setParam(Node param, int index) {
		if (param.getType() != null)
		{
			param.Source = null;
			Params.nodes.add(param);
		}
		else
		{
			if (index == Params.nodes.size())
				Params.nodes.add(param);
			else
			if (index <= Params.nodes.size())
				if (Params.nodes.get(index) != param)
					Params.nodes.set(index, param);
		}
	}
	
	public Node getValue() {
		ArrayList<Node> valueStack = new ArrayList<Node>();
		Node result = null;
		Node node = this;
		while (node != null)
		{
			valueStack.add(node);
			if (node.Source != null)
				node = node.Source.node;
			else
			{
				result = node;
				if (node.Value != null) break;
				if (valueStack.indexOf(node.Value.node) != -1) break;
				node = node.Value.node;
			}
		}
		valueStack.clear();
		return result;
	}
	
	public void setValue(Node node) {
		Value.node = node;
	}
	
	public Object getData() {
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
	
	public Link getLocals() {
		return Locals;
	}

	public void setLocal(Node local) {
		if (Locals.nodes.indexOf(local) != -1)
			Locals.nodes.add(local);
	}

	public String getBody() 
	{
		String result = null;

		if (Comment != null)
			result += Const.sComment + Comment.node.Index.getIndex();
		if (Source != null)
			result += Const.sSource + Source.node.Index.getIndex();
		
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
			result += Const.sType + Type.node.Index.getIndex();
		if (Params != null)
		{
			String str = null;
			for (int i=0; i<Params.nodes.size(); i++)
			{
				if (str != null)
					str += Const.sAnd;
				str += Params.nodes.get(i).Index.getIndex();
			}
			result += Const.sParams + str;
		}
		if (Value != null)
			result += Const.sValue + Value.node.Index.getIndex();
		if (True != null)
			result += Const.sTrue + True.node.Index.getIndex();
		if (Else != null)
			result += Const.sElse + Else.node.Index.getIndex();
		if (Next != null)
			result += Const.sNext + Next.node.Index.getIndex();
		if (Locals != null)
			for (int i=0; i<Locals.nodes.size(); i++)
				result += Const.sLocals + Locals.nodes.get(i).Index.getIndex();
		return result;
	}
	
	Boolean compare()
	{
		if (getNodeType() == Const.ntNumber)
			if ((Double)Data == 1)
				return true;
		if (getNodeType() == Const.ntString)
			if (((String)Data).isEmpty())
				return true;
		return false;
	}*/

}
