package NodeBase;


class Const 
{
	public final static String 
		sID 		= "@",
		sSource 	= "^",
		sVars       = "$",
		sType       = ":",
		sParams     = "?",
		sVal        = "=",
		sAnd        = "&",
		sParamEnd   = ";",
		sValue      = "#",
		sTrue       = ">",
		sElse       = "|",
		sNext       = "\n",
		sLocal      = "\n\n";
	
	
	static String 
		CharSequence[] = {sID, sSource, sVars, sType, sParams, sValue, sTrue, sElse, sNext, sLocal};
	
	static int CharCount = CharSequence.length;
	

	public final static Integer 
		iName    = 0,
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
}


public class Utils 
{
	
}
