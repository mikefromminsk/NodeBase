package NodeBase;


import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.RandomAccessFile;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
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

	public static Map<String, String> slice(String string, String delimeter)    
	{
		Map<String, String> result = new HashMap<String, String>();
		String[] strings = string.split(delimeter);
		for (int i=0; i<strings.length; i++)
		{
			String[] var = strings[i].split(Const.sEqual);
			if (var.length == 2)
				result.put(var[0], var[1]);
			else
				result.put(var[0], null);
		}
		return result;
	}

	public static String toFileSystemName(ArrayList<String> indexes) 
	{
		String result = "";
		for (int i=0; i<indexes.size(); i++)
		{
			String index = indexes.get(i);
			if (index.length() == 1)
			{
				if (!(															 // if not
						((index.charAt(0) >= 48) && (index.charAt(0) <= 57)) ||  //numbers
						((index.charAt(0) >= 65) && (index.charAt(0) <= 90)) ||  //eng uppercase
						((index.charAt(0) >= 97) && (index.charAt(0) <= 122))    //eng lowercase
					))
					index = String.format("%02X", index.charAt(0));
			}
			else
			{
				for (int j=0; j<Const.IllegalFileNames.length; j++)
					if (index == Const.IllegalFileNames[j])
						index = index + '1'; //recode
			}
			result = index + "/" + result;
		}
		return null;
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
