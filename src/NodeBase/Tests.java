package NodeBase;

import java.io.File;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

public class Tests {
	
	
	
	public static void main(String[] args) throws Exception 
	{

		/*{
			beginTest("indexNode");
			IndexNode node = new IndexNode();
			testingEqual(node.getSubNode("ind1/ind2/ind3").getIndex(), "ind1/ind2/ind3");
			testingEqual(node.getSubNode("ind1/ind2/ind4").getIndex(), "ind1/ind2/ind4");
			testingEqual(node.getSubNode("ab").getIndex(), "ab");
			testingEqual(node.getSubNode("ac").getIndex(), "ac");
			testingEqual(node.getSubNode("a").childs.size(), 2);
		}
		System.out.println( String.format("%02X",255));
		Kernel kernel = new Kernel();
		kernel.NextID();
		
		System.out.println(Utils.LoadFromFile("e:\\aaa.txt"));
		
		
		TextNode node = new TextNode("Comment");
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
		endTesting();
	}
	
	static void testingEqual(String str1, String str2)
	{
		if (str1.compareTo(str2) != 0)
		{
			testError();
			System.out.println(str1 + " != " + str2);
		}
	}
	
	static void testingEqual(int num1, int num2)
	{
		if (num1 != num2)
		{
			testError();
			System.out.println(Integer.toString(num1) + " != " + Integer.toString(num2));
		}
	}
	
	private static void testError(String message)
	{
		testError();
		System.out.println(message);
	}

	static String testName = null;
	static int success = 0;
	static int errors = 0;
	
	private static void beginTest(String string) {
		if (testName != null)
			success++;
		testName = string;
	}
	
	private static void testError() {
		System.out.println(testName);
		errors++;
		testName = null;
	}

	private static void endTesting() {
		if (testName != null)
			success++;
		//System.out.println("ошибок " + Integer.toString(errors) + " успешно " + Integer.toString(success));
	}

	
}
