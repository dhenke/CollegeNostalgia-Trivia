package android.triviarea.main;

import java.util.ArrayList;
import java.util.List;

import org.apache.http.NameValuePair;
import org.apache.http.message.BasicNameValuePair;

import android.app.Activity;
import android.os.Bundle;
import android.triviarea.data.User;
import android.triviarea.utility.Internet;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

public class ManualPasswordReset extends Activity {

	// Globals
	private Button resetSubmit;
	private EditText oldPass;
	private EditText newPass1;
	private EditText newPass2;
	private String PASSWORD_URL; 


	/** Called when the activity is first created. */
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.manualpasswordreset);
		PASSWORD_URL = getResources().getString(R.string.password_change_url);
		
        oldPass = (EditText) findViewById(R.id.manualresetoldpass);
        newPass1 = (EditText) findViewById(R.id.manualresetpass1);
        newPass2 = (EditText) findViewById(R.id.manualresetpass2);		

		resetSubmit = (Button) findViewById(R.id.manualresetbutton);
		resetSubmit.setOnClickListener(new View.OnClickListener() {
			public void onClick(View view) {
				
				if(newPass1.getText().toString().equals(newPass2.getText().toString()))
					resetPassword();
				else{
    				CharSequence message = "Passwords do not match";
    				Toast.makeText(ManualPasswordReset.this, message, Toast.LENGTH_LONG)
    								.show();
				}
			}
		});
	}

	/**
	 * resets users password if they provide swell information. You dig?
	 */
	private void resetPassword() {
		try {
			User user = User.getInstance();
			List<NameValuePair> params = new ArrayList<NameValuePair>();			
			params.add(new BasicNameValuePair("request", "change"));			
			params.add(new BasicNameValuePair("userID", user.getUserID()));
			String oldPassword = oldPass.getText().toString();
			params.add(new BasicNameValuePair("password", Internet.convertToMD5(oldPassword)));
			String newPassword = newPass1.getText().toString();
			params.add(new BasicNameValuePair("newPassword", Internet.convertToMD5(newPassword)));
			String response = Internet.Post(PASSWORD_URL, params);
			Toast.makeText(ManualPasswordReset.this, response, Toast.LENGTH_LONG)
							.show();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
