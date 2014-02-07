package com.example.notepad;

import java.io.IOException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.util.EntityUtils;

import android.os.Bundle;
import android.app.Activity;
import android.util.Log;
import android.view.Menu;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.ListView;
import android.widget.Toast;

public class MainActivity extends Activity {

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);
		
		//Connect
		//Load Options
		//Reg Notepad
		
		
		ListView List = (ListView)findViewById(R.id.listView1);
		String[] arr = {"1", "2", "3", "1", "2", "3", "1", "2", "3", "1", "2", "3", "1", "2", "3", "1", "2", "3", "1", "2", "3", "1", "2", "3", "1", "2", "3", "1", "2", "3", "1", "2", "3", "1", "2", "3"};
		MetaAdapter adapter = new MetaAdapter(this, R.layout.list_item);
		List.setAdapter(adapter);
		
		Button button = (Button)findViewById(R.id.button1);
		button.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View arg0){
				try
				{
					 Pattern p = Pattern.compile("^(.*?)?@(.+?)(\\?(.*?):(.*?)?=(.*?))?(#(.*?))?(\\|(.*?))?$");
					 Matcher m = p.matcher("!hello@3431#!hello");
					 while (m.find()) {
					     String name = m.group(1);
					     Toast.makeText(getApplication(), name, Toast.LENGTH_SHORT).show(); 
					 }
					     	    
				}catch (Exception e)
				{Log.i("GET RESPONSE", "Error " + e.getMessage());}
			}
		});
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.main, menu);
		return true;
	}

}
