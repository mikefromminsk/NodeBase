package com.example.notepad2;

import android.os.Bundle;
import android.app.Activity;
import android.content.Intent;
import android.view.Menu;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.EditText;

public class Edit extends Activity {

	@Override
	protected void onStart() {
		
		super.onStart();
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.node_edit);
		getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_VISIBLE);
		
		final EditText edittext = (EditText)findViewById(R.id.editText1);
		edittext.setText(getIntent().getExtras().getString("data"));
        
        Button button = (Button)findViewById(R.id.button2);
        button.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View arg0) 
			{
				Intent intent = new Intent();
				intent.putExtra("result", edittext.getText().toString());
				setResult(RESULT_OK, intent);
				finish();
			}
				
		});
	}

}
