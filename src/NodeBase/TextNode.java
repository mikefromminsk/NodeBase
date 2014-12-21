package NodeBase;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import NodeBase.Const;



public class TextNode 
{
	String 				Comment;
	String 				ID;
	TextNode 			Source;
	Map<String, String>	Attr;
	TextNode 			Type;
	ArrayList<TextNode>	Params;
	TextNode 			Value;
	TextNode 			True;
	TextNode 			Else;
	TextNode 			Next;
	ArrayList<TextNode>	Locals;
	

	public TextNode(String string) 
	{
		ID = string;
	}
	
	static String[] ToString(String Str)
	{
		int[] indexes = new int[Const.LinksCount + 1];
		for (int i=0; i<Const.LinksCount; i++)
			indexes[i] = Str.indexOf(Const.LinksSequence[i]);
		
		indexes[indexes.length - 1] = Str.length();

		for (int i=indexes.length - 2; i>=0; i--)
			if (indexes[i] == -1)
				indexes[i] = indexes[i + 1];
			else
				if (indexes[i] > indexes[i + 1])
					indexes[i] = indexes[i + 1];
		
		String[] Result = new String[Const.LinksCount];
		for(int i=0; i<Const.LinksCount; i++)
			if (indexes[i] != indexes[i + 1])
				Result[i] = Str.substring(indexes[i] + Const.LinksSequence[i].length(), indexes[i + 1]);
		
		return Result;
	}
	
	
	//Comment@ID^Source$Name=Val&Name=Val:Type?Name=Val&Name=Val#Value>True|Else\nNext\n\nLocal\n\nLocal2
	TextNode BaseParse()
	{
		Destroy();
		String[] strings = ToString(ID);
		Comment = strings[Const.iComment];
		ID = strings[Const.iID];
		if (strings[Const.iSource] != null)
			Source = new TextNode(strings[Const.iSource]);
		if (strings[Const.iAttr] != null)
			Attr = Utils.slice(strings[Const.iAttr], Const.sAnd);
		if (strings[Const.iType] != null)
			Type = new TextNode(strings[Const.iType]);
		if (strings[Const.iParams] != null)
		{
			Params = new ArrayList<TextNode>();
		    String[] params = strings[Const.iParams].split(Const.sAnd);
		    for (int i=0; i<params.length; i++)
		    	Params.add(new TextNode(params[i]));
		}
		if (strings[Const.iValue] != null)
			Value = new TextNode(strings[Const.iValue]);
		if (strings[Const.iTrue] != null)
			True = new TextNode(strings[Const.iTrue]);
		if (strings[Const.iElse] != null)
			Else = new TextNode(strings[Const.iElse]);
		if (strings[Const.iNext] != null)
			Next = new TextNode(strings[Const.iNext]);
		if (strings[Const.iLocals] != null)
		{
			Locals = new ArrayList<TextNode>();
		    String[] locals = strings[Const.iLocals].split(Const.sLocals);
		    for (int i=0; i<locals.length; i++)
		    	Locals.add(new TextNode(locals[i]));
		}
		return this;
	}
	
	
	
	static int FindCloseTag(String str, char open, char close)
	{
		int level = 0;
		for (int i=0; i<str.length(); i++)
			if ((str.charAt(i) == open) || (str.charAt(i) == close))
			{
				if (str.charAt(i) == open)
					level++;
				if (str.charAt(i) == close)
					level--;
				if (level == 0)
					return i;
			}
		return -1;
	}

	static int Index(String[] substrs, String str)
	{
		int result = -1;
		for (int i=0; i<substrs.length; i++)
		{
			int pos = str.indexOf(substrs[i]);
			if (pos != -1)
				result = (result == -1) ? pos : Math.min(result, pos);
		}
		return result;
	}
	
	void StackOverFlow(String str, TextNode node)
	{
		node.Params = new ArrayList<TextNode>();
		while (!str.isEmpty()) 
		{
			int funcEnd = Index(new String[]{Const.sParams, Const.sAnd} , str);
			if (funcEnd == -1)
			{
				node.Params.add(new TextNode(str).UserParse());
				break;
			}
			else
			{
				node.Params.add(new TextNode(str.substring(0, funcEnd)).UserParse());
				if (str.charAt(funcEnd) == Const.sParams.charAt(0))
				{
					int closePos = FindCloseTag(str, Const.sParams.charAt(0), Const.sParamEnd.charAt(0));
					String ParamsStr = (closePos == -1) ? str : str.substring(funcEnd + 1, closePos);
					StackOverFlow(ParamsStr, node.Params.get(node.Params.size() - 1));
					str = Utils.deleteStr(str, funcEnd, closePos + 1);
				}
				str = Utils.deleteStr(str, 0, funcEnd + 1);
			}			
		}
	}

	TextNode UserParse()
	{
		Destroy();
		//to 
		int posValue = ID.indexOf(Const.sEqual);
		int posParams = ID.indexOf(Const.sParams);
		int posAttr = ID.indexOf(Const.sAttr);
		if (((posAttr == -1) & (posValue != -1) & (posParams == -1)) |
			((posAttr == -1) & (posValue != -1) & (posParams != -1) & (posParams < posParams)))
			ID = ID.replace(Const.sEqual, Const.sValue);
		    
		String[] strings = ToString(ID);
		Comment = strings[Const.iComment];
		ID = strings[Const.iID];
		if (strings[Const.iSource] != null)
			Source = new TextNode(strings[Const.iSource]).UserParse();
		if (strings[Const.iAttr] != null)
			Attr = Utils.slice(strings[Const.iAttr], Const.sAnd);
		if (strings[Const.iType] != null)
			Type = new TextNode(strings[Const.iType]).UserParse();
		if (strings[Const.iParams] != null)
			StackOverFlow(strings[Const.iParams], this);
		if (strings[Const.iValue] != null)
			Value = new TextNode(strings[Const.iValue]).UserParse();
		if (strings[Const.iTrue] != null)
			True = new TextNode(strings[Const.iTrue]).UserParse();
		if (strings[Const.iElse] != null)
			Else = new TextNode(strings[Const.iElse]).UserParse();
		if (strings[Const.iNext] != null)
			Next = new TextNode(strings[Const.iNext]).UserParse();
		if (strings[Const.iLocals] != null)
		{
			Locals = new ArrayList<TextNode>();
		    String[] locals = strings[Const.iLocals].split(Const.sLocals);
		    for (int i=0; i<locals.length; i++)
		    	Locals.add(new TextNode(locals[i]).UserParse());
		}
		return this;
	}

	void Destroy()
	{
		/*TextNode 	Source;
		String[]	Vars;
		TextNode 	Type;
		TextNode[]	Params;
		TextNode 	Value;
		TextNode 	True;
		TextNode 	Else;
		TextNode 	Next;
		TextNode[]	Local;*/
	}
	


}
