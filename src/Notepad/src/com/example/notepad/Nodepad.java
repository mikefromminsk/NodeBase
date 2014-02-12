package com.example.notepad;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.DataOutputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLConnection;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.util.EntityUtils;

import android.os.Bundle;
import android.app.ActionBar.Tab;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.res.Configuration;
import android.text.InputType;
import android.util.Log;
import android.view.Menu;
import android.view.View;
import android.view.WindowManager;
import android.view.inputmethod.InputMethodManager;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.Toast;

public class Nodepad extends Activity {

	Node root;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.notepad);
		
		
		root = new Node("http://178.124.178.151/", "!hello");
		root.loadNode();
		
		ListView List = (ListView)findViewById(R.id.listView1);
		Adapter adapter = new Adapter(this, R.layout.list_item, root);
		List.setAdapter(adapter);
		
		Button button = (Button)findViewById(R.id.button1);
		button.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View arg0){
				    Intent intent = new Intent(Nodepad.this, NodeEdit.class);
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
			root.local.add(new Node(root.host, "!" + data.getStringExtra("result")));
		}
	}
	

	final String FileName = "file";
	  
	  void writeFile() throws IOException {
				FileWriter file = new FileWriter(FileName);
				file.write("123"); 
				file.close();
		  }

		  void readFile() throws IOException {
		    	String str = "";
		    	BufferedReader buf = new BufferedReader(new FileReader(FileName));
		    	while ((str = buf.readLine()) != null) 
			        Log.d("Adapter", str); 
		    	buf.close();
		  }


}
