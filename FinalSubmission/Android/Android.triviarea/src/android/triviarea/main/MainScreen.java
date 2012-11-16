package android.triviarea.main;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.triviarea.data.User;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

/**
 * 
 * @author Sam, Neeraj, Chad
 *
 */
public class MainScreen extends Activity {
	
	private Button playGameButton;
	private Button leaderboardButton;
	private Button logoutButton;
	private Button friendsListButton;
	private Button passwordResetButton;
	private User user;
	public Thread t;
		
	/** Called when the activity is first created. */
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.mainscreen);
		
	    user = User.getInstance();
	    TextView usernameView = (TextView) findViewById(R.id.displayuser);
	    usernameView.setText(user.getUsername());
	    
		setUpActionListeners();
	}

	/**
	 *  Set up button listeners
	 */
	private void setUpActionListeners() {
		
		playGameButton = (Button) findViewById(R.id.playgame);
		playGameButton.setOnClickListener(new View.OnClickListener() {
        	public void onClick(View view) {
        		
        		/* Request available Categories to set up next screen. */
    			t = new Thread(){
    				public void run() {
        	    user.requestAvailableCategories();
        	    //user.reinstateCategoryButtons();
    				}
    			};
    			t.start();
    			
        		/* Begin Category Screen Activity */
        		Intent i = new Intent("android.triviarea.main.CategoryScreen");
      		  	startActivity(i);
        	}
        });
		logoutButton = (Button) findViewById(R.id.logoutButton);
		logoutButton.setOnClickListener(new View.OnClickListener()
		{			
			public void onClick(View v)
			{
				MainScreen.this.finish();			
			}
		});
		
		friendsListButton = (Button) findViewById(R.id.main_friends_list_button);
		friendsListButton.setOnClickListener(new View.OnClickListener() {
        	public void onClick(View view) {
        		Intent i = new Intent(MainScreen.this, FriendScreen.class);
        		startActivity(i);
        	}
        });
		
		leaderboardButton = (Button) findViewById(R.id.leaderboards);
		leaderboardButton.setOnClickListener(new View.OnClickListener() {
        	public void onClick(View view) {
        		Intent i = new Intent("android.triviarea.main.LeaderboardCategoryScreen");
        		i.putExtra("Type", "Global");
        		startActivity(i);
        	}
        });
		
		passwordResetButton = (Button) findViewById(R.id.resetbutton);
		passwordResetButton.setOnClickListener(new View.OnClickListener() {
        	public void onClick(View view) {
        		Intent i = new Intent("android.triviarea.main.ManualPasswordReset");
      		startActivity(i);
        	}
        });
		
	}
}
