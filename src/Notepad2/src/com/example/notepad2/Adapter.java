package com.example.notepad2;

import android.os.AsyncTask;
import android.util.SparseBooleanArray;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import java.io.IOException;
import java.net.URLDecoder;
import java.util.List;
import android.content.Context;
import android.widget.ArrayAdapter;
import android.widget.Toast;

public class Adapter extends ArrayAdapter<Node> {


	Context context;
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
			row = inflater.inflate(R.layout.listview_item, null);
		TextView textView = (TextView)row.findViewById(R.id.textView);
		new DownloadLocalNode().execute(textView, getItem(position));
		
		return row;
	}
	
	@Override
	public void remove(Node object) {
		list.remove(object);
		notifyDataSetChanged();
	}

	public void toggleSelection(int position) {
		selectView(position, !selected.get(position));
	}

	public void removeSelection() {
		selected = new SparseBooleanArray();
		notifyDataSetChanged();
	}

	public void selectView(int position, boolean value) {
		if (value) 	selected.put(position, value);
		else 		selected.delete(position);
		notifyDataSetChanged();
	}

	public int getSelectedCount() {
		return selected.size();
	}

	public SparseBooleanArray getSelectedIds() {
		return selected;
	}
	
	
	class DownloadLocalNode extends AsyncTask<Object, Void, Void>{

		TextView textView;
		Node node;

        @Override
        protected Void doInBackground(Object... params) {   

        	try {
	        	textView = (TextView)params[0];
	        	node = (Node)params[1];
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
				textView.setText(URLDecoder.decode(node.value.getName(), "Windows-1251").replace('\n', ' '));
				
			}catch (IOException e){
				Toast.makeText(context, "Error " + e.getMessage(), Toast.LENGTH_LONG).show();
			}
		}

    }
}