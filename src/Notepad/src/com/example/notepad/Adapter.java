package com.example.notepad;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.UnsupportedEncodingException;
import java.net.URL;
import java.net.URLConnection;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.util.EntityUtils;

import android.content.Context;
import android.graphics.Bitmap;
import android.os.AsyncTask;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;
import android.widget.Toast;


public class Adapter extends ArrayAdapter {
	
	Context context;
	Node root;

	public Adapter(Context context, int resource, Node root) {
		super(context, resource);
		this.context = context;
		this.root = root;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		LayoutInflater inflater = (LayoutInflater)context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		View row = inflater.inflate(R.layout.list_item, parent, false);
		
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

        	textView = (TextView)params[0];
        	node = (Node)params[1];
        	node.loadNode();
			return null;
        }
        
		@Override
		protected void onPostExecute(Void result) {
			super.onPostExecute(result);
			textView.setText(node.id);
			new DownloadValueNode().execute(textView, node.value);
			
		}

    }
	
	class DownloadValueNode extends AsyncTask<Object, Void, Void>{

		TextView textView;
		Node node;

        @Override
        protected Void doInBackground(Object... params) {   

        	textView = (TextView)params[0];
        	node = (Node)params[1];
        	if (node.name != null)
        		if (node.name.charAt(0) != '!')
        			node.loadNode();
			return null;
        }
        
		@Override
		protected void onPostExecute(Void result) {
			super.onPostExecute(result);
			
			try {
				textView.setText(URLDecoder.decode(node.query, "Windows-1251"));
			} catch (UnsupportedEncodingException e) {
				e.printStackTrace();
			}
		}

    }


}
