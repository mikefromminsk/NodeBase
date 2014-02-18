package com.example.notepad;


import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;

import android.content.Context;
import android.os.AsyncTask;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnTouchListener;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;
import android.widget.Toast;


public class List extends ArrayAdapter {
	
	Context context;
	View.OnTouchListener mTouchListener;
	Node root;
	

	public List(Context context, int resource, Node root, View.OnTouchListener mTouchListener) {
		super(context, resource);
		this.context = context;
		this.mTouchListener = mTouchListener;
		this.root = root;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		
		LayoutInflater inflater = (LayoutInflater)context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		View row = inflater.inflate(R.layout.list_item, parent, false);
		
        if (row != convertView) 
        {
        	row.setOnTouchListener(mTouchListener);
        }
		TextView textView = (TextView)row.findViewById(R.id.textView1);		
		new DownloadLocalNode().execute(textView, root.local.get(position));
		
		return row;
	}

	@Override
	public int getCount() {
		return root.local.size();
	}
	
	
	class DownloadLocalNode extends AsyncTask<Object, Void, Void>{

		TextView textView;
		Node node;

        @Override
        protected Void doInBackground(Object... params) {   

        	try
        	{
	        	textView = (TextView)params[0];
	        	node = (Node)params[1];
	        	node.loadNode();
        	}
    		catch (IOException e)
    		{
    			Toast.makeText(context, "Error " + e.getMessage(), Toast.LENGTH_LONG).show();
    		}
			return null;
        }
        
		@Override
		protected void onPostExecute(Void result) {
			super.onPostExecute(result);
			try 
			{
				textView.setText(URLDecoder.decode(node.value.getName(), "Windows-1251").replace('\n', ' '));
			} 
			catch (IOException e) 
			{
				Toast.makeText(context, "Error " + e.getMessage(), Toast.LENGTH_LONG).show();
			}
		}

    }



}
