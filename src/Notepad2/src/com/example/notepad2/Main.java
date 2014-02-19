package com.example.notepad2;

import java.util.ArrayList;
import java.util.List;

import android.os.Bundle;
import android.app.Activity;
import android.util.SparseBooleanArray;
import android.view.ActionMode;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.AbsListView.MultiChoiceModeListener;
import android.widget.ListView;

public class Main extends Activity {

	ListView list;
	Adapter adapter;
	List<String> worldpopulationlist = new ArrayList<String>();
	String[] rank;
	String[] country;
	String[] population;
	int[] flag;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setContentView(R.layout.activity_main);

		for (int i=0;i<10;i++)
			worldpopulationlist.add(Integer.toString(i));
		list = (ListView) findViewById(R.id.listview);

		adapter = new Adapter(this, R.layout.listview_item, worldpopulationlist);

		list.setAdapter(adapter);
		list.setChoiceMode(ListView.CHOICE_MODE_MULTIPLE_MODAL);

		
		list.setMultiChoiceModeListener(new MultiChoiceModeListener() {
			
			@Override
			public void onItemCheckedStateChanged(ActionMode mode,
					int position, long id, boolean checked) {
				final int checkedCount = list.getCheckedItemCount();
				mode.setTitle(checkedCount + " Selected");
				adapter.toggleSelection(position);
			}

			@Override
			public boolean onActionItemClicked(ActionMode mode, MenuItem item) {
				switch (item.getItemId()) {
				case R.id.action_settings:

					SparseBooleanArray selected = adapter
							.getSelectedIds();

					for (int i = (selected.size() - 1); i >= 0; i--) {
						if (selected.valueAt(i)) {
							String selecteditem = adapter.getItem(selected.keyAt(i));
							adapter.remove(selecteditem);
						}
					}
					mode.finish();
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
}
