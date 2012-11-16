package android.triviarea.main;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.triviarea.data.GameSession;
import android.triviarea.data.User;
import android.triviarea.utility.Internet;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

/**
 * @author Neeraj, Chad, Sam
 */
public class MainActivity extends Activity {
	
	protected static final String TAG = "Main Activity";
	private Button loginButton;
	private Button registerButton;
	private Button forgotPassButton;;
	private EditText userNameText;
	private EditText passwordText;
	private User user;

	@Override
	protected void onRestart()
	{
		super.onRestart();
		main();
	}
	
	@Override
	protected void onResume()
	{
		super.onResume();
		main();
	}
	
	/** Called when the activity is first created. */
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        //initialize static methods and classes
        new Internet();  
        GameSession.setInstance(this);
		user = User.setInstance(this);
        setContentView(R.layout.loginscreen);
        main();
    }
    
	/**
	 * The main function of this class. Sets up all the views and their 
	 * listeners
	 */
	private void main()
	{
		Log.v(TAG, "Started main");
        userNameText = (EditText) findViewById(R.id.Login_User_EditText);
        passwordText = (EditText) findViewById(R.id.Login_Password_EditText);
        if(user.getPassword() != null)
        	passwordText.setText(user.getPassword());
        if(user.getUsername() != null)
        	userNameText.setText(user.getUsername());
        Log.v(TAG, "Setting up login button");
        
		loginButton = (Button) findViewById(R.id.Login_Login_Button);
		setUpLoginButton();
		
        registerButton = (Button) findViewById(R.id.Login_Register_Button);
        setUpRegisterButton();
        
        forgotPassButton = (Button) findViewById(R.id.forgotpassword);
        setUpForgotPasswordButton();
	}

	/**
	 * The register button takes the user to a page to register a new account
	 */
	private void setUpRegisterButton()
	{
		Log.v(TAG, "setting up register button");
        registerButton.setOnClickListener(new View.OnClickListener() {
        	public void onClick(View view) {
        		Log.v(TAG, "register button clicked");
        		Intent i = new Intent("android.triviarea.main.Register");
      		  	startActivity(i);
        	}
        });		
	}
	
	/**
	 * The login button takes the values of the username and password textboxes
	 * and attempt to verify the account is one stored on the server. The user info 
	 * is updated
	 */
	private void setUpLoginButton()
	{
		Log.v(TAG, "setting up login button");
		loginButton.setOnClickListener(new View.OnClickListener() {
        	public void onClick(View view) {
        		Log.v(TAG, "login button clicked");
        		String username = userNameText.getText().toString();
        		String password = passwordText.getText().toString();
        		Log.v(TAG, "Got username and password from text views");

        		if(user.setUsername(username) && user.setPassword(password))
        		{
	           		Log.v(TAG, "Attempting to login");
	       			if(user.login(MainActivity.this))
	       			{
	            		Log.v(TAG, "login successful");	
	    				Intent i = new Intent("android.triviarea.main.MainScreen");
	  		  			startActivity(i);
	        		}
	    			else {
	    				String failMessage = getResources().getString(R.string.login_fail_not_found);
	    				Toast.makeText(MainActivity.this, failMessage, Toast.LENGTH_LONG)
	    								.show();
	    			} 
        		}
        		else {
        			String failMessage = getResources().getString(R.string.login_fail_incorrect_input);
    				Toast.makeText(MainActivity.this, failMessage, Toast.LENGTH_LONG)
    								.show();
        		} 
        	}
        });		
	}
	
	/**
	 * The forgot password button takes the user to a form to reset their password.
	 */
	private void setUpForgotPasswordButton()
	{
		Log.v(TAG, "setting up forgotten password button");
        forgotPassButton.setOnClickListener(new View.OnClickListener() {
        	public void onClick(View view) {
        		Log.v(TAG, "register button clicked");
        		Intent i = new Intent("android.triviarea.main.AutoPasswordReset");
      		  	startActivity(i);
        	}
        });		
	}
}