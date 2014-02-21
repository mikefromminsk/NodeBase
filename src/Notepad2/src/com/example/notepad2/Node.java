package com.example.notepad2;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLConnection;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.util.EntityUtils;

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
		
		if (query != null)
			if (this.query.charAt(0) == '@')
			{
				id = this.query;
				this.query = "";
			}
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
	
	public static String DecodeName(String str)
	{
		try {
			return URLDecoder.decode(str, "Windows-1251");
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		return str;
	}
	
	public static String EncodeName(String str)
	{
		try {
			return URLEncoder.encode(str, "Windows-1251");
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		return str;
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
	    HttpClient client = new DefaultHttpClient();
	    HttpGet get = new HttpGet(getUrl());
	    HttpResponse responseGet = client.execute(get);
	    HttpEntity resEntityGet = responseGet.getEntity();
	    if (resEntityGet != null) 
	    	setBody(resEntityGet.getContent());
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
		HttpClient client = new DefaultHttpClient();
		HttpPost post = new HttpPost(getUrl());
		StringEntity entity = new StringEntity(getBody());
		post.setEntity(entity);
	    HttpResponse responseGet = client.execute(post);
	    HttpEntity resEntityGet = responseGet.getEntity();
	    if (resEntityGet != null) 
	    	setBody(resEntityGet.getContent());
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
			body += "\n\n" + local.get(i).getName();	
		return body;
	}
	
	public String pathNode()
	{
		String path = "";
		for (int i=0;i<id.length();i++)
			path += EncodeName(String.valueOf(id.charAt(i))) + File.separator;
		return path;
	}
	


}
