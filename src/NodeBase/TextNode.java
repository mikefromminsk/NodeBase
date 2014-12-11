package NodeBase;
import java.util.HashMap;
import java.util.Map;

import NodeBase.Const;



public class TextNode 
{
	String 				Comment;
	String 				ID;
	TextNode 			Source;
	Map<String, String> Vars = new HashMap<String, String>();
	TextNode 			Type;
	TextNode[] 			Params;
	TextNode 			Value;
	TextNode 			True;
	TextNode 			Else;
	TextNode 			Next;
	TextNode[] 			Local;
	
	
	public static void main(String[] args)
	{
		String[] Result = ToString("Comment@ID^Source$Vars?Params#Value|Else");
		System.out.println(Result.length);
	}
	
	public TextNode(String string) 
	{
		ID = string;
	}
	
	static String[] ToString(String Str)
	{
		int Count = Const.CharCount;
		int[] Indexes = new int[Count];
		int NameEnd = 0;
		
		Indexes[Indexes.length - 1] = Str.length() + 1;
		
		for (int i=0; i<Count; i++)
			Indexes[i] = Str.indexOf(Const.CharSequence[i]);
		
		for (int i=0; i<Count; i++) 
			if (Indexes[i] != -1)
			{
				NameEnd = i;
				break;
			}

		for (int i=0; i<Count-1; i++)
			if (Indexes[i] == -1)
				Indexes[i] = Indexes[i + 1];
			else
				if (Indexes[i] > Indexes[i + 1])
					Indexes[i] = Indexes[i + 1];
		
		String[] Result = new String[Count];
		Result[0] = Str.substring(1, Indexes[NameEnd] - Const.CharSequence[NameEnd].length());
		
		for(int i=0; i<Count; i++)
			Result[i] = Str.substring(Indexes[i] + Const.CharSequence[i].length(), Indexes[i + 1] - (Indexes[i] + Const.CharSequence[i].length()));
		
		return Result;
	}
	
	

}
