package com.example.notepad2;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.net.URLEncoder;

import android.os.Bundle;
import android.os.Environment;
import android.os.StrictMode;
import android.app.Activity;
import android.content.Intent;
import android.util.Log;
import android.util.SparseBooleanArray;
import android.view.ActionMode;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.AbsListView.MultiChoiceModeListener;
import android.widget.Button;
import android.widget.ListView;
import android.widget.Toast;

public class Main extends Activity {

	ListView List;
	Adapter adapter;
	Node root;

	File rootDir = new File(Environment.getExternalStorageDirectory(), "meta");
	

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setContentView(R.layout.main);

		
		rootDir.mkdirs(); 
		
		try
		{
			String host = "http://178.124.178.151/";
			String rootNode = "@101";

			/*File params = new File(rootDir, "params.ini");
			
			if (params.exists())
			{
				BufferedReader buf = new BufferedReader(new FileReader(params));
				host = buf.readLine();
				rootNode = buf.readLine();
				buf.close();
			}*/
			
			StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();

			StrictMode.setThreadPolicy(policy); 
			
			root = new Node(host, rootNode);
			
			root.loadNode();
			
			/*
			FileWriter file = new FileWriter(params);
			file.write(root.host + "\n");
			file.write(root.getName() + "\n");
			file.flush();
			file.close();*/
		
			
			Button button = (Button)findViewById(R.id.AddButton);
			button.setOnClickListener(new View.OnClickListener() {
				
				@Override
				public void onClick(View arg0){
				    Intent intent = new Intent(Main.this, Edit.class);
				    intent.putExtra("data", "");
				    startActivityForResult(intent, 0);
				}
			});	
			
			List = (ListView) findViewById(R.id.listview);
	
			adapter = new Adapter(this, R.layout.listview_item, root.local);
	
			List.setAdapter(adapter);
			List.setChoiceMode(ListView.CHOICE_MODE_MULTIPLE_MODAL);
	
			
			List.setMultiChoiceModeListener(new MultiChoiceModeListener() {
				
				@Override
				public void onItemCheckedStateChanged(ActionMode mode,
						int position, long id, boolean checked) {
					final int checkedCount = List.getCheckedItemCount();
					mode.setTitle(checkedCount + " Выделено");
					adapter.toggleSelection(position);
				}
	
				@Override
				public boolean onActionItemClicked(ActionMode mode, MenuItem item) {
					switch (item.getItemId()) {
					case R.id.delete:
						SparseBooleanArray selected = adapter.getSelectedIds();
						for (int i = (selected.size() - 1); i >= 0; i--) {
							if (selected.valueAt(i)) {
								Node selecteditem = adapter.getItem(selected.keyAt(i));
								adapter.remove(selecteditem);
							}
						}
						mode.finish();
						try {
							root.sendNode();
							
						} catch (IOException e) {
							e.printStackTrace();
						}
						return true;
					default:
						return false;
					}
				}
	
				@Override
				public boolean onCreateActionMode(ActionMode mode, Menu menu) {
					mode.getMenuInflater().inflate(R.menu.main, menu);
					return true;
				}
	
				@Override
				public void onDestroyActionMode(ActionMode mode) {
					adapter.removeSelection();
				}
	
				@Override
				public boolean onPrepareActionMode(ActionMode mode, Menu menu) {
					return false;
				}
			});
		}
		catch (IOException e)
		{
			Toast.makeText(getApplication(), "Error " + e.getMessage(), Toast.LENGTH_LONG).show();
		}

		
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
