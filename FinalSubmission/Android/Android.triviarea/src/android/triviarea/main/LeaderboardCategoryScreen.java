package android.triviarea.main;

import android.app.ListActivity;
import android.content.Intent;
import android.os.Bundle;
import android.triviarea.data.GameSession;
import android.triviarea.data.User;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.AdapterView.OnItemClickListener;

/**
 * 
 * @author Sam, Neeraj, Chad
 *
 */
public class LeaderboardCategoryScreen extends ListActivity {

	private GameSession gameSession;
	private User user;
	
	private String[] categoryList = {"Geography", "History", "Literature", "Movies", "Music",
									 "Science & Technology", "Sports", "Television", "Video Games"};
	
	/** Called when the activity is first created. */
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.categories);

		gameSession = GameSession.getInstance();
		user = User.getInstance();

		setListAdapter(new ArrayAdapter<String>(this, android.R.layout.simple_list_item_1, categoryList));
		ListView lv = getListView();
		
		Bundle extras = getIntent().getExtras();
		final String type = extras.getString("Type");
		
		if (type.equals("Friends"))
			user.requestFriendsScores();
	
		lv.setOnItemClickListener(new OnItemClickListener() {
			public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
			
				String category = ((TextView) view).getText().toString();
				gameSession.setLeaderboardCategory(category);
				Intent i = new Intent("android.triviarea.main.LeaderboardScreen");
				
				if (type.equals("Global")) {
					if (gameSession.requestLeaderboard(category));
						startActivity(i);
				}
				else if (type.equals("Friends")) {
					gameSession.setLeaderboard(user.getMyFriends(), user.getFriendsScores().get(category));
					startActivity(i);
				}
				
			}
		});
	}
	
}
