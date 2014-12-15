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
	
	String getFileName(Node node)
	{
		IndexTree indexNode = node.Index;
		ArrayList<String> indexes = new ArrayList<String>();
		while (indexNode != null)
		{
			indexes.add(indexNode.IndexName);
			indexNode = indexNode.parent;
		}
		String fileName = root.getAttr(Const.naRootPath) + Utils.toFileSystemName(indexes) + Const.NodeFileName;
		indexes.clear();
		return fileName;
	}
	
	void LoadNode(Node node)
	{
		node.setNodeType(Const.ntLoad); //recode to status
		String body = Utils.LoadFromFile(getFileName(node));
		if (body != null)
			setNode(body);
	}	
	
	void SaveNode(Node node)
	{
		//node.setNodeType(Const.ntSave);
		Utils.SaveToFile(getFileName(node), node.getBody());
	}

	Node newNode(TextNode textNode) 
	{
		Node result = null;
		
		
		if (textNode.ID != null)
		{
			result = rootIndex.newSubIndex(Const.sID + textNode.ID);
			if (result.getNodeType() == null)
				LoadNode(result);
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
				result.setParam(newNode(textNode.Params.get(i)));

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

	private Node nextNode(Node prev, Node next) 
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
	
	void loadModule(Node node)
	{
		String fileName = "C:\\Users\\GaidukMD\\Desktop\\NodeBase\\src\\Module.java";
		if (fileName.indexOf(".java") == fileName.length() - ".java".length())
		{
			try 
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
			  	
			  	Object obj = c.newInstance();

 
			        
			  } catch (ClassNotFoundException e) {
			    e.printStackTrace();
			  } catch (InstantiationException e) {
			    e.printStackTrace();
			  } catch (IllegalAccessException e) {
			    e.printStackTrace();
			  }  catch (SecurityException e) {
				e.printStackTrace();
			  } catch (IllegalArgumentException e) {
				e.printStackTrace();
			  }
		}
		
	}
	
	void call(Node node)
	{
		try
		{
			Object obj = c.newInstance();
			Class[] paramTypes = new Class[] { int.class }; 
			Method method = c.getMethod("run", paramTypes); 
			Object[] params = new Object[] { new Integer(10) }; 
			Object ret = method.invoke(obj, params);
			System.out.print(((Integer)ret).toString());
			
		}catch (InvocationTargetException e) {
			e.printStackTrace();
		  }catch (NoSuchMethodException e) {
			e.printStackTrace();
		  }
	}
	
	void run(Node node)
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
		    	if (compare(node.getValue()))
		    	{
		    		if (node.True != null)
		    		{
		    			node = node.True.node.getSource();
		    			continue;
		    		}
		    	}
		    	else
		    	{
		    		if (node.Else != null)
		    		{
		    			node = node.Else.node.getSource();
		    			continue;
		    		}
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

	Node runNode(String string)
	{
		Node result = newNode(new TextNode(string).UserParse());
		prev = nextNode(prev, result);
		if (result != null)
			if (result.getAttr(Const.naActivate) != null)
				run(result);
		return result;
	}
	
	
	
	
}
