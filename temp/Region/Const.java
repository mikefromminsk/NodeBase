package brain;

class Const
{
	//NodeAttribute
	final static String 
	  naType        = "TYPE",
	  naHandle      = "HANDLE",
	  naActivate    = "ACTIVATE",
	  naLastID      = "LASTID",
	  naStartID     = "STARTID",
	  naServerPort  = "SERVERPORT",
	  naRootPath    = "ROOTPATH",
	  naGenerate    = "GENERATE";

	//naType Values
	final static String 
	  ntRoot    = "ROOT",
	  ntString  = "STRING",
	  ntNumber  = "NUMBER",
	  ntComment = "COMMENT",
	  ntFile  	= "FILE",
	  ntExternalFunc = "EXTERNALFUNC";
	
	//Node Status
	final static String 
	  ntLoad    = "LOAD",
	  ntSave    = "SAVE";

	
	public final static String 
	  	sFile 		= "/",
	  	sDecimalSeparator = ",";
	
	//File Names
	public static String
	  NodeFileExtention = ".node",
	  NodeFileName = "Node" + NodeFileExtention,
	  FileDelimeter = "/";
	  
	
	static String IllegalCharacters = "/\\:*?@\"<>|";
	static String IllegalFileNames[] = {"con"};
						

}
