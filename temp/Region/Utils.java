package brain;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.Map;

public class Utils 
{
	
	static String deleteStr(String str, int fromindex, int toindex)
	{
		if ((fromindex < toindex) && (fromindex > -1) && (toindex < str.length()))
			return str.substring(0, fromindex) + str.substring(toindex, str.length());
		return str;
	}
	
	public static String Inc(String number)
	{
		return Integer.toString((Integer.parseInt(number) + 1));
	}
	
	public static String LoadFromFile(String path)    
	{
		try 
		{
			byte[] encoded = Files.readAllBytes(Paths.get(path));
			return new String(encoded);	
		} 
		catch (IOException  e){
			return null;
		}
	}
	
	public static void SaveToFile(String fileName, String text)
	{
		try {
			PrintWriter out = new PrintWriter(fileName);
			out.print(text);
			out.close();
		} 
		catch (IOException e) {
			e.printStackTrace();
		}
	}

    public static void CreateDir(String directoryName)
    {
        File theDir = new File(directoryName);
        if (!theDir.exists()) {
            try{
                theDir.mkdir();
            }
            catch(SecurityException se){
                //
            }
        }
    }


	public static Map<String, String> slice(String string, String delimeter)    
	{
		Map<String, String> result = new HashMap<String, String>();
		String[] strings = string.split(delimeter);
		for (int i=0; i<strings.length; i++)
		{
			String[] var = strings[i].split("=");
			if (var.length == 2)
				result.put(var[0], var[1]);
			else
				result.put(var[0], null);
		}
		return result;
	}
	
	static String encodeStr(String str)
	{
		String result = null;
		for (int i=0; i<str.length(); i++)
			if (															 // if
					((str.charAt(i) >= 48) && (str.charAt(i) <= 57)) ||  //numbers
					((str.charAt(i) >= 65) && (str.charAt(i) <= 90)) ||  //eng uppercase
					((str.charAt(i) >= 97) && (str.charAt(i) <= 122))    //eng lowercase
				)
				result += "" + str.charAt(i);
			else
				result += "%" + String.format("%02X", str.charAt(i));
		return result;
	}
	
	static String decodeStr(String str)
	{
		String result = null;
		int i=1;
		while (i <= str.length())
		{
			if (str.charAt(i) != '%')
				result += "" + str.charAt(i);
			else
			{
				i++;
				String esc = str.substring(i, i + 2);
				i++;
				int charCode = Integer.parseInt(esc, 16);
				result += (char)charCode;
			}
			i++;
		}
		return result;
	}

	

}
