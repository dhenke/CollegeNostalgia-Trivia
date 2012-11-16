/**
 * 
 * @author Sam, Neeraj, Chad
 *
 */

package android.triviarea.main;

import java.util.ArrayList;

import android.app.ListActivity;
import android.content.Intent;
import android.os.Bundle;
import android.triviarea.data.GameSession;
import android.triviarea.data.User;
import android.triviarea.threads.QuestionsThread;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ListAdapter;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.AdapterView.OnItemClickListener;

public class CategoryScreen extends ListActivity {

	private GameSession gameSession;
	private User user;
	private String[] availableCategories;
	
	private ArrayList<String> categoryList = new ArrayList<String>();
	private ListAdapter categoryListAdapter;

	
	/** Called when the activity is first created. */
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.categories);
		
		gameSession = GameSession.getInstance();
		user = User.getInstance();
		availableCategories = user.getAvailableCategories();
		
		categoryList.clear();
		for (int i=0; i<availableCategories.length; i++) {
			System.out.println(availableCategories[i]);
			categoryList.add(availableCategories[i]);
		}
		
		setListAdapter(new ArrayAdapter<String>(this, android.R.layout.simple_list_item_1, categoryList));
		ListView lv = getListView();
		categoryListAdapter = lv.getAdapter();
		
		lv.setOnItemClickListener(new OnItemClickListener() {
			public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
				String category = ((TextView) view).getText().toString();
				//System.out.println(category + "selected.");
				gameSession.setPlayCategory(category);
				fetchCategory();
				Intent i = new Intent("android.triviarea.main.LoadQuestionsScreen");
				startActivity(i);
			}
		});
	}

	
	/** Called when the activity is restarted once its child activity finishes. */
	@Override
	public void onRestart() {
		super.onRestart();

		/* Cancel Loading... Timer */
		LoadQuestionsScreen.loadingTimer.cancel();
		LoadQuestionsScreen.updateLoad.cancel();

		this.finish();
	}

	
	private void fetchCategory() {
		Thread getQuestionsThread = new QuestionsThread();
		getQuestionsThread.start();
	}	
	
}
