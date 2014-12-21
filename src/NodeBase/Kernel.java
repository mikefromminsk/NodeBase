package NodeBase;

	/*
	 *  Autor: Haiduk Michail
	 *  2014
	 */

import java.io.File;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.Map;

public class Kernel
{

	Index rootIndex;
	Node
		root,
		prev,
		unit;
	
	public Kernel() 
	{
		rootIndex = new Index();
		rootIndex.node = new Node(rootIndex);
		root = rootIndex.node;
		root.attr = Utils.slice(Utils.LoadFromFile(Const.RootFileName), "\n");
		if (root.getAttr(Const.naLastID) == null)
			root.setAttr(Const.naLastID, "0");
		root.setNodeType(Const.ntRoot);
	}
	
	String NextID()
	{
		root.setAttr(Const.naLastID, Utils.Inc(Const.naLastID));
		return root.getAttr(Const.naLastID);
	}
	
	void loadNode(Node node)
	{
		node.setNodeType(Const.ntLoad); //recode to status
		String body = Utils.LoadFromFile(root.getAttr(Const.naRootPath) + node.Index.getIndexFileName());
		if (body != null)
			setNode(body);
	}	
	
	void saveNode(Node node)
	{
		//node.setNodeType(Const.ntSave);
		Utils.SaveToFile(root.getAttr(Const.naRootPath) + node.Index.getIndexFileName(), node.getBody());
	}
	
	void saveTree(Index indexTree)
	{
		saveNode(indexTree.node);
		for (int i=0; i<indexTree.childs.size(); i++)
			saveTree(indexTree.childs.get(i));
	}
	

	Node newNode(TextNode textNode) 
	{
		Node result = null;
		
		
		if (textNode.ID != null)
		{
			Index index = rootIndex.getSubNode(Const.sID + textNode.ID);
			
			if (result.getNodeType() == null)
				loadNode(result);
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
				result.setParam(newNode(textNode.Params.get(i)), i);

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

	Node nextNode(Node prev, Node next) 
	{
		Node result; 
		if (prev != null)
			prev.setNext(next);
		else
			if (next != null)
				unit = next;
			else
				unit.setLocal(next);
		return next;
	}
	
	ModuleLoader loader = new ModuleLoader(ClassLoader.getSystemClassLoader());

	Object obj = null; 
	
	void loadModule(Node node) throws Exception
	{
		String fileName = "C:\\Users\\GaidukMD\\Desktop\\NodeBase\\src\\Module.java";
		if (fileName.indexOf(".java") == fileName.length() - ".java".length())
		{

			File moduleFile = new File(fileName);
			loader.pathToDir = moduleFile.getParentFile().getAbsolutePath();
		 	Class c = loader.loadClass(moduleFile.getName().replace(".java", ""));
		 	Method[] methods = c.getDeclaredMethods(); 
		  	for (Method method : methods) 
		  	{ 
		  		System.out.println(method.getName()); 
		    	System.out.println(method.getReturnType().getName()); 
		    	Class[] paramTypes = method.getParameterTypes(); 
		     	for (Class paramType : paramTypes) 
		        	System.out.print(paramType.getName()); 
		  	}
		  	
		  	obj = c.newInstance();
 
			  
		}
		
	}
	
	void call(Node node) throws Exception
	{
		Class c = obj.getClass();
		Class[] paramTypes = new Class[] { int.class }; 
		Method method = null;
		
		method = c.getMethod("run", paramTypes);
		
		Object[] params = new Object[] { new Integer(10) }; 
		Object ret = method.invoke(obj, params);
			
		
			System.out.print(((Integer)ret).toString());
	}
	
	void run(Node node) throws Exception
	{
		while (true)
		{
			if (node.getNodeType() == Const.ntFile)
				loadModule(node); //recode
			for (int i=0; i<node.Params.nodes.size(); i++)
				run(node.Params.nodes.get(i));
		    if ((node.Source != null) && (((node.Source.node.Locals.parent == unit) 
		    		&& (node.Source.node.Next != null)) || (node.Source.node.getNodeType() == Const.ntExternalFunc))) //recode
		    {
		    	for (int i=0; i<node.Params.nodes.size(); i++)
		    		node.getSource().setParam(node.Params.nodes.get(i).getValue(), i);
		    	run(node.Source.node);
		    }
		    if (node.getNodeType() == Const.ntExternalFunc)
		    	call(node);
		    if ((node.True != null) || (node.Else != null))
		    {
		    	if (node.getValue().compare())
		    	{
		    		if (node.True != null)
		    		{
		    			node = node.True.node.getSource();
		    			continue;
		    		}
		    	}
		    	else
		    		if (node.Else != null)
		    		{
		    			node = node.Else.node.getSource();
		    			continue;
		    		}
		    }
		    else
		    if ((node.Source != null) && (node.Value != null))
		    {
		    	run(node.Value.node);
		    	node.Source.node.Value.node = node.Value.node.getValue();
		    }
		    node = node.Next.node;
		}
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

	Node runNode(String string) throws Exception
	{
		Node result = newNode(new TextNode(string).UserParse());
		prev = nextNode(prev, result);
		if (result != null)
			if (result.getAttr(Const.naActivate) != null)
				run(result);
		return result;
	}
	
	
	
	
}
