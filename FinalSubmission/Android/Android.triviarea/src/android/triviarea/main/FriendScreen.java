package android.triviarea.main;

import java.util.HashSet;

import android.app.AlertDialog;
import android.app.ListActivity;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Handler;
import android.triviarea.data.User;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnFocusChangeListener;
import android.view.inputmethod.InputMethodManager;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.AdapterView.OnItemClickListener;

public class FriendScreen extends ListActivity
{
	private Button deleteButton;
	private Button leaderBoardButton;
	private User user;
	private EditText addFriendEditText;
	private Button addButton;
	private static final String TAG = "FriendScreen";
	private ArrayAdapter<String> adapter;
	private HashSet<String> friendsToBeDeleted;
	private View mainView;
	private ListView listView;
	private static int deleteFriendColor;
	private Handler mHandler;

	/** Called when the activity is first created. */
	@Override
	public void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);
		setContentView(R.layout.friendscreen);
		deleteFriendColor = getResources().getColor(R.color.Orange);
		user = User.getInstance();
		deleteButton = (Button) findViewById(R.id.friend_delete);
		leaderBoardButton = (Button) findViewById(R.id.friend_leaderboard);
		addFriendEditText = (EditText) findViewById(R.id.add_friend_ET);
		addButton = (Button) findViewById(R.id.friend_addfriend_submit);
		mainView = findViewById(R.id.friend_screen_mainlayout);
		adapter = new ArrayAdapter<String>(this,
				android.R.layout.simple_list_item_1, user.getFriends());
		setListAdapter(adapter);
		listView = getListView();
		mHandler = new Handler();
		setUpButtons();

	}

	private void setUpButtons()
	{
		setUpDeleteButton();
		setUpListView();
		setUpAddFriend();
		setUpLeaderBoardButton();
	}

	private void setUpLeaderBoardButton()
	{
		leaderBoardButton.setOnClickListener(new OnClickListener()
		{
			public void onClick(View v)
			{
				Intent i = new Intent(
						"android.triviarea.main.LeaderboardCategoryScreen");
				i.putExtra("Type", "Friends");
				startActivity(i);
			}
		});
	}

	private void setUpAddFriend()
	{
		addFriendEditText.setOnClickListener(new OnClickListener()
		{
			public void onClick(View v)
			{
				mHandler.post(new Runnable()
				{
					public void run()
					{
						listView.setVisibility(View.GONE);
					}
				});
			}
		});
		// we uses a focus change listener because we have to hide half the
		// screen the list
		// when focused or the keyboard when not
		addFriendEditText.setOnFocusChangeListener(new OnFocusChangeListener()
		{
			public void onFocusChange(View v, boolean hasFocus)
			{
				if (hasFocus)
				{
					mHandler.post(new Runnable()
					{
						public void run()
						{
							listView.setVisibility(View.GONE);
						}
					});
				} else
				{
					mHandler.post(new Runnable()
					{
						public void run()
						{
							// hide keyboard
							InputMethodManager imm = (InputMethodManager) FriendScreen.this
									.getSystemService(Context.INPUT_METHOD_SERVICE);
							imm.hideSoftInputFromWindow(
									mainView.getWindowToken(), 0);
							listView.setVisibility(View.VISIBLE);
						}
					});
				}
			}
		});
		// tries to add a friend to the list, if the friend is added updates the
		// GUI
		addButton.setOnClickListener(new OnClickListener()
		{
			public void onClick(View v)
			{
				mHandler.post(new Runnable()
				{
					public void run()
					{
						addFriendEditText.clearFocus();
						String friendName = addFriendEditText.getText()
								.toString();
						if (friendName != null && friendName.length() != 0)
							if (!user.addFriend(friendName))
							{
								Toast.makeText(FriendScreen.this,
										"friend could not be found or you already added that friend",
										Toast.LENGTH_LONG).show();
							} else
								listView.postInvalidate();
					}
				});
			}
		});
	}
	private void setUpListView()
	{
		friendsToBeDeleted = new HashSet<String>();
		listView.setOnItemClickListener(new OnItemClickListener()
		{
			public void onItemClick(AdapterView<?> parent, View v,
					int position, long id)
			{
				TextView view = (TextView) v;
				String friendName = view.getText().toString();
				if (friendsToBeDeleted.add(friendName))
				{
					view.setBackgroundColor(deleteFriendColor);
				} else
				{
					friendsToBeDeleted.remove(friendName);
					view.setBackgroundColor(Color.BLACK);
				}
			}
		});
	}

	private void setUpDeleteButton()
	{
		deleteButton.setOnClickListener(new OnClickListener()
		{
			public void onClick(View v)
			{
				if (friendsToBeDeleted.size() == 0)
				{
					mHandler.post(new Runnable()
					{
						public void run()
						{
							Log.v(TAG, "makng toast");
							Toast.makeText(FriendScreen.this,
									"Click on a friend to delete",
									Toast.LENGTH_LONG).show();
						}
					});
				} else
				{
					mHandler.post(new Runnable()
					{
						public void run()
						{
							// allFriends is just a list of all the friends that
							// are going to be deleted
							String allFriends = new String();
							for (String s : friendsToBeDeleted)
							{
								if (allFriends.length() != 0)
									allFriends += ", ";
								allFriends += s;
							}
							// build dialog asking the user if they're sure
							AlertDialog.Builder builder = new AlertDialog.Builder(
									FriendScreen.this);
							builder.setMessage(
									"Are you sure you want to remove "
											+ allFriends + "?")
									.setCancelable(false)
									.setPositiveButton(
											"Yes",
											new DialogInterface.OnClickListener()
											{
												public void onClick(
														DialogInterface dialog,
														int id)
												{
													user.removeFriends(friendsToBeDeleted);
													friendsToBeDeleted.clear();
													setListAdapter(adapter);
												}
											})
									.setNegativeButton(
											"No",
											new DialogInterface.OnClickListener()
											{
												public void onClick(
														DialogInterface dialog,
														int id)
												{
													dialog.cancel();
												}
											});
							builder.show();
						}
					});

				}
			}
		});
	}

}
