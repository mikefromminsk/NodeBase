package com.example.notepad;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.util.Log;
import android.widget.Toast;

public class MetaNode {
	
	String host;
	String query;
	
	public String parent, name, id, parameters, value, felse;
	String next;
	
	List<MetaNode> local;
		
	public MetaNode(String host, String query)
	{
		this.host = host;
		this.query = query;
		
		local = new ArrayList<MetaNode>();
	}
	
	String getURL()
	{
		String url = host;
		if (query == "")
			url	+= id;
		else
			url	+= query;
		return url;
	}
	
	public void loadNode() 
	{
		try 
		{
			URLConnection conn = new URL(getURL()).openConnection();
			setNodeStream(conn.getInputStream());
		} 
		catch (IOException e) {
			e.printStackTrace();
		}
			
	}
	
	@SuppressLint("NewApi")
	public void setNodeStream(InputStream body)
	{
    	try
    	{
			BufferedReader buf = new BufferedReader(new InputStreamReader(body));
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
			
			local.clear();

			if ((next != null) & (next.isEmpty()))
			{
				String str = "";
				while ((str = buf.readLine()) != null)
			    	 if (!str.isEmpty())
			    		 local.add(new MetaNode(host, str));
			}
			buf.close();
			
		}catch (Exception e){
			Log.i("GET RESPONSE", "Error " + e.getMessage());
		}	
	}
	

	public void setNode()
	{
		try
		{
			HttpURLConnection conn = (HttpURLConnection)new URL(getURL()).openConnection();
			conn.setRequestMethod("POST");						
			conn.setDoInput(true);
			conn.setDoOutput(true);
			
			String body = "";
			if (parent != null) 	body = parent + "^";
			if (name != null) 		body += name;
			if (id != null) 		body += id;
			if (parameters != null) body += "?" + parameters;
			if (value != null) 		body += "#" + value;
			if (felse != null) 		body += "|" + felse;
			
			if (next != null) 		body += "\n" + next;
			
			for (int i=0; i<local.size(); i++)
				body += "\n\n" + local.get(i);
			
			DataOutputStream output = new DataOutputStream(conn.getOutputStream());
			output.writeBytes(body);
			output.flush();
			output.close();

			setNodeStream(conn.getInputStream());

		}
		catch (Exception e)
			{Log.i("test", "Error " + e.getMessage());}		
		
	}


}
