package com.example.notepad;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;

import android.content.Context;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;


public class MetaAdapter extends ArrayAdapter {
	Context context;
	
	public MetaAdapter(Context context, int resource) {
		super(context, resource);
		this.context = context;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		return super.getView(position, convertView, parent);
	}

	final String FileName = "file";
	  
	  void writeFile() {
		  
	
			try 
			{
				FileWriter file = new FileWriter(FileName);
				file.write("123"); 
				file.close();
				
			} catch (IOException e) 
			{
				e.printStackTrace();
			}  

		 
		  }

		  void readFile() 
		  {
		    try 
		    {
		    	String str = "";
		    	BufferedReader buf = new BufferedReader(new FileReader(FileName));
		    	while ((str = buf.readLine()) != null) 
		    	{
			        Log.d("Adapter", str); 
		    	}
		    	buf.close();
			} 
		    catch (IOException e) 
		    {
			      e.printStackTrace();
			}
			    
		      
		  }

}
