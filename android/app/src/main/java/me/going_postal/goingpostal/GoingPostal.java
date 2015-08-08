package me.going_postal.goingpostal;

import android.app.Application;

import com.parse.Parse;
import com.parse.ParseInstallation;

public class GoingPostal extends Application {
  @Override
  public void onCreate() {
    super.onCreate();
    Parse.initialize(this, "4aDYgLKaevqtk3bVCZSZB6zDGYIFJ3W8XfP81uxZ", "5az5OAF2Wzqao976jAkFJteTGsYJAYP5SajKU6EL");
    ParseInstallation.getCurrentInstallation().saveInBackground();
  }
}
