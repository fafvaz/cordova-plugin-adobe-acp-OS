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

 import android.os.Handler;
 import android.os.Looper;
 import android.util.Log;
 
 import org.apache.cordova.CordovaPlugin;
 import org.apache.cordova.CallbackContext;
 
 import org.json.JSONArray;
 import org.json.JSONException;
 import org.json.JSONObject;
 import com.adobe.marketing.mobile.AdobeCallback;
 import com.adobe.marketing.mobile.Campaign;
 import com.adobe.marketing.mobile.Identity;
 import com.adobe.marketing.mobile.Lifecycle;
 import com.adobe.marketing.mobile.MobileCore;
 import com.adobe.marketing.mobile.Signal;
 import com.adobe.marketing.mobile.UserProfile;
 
 import java.util.HashMap;
 import java.util.Iterator;
 
 
 /**
  * This class echoes a string called from JavaScript.
  */
 public class ACPCampaign_Cordova extends CordovaPlugin {
 
 
     @Override
     public boolean execute(String action, JSONArray args, CallbackContext callbackContext) {
 
         if ("extensionVersion".equals(action)) {
             extensionVersion(callbackContext);
             return true;       
         }
         else if ("setPushIdentifier".equals(action) || "loadAdobe".equals(action)){
             setPushIdentifier(args, callbackContext);
             return true;
         }
 
         return false;
     }
 
     private void extensionVersion(final CallbackContext callbackContext) {
         cordova.getThreadPool().execute(new Runnable() {
             @Override
             public void run() {
                 String extensionVersion = Campaign.extensionVersion();
                 if (extensionVersion.length() > 0) {
                     callbackContext.success(extensionVersion);
                 } else {
                     callbackContext.error("Extension version is null or empty");
                 }
             }
         });
     }
 
     //SetPushIdentifier
     private void setPushIdentifier(final JSONArray args, final CallbackContext callbackContext) {
 
 
         // Read the Type Id from config.xml preferences (plugin variable TYPE_ID).
        // MABS 12 (cordova-android 13) ignores plugin config-file injections targeting
        // res/values/*strings*.xml, so the "TypeId" string resource may not exist.
        String typeId = webView.getPreferences().getString("TYPE_ID", null);
        if (typeId == null || typeId.isEmpty()) {
            // Plugin variables are persisted as <variable> elements in the packaged
            // res/xml/config.xml; CordovaPreferences cannot see them, so parse them.
            typeId = ACPCore_Cordova.readVariableFromPackagedConfig(
                    cordova.getActivity().getApplicationContext(), "cordova-acp", "TYPE_ID");
        }
        if (typeId == null || typeId.isEmpty()) {
            int typeIdResId = cordova.getActivity().getResources().getIdentifier("TypeId", "string", cordova.getActivity().getPackageName());
            if (typeIdResId != 0) {
                typeId = cordova.getActivity().getString(typeIdResId);
            }
        }
        if (typeId == null || typeId.isEmpty()) {
            Log.e("ACP_CORE", "Type Id not found: set the TYPE_ID plugin variable in the Extensibility Configurations.");
        }
 
         cordova.getThreadPool().execute(() -> {
             if (args == null || args.length() < 1 || args.length() > 3) {
                 callbackContext.error("Invalid argument count, expected 1 to 3 arguments.");
                 return;
             }
             try {
 
                 // An empty/missing token must NOT abort the call: the app may call
                 // before Firebase has produced a token. Only the push registration
                 // is skipped; the PII below is still delivered (regression fix: the
                 // previous hard return on an empty token silently dropped the email.
                 String deviceToken = args.isNull(0) ? null : args.optString(0, null);
                 boolean tokenSent = false;
                 if (deviceToken != null && !deviceToken.trim().isEmpty()) {
                     MobileCore.setPushIdentifier(deviceToken.trim());
                     tokenSent = true;
                 } else {
                     Log.w("ACP_CAMPAIGN", "setPushIdentifier: device token missing/empty - "
                             + "skipping push registration, still collecting PII.");
                 }

                 // optJSONObject: a null / non-object 3rd argument must not throw.
                 final HashMap<String, String> data = new HashMap<String, String>();
                 JSONObject contextData = args.optJSONObject(2);
                 if (contextData != null) {
                     data.putAll(getStringMapFromJSON(contextData));
                 }
                 if (args.length() >= 2 && !args.isNull(1)) {
                     String email = args.optString(1, null);
                     if (email != null && !email.trim().isEmpty()) {
                         // Canonical, case-sensitive key (matches iOS).
                         data.put("emailaddress", email);
                         // Also send under the configured TYPE_ID key (e.g.
                         // "fiscalnumber") so attributes populated before the
                         // key rename keep being refreshed.
                         if (typeId != null && !typeId.isEmpty() && !"emailaddress".equals(typeId)) {
                             data.put(typeId, email);
                         }
                     }
                 }
                 boolean piiSent = !data.isEmpty();
                 if (piiSent) {
                     MobileCore.collectPii(data);
                 }

                 if (tokenSent || piiSent) {
                     Log.i("ACP_CAMPAIGN", "setPushIdentifier: sent token=" + tokenSent
                             + ", pii keys=" + data.keySet());
                     callbackContext.success();
                 } else {
                     callbackContext.error("Nothing to send: device token and PII are both empty.");
                 }
 
                 return;
             } catch (JSONException e) {
                 callbackContext.error("Error while parsing argument, Error " + e.getLocalizedMessage());
                 return;
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
 
 }
 
