package me.going_postal.goingpostal;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import com.google.zxing.integration.android.IntentIntegrator;
import com.google.zxing.integration.android.IntentResult;
import com.parse.ParseInstallation;

import me.going_postal.goingpostal.rest.ServerClient;
import me.going_postal.goingpostal.tasks.AddDeviceTask;

public class MainActivity extends Activity {
  private static final String QR_CODE_HEADER = "GPv1.0|";

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_main);

    Button btnSignOut = (Button) findViewById(R.id.btn_sign_out);
    Button btnAddDevice = (Button) findViewById(R.id.btn_add_device);

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
                    dialog.dismiss();
                    ParseInstallation installation = ParseInstallation.getCurrentInstallation();
                    installation.remove("userHash");
                    installation.saveInBackground();
                  }
                })
                .setNegativeButton("No", null)
                .show();
      }
    });
    btnAddDevice.setOnClickListener(new View.OnClickListener() {
      @Override
      public void onClick(View v) {
        IntentIntegrator integrator = new IntentIntegrator(MainActivity.this);
        integrator.setDesiredBarcodeFormats(IntentIntegrator.QR_CODE_TYPES);
        integrator.setPrompt("");
        integrator.initiateScan();
      }
    });
  }

  @Override
  protected void onActivityResult(int requestCode, int resultCode, Intent data) {
    IntentResult result = IntentIntegrator.parseActivityResult(requestCode, resultCode, data);
    if(result != null) {
      if(result.getContents() != null) {
        addNewDeviceFromQRCode(result.getContents());
      }
    } else {
      super.onActivityResult(requestCode, resultCode, data);
    }
  }

  private void addNewDeviceFromQRCode(final String qrCodeContents) {
    if (!qrCodeContents.startsWith(QR_CODE_HEADER)) {
      Toast.makeText(this, "Invalid QR code.", Toast.LENGTH_LONG).show();
      return;
    }

    final AlertDialog dialog = new AlertDialog.Builder(this, AlertDialog.THEME_HOLO_LIGHT)
            .setView(R.layout.alert_device_location)
            .setTitle("Add device")
            .setPositiveButton("Add device", null)
            .setNegativeButton("Cancel", null)
            .create();
    dialog.setOnShowListener(new DialogInterface.OnShowListener() {
      @Override
      public void onShow(DialogInterface unused) {
        InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.showSoftInput(dialog.findViewById(R.id.et_location), InputMethodManager.SHOW_IMPLICIT);

        dialog.getButton(DialogInterface.BUTTON_POSITIVE).setOnClickListener(new View.OnClickListener() {
          @Override
          public void onClick(View v) {
            final EditText etLocation = (EditText) dialog.findViewById(R.id.et_location);
            String location = etLocation.getText().toString().trim();
            if ("".equals(location)) {
              Toast.makeText(MainActivity.this, "Please enter device location.", Toast.LENGTH_LONG).show();
              return;
            }
            String key = qrCodeContents.substring(QR_CODE_HEADER.length());
            new AddDeviceTask(MainActivity.this, key, location, new Runnable() {
              @Override
              public void run() {
                dialog.dismiss();
              }
            }).execute();
          }
        });
      }
    });
    dialog.show();
  }
}
