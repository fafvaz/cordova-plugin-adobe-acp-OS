/*
 Copyright 2020 Adobe. All rights reserved.
 This file is licensed to you under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License. You may obtain a copy
 of the License at http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software distributed under
 the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 OF ANY KIND, either express or implied. See the License for the specific language
 governing permissions and limitations under the License.
 */

package com.adobe.marketing.mobile.cordova;

import android.content.Context;
import android.support.annotation.NonNull;
import com.adobe.marketing.mobile.AdobeCallback;
import com.adobe.marketing.mobile.Analytics;
import com.adobe.marketing.mobile.Event;
import com.adobe.marketing.mobile.Event.Builder;
import com.adobe.marketing.mobile.ExtensionError;
import com.adobe.marketing.mobile.ExtensionErrorCallback;
import com.adobe.marketing.mobile.Identity;
import com.adobe.marketing.mobile.InvalidInitException;
import com.adobe.marketing.mobile.Lifecycle;
import com.adobe.marketing.mobile.LoggingMode;
import com.adobe.marketing.mobile.MobileCore;
import com.adobe.marketing.mobile.MobileServices;
import com.adobe.marketing.mobile.MobilePrivacyStatus;
import com.adobe.marketing.mobile.Signal;
import com.adobe.marketing.mobile.Target;
import com.adobe.marketing.mobile.UserProfile;
import com.adobe.marketing.mobile.WrapperType;
import com.adobe.marketing.mobile.Campaign;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
//import com.google.firebase.installations.FirebaseInstallations;
//import com.google.firebase.installations.InstallationTokenResult;
//import com.google.firebase.iid.FirebaseInstanceId;
//import com.google.firebase.iid.InstanceIdResult;
import android.os.Bundle;
import android.util.Log;
import android.widget.Toast;
import android.os.Build;
import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.provider.Settings;
import android.os.Bundle;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import java.util.HashMap;
import java.util.Iterator;

public class ACPCore_Cordova extends CordovaPlugin {
    final static String METHOD_CORE_DISPATCH_EVENT = "dispatchEvent";
    final static String METHOD_CORE_DISPATCH_EVENT_WITH_RESPONSE_CALLBACK = "dispatchEventWithResponseCallback";
    final static String METHOD_CORE_DISPATCH_RESPONSE_EVENT = "dispatchResponseEvent";
    final static String METHOD_CORE_DOWNLOAD_RULES = "downloadRules";
    final static String METHOD_CORE_EXTENSION_VERSION_CORE = "extensionVersion";
    final static String METHOD_CORE_GET_PRIVACY_STATUS = "getPrivacyStatus";
    final static String METHOD_CORE_GET_SDK_IDENTITIES = "getSdkIdentities";
    final static String METHOD_CORE_SET_ADVERTISING_IDENTIFIER = "setAdvertisingIdentifier";
    final static String METHOD_CORE_SET_LOG_LEVEL = "setLogLevel";
    final static String METHOD_CORE_SET_PRIVACY_STATUS = "setPrivacyStatus";
    final static String METHOD_CORE_TRACK_ACTION = "trackAction";
    final static String METHOD_CORE_TRACK_STATE = "trackState";
    final static String METHOD_CORE_UPDATE_CONFIGURATION = "updateConfiguration";
    final static String METHOD_CORE_GET_APP_ID = "getAppId";
    final static String METHOD_CORE_BEGIN_TEST = "beginTest";
    final static String METHOD_CORE_SET_PUSH_IDENTIFIER = "setPushIdentifier";

    private String appId;
    private String initTime;

