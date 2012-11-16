package android.triviarea.utility;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.List;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.protocol.HTTP;
import org.apache.http.util.EntityUtils;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.util.Log;

public class Internet
{
	private static final String TAG = "Internet";
	
	/**
	 * returns a string of the source of a webpage
	 * @param pageURL
	 * @return HTML source
	 */
	public static String getHTMLFromUrl(String pageURL)
	{
		URL url;
		String result = new String();
		try 
		{
			url = new URL(pageURL);
			HttpURLConnection connection = (HttpURLConnection) url.openConnection();
			
			BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()));
			String inputLine;

			while ((inputLine = in.readLine()) != null) {
				result = result.concat(inputLine);				
			}
			in.close();			
		} 
		catch (MalformedURLException e) {
			e.printStackTrace();
		} 
		catch (Exception e) {
			e.printStackTrace();
		}			
		
		if (result.length() == 0) {
			result = "HTTP REQUEST FAILED";
		}
		
		System.out.println(result);
		return result;
	}
	
	/**
	 * Posts to the desired URL and returns the response as a string or null
	 * on failure
	 *
	 * Tutorial used from:
	 * http://www.softwarepassion.com/android-series-get-post-and-multipart-post-requests/
	 * @param postURL
	 * @param params
	 * @return the String result of the post
	 */
	public static String Post(String postURL, List<NameValuePair> params)
	{
		try {
			HttpClient client = new DefaultHttpClient();
			HttpPost post = new HttpPost(postURL);
			UrlEncodedFormEntity ent = new UrlEncodedFormEntity(params,
					HTTP.UTF_8);
			post.setEntity(ent);
			HttpResponse responsePOST = client.execute(post);
			HttpEntity resEntity = responsePOST.getEntity();
			return EntityUtils.toString(resEntity);
			
		} catch (UnsupportedEncodingException e) {
			Log.v(TAG, e.toString());
		} catch (ClientProtocolException e) {
			Log.v(TAG, e.toString());
		} catch (IOException e) {
			Log.v(TAG, e.toString());
		}
		Log.v(TAG, "Error in posting to " + postURL + "params " + params.toString());
		return null;
	}
	
	/**
	 * converts the string into its MD5 equivalent
	 * @param string
	 * @return MD5 equivalent
	 */
	public static String convertToMD5(String string)
	{
		String MD5_string;
		try{
			MessageDigest digest = MessageDigest.getInstance("MD5");
			byte [] bytes = digest.digest(string.getBytes());
			
	        // Create Hex String
	        StringBuffer hexString = new StringBuffer();
	        for (int i=0; i < bytes.length; i++)
	            hexString.append(Integer.toHexString(0xFF & bytes[i]));
	        MD5_string = hexString.toString();
	        
			Log.v(TAG, string + " converted to " + MD5_string);
			return MD5_string;
		} catch (NoSuchAlgorithmException e){e.printStackTrace();}
		return null;
	}
	
	/**
	 * Checks to see if an internet connection is currently available for the system
	 * @return
	 */
	private boolean isNetworkAvailable(Context context) {
	    ConnectivityManager connectivityManager 
	          = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
	    NetworkInfo activeNetworkInfo = connectivityManager.getActiveNetworkInfo();
	    return activeNetworkInfo != null;
	}
}
