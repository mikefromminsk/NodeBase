package NodeBase;

import java.io.File;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

public class Tests {
	
	
	
	public static void main(String[] args) throws Exception 
	{
		{
			Kernel kernel = new Kernel();
			kernel.loadModule(null);
			kernel.call(null);
		}
		{
			beginTest("loadModule");
			Kernel kernel = new Kernel();
			kernel.loadModule(null);
			kernel.call(null);
			testError();
		}
		/*System.out.println( String.format("%02X",255));
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
	
	static String testName = null;
	static int success = 0;
	static int errors = 0;
	
	private static void beginTest(String string) {
		if (testName != null)
			success++;
		testName = string;
	}
	
	private static void testError() {
		System.out.println(testName + " не работает");
		errors++;
		testName = null;
	}

	private static void endTesting() {
		if (testName != null)
			success++;
		//System.out.println("ошибок " + Integer.toString(errors) + " успешно " + Integer.toString(success));
	}

	
}
