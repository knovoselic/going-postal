package me.going_postal.goingpostal.tasks;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.AsyncTask;
import android.util.Log;
import android.widget.Toast;

import org.json.JSONException;
import org.json.JSONObject;

import java.net.HttpURLConnection;

import me.going_postal.goingpostal.MainActivity;
import me.going_postal.goingpostal.rest.BasicResponse;
import me.going_postal.goingpostal.rest.ServerClient;

public class LoginTask extends AsyncTask<Void, Void, BasicResponse> {
  private static final String TAG = LoginTask.class.getName();
  private String username;
  private String password;
  private ProgressDialog progressDialog;
  private Activity context;

  public LoginTask(Activity context, String username, String password) {
    this.context = context;
    this.username = username;
    this.password = password;
    progressDialog = new ProgressDialog(context, ProgressDialog.THEME_HOLO_LIGHT);
    progressDialog.setCancelable(false);
    progressDialog.setIndeterminate(true);
    progressDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
    progressDialog.setMessage("Please wait...");
  }

  @Override
  protected void onPreExecute() {
    progressDialog.show();
  }

  @Override
  protected BasicResponse doInBackground(Void... params) {
    return ServerClient.getInstance().signIn(username, password);
  }

  @Override
  protected void onPostExecute(BasicResponse response) {
    if (response.connectionError) {
      Toast.makeText(context, "Unable to connect ot the server. Please make sure your internet connection is working.", Toast.LENGTH_LONG).show();
    } else if (response.statusCode == HttpURLConnection.HTTP_NO_CONTENT) {
      Intent intent = new Intent(context, MainActivity.class);
      context.startActivity(intent);
      context.finish();
      ServerClient.getInstance().persistSession(context);
    } else {
      try {
        JSONObject test = new JSONObject(response.body);
        Toast.makeText(context, test.getString("error"), Toast.LENGTH_LONG).show();
      } catch (NullPointerException | JSONException e) {
        Toast.makeText(context, "Unexpected server error has occurred. Please try again later.", Toast.LENGTH_LONG).show();
        Log.e(TAG, "", e);
      }
    }
    progressDialog.dismiss();
  }

}
