package com.example.notepad;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
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
import android.os.Environment;
import android.util.Log;

public class Node {
	
	String host;
	String query;
	File rootDir = new File(Environment.getExternalStorageDirectory(), "meta");
	
	int Timeout = 3000;
	
	public String parent, name, id, parameters, felse;
	
	String next;
	
	Node value;
	
	List<Node> local;
		
	public Node(String host, String query) throws IOException
	{
		this.host = host;
		this.query = query;
		
		local = new ArrayList<Node>();
		
		/*if (query != null)
			if (this.query.charAt(0) == '@')
			{
				id = this.query;
				this.query = "";
				getNode();
			}*/
	}
	
	public String getUrl(){
		return host + getName();
	}
	
	public String getName(){
		if (query == "")
			return id;
		else
			return query;
	}
	
	public void addLocal(String localBody) throws IOException
	{
		local.add(new Node(host, localBody));
	}
	
	public void getNode() throws IOException
	{
		if (id != null)
		{
			File file = new File(rootDir, pathNode()  + "/node.meta");
			if (file.exists())
				setBody(new BufferedInputStream(new FileInputStream(file)));
		}
		//loadNode();
	}
	
	public void loadNode() throws IOException
	{
		URLConnection conn = new URL(getUrl()).openConnection();
		conn.setConnectTimeout(Timeout);
		setBody(conn.getInputStream());
		//saveNode();			
	}
	
	public void saveNode() throws IOException
	{
		if (id != null)
		{
			File dir = new File(rootDir, pathNode());
			dir.mkdirs();
			FileWriter file = new FileWriter(dir.getAbsolutePath() + "/node.meta");
			file.write(getBody());
			file.flush();
			file.close();
		}
		//sendNode();
	}
	

	public void sendNode() throws IOException
	{
		HttpURLConnection conn = (HttpURLConnection)new URL(getUrl()).openConnection();
		conn.setRequestMethod("POST");						
		conn.setDoInput(true);
		conn.setDoOutput(true);
		conn.setConnectTimeout(Timeout);
		
		DataOutputStream output = new DataOutputStream(conn.getOutputStream());
		Log.i("123", "Error"  + getBody());
		output.writeBytes(getBody());
		output.flush();
		output.close();

		setBody(conn.getInputStream());
	}
	
	@SuppressLint("NewApi")
	public void setBody(InputStream body) throws IOException
	{
		BufferedReader buf = new BufferedReader(new InputStreamReader(body));
		Pattern p = Pattern.compile("^((.*?)\\^)?(.*?)?(@(.*?))(\\?(.*?))?(#(.*?))?(\\|(.*?))?$");
		String head = buf.readLine();
		Matcher m = p.matcher(head);
		if (m.find()) 
		{	 
			 parent = m.group(2);
			 name = m.group(3);
			 id = m.group(4);
			 parameters = m.group(7);
			 if (m.group(9) != null)
				 value = new Node(host, m.group(9));
			 felse = m.group(11);
		}
		next = buf.readLine();
		if (next != null)
		{
			local.clear();
			String str = "";
			while ((str = buf.readLine()) != null)
		    	 if (!str.isEmpty())
		    		 addLocal(str);
		}
		buf.close();
		if (id != "")
			query = "";
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
			body += "\n" + local.get(i).getName() + "\n";	
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
	


}
