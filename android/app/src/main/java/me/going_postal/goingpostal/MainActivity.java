package me.going_postal.goingpostal;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import org.json.JSONException;
import org.json.JSONObject;

import me.going_postal.goingpostal.rest.BasicResponse;
import me.going_postal.goingpostal.rest.Client;

public class MainActivity extends Activity {
  private static final String TAG = MainActivity.class.getName();
  private EditText edUsername;
  private EditText edPassword;

  class LoginTask extends AsyncTask<Void, Void, BasicResponse> {
    private String username;
    private String password;
    private ProgressDialog progressDialog;

    public LoginTask(String username, String password) {
      this.username = username;
      this.password = password;
      progressDialog = new ProgressDialog(getContext(), ProgressDialog.THEME_HOLO_LIGHT);
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
      return Client.getInstance().login(username, password);
    }

    @Override
    protected void onPostExecute(BasicResponse response) {
      if (response.connectionError) {
        Toast.makeText(getContext(), "Unable to connect ot the server. Please make sure your internet connection is working.", Toast.LENGTH_LONG).show();
      } else if (response.statusCode == 204) {
        Toast.makeText(getContext(), "Woohoo!", Toast.LENGTH_SHORT).show();
      } else {
        try {
          JSONObject test = new JSONObject(response.body);
          Toast.makeText(getContext(), test.getString("error"), Toast.LENGTH_LONG).show();
        } catch (NullPointerException | JSONException e) {
          Toast.makeText(getContext(), "Unexpected server error has occurred. Please try again later.", Toast.LENGTH_LONG).show();
          Log.e(TAG, "", e);
        }
      }
      progressDialog.dismiss();
    }

    private Context getContext() {
      return MainActivity.this;
    }
  }

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_main);

    edUsername = (EditText) findViewById(R.id.et_username);
    edPassword = (EditText) findViewById(R.id.et_password);
    Button btnLogin = (Button) findViewById(R.id.btn_login);

    btnLogin.setOnClickListener(new View.OnClickListener() {
      @Override
      public void onClick(View v) {
        final String username = edUsername.getText().toString().trim();
        final String password = edPassword.getText().toString().trim();

        if ("".equals(username)) {
          Toast.makeText(MainActivity.this, "Username can not be empty.", Toast.LENGTH_SHORT).show();
          return;
        }
        if ("".equals(password)) {
          Toast.makeText(MainActivity.this, "Password can not be empty.", Toast.LENGTH_SHORT).show();
          return;
        }

        new LoginTask(username, password).execute();
      }
    });
  }
}
