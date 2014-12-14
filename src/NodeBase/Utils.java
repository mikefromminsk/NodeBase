package NodeBase;


import java.io.IOException;
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
		catch (IOException  e) 
		{
			return null;
		}
	}
	
	class indexResult{
		int posInString;
		int posInSubStrings;	
		public indexResult(int i, int j) {
			posInString = i;
			posInSubStrings = j;
		}
	}
	
	static indexResult Index(String[] substrs, String str)
	{
		indexResult result = new indexResult(-1, -1);
		for (int i=0; i<substrs.length; i++)
		{
			int pos = str.indexOf(substrs[i]);
			if (pos != -1)
				result.posInString = (result.posInString == -1) ? pos : Math.min(result.posInString, pos);
		}
		return result;
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
		for (int i=0; i<indexes.size(); i++)
		{
			String index = indexes.get(i);
			int pos = Utils.Index
		}
		return null;
	}
	

	
	/*function ToFileSystemName(var Indexes: AString): String;
var          //c:\data\@\1\
  i, j: Integer;
  Index: String;
const
  IllegalCharacters = [#0..#32, '/', '\', ':', '*', '?', '@', '"', '<', '>', '|'];
  IllegalFileNames: array[0..0] of String = ('con') ;
begin
  Result := '';
  for i:=0 to High(Indexes) do
  begin
    Index := Indexes[i];
    if Length(Index) = 1 then
    begin
      if Index[1] in IllegalCharacters then
        Indexes[i] := IntToHex(Ord(Index[1]), 2);
    end
    else
    begin
      for j:=0 to High(IllegalFileNames) do
        if Index = IllegalFileNames[i] then
          Indexes[i] := Indexes[i] + '1';
    end;
    Result := Indexes[i] + '\' + Result;
  end;
end;*/


}
