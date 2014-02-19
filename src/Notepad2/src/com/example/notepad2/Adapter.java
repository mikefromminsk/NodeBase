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

	LayoutInflater inflater;
	List<Node> list;
	private SparseBooleanArray selected;

	public Adapter(Context context, int resourceId, List<Node> list) {
		super(context, resourceId, list);
		this.list = list;
		selected = new SparseBooleanArray();
		inflater = LayoutInflater.from(context);
	}

	public View getView(int position, View row, ViewGroup parent) {

		if (row == null) 
		{
			row = inflater.inflate(R.layout.listview_item, null);
			TextView textView = (TextView)row.findViewById(R.id.textView);
			new Download().execute(getItem(position), textView, getContext());
		}
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
	
}