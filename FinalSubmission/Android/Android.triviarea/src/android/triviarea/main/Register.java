package android.triviarea.main;

import android.app.Activity;
import android.os.Bundle;
import android.triviarea.data.User;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

public class Register extends Activity
{
	private Button submit;
	private EditText usernameText;
	private EditText passwordText;
	private EditText emailText;
	private User user;
	private static String success;
	private static String fail_at_server;	
	private static final String TAG = "Register";
	
	/** Called when the activity is first created. */
	@Override
	protected void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);
		Log.v(TAG, "Starting register screen");
		if(success == null || fail_at_server == null)
		{
			success = getResources().getString(R.string.register_success);
			fail_at_server = getResources().getString(R.string.register_fail_at_server);
		}
		setContentView(R.layout.registerscreen);
		user = User.getInstance();
		submit = (Button) findViewById(R.id.Regsiter_Submit_button);
		usernameText = (EditText) findViewById(R.id.Register_Username_EditText);
		passwordText = (EditText) findViewById(R.id.Register_Password_EditText);
		emailText = (EditText) findViewById(R.id.Register_Email_EditText);
		Log.v(TAG, "Waiting submit");
		submit.setOnClickListener(new View.OnClickListener()
		{
			public void onClick(View v)
			{
				Log.v(TAG, "submit clicked");
				String toastMessage = new String();
				String username = usernameText.getText().toString();
				String password = passwordText.getText().toString();
				String email = emailText.getText().toString();
				//make sure input is valid
				if(!user.validateUsername(username))
					toastMessage += "Invalid Username\n";
				if(!user.validatePassword(password))
					toastMessage += "Invalid Password\n";
				if(!user.validateEmail(email))
					toastMessage += "Invalid Email";
				if(toastMessage.length() == 0)
				{
					Log.v(TAG, "trying to register");
					String tempUsername = user.getUsername();
					String tempPassword = user.getPassword();
					String tempEmail = user.getEmail();
					user.setUsername(username);
					user.setPassword(password);
					user.setEmail(email);
					if(user.register(Register.this))
					{					
						Toast.makeText(Register.this, success, Toast.LENGTH_LONG);
						Register.this.finish();
					}
					else
					{
						Log.v(TAG, "register not successful");
						user.setEmail(tempEmail);
						user.setPassword(tempPassword);
						user.setUsername(tempUsername);
						Toast.makeText(Register.this, fail_at_server, Toast.LENGTH_LONG)
						.show();		
					}
				}
				else
				{
					Log.v(TAG, "input error by user");
    				Toast.makeText(Register.this, toastMessage, Toast.LENGTH_LONG)
    								.show();
				}
			}
		});
	}
}
