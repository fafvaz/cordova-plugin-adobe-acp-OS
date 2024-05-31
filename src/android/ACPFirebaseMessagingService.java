package com.adobe.marketing.mobile.cordova;

import android.os.Bundle;
import android.util.Log;

import com.adobe.marketing.mobile.MobileCore;
import com.google.firebase.messaging.RemoteMessage;

import org.apache.cordova.firebase.FirebasePluginMessageReceiver;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;

public class ACPFirebaseMessagingService extends FirebasePluginMessageReceiver {


  final static String ACP_CORE_PUSH_TAG_LOG = "ACP_CORE_PUSH";
  final static String ACP_CORE_LAST_PUSH_PREF_KEY = "ACP_LAST_PUSH_PREF";
  final static String ACP_CORE_LAST_PUSH_KEY = "ACP_LAST_PUSH";


  @Override
  public boolean onMessageReceived(RemoteMessage remoteMessage) {

    Log.d(ACP_CORE_PUSH_TAG_LOG, "begin onMessageReceived");

    Map<String, String> data = remoteMessage.getData();

    String deliveryId = data.get("_dId");
    String messageId = data.get("_mId");
    String acsDeliveryTracking = data.get("_acsDeliveryTracking");


    if (acsDeliveryTracking == null) {
      acsDeliveryTracking = "on";
    }
    data.put("FromPushNotification", "false");
    // Verifica se a notificação push contém os dados necessários para o rastreamento
    if (deliveryId != null && messageId != null && acsDeliveryTracking.equals("on")) {
      handleTracking(data, "7", false);
      return true;
    }

    Log.d(ACP_CORE_PUSH_TAG_LOG, "end onMessageReceived");

    return false;
  }

  public static void handleMessage(Bundle bundle, boolean fromBackground) {
    Log.d(ACP_CORE_PUSH_TAG_LOG, "begin handleMessage == background: " + fromBackground);

    if (bundle != null) {
      Map<String, String> data = new HashMap<>();
      Set<String> keys = bundle.keySet();

      for (String key : keys) {
        data.put(key, bundle.getString(key, null));
      }

      data.put("FromPushNotification", fromBackground ? "true" : "false");
      if(fromBackground) {
        ACPCore_Cordova.addPushToPreferences(data);
        handleTracking(data, "2", false);
        handleTracking(data, "1", true);
      } else {
        handleTracking(data, "2", false);
        handleTracking(data, "1", true);
      }

    } else {
      Log.d(ACP_CORE_PUSH_TAG_LOG, "bundle null. nothing to do || background: " + fromBackground);
    }
    Log.d(ACP_CORE_PUSH_TAG_LOG, "end handleMessage || background: " + fromBackground);
  }

  private static void handleTracking(Map<String, String> data, String action, boolean skipDeepLink) {

    String deliveryId = data.get("_dId");
    String messageId = data.get("_mId");
    String acsDeliveryTracking = data.get("_acsDeliveryTracking");

    if (acsDeliveryTracking == null) {
      acsDeliveryTracking = "on";
    }

    // Verifica se a notificação push contém os dados necessários para o rastreamento
    if (deliveryId != null && messageId != null && acsDeliveryTracking.equals("on")) {

      HashMap<String, Object> contextData = new HashMap<>();

      contextData.put("deliveryId", deliveryId);
      contextData.put("broadlogId", messageId);
      contextData.put("action", action);

      MobileCore.collectMessageInfo(contextData);

      if (!skipDeepLink) {
        handleCallback(data);
      }
      Log.d(ACP_CORE_PUSH_TAG_LOG, "handleTracking successfully");
    }
  }

  private static void handleCallback(final Map<String, String> data) {
    JSONObject jsonObject = new JSONObject(data);
    ACPCore_Cordova.intance.subscribe(jsonObject);
  }

}
