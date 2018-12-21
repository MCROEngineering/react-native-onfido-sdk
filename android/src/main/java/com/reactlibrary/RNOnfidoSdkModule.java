package com.reactlibrary;

import android.app.Activity;
import android.content.Intent;

import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.BaseActivityEventListener;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
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

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class RNOnfidoSdkModule extends ReactContextBaseJavaModule {

  private static final String E_ACTIVITY_DOES_NOT_EXIST = "E_ACTIVITY_DOES_NOT_EXIST";
  private static final String E_FAILED_TO_SHOW_ONFIDO = "E_FAILED_TO_SHOW_ONFIDO";
  private final Onfido client;
  private Callback mSuccessCallback;
  private Callback mErrorCallback;
  private static final int REQUEST_CODE_DOCUMENT_TYPE = 1;
  private static final int REQUEST_CODE_ONFIDO = 2;
  private ReadableMap mParams;

  private final ActivityEventListener mActivityEventListener = new BaseActivityEventListener() {
    @Override
    public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
      super.onActivityResult(activity, requestCode, resultCode, data);
      if (requestCode == REQUEST_CODE_ONFIDO) {
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
      if (requestCode == REQUEST_CODE_DOCUMENT_TYPE) {
        Activity currentActivity = getCurrentActivity();

        HashMap m = mParams.toHashMap();
        int[] docTypes = {1};
        m.put("documentTypes", docTypes);
        OnfidoConfig c = getOnfidoConfig(m);
        client.startActivityForResult(currentActivity, REQUEST_CODE_ONFIDO, c);
      }
    }
  };

  public RNOnfidoSdkModule(ReactApplicationContext reactContext) {
    super(reactContext);
    client = OnfidoFactory.create(reactContext).getClient();
    reactContext.addActivityEventListener(mActivityEventListener);
  }

  private DocumentType convertToDocumentType(int docType) {
    switch (docType) {
      case 0: return DocumentType.PASSPORT;
      case 1: return DocumentType.DRIVING_LICENCE;
      case 2: return DocumentType.NATIONAL_IDENTITY_CARD;
      case 3: return DocumentType.RESIDENCE_PERMIT;
    }
    return DocumentType.PASSPORT;
  }

  private OnfidoConfig getOnfidoConfig(HashMap params) {
    ArrayList documentTypes = (ArrayList) params.get("documentTypes");
    String token = (String) params.get("token");
    String applicantId = (String) params.get("applicantId");
    Boolean withWelcomeScreen = (Boolean) params.get("withWelcomeScreen");

    if (this.isDefaultFlow(params)) {
      FlowStep[] defaultSteps = new FlowStep[]{
              FlowStep.WELCOME,
              FlowStep.CAPTURE_DOCUMENT,
              FlowStep.CAPTURE_FACE,
              FlowStep.FINAL
      };

      return OnfidoConfig.builder()
              .withCustomFlow(defaultSteps)
              .withApplicant(applicantId)
              .withToken(token)
              .build();
    } else if (documentTypes.size() == 1) {
      try {
        Double docTypeObj = (Double)documentTypes.get(0);
        DocumentType documentType = this.convertToDocumentType(docTypeObj.intValue());
        final FlowStep[] steps = new FlowStep[]{
                new CaptureScreenStep(documentType, CountryCode.RO),
                FlowStep.CAPTURE_FACE
        };
        return OnfidoConfig.builder()
                .withCustomFlow(steps)
                .withApplicant(applicantId)
                .withToken(token)
                .build();
      }
      catch (Exception e) {
        mErrorCallback.invoke(E_FAILED_TO_SHOW_ONFIDO);
        mErrorCallback = null;
      }
    }
    return null;
  }

  private Boolean isDefaultFlow(HashMap params) {
    ArrayList documentTypes = (ArrayList) params.get("documentTypes");

    return documentTypes == null || documentTypes.indexOf(4.0) > -1;
  }

  private Boolean isCustomFlow(HashMap params) {
    if (isDefaultFlow(params)) {
      return true;
    }
    ArrayList documentTypes = (ArrayList) params.get("documentTypes");

    return documentTypes.size() > 1;
  }

  @Override
  public String getName() {
    return "RNOnfidoSdk";
  }

  @Override
  public Map<String, Object> getConstants() {
    final Map<String, Object> constants = new HashMap<>();
    constants.put("DocumentTypePassport", 0);
    constants.put("DocumentTypeDrivingLicence", 1);
    constants.put("DocumentTypeNationalIdentityCard", 2);
    constants.put("DocumentTypeResidencePermit", 3);
    constants.put("DocumentTypeAll", 4);
    return constants;
  }

  @ReactMethod
  public void startSDK(ReadableMap params, Callback successCallback, Callback errorCallback) {
    Activity currentActivity = getCurrentActivity();
    mSuccessCallback = successCallback;
    mErrorCallback = errorCallback;
    mParams = params;

    if (currentActivity == null) {
      mErrorCallback.invoke(E_ACTIVITY_DOES_NOT_EXIST);
      return;
    }
    HashMap paramsMap = params.toHashMap();

    if (this.isCustomFlow(paramsMap)) {
      Intent intent = new Intent(currentActivity, OnfidoCustomDocumentTypesActivity.class);
//      intent.putExtra("documentTypes", )
      currentActivity.startActivityForResult(intent, REQUEST_CODE_DOCUMENT_TYPE);
    } else {
      OnfidoConfig onfidoConfig = this.getOnfidoConfig(paramsMap);
      int activityRequestCode = this.isDefaultFlow(paramsMap) ? REQUEST_CODE_ONFIDO : REQUEST_CODE_DOCUMENT_TYPE;
      client.startActivityForResult(currentActivity, activityRequestCode, onfidoConfig);
    }
  }
}