    // ===============================================================
    // all calls filter through this method
    // ===============================================================
    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (METHOD_CORE_DISPATCH_EVENT.equals(action)) {
            this.dispatchEvent(args, callbackContext);
            return true;
        } else if (METHOD_CORE_DISPATCH_EVENT_WITH_RESPONSE_CALLBACK.equals(action)) {
            this.dispatchEventWithResponseCallback(args, callbackContext);
            return true;
        } else if (METHOD_CORE_DISPATCH_RESPONSE_EVENT.equals(action)) {
            this.dispatchResponseEvent(args, callbackContext);
            return true;
        } else if (METHOD_CORE_DOWNLOAD_RULES.equals(action)) {
            this.downloadRules(callbackContext);
            return true;
        } else if (METHOD_CORE_EXTENSION_VERSION_CORE.equals(action)) {
            this.extensionVersion(callbackContext);
            return true;
        } else if (METHOD_CORE_GET_PRIVACY_STATUS.equals(action)) {
            this.getPrivacyStatus(callbackContext);
            return true;
        } else if (METHOD_CORE_GET_SDK_IDENTITIES.equals(action)) {
            this.getSdkIdentities(callbackContext);
            return true;
        } else if (METHOD_CORE_SET_ADVERTISING_IDENTIFIER.equals(action)) {
            this.setAdvertisingIdentifier(args, callbackContext);
            return true;
        } else if (METHOD_CORE_SET_LOG_LEVEL.equals(action)) {
            this.setLogLevel(args, callbackContext);
            return true;
        } else if (METHOD_CORE_SET_PRIVACY_STATUS.equals(action)) {
            this.setPrivacyStatus(args, callbackContext);
            return true;
        } else if (METHOD_CORE_TRACK_ACTION.equals(action)) {
            this.trackAction(args, callbackContext);
            return true;
        } else if (METHOD_CORE_TRACK_STATE.equals(action)) {
            this.trackState(args, callbackContext);
            return true;
        } else if (METHOD_CORE_UPDATE_CONFIGURATION.equals(action)) {
            this.updateConfiguration(args, callbackContext);
            return true;
        } else if (METHOD_CORE_GET_APP_ID.equals(action)) {
            this.getAppId(callbackContext);
            return true;
        } else if (METHOD_CORE_SET_PUSH_IDENTIFIER.equals(action)) {
            this.setPushIdentifier(args, callbackContext);
            return true;
        } else if (METHOD_CORE_BEGIN_TEST.equals(action)) {
            this.beginTest(callbackContext);
            return true;
        }

