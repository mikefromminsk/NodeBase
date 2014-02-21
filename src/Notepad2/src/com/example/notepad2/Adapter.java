package com.example.notepad2;

import android.os.AsyncTask;
import android.util.Log;
import android.util.SparseBooleanArray;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.util.List;

import android.content.Context;
import android.content.Intent;
import android.widget.ArrayAdapter;
import android.widget.Toast;
import android.app.Activity;

public class Adapter extends ArrayAdapter<Node> {


	final Context context;
	LayoutInflater inflater;
	List<Node> list;
	private SparseBooleanArray selected;

	public Adapter(Context context, int resourceId, List<Node> list) {
		super(context, resourceId, list);
		this.context = context;
		this.list = list;
		selected = new SparseBooleanArray();
		inflater = LayoutInflater.from(context);
	}

	public View getView(int position, View row, ViewGroup parent) {

		if (row == null) 
			row = inflater.inflate(R.layout.listview_item, parent, false);
		TextView textView = (TextView)row.findViewById(R.id.textView);
		textView.setTag(getItem(position));
		new DownloadLocalNode().execute(row);
		return row;
	}
	
	@Override
	public void remove(Node object) {
		list.remove(object);
		//notifyDataSetChanged();
	}

	public void toggleSelection(int position) {
		selectView(position, !selected.get(position));
	}

	public void removeSelection() {
		selected = new SparseBooleanArray();
		//notifyDataSetChanged();
	}

	public void selectView(int position, boolean value) {
		if (value) 	selected.put(position, value);
		else 		selected.delete(position);
		//notifyDataSetChanged();
	}

	public int getSelectedCount() {
		return selected.size();
	}

	public SparseBooleanArray getSelectedIds() {
		return selected;
	}
	
	
	class DownloadLocalNode extends AsyncTask<Object, Void, Void>{

		@Override
		protected void onPreExecute() {
			// TODO Auto-generated method stub
			super.onPreExecute();
		}

		TextView textView;
		Node node;

        @Override
        protected Void doInBackground(Object... params) {   

        	try {
        		View row = (View)params[0];
        		textView = (TextView)row.findViewById(R.id.textView);
	        	node = (Node)textView.getTag();
	        	
	        	node.loadNode();
	        	
        	} catch (IOException e) {
    			Toast.makeText(context, "Error " + e.getMessage(), Toast.LENGTH_LONG).show();
    		}
			return null;
        }
        
		@Override
		protected void onPostExecute(Void result) {
			super.onPostExecute(result);
			textView.setText(Node.DecodeName(node.value.getName()).replace('\n', ' '));
				
		}

    }
}