// Must match the <receiver> entry in plugin.xml
// (com.adobe.marketing.mobile.cordova.NotificationDismissedReceiver) and the
// target-dir this file is copied to. A mismatched package breaks manifest
// resolution and the dismiss (action "2") click tracking silently never fires.
package com.adobe.marketing.mobile.cordova;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;

import com.adobe.marketing.mobile.MobileCore;

import java.util.HashMap;

public class NotificationDismissedReceiver extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        Bundle data = intent.getExtras();

        if(data != null) {
            String deliveryId = data.getString("_dId");
            String messageId = data.getString("_mId");
            String acsDeliveryTracking = data.getString("_acsDeliveryTracking");

            if( acsDeliveryTracking == null ) {
                acsDeliveryTracking = "on";
            }

            HashMap<String, Object> contextData = new HashMap<>();

            //We only send the click tracking since the user dismissed the notification
            if (deliveryId != null && messageId != null && acsDeliveryTracking.equals("on")) {
                // collectMessageInfo takes Map<String, Object> (per AEPCore API reference),
                // so this map stays Object-typed.
                contextData.put("deliveryId", deliveryId);
                contextData.put("broadlogId", messageId);
                contextData.put("action", "2");
                MobileCore.collectMessageInfo(contextData);

                // Collect the custom payload keys as PII, matching the receipt/tap
                // paths and the iOS behavior (excludes Adobe system keys).
                // Must stay String-typed: MobileCore.collectPii takes Map<String, String>.
                HashMap<String, String> piiData = new HashMap<>();
                String[] excludedKeys = {"_dId", "_mId", "_acsDeliveryTracking", "aps",
                                         "google.message_id", "from", "collapse_key"};
                for (String key : data.keySet()) {
                    boolean excluded = false;
                    for (String ek : excludedKeys) {
                        if (ek.equals(key)) {
                            excluded = true;
                            break;
                        }
                    }
                    String value = data.getString(key);
                    if (!excluded && value != null) {
                        piiData.put(key, value);
                    }
                }
                if (!piiData.isEmpty()) {
                    MobileCore.collectPii(piiData);
                }
            }
        }
    }
}