        return false;
    }

    // ===============================================================
    // MobileCore Methods
    // ===============================================================
    private void dispatchEvent(final JSONArray args, final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(new Runnable() {
            @Override
            public void run() {
                try {
                    final HashMap<String, Object> eventMap = getObjectMapFromJSON(args.getJSONObject(0));
                    final Event event = getEventFromMap(eventMap);

                    MobileCore.dispatchEvent(event, new ExtensionErrorCallback<ExtensionError>() {
                        @Override
                        public void error(ExtensionError extensionError) {
                            callbackContext.error(extensionError.getErrorName());
                        }
                    });

                    callbackContext.success();
                } catch (Exception ex) {
                    final String errorMessage = String.format("Exception in call to dispatchEvent: %s",
                            ex.getLocalizedMessage());
                    MobileCore.log(LoggingMode.WARNING, "AEP SDK", errorMessage);
                    callbackContext.error(errorMessage);
                }
            }
        });
    }

    private void dispatchEventWithResponseCallback(final JSONArray args, final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(new Runnable() {
            @Override
            public void run() {
                try {
                    final HashMap<String, Object> eventMap = getObjectMapFromJSON(args.getJSONObject(0));
                    final Event event = getEventFromMap(eventMap);

                    MobileCore.dispatchEventWithResponseCallback(event, new AdobeCallback<Event>() {
                        @Override
                        public void call(Event event) {
                            final HashMap<String, Object> eventMap = getMapFromEvent(event);
                            final JSONObject eventJson = new JSONObject(eventMap);
                            callbackContext.success(eventJson);
                        }
                    }, new ExtensionErrorCallback<ExtensionError>() {
                        @Override
                        public void error(ExtensionError extensionError) {
                            callbackContext.error(extensionError.getErrorName());
                        }
                    });

                    callbackContext.success();
                } catch (Exception ex) {
                    final String errorMessage = String.format(
                            "Exception in call to dispatchEventWithResponseCallback: %s", ex.getLocalizedMessage());
                    MobileCore.log(LoggingMode.WARNING, "AEP SDK", errorMessage);
                    callbackContext.error(errorMessage);
                }
            }
        });
    }

    private void dispatchResponseEvent(final JSONArray args, final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(new Runnable() {
            @Override
            public void run() {
                try {
                    final HashMap<String, Object> responseEventMap = getObjectMapFromJSON(args.getJSONObject(0));
                    final Event responseEvent = getEventFromMap(responseEventMap);
                    final HashMap<String, Object> requestEventMap = getObjectMapFromJSON(args.getJSONObject(1));
                    final Event requestEvent = getEventFromMap(requestEventMap);

                    MobileCore.dispatchResponseEvent(responseEvent, requestEvent,
                            new ExtensionErrorCallback<ExtensionError>() {
                                @Override
                                public void error(ExtensionError extensionError) {
                                    callbackContext.error(extensionError.getErrorName());
                                }
                            });

                    callbackContext.success();
                } catch (Exception ex) {
                    final String errorMessage = String.format("Exception in call to dispatchResponseEvent: %s",
                            ex.getLocalizedMessage());
                    MobileCore.log(LoggingMode.WARNING, "AEP SDK", errorMessage);
                    callbackContext.error(errorMessage);
                }
            }
        });
    }

    private void downloadRules(final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(new Runnable() {
            @Override
            public void run() {
                // TODO: this method is not implemented in Android
                callbackContext.success();
            }
        });
    }

    private void extensionVersion(final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(new Runnable() {
            @Override
            public void run() {
                final String version = initTime + ": " + MobileCore.extensionVersion();
                callbackContext.success(version);
            }
        });
    }

    private void getPrivacyStatus(final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(new Runnable() {
            @Override
            public void run() {
                MobileCore.getPrivacyStatus(new AdobeCallback<MobilePrivacyStatus>() {
                    @Override
                    public void call(MobilePrivacyStatus mobilePrivacyStatus) {
                        callbackContext.success(mobilePrivacyStatus.getValue());
                    }
                });
            }
        });
    }

    private void getSdkIdentities(final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(new Runnable() {
            @Override
            public void run() {
                MobileCore.getSdkIdentities(new AdobeCallback<String>() {
                    @Override
                    public void call(String s) {
                        callbackContext.success(s);
                    }
                });
            }
        });
    }

    private void setAdvertisingIdentifier(final JSONArray args, final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(new Runnable() {
            @Override
            public void run() {
                try {
                    final String newAdId = args.getString(0);
                    MobileCore.setAdvertisingIdentifier(newAdId);
                    callbackContext.success();
                } catch (final Exception ex) {
                    final String errorMessage = String.format("Exception in call to setAdvertisingIdentifier: %s",
                            ex.getLocalizedMessage());
                    MobileCore.log(LoggingMode.WARNING, "AEP SDK", errorMessage);
                    callbackContext.error(errorMessage);
                }
            }
        });
    }

    private void setLogLevel(final JSONArray args, final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(new Runnable() {
            @Override
            public void run() {
                try {
                    LoggingMode newLogLevel;
                    switch (args.getInt(0)) {
                        case 0:
                        default:
                            newLogLevel = LoggingMode.ERROR;
                            break;
                        case 1:
                            newLogLevel = LoggingMode.WARNING;
                            break;
                        case 2:
                            newLogLevel = LoggingMode.DEBUG;
                            break;
                        case 3:
                            newLogLevel = LoggingMode.VERBOSE;
                            break;
                    }
                    MobileCore.setLogLevel(newLogLevel);
                    callbackContext.success();
                } catch (final Exception ex) {
                    final String errorMessage = String.format("Exception in call to setLogLevel: %s",
                            ex.getLocalizedMessage());
                    MobileCore.log(LoggingMode.WARNING, "AEP SDK", errorMessage);
                    callbackContext.error(errorMessage);
                }
            }
        });
    }

    private void setPrivacyStatus(final JSONArray args, final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(new Runnable() {
            @Override
            public void run() {
                try {
                    MobilePrivacyStatus newPrivacyStatus;
                    switch (args.getInt(0)) {
                        case 0:
                            newPrivacyStatus = MobilePrivacyStatus.OPT_IN;
                            break;
                        case 1:
                            newPrivacyStatus = MobilePrivacyStatus.OPT_OUT;
                            break;
                        case 2:
                        default:
                            newPrivacyStatus = MobilePrivacyStatus.UNKNOWN;
                            break;
                    }
                    MobileCore.setPrivacyStatus(newPrivacyStatus);
                    callbackContext.success();
                } catch (final Exception ex) {
                    final String errorMessage = String.format("Exception in call to setPrivacyStatus: %s",
                            ex.getLocalizedMessage());
                    MobileCore.log(LoggingMode.WARNING, "AEP SDK", errorMessage);
                    callbackContext.error(errorMessage);
                }
            }
        });
    }

    private void trackAction(final JSONArray args, final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(new Runnable() {
            @Override
            public void run() {
                try {
                    final String action = args.getString(0);
                    final HashMap<String, String> contextData = getStringMapFromJSON(args.getJSONObject(1));

                    MobileCore.trackAction(action, contextData);
                    callbackContext.success();
                } catch (final Exception ex) {
                    final String errorMessage = String.format("Exception in call to trackAction: %s",
                            ex.getLocalizedMessage());
                    MobileCore.log(LoggingMode.WARNING, "AEP SDK", errorMessage);
                    callbackContext.error(errorMessage);
                }
            }
        });
    }

    private void trackState(final JSONArray args, final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(new Runnable() {
            @Override
            public void run() {
                try {
                    final String state = args.getString(0);
                    final HashMap<String, String> contextData = getStringMapFromJSON(args.getJSONObject(1));

                    MobileCore.trackState(state, contextData);
                    callbackContext.success();
                } catch (final Exception ex) {
                    final String errorMessage = String.format("Exception in call to trackState: %s",
                            ex.getLocalizedMessage());
                    MobileCore.log(LoggingMode.WARNING, "AEP SDK", errorMessage);
                    callbackContext.error(errorMessage);
                }
            }
        });
    }

    private void updateConfiguration(final JSONArray args, final CallbackContext callbackContext) {
        cordova.getThreadPool().execute(new Runnable() {
            @Override
            public void run() {
                try {
                    final HashMap<String, Object> newConfig = getObjectMapFromJSON(args.getJSONObject(0));

                    MobileCore.updateConfiguration(newConfig);
                    callbackContext.success();
                } catch (final Exception ex) {
                    final String errorMessage = String.format("Exception in call to updateConfiguration: %s",
                            ex.getLocalizedMessage());
                    MobileCore.log(LoggingMode.WARNING, "AEP SDK", errorMessage);
                    callbackContext.error(errorMessage);
                }
            }
        });
    }

    private void setPushIdentifier(final JSONArray args, final CallbackContext callbackContext) {
        
        cordova.getThreadPool().execute(new Runnable() {
            @Override
            public void run() {
                try {
                    final String token = args.getString(0);
                    System.out.println("setPushIdentifier: " + token);
                    MobileCore.setPushIdentifier(token);
                   
                    callbackContext.success();
                } catch (final Exception ex) {
                    final String errorMessage = String.format("Exception in call to setPushIdentifier: %s",
                            ex.getLocalizedMessage());
                    MobileCore.log(LoggingMode.WARNING, "AEP SDK", errorMessage);
                    callbackContext.error(errorMessage);
                }
            }
        });
    }

    private void getAppId(final CallbackContext callbackContext) {

       // System.out.println("getAppId");
 
        cordova.getThreadPool().execute(new Runnable() {
            @Override
            public void run() {
                callbackContext.success(appId);
            }
        });
    }

    private void beginTest(final CallbackContext callbackContext) {

        System.out.println("beginTest");

        cordova.getThreadPool().execute(new Runnable() {
            @Override
            public void run() {
                callbackContext.success("beginTest");
            }
        });
    }

    // ===============================================================
    // Helpers
    // ===============================================================
    private HashMap<String, String> getStringMapFromJSON(JSONObject data) {
        HashMap<String, String> map = new HashMap<String, String>();
        @SuppressWarnings("rawtypes")
        Iterator it = data.keys();
        while (it.hasNext()) {
            String n = (String) it.next();
            try {
                map.put(n, data.getString(n));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        return map;
    }

    private HashMap<String, Object> getObjectMapFromJSON(JSONObject data) {
        HashMap<String, Object> map = new HashMap<String, Object>();
        @SuppressWarnings("rawtypes")
        Iterator it = data.keys();
        while (it.hasNext()) {
            String n = (String) it.next();
            try {
                map.put(n, data.getString(n));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        return map;
    }

    private Event getEventFromMap(final HashMap<String, Object> event) throws Exception {
        return new Event.Builder(event.get("name").toString(), event.get("type").toString(),
                event.get("source").toString())
                        .setEventData(getObjectMapFromJSON(new JSONObject(event.get("data").toString()))).build();
    }

    private HashMap<String, Object> getMapFromEvent(final Event event) {
        final HashMap<String, Object> eventMap = new HashMap<>();
        eventMap.put("name", event.getName());
        eventMap.put("type", event.getType());
        eventMap.put("source", event.getSource());
        eventMap.put("data", event.getEventData());

        return eventMap;
    }

    // ===============================================================
    // Plugin lifecycle events
    // ===============================================================
    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {

        super.initialize(cordova, webView);
        MobileCore.setApplication(this.cordova.getActivity().getApplication());

        appId = cordova.getActivity().getString(cordova.getActivity().getResources().getIdentifier("AppId", "string", cordova.getActivity().getPackageName()));
        Log.e("appId ", appId);
         
       final Context context = this.cordova.getActivity().getApplicationContext();   
       MobileCore.setLogLevel(LoggingMode.VERBOSE);
       MobileCore.setWrapperType(WrapperType.CORDOVA);

        try {
            Analytics.registerExtension();
            MobileServices.registerExtension();
            Campaign.registerExtension();
            UserProfile.registerExtension();
            Lifecycle.registerExtension();
            Target.registerExtension();
            Identity.registerExtension();
            Signal.registerExtension();

           // MobileCore.lifecycleStart(null);

            MobileCore.start(new AdobeCallback() {
                @Override
                public void call(Object o) {
                  //MobileCore.lifecycleStart(null);
                   
                   MobileCore.configureWithAppID(appId);
  
                   collectPii();
                   //registerToken();
                   
                }
            });
 
        } catch (InvalidInitException e) {
            Log.e("CampaignTestApp error", e.getMessage());
        }
          
    }
    
   /*
    void registerToken() {

       final Context context = this.cordova.getActivity().getApplicationContext();
        FirebaseApp.initializeApp(context);
  
        FirebaseInstallations.getInstance().getToken(true).addOnCompleteListener(new OnCompleteListener<InstallationTokenResult>() {
            @Override 
            public void onComplete(@NonNull Task<InstallationTokenResult> task) {
               
                if (!task.isSuccessful()) {
                    System.out.println("Message App getInstanceId failed: " + task.getException());
                    return;
                } 
                
                String token = task.getResult().getToken();
                System.out.println("Got token: " +  token);

                Thread t = new Thread() {
                    @Override
                    public void run() {
                        super.run();
                        try {
                            Thread.sleep(1000);
                        } catch (InterruptedException e) {
                            e.printStackTrace();
                        }

                        MobileCore.setPushIdentifier(token);
                        collectPii();
                        
                    }
                };

                t.start();
            }
        });
 
    }
    */
 
    void collectPii(){ 
        
        Log.d("Core version ", MobileCore.extensionVersion());
        Log.d("Campaign version ", Campaign.extensionVersion());
        Log.d("UserProfile version ", UserProfile.extensionVersion());
        Log.d("Identity version ", Identity.extensionVersion());
        Log.d("Lifecycle version ", Lifecycle.extensionVersion());
        Log.d("Signal version ", Signal.extensionVersion());

        Thread t = new Thread() {
            @Override
            public void run() {
                super.run();
                try {
                    Thread.sleep(10000);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }

                System.out.println("--");
                System.out.println("--");
                System.out.println("--");
                System.out.println("Collect PII");

                System.out.println("Build.DEVICE: " + Build.DEVICE);
                System.out.println("Build.DEVICE: " + Build.MODEL);
                System.out.println("Build.DEVICE: " + Build.BRAND);
                System.out.println("Build.DEVICE: " + Build.MANUFACTURER);
                System.out.println("Build.DEVICE: " + Build.VERSION.RELEASE);

                Map<String, String> linkageFields = new HashMap<>();
                    
                //linkageFields.put("pushPlatform", "gcm"); // fcm
                linkageFields.put("cusFiscalNumber", "111111111");
                //linkageFields.put("FiscalNumber", "205266649");
                // linkageFields.put("marketingCloudId", "123");
                // linkageFields.put("userKey", "rodrigo.santos@galp.com");
                
                MobileCore.collectPii(linkageFields);
                Campaign.setLinkageFields(linkageFields);

                
            }
        };

        t.start();

    }
 
    @Override
    public void onPause(boolean multitasking) {
        MobileCore.lifecyclePause();
        super.onPause(multitasking);
    }

    @Override
    public void onResume(boolean multitasking) {
        MobileCore.setApplication(this.cordova.getActivity().getApplication());
        MobileCore.lifecycleStart(null);
        super.onResume(multitasking);
    }
 
} 
