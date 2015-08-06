package me.going_postal.goingpostal.rest;

import android.util.Log;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;

public class Client {
  private static final String TAG = Client.class.getName();
  private static Client instance;
  private URL baseUrl;
  private final String charset = java.nio.charset.StandardCharsets.UTF_8.name();

  public static Client getInstance() {
    if (instance == null) {
      instance = new Client();
    }
    return instance;
  }

  private Client() {
    try {
      baseUrl = new URL("http://192.168.144.40:3000/");
    } catch (MalformedURLException e) {
      e.printStackTrace();
    }
  }

  public BasicResponse login(String username, String password) {
    String postData = String.format("{\"login\": {\"username\": \"%s\", \"password\": \"%s\"}}", username, password);
    return doPost(getUrl("/api/v1/users/sign_in"), postData);
  }

  private BasicResponse doPost(URL url, String postData) {
    HttpURLConnection connection;
    try {
      connection = (HttpURLConnection) url.openConnection();
    } catch (IOException e) {
      Log.e(TAG, "", e);
      return BasicResponse.empty();
    }

    try {
      connection.setDoOutput(true);
      connection.setRequestProperty("Accept-Charset", charset);
      connection.setRequestProperty("Content-Type", String.format("application/json;charset=%s", charset));
      OutputStream output = connection.getOutputStream();
      output.write(postData.getBytes(charset));

      String body;
      int statusCode = connection.getResponseCode();
      if (statusCode >= 200 && statusCode < 300) {
        body = readStream(connection.getInputStream());
      } else {
        body = readStream(connection.getErrorStream());
      }
      return  new BasicResponse(statusCode, body, false);
    } catch (IOException e) {
      Log.e(TAG, "", e);
    }
    return BasicResponse.empty();
  }

  private URL getUrl(String apiCall) {
    try {
      return new URL(baseUrl, apiCall);
    } catch (MalformedURLException e) {
      Log.e(TAG, "", e);
    }
    return null;
  }

  private String readStream(InputStream stream) {
    BufferedReader reader = new BufferedReader(new InputStreamReader(stream));
    StringBuilder result = new StringBuilder();
    String line;
    try {
      while ((line = reader.readLine()) != null) {
        result.append(line);
      }
    } catch (IOException e) {
      Log.e(TAG, "", e);
    }
    return result.toString();
  }
}
