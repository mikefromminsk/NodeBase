package com.example.notepad;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.os.Environment;
import android.util.Log;
import android.widget.Toast;

public class Node {
	
	String host;
	String query;
	File rootDir;
	
	public String parent, name, id, parameters, felse;
	
	String next;
	
	Node value;
	
	List<Node> local;
		
	public Node(String host, String query)
	{
		this.host = host;
		this.query = query;
		
		local = new ArrayList<Node>();
		
		if (query != null)
			if (this.query.charAt(0) == '@')
			{
				id = this.query;
				this.query = "";
				getNode();
			}
	}
	
	public String getUrl()
	{
		return host + getName();
	}
	
	public String getName()
	{
		if (query == "")
			return id;
		else
			return query;
	}
	
	public void getNode()
	{
		if (id != null)
		{
			try 
			{
				File file = new File(rootDir, pathNode());
				InputStream in = new BufferedInputStream(new FileInputStream(file.getAbsolutePath() + "/node.meta"));
				setBody(in);
			} 
			catch (FileNotFoundException e) {
				e.printStackTrace();
			}
		}
	}
	
	public void loadNode() 
	{
		try 
		{
			URLConnection conn = new URL(getUrl()).openConnection();
			setBody(conn.getInputStream());
			if (id != "")
				query = "";
			saveNode();
		} 
		catch (IOException e) {
			e.printStackTrace();
		}
			
	}
	
	public void addLocal(String localBody)
	{
		local.add(new Node(host, localBody));
	}
	
	@SuppressLint("NewApi")
	public void setBody(InputStream body)
	{
    	try
    	{
			BufferedReader buf = new BufferedReader(new InputStreamReader(body));
			Pattern p = Pattern.compile("^((.*?)\\^)?(.*?)?(@(.*?))(\\?(.*?))?(#(.*?))?(\\|(.*?))?$");
			String head = buf.readLine();
			Matcher m = p.matcher(head);
			Log.i("123", "Error 3");
			if (m.find()) 
			{	 
				 parent = m.group(2);
				 name = m.group(3);
				 id = m.group(4);
				 parameters = m.group(7);
				 value = new Node(host, m.group(9));
				 felse = m.group(11);
			}
			Log.i("123", "Error 4");
			next = buf.readLine();
			
			local.clear();

			if ((next != null) & (next.isEmpty()))
			{
				String str = "";
				while ((str = buf.readLine()) != null)
			    	 if (!str.isEmpty())
			    		 addLocal(str);
			}
			buf.close();
		}
    	catch (Exception e){
    		e.printStackTrace();
		}	
	}
	
	public String getBody()
	{
		String body = "";
		if (parent != null) 	body = parent + "^";
		if (name != null) 		body += name;
		if (id != null) 		body += id;
		if (parameters != null) body += "?" + parameters;
		if (value != null) 		body += "#" + value.getName();
		if (felse != null) 		body += "|" + felse;
		
		if (next != null) 		body += "\n" + next;
		
		for (int i=0; i<local.size(); i++)
			body += "\n\n" + local.get(i).getName();	
		return body;
	}
	
	@SuppressWarnings("deprecation")
	public String pathNode()
	{
		String path = "";
		for (int i=0;i<id.length();i++)
			path += URLEncoder.encode(String.valueOf(id.charAt(i))) + File.separator;
		return path;
	}
	
	public void saveNode()
	{
		if (id != null)
		{
			try 
			{	
				File dir = new File(rootDir, pathNode());
				dir.mkdirs();
				FileWriter filewrite = new FileWriter(dir.getAbsolutePath() + "/node.meta");
				filewrite.write(getBody());
				filewrite.flush();
				filewrite.close();
			} 
			catch (IOException e) {
				e.printStackTrace();
			}
		}
	}
	

	public void sendNode()
	{
		try
		{
			HttpURLConnection conn = (HttpURLConnection)new URL(getUrl()).openConnection();
			conn.setRequestMethod("POST");						
			conn.setDoInput(true);
			conn.setDoOutput(true);
			
			DataOutputStream output = new DataOutputStream(conn.getOutputStream());
			output.writeBytes(getBody());
			output.flush();
			output.close();

			setBody(conn.getInputStream());

		}
		catch (Exception e){
			e.printStackTrace();
		}		
		
	}

}
