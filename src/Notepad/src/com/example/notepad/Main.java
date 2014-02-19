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
import android.view.ActionMode;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.AbsListView.MultiChoiceModeListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemLongClickListener;
import android.widget.Button;
import android.widget.ListView;
import android.widget.Toast;

public class Main extends Activity{

	
	File rootDir = new File(Environment.getExternalStorageDirectory(), "meta");
	
	Node root;
	
	  protected Object mActionMode;
	  public int selectedItem = -1;
	  
	private ActionMode.Callback mActionModeCallback = new ActionMode.Callback() {

	    // called when the action mode is created; startActionMode() was called
	    public boolean onCreateActionMode(ActionMode mode, Menu menu) {
	      // Inflate a menu resource providing context menu items
	      MenuInflater inflater = mode.getMenuInflater();
	      // assumes that you have "contexual.xml" menu resources
	      inflater.inflate(R.menu.list_item, menu);
	      return true;
	    }

	    // the following method is called each time 
	    // the action mode is shown. Always called after
	    // onCreateActionMode, but
	    // may be called multiple times if the mode is invalidated.
	    public boolean onPrepareActionMode(ActionMode mode, Menu menu) {
	      return false; // Return false if nothing is done
	    }

	    // called when the user selects a contextual menu item
	    public boolean onActionItemClicked(ActionMode mode, MenuItem item) {
	      switch (item.getItemId()) {
	      case R.id.menuitem1_show:
	        show();
	        // the Action was executed, close the CAB
	        mode.finish();
	        return true;
	      default:
	        return false;
	      }
	    }

	    // called when the user exits the action mode
	    public void onDestroyActionMode(ActionMode mode) {
	      mActionMode = null;
	      selectedItem = -1;
	    }
	  };

	  private void show() {
	    Toast.makeText(Main.this,
	        String.valueOf(selectedItem), Toast.LENGTH_LONG).show();
	  }


	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.notepad);
		
		rootDir.mkdirs();
		
		try
		{
			String host = "http://178.124.178.151/";
			String rootNode = "@101";

			File params = new File(rootDir, "params.ini");
			
			/*if (params.exists())
			{
				BufferedReader buf = new BufferedReader(new FileReader(params));
				host = buf.readLine();
				rootNode = buf.readLine();
				buf.close();
			}*/
			
			root = new Node(host, rootNode);

			root.loadNode();
			

			FileWriter file = new FileWriter(params);
			file.write(root.host + "\n");
			file.write(root.getName() + "\n");
			file.flush();
			file.close();

			
			

			final ListView List = (ListView)findViewById(R.id.listView1);
			List adapter = new List(this, R.layout.list_item, root);
			List.setAdapter(adapter);		
			List.setChoiceMode(ListView.CHOICE_MODE_MULTIPLE);
			List.setOnItemLongClickListener(new OnItemLongClickListener() {

		        @Override
		        public boolean onItemLongClick(AdapterView<?> parent, View view,
		            int position, long id) {

		          if (mActionMode != null) {
		            return false;
		          }
		          selectedItem = position;

		          // start the CAB using the ActionMode.Callback defined above
		          mActionMode = Main.this
		              .startActionMode(mActionModeCallback);
		          view.setSelected(true);
		          return true;
		        }
		      });
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
