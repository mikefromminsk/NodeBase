package com.example.notepad;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;

import android.os.Bundle;
import android.os.Environment;
import android.app.Activity;
import android.content.Intent;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.ListView;
import android.widget.Toast;

public class Main extends Activity{

	
	File rootDir = new File(Environment.getExternalStorageDirectory(), "meta");
	
	Node root;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.notepad);
		
		rootDir.mkdirs();
		
		try
		{
			String host = "http://178.124.178.151/";
			String rootNode = "!hello";

			File params = new File(rootDir, "params.ini");
			
			if (params.exists())
			{
				BufferedReader buf = new BufferedReader(new FileReader(params));
				host = buf.readLine();
				rootNode = buf.readLine();
				buf.close();
			}
			
			root = new Node(host, rootNode);

			root.loadNode();
			

			FileWriter file = new FileWriter(params);
			file.write(root.host + "\n");
			file.write(root.getName() + "\n");
			file.flush();
			file.close();

			
			

			ListView List = (ListView)findViewById(R.id.listView1);
			List adapter = new List(this, R.layout.list_item, root);
			List.setAdapter(adapter);		
		}
		catch (IOException e)
		{
			Toast.makeText(getApplication(), "Error " + e.getMessage(), Toast.LENGTH_LONG).show();
		}
		
		
		Button button = (Button)findViewById(R.id.button1);
		button.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View arg0){
				    Intent intent = new Intent(Main.this, Edit.class);
				    intent.putExtra("data", "");
				    startActivityForResult(intent, 0);
			}
		});	
		
	}
	

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);

		if (resultCode == RESULT_OK)
		{
			try 
			{
				root.addLocal("!" + URLEncoder.encode(data.getStringExtra("result"), "Windows-1251"));
				root.sendNode();
			}
			catch (IOException e)
			{
				Toast.makeText(getApplication(), "Error " + e.getMessage(), Toast.LENGTH_LONG).show();
			}
		}
	}
	
	  



}
