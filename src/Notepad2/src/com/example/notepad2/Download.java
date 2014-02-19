package com.example.notepad2;

import java.io.IOException;
import java.net.URLDecoder;

import android.content.Context;
import android.os.AsyncTask;
import android.widget.TextView;
import android.widget.Toast;

class Download extends AsyncTask<Object, Void, Void>{
	
	Node node;
	TextView textView;
	Context context;

    @Override
    protected Void doInBackground(Object... params) {   

    	try {
        	
        	node = (Node)params[0];
        	textView = (TextView)params[1];
        	context = (Context)params[2];
        	node.loadNode();
        	
    	} catch (IOException e) {
			Toast.makeText(context, "Error " + e.getMessage(), Toast.LENGTH_LONG).show();
		}
		return null;
    }
    
	@Override
	protected void onPostExecute(Void result) {
		super.onPostExecute(result);
		try {
			if (textView != null)
				textView.setText(URLDecoder.decode(node.value.getName(), "Windows-1251").replace('\n', ' '));
			
		}catch (IOException e){
			Toast.makeText(context, "Error " + e.getMessage(), Toast.LENGTH_LONG).show();
		}
	}

}