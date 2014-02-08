package com.example.notepad;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.InputStreamReader;
import java.net.URL;
import java.net.URLConnection;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import android.annotation.SuppressLint;
import android.util.Log;
import android.widget.Toast;

public class MetaNode {
	
	public String parent, name, id, parameters, value, felse, next;
	List<String> local;
	
	@SuppressLint("NewApi")
	public MetaNode(String url)
	{
    	try
    	{
			URLConnection conn = new URL(url).openConnection();
			BufferedReader buf = new BufferedReader(new InputStreamReader(conn.getInputStream()));
			Pattern p = Pattern.compile("^((.*?)\\^)?(.*?)?(@(.*?))(\\?(.*?))?(#(.*?))?(\\|(.*?))?$");
			Matcher m = p.matcher(buf.readLine());
			if (m.find()) 
			{	 
				 parent = m.group(2);
				 name = m.group(3);
				 id = m.group(4);
				 parameters = m.group(7);
				 value = m.group(9);
				 felse = m.group(11);
			}
			next = buf.readLine();
			local = new ArrayList<String>();
			
			if ((next != null) & (next.isEmpty()))
			{
				String str = "";
				while ((str = buf.readLine()) != null)
			    	 if (!str.isEmpty())
				        local.add(str);
			}
			
		}catch (Exception e){
			Log.i("GET RESPONSE", "Error " + e.getMessage());
		}
		
	}

}
