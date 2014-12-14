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
	  //ntEmpty   = "EMPTY",
	  ntLoad    = "LOAD",
	  ntRoot    = "ROOT",
	  ntString  = "STRING",
	  ntNumber  = "NUMBER",
	  ntWord    = "WORD",
	  ntModule  = "MODULE",
	  ntDLLFunc = "DLLFUNC";
	  
	final static String 
		sComment   	= "",
		sID 		= "@",
		sSource 	= "^",
		sVars       = "$",
		sType       = ":",
		sParams     = "?",
		sEqual      = "=",
		sAnd        = "&",
		sParamEnd   = ";",
		sValue      = "#",
		sTrue       = ">",
		sElse       = "|",
		sNext       = "\n",
		sLocal      = "\n\n";
	
	
	static String 
		CharSequence[] = {sComment, sID, sSource, sVars, sType, sParams, sValue, sTrue, sElse, sNext, sLocal};
	
	static int CharCount = CharSequence.length;
	

	final static Integer 
		iComment = 0,
		iID      = 1,
		iSource  = 2,
		iVars    = 3,
		iType    = 4,
		iParams  = 5,
		iValue   = 6,
		iTrue    = 7,
		iElse    = 8,
		iNext    = 9,
		iLocal   = 10;
	
	public final static String 
	  	sFile 		= "/",
	  	sData 		= "!",
	  	sDecimalSeparator = ",";
	
	//File Names
	public final static String 
	  RootFileName = "root.ini",
	  NodeFileExtention = ".node",
	  NodeFileName = "Node" + NodeFileExtention/*,
	  ExternalModuleExtention = ".dll"*/;
	
	

	static String EscapedStrings[] = {"/", "\\", ":", "*", "?", "@", "\"", "<", ">", "|", "con"};
						

}
