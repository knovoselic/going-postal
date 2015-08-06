package me.going_postal.goingpostal.rest;

public class BasicResponse {
  public final Boolean connectionError;
  public final int statusCode;
  public final String body;

  public static BasicResponse empty() {
    return new BasicResponse(-1, null, true);
  }

  public BasicResponse(int statusCode, String body, Boolean connectionError) {
    this.statusCode = statusCode;
    this.body = body;
    this.connectionError = connectionError;
  }
}
