package com.example.notepad;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.UnsupportedEncodingException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLConnection;
import java.net.URLEncoder;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.util.EntityUtils;

import android.os.Bundle;
import android.os.Environment;
import android.annotation.SuppressLint;
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

	
	File rootDir = new File(Environment.getExternalStorageDirectory(), "meta");
	
	Node root;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.notepad);
		
		
		String host = "";
		String rootNode = "";

		try 
		{	
			BufferedReader buf = new BufferedReader(new FileReader(rootDir.getAbsolutePath() + "/params.ini"));
			host = buf.readLine();
			rootNode = buf.readLine();
			root = new Node(host, rootNode);
			root.loadNode();
			buf.close();
			
		}
		catch (IOException e) {
			
			host = "http://178.124.178.151/";
			rootNode = "!hello";
			root = new Node(host, rootNode);
			root.loadNode();
			try 
			{
				FileWriter filewrite = new FileWriter(rootDir.getAbsolutePath() + "/params.ini");
				filewrite.write(root.host + "\n");
				filewrite.write(root.id + "\n");
				filewrite.flush();
				filewrite.close();
			} 
			catch (IOException e1) {
				e1.printStackTrace();
			}
		}

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
	
	@SuppressLint("ShowToast")
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
			catch (UnsupportedEncodingException e) {
				e.printStackTrace();
			}
		}
	}
	
	  



}
