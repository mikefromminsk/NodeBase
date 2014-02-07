package com.example.notepad;

import java.io.IOException;

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
				    HttpClient client = new DefaultHttpClient();  
				    HttpGet get = new HttpGet("http://178.124.178.151/1/test.txt");
				    HttpResponse responseGet = client.execute(get);  
				    HttpEntity resEntityGet = responseGet.getEntity();  
				    if (resEntityGet != null) 
				    {  
				        String response = EntityUtils.toString(resEntityGet);
				        Toast.makeText(getApplication(), "Запрос выполнен", Toast.LENGTH_SHORT).show(); 
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
