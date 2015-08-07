package me.going_postal.goingpostal.tasks;

import android.app.Activity;
import android.app.ProgressDialog;
import android.os.AsyncTask;
import android.util.Log;
import android.widget.Toast;

import org.json.JSONException;
import org.json.JSONObject;

import java.net.HttpURLConnection;

import me.going_postal.goingpostal.rest.BasicResponse;
import me.going_postal.goingpostal.rest.ServerClient;

public class AddDeviceTask extends AsyncTask<Void, Void, BasicResponse> {
  private static final String TAG = LoginTask.class.getName();
  private String key;
  private String location;
  private ProgressDialog progressDialog;
  private Activity context;
  private Runnable onSuccess;

  public AddDeviceTask(Activity context, String key, String location, Runnable onSuccess) {
    this.context = context;
    this.key = key;
    this.location = location;
    this.onSuccess = onSuccess;
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
    return ServerClient.getInstance().addDevice(key, location);
  }

  @Override
  protected void onPostExecute(BasicResponse response) {
    progressDialog.dismiss();
    if (response.connectionError) {
      Toast.makeText(context, "Unable to connect ot the server. Please make sure your internet connection is working.", Toast.LENGTH_LONG).show();
      return;
    }
    if (response.statusCode == HttpURLConnection.HTTP_CREATED) {
      Toast.makeText(context, "Device was successfully added to your account.", Toast.LENGTH_LONG).show();
      onSuccess.run();
      return;
    }

    try {
      JSONObject responseJSON = new JSONObject(response.body);
      if (responseJSON.has("key")) {
        Toast.makeText(context, "This device is already linked with an account.", Toast.LENGTH_LONG).show();
        return;
      }
    } catch (NullPointerException | JSONException e) {
      Log.w(TAG, response.body);
      Log.e(TAG, "", e);
    }
    Toast.makeText(context, "Unexpected server error has occurred. Please try again later.", Toast.LENGTH_LONG).show();
  }
}
