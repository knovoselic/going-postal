package me.going_postal.goingpostal;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import me.going_postal.goingpostal.tasks.LoginTask;

public class SignInActivity extends Activity {
  private EditText edUsername;
  private EditText edPassword;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_sign_in);

    edUsername = (EditText) findViewById(R.id.et_username);
    edPassword = (EditText) findViewById(R.id.et_password);
    Button btnLogin = (Button) findViewById(R.id.btn_login);

    btnLogin.setOnClickListener(new View.OnClickListener() {
      @Override
      public void onClick(View v) {
        final String username = edUsername.getText().toString().trim();
        final String password = edPassword.getText().toString().trim();

        if ("".equals(username)) {
          Toast.makeText(SignInActivity.this, "Username can not be empty.", Toast.LENGTH_SHORT).show();
          return;
        }
        if ("".equals(password)) {
          Toast.makeText(SignInActivity.this, "Password can not be empty.", Toast.LENGTH_SHORT).show();
          return;
        }

        new LoginTask(SignInActivity.this, username, password).execute();
      }
    });
  }
}
