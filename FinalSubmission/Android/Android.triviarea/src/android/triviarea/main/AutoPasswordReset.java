package android.triviarea.main;

import java.util.ArrayList;
import java.util.List;

import org.apache.http.NameValuePair;
import org.apache.http.message.BasicNameValuePair;

import android.app.Activity;
import android.os.Bundle;
import android.triviarea.utility.Internet;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

public class AutoPasswordReset extends Activity {

	//Globals
	private Button resetSubmit;
	private EditText username;
	private EditText email;
	
	private static String PASSWORD_URL;


	/** Called when the activity is first created. */
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.autopasswordreset);
		PASSWORD_URL = getResources().getString(R.string.password_change_url);

        username = (EditText) findViewById(R.id.autoresetusername);
        email = (EditText) findViewById(R.id.autoresetemail);
		resetSubmit = (Button) findViewById(R.id.autoresetbutton);
		
		resetSubmit.setOnClickListener(new View.OnClickListener() {
			public void onClick(View view) {				
				resetPassword();
			}
		});
	}
	
	/**
	 * resets users password if they provide swell information. Mails it to their 
	 * brick and mortar address, digitally.
	 */
	private void resetPassword() {
		try {

			List<NameValuePair> params = new ArrayList<NameValuePair>();
			
			params.add(new BasicNameValuePair("request", "reset"));
			
			params.add(new BasicNameValuePair("username", username.getText().toString()));
			
			params.add(new BasicNameValuePair("email", email.getText().toString()));

			String response = Internet.Post(PASSWORD_URL, params);
			
			Toast.makeText(AutoPasswordReset.this, response, Toast.LENGTH_LONG)
							.show();

		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
