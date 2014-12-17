package NodeBase;

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
	  
	final static String 
		sComment   	= "",
		sID 		= "@",
		sSource 	= "^",
		sAttr       = "$",
		sType       = ":",
		sParams     = "?",
		sEqual      = "=",
		sAnd        = "&",
		sParamEnd   = ";",
		sValue      = "#",
		sTrue       = ">",
		sElse       = "|",
		sNext       = "\n",
		sLocals     = "\n\n";
	
	
	static String 
		CharSequence[] = {sComment, sID, sSource, sAttr, sType, sParams, sValue, sTrue, sElse, sNext, sLocals};
	
	static int CharCount = CharSequence.length;
	

	final static Integer 
		iComment = 0,
		iID      = 1,
		iSource  = 2,
		iAttr    = 3,
		iType    = 4,
		iParams  = 5,
		iValue   = 6,
		iTrue    = 7,
		iElse    = 8,
		iNext    = 9,
		iLocals  = 10;
	
	public final static String 
	  	sFile 		= "/",
	  	sData 		= "!",
	  	sDecimalSeparator = ",";
	
	//File Names
	public static String 
	  RootFileName = "root.ini",
	  NodeFileExtention = ".node",
	  NodeFileName = "Node" + NodeFileExtention,
	  ExternalModuleExtention = ".java",
	  FileDelimeter = "/";
	  
	
	static String IllegalCharacters = "/\\:*?@\"<>|";
	static String IllegalFileNames[] = {"con"};
						

}
