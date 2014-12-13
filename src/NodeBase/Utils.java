package NodeBase;

public class Utils 
{
	
	static String deleteStr(String str, int fromindex, int toindex)
	{
		if ((fromindex < toindex) && (fromindex > -1) && (toindex < str.length()))
			return str.substring(0, fromindex) + str.substring(toindex, str.length());
		return str;
	}
	
}
