package com.reactlibrary;

import android.app.Activity;
import android.content.Intent;

import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.BaseActivityEventListener;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
import com.onfido.android.sdk.capture.Onfido;
import com.onfido.android.sdk.capture.ExitCode;
import com.onfido.android.sdk.capture.OnfidoConfig;
import com.onfido.android.sdk.capture.OnfidoFactory;
import com.onfido.android.sdk.capture.errors.OnfidoException;
import com.onfido.android.sdk.capture.ui.options.FlowStep;
import com.onfido.android.sdk.capture.ui.options.CaptureScreenStep;
import com.onfido.android.sdk.capture.DocumentType;
import com.onfido.android.sdk.capture.utils.CountryCode;
import com.onfido.api.client.data.Applicant;
import com.onfido.android.sdk.capture.upload.Captures;

import android.support.annotation.Nullable;

public class RNOnfidoSdkModule extends ReactContextBaseJavaModule {

  private static final String E_ACTIVITY_DOES_NOT_EXIST = "E_ACTIVITY_DOES_NOT_EXIST";
  private static final String E_FAILED_TO_SHOW_ONFIDO = "E_FAILED_TO_SHOW_ONFIDO";
  private final Onfido client;
  private Callback mSuccessCallback;
  private Callback mErrorCallback;

  private final ActivityEventListener mActivityEventListener = new BaseActivityEventListener() {
    @Override
    public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
      super.onActivityResult(activity, requestCode, resultCode, data);
      if (requestCode == 1) {
        client.handleActivityResult(resultCode, data, new Onfido.OnfidoResultListener() {
          @Override
          public void userCompleted(Applicant applicant, Captures captures) {
            mSuccessCallback.invoke(applicant.getId());
          }

          @Override
          public void userExited(ExitCode exitCode, Applicant applicant) {
            mErrorCallback.invoke(exitCode.toString());
          }

          @Override
          public void onError(OnfidoException exception, @Nullable Applicant applicant) {
            // An exception occurred during the flow
          }
        });
      }
    }
  };

  public RNOnfidoSdkModule(ReactApplicationContext reactContext) {
    super(reactContext);
    client = OnfidoFactory.create(reactContext).getClient();
    reactContext.addActivityEventListener(mActivityEventListener);
  }

  @Override
  public String getName() {
    return "RNOnfidoSdk";
  }

  @ReactMethod
  public void startSDKWithToken(String token, String applicantId, String countryCode, int documentType, Callback successCallback, Callback errorCallback) {
    Activity currentActivity = getCurrentActivity();
    mSuccessCallback = successCallback;
    mErrorCallback = errorCallback;

    if (currentActivity == null) {
      mErrorCallback.invoke(E_ACTIVITY_DOES_NOT_EXIST);
      return;
    }

    DocumentType docType = documentType == 0
            ? DocumentType.PASSPORT
            : documentType == 1 ? DocumentType.DRIVING_LICENCE : DocumentType.NATIONAL_IDENTITY_CARD;

    try {
      final FlowStep[] steps = new FlowStep[]{
              new CaptureScreenStep(docType, CountryCode.getByCode(countryCode)),
              FlowStep.CAPTURE_FACE
      };
      OnfidoConfig onfidoConfig = OnfidoConfig.builder()
              .withCustomFlow(steps)
              .withApplicant(applicantId)
              .withToken(token)
              .build();
      client.startActivityForResult(currentActivity, 1, onfidoConfig);
    }
    catch (Exception e) {
      mErrorCallback.invoke(E_FAILED_TO_SHOW_ONFIDO);
      mErrorCallback = null;
    }
  }
}
