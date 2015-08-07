package me.going_postal.goingpostal;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;

import me.going_postal.goingpostal.rest.ServerClient;

public class MainActivity extends Activity {

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_main);

    Button btnSignOut = (Button) findViewById(R.id.btn_sign_out);
    btnSignOut.setOnClickListener(new View.OnClickListener() {
      @Override
      public void onClick(View v) {
        new AlertDialog.Builder(MainActivity.this, AlertDialog.THEME_HOLO_LIGHT)
                .setMessage("Do you really want to sign out?")
                .setCancelable(false)
                .setPositiveButton("Yes", new DialogInterface.OnClickListener() {
                  @Override
                  public void onClick(DialogInterface dialog, int which) {
                    ServerClient.getInstance().signOut(MainActivity.this);
                    Intent intent = new Intent(MainActivity.this, SignInActivity.class);
                    startActivity(intent);
                    finish();
                  }
                })
                .setNegativeButton("No", null)
                .show();
      }
    });
  }
}
