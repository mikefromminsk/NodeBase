package NodeBase;

public class Tests {
	
	static String deleteStr(String str, int fromindex, int toindex)
	{
		if ((fromindex < toindex) && (fromindex < str.length()) && (toindex < str.length()))
			return str.substring(0, fromindex) + str.substring(toindex, str.length());
		return str;
	}
	
	public static void main(String[] args) 
	{
		/*TextNode node = new TextNode("Comment");
		node.BaseParse();
		System.out.println(node.Comment);
		
		TextNode node = new TextNode("Comment@ID^Source$Names=Values&na=va:Type?Param&Param#Value>True|Else\nNext\n\nLocal\n\nLocal2");
		node.BaseParse();
		System.out.println(node.ID);
	
		
		System.out.println("Utils.Index " + Utils.Index(new String[]{"Foo","Bar","Baz"}, "ssdfdBazfFoosdf")); 
		
		TextNode node2 = new TextNode("Comment@ID^Source$Names=Values:Type?Param&Param#Value>True|Else\nNext\n\nLocal\n\nLocal2");
		node2.UserParse();
		System.out.println(node2.ID);
		
		System.out.println(FindCloseTag("func?par1?par2&par3;&par4", '?', ';'));
		
		System.out.println(deleteStr("1234567890", 4, 5));
		
		
		TextNode node2 = new TextNode("Comment@ID^Source$Names=Values&na=va:Type?par1?par2&par3;&par4#Value>True|Else\nNext\n\nLocal\n\nLocal2");
		node2.UserParse();
		System.out.println(node2.ID);*/
		
	}
	
}
