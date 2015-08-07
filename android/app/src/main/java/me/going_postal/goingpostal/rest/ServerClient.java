package me.going_postal.goingpostal.rest;

import android.content.Context;
import android.content.SharedPreferences;
import android.util.Log;

import org.apache.http.cookie.Cookie;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.CookieHandler;
import java.net.CookieManager;
import java.net.CookieStore;
import java.net.HttpCookie;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class ServerClient {
  private static final String TAG = ServerClient.class.getName();
  private static final String PREFERENCES_NAME = "me.going_postal.goingpostal.session";
  private static final String PREFERENCES_KEY = "cookies";
  private static ServerClient instance;
  private URL baseUrl;
  private URI baseUri;
  private final String charset = java.nio.charset.StandardCharsets.UTF_8.name();

  public static ServerClient getInstance() {
    if (instance == null) {
      instance = new ServerClient();
    }
    return instance;
  }

  private ServerClient() {
    try {
      baseUrl = new URL("http://192.168.144.40:3000/");
      baseUri = new URI(baseUrl.toString());
    } catch (URISyntaxException | MalformedURLException e) {
      Log.e(TAG, "", e);
    }
    // set up VM wide cookie manager
    CookieManager cookieManager = new CookieManager();
    CookieHandler.setDefault(cookieManager);
  }

  public BasicResponse signIn(String username, String password) {
    String postData = String.format("{\"login\": {\"username\": \"%s\", \"password\": \"%s\"}}", username, password);
    return doPost(getUrl("/api/v1/users/sign_in"), postData);
  }

  public void signOut(Context context) {
    SharedPreferences.Editor editor = context.getSharedPreferences(PREFERENCES_NAME, Context.MODE_PRIVATE).edit();
    editor.remove(PREFERENCES_KEY);
    editor.apply();
    ((CookieManager)CookieManager.getDefault()).getCookieStore().removeAll();
  }

  public void persistSession(Context context) {
    List<HttpCookie> cookies = ((CookieManager)CookieManager.getDefault()).getCookieStore().get(baseUri);
    Set<String> cookiesToPersist = new HashSet<>();
    for(HttpCookie cookie : cookies) {
      cookiesToPersist.add(cookie.toString());
    }
    SharedPreferences.Editor editor = context.getSharedPreferences(PREFERENCES_NAME, Context.MODE_PRIVATE).edit();
    editor.putStringSet(PREFERENCES_KEY, cookiesToPersist);
    editor.apply();
  }

  public BasicResponse addDevice(String key, String location) {
    String postData = String.format("{\"device\": {\"key\": \"%s\", \"location\": \"%s\"}}", key, location);
    return doPost(getUrl("/api/v1/devices"), postData);
  }

  public Boolean restoreSession(Context context) {
    SharedPreferences prefs = context.getSharedPreferences(PREFERENCES_NAME, Context.MODE_PRIVATE);
    Set<String> cookies = prefs.getStringSet(PREFERENCES_KEY, new HashSet<String>());
    if (cookies.isEmpty()) {
      return false;
    }
    CookieStore cookieStore = ((CookieManager)CookieManager.getDefault()).getCookieStore();
    for(String cookie : cookies) {
      for(HttpCookie parsedCookie : HttpCookie.parse(cookie)) {
        cookieStore.add(baseUri, parsedCookie);
      }
    }
    return true;
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

      return new BasicResponse(statusCode, body, false);
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
