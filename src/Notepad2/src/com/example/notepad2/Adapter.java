package com.example.notepad2;

import android.util.SparseBooleanArray;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import java.util.List;

import android.content.Context;
import android.widget.ArrayAdapter;
import android.widget.ImageView;

public class Adapter extends ArrayAdapter<String> {

	Context context;
	LayoutInflater inflater;
	List<String> list;
	private SparseBooleanArray selected;

	public Adapter(Context context, int resourceId, List<String> list) {
		super(context, resourceId, list);
		this.context = context;
		this.list = list;
		selected = new SparseBooleanArray();
		inflater = LayoutInflater.from(context);
	}

	public View getView(int position, View row, ViewGroup parent) {

		if (row == null) 
		{
			row = inflater.inflate(R.layout.listview_item, null);
			TextView textView = (TextView)row.findViewById(R.id.textView);
			textView.setText(getItem(position));
		} 
		return row;
	}
	
	@Override
	public void remove(String object) {
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