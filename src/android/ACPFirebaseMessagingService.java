package com.adobe.marketing.mobile.cordova;

import android.widget.Toast;

import com.adobe.marketing.mobile.MobileCore;
import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;

import java.util.HashMap;
import java.util.Map;

public class ACPFirebaseMessagingService extends FirebaseMessagingService {

  @Override
  public void onMessageReceived(RemoteMessage remoteMessage) {
    // Aqui você lida com o recebimento da notificação push
    // Extrai as informações necessárias do objeto remoteMessage, como deliveryId, messageId e acsDeliveryTracking

    System.out.println("onMessageReceived");

    Map<String, String> data = remoteMessage.getData();
    String deliveryId = data.get("_dId");
    String messageId = data.get("_mId");
    String acsDeliveryTracking = data.get("_acsDeliveryTracking");

    if (acsDeliveryTracking == null) {
      acsDeliveryTracking = "on";
    }

    Toast.makeText(this, "Messagem recebida", Toast.LENGTH_LONG).show();
    Toast.makeText(this, "Messagem recebida --> delivery track " + acsDeliveryTracking, Toast.LENGTH_LONG).show();

    System.out.println("deliveryId");
    System.out.println(deliveryId);

    System.out.println("messageId");
    System.out.println(messageId);

    System.out.println("acsDeliveryTracking");
    System.out.println(acsDeliveryTracking);

    HashMap<String, String> contextDataTemp = new HashMap<>();
    contextDataTemp.put("deliveryId", deliveryId);
    contextDataTemp.put("broadlogId", messageId);
    contextDataTemp.put("ronelio", "random");
    MobileCore.trackAction("tracking", contextDataTemp);

    HashMap<String, Object> contextDataObjTemp = new HashMap<>();
    // Adiciona os dados necessários ao HashMap
    contextDataObjTemp.put("deliveryId", deliveryId);
    contextDataObjTemp.put("broadlogId", messageId);
    contextDataObjTemp.put("action", "7");
    contextDataObjTemp.put("ronelio", "random");
    MobileCore.collectMessageInfo(contextDataObjTemp);

    // Verifica se a notificação push contém os dados necessários para o rastreamento
    if (deliveryId != null && messageId != null && acsDeliveryTracking.equals("on")) {
      // Cria um HashMap para armazenar os dados de contexto
      HashMap<String, String> contextData = new HashMap<>();
      HashMap<String, Object> contextDataObj = new HashMap<>();
      // Adiciona os dados necessários ao HashMap
      contextData.put("deliveryId", deliveryId);
      contextData.put("broadlogId", messageId);


      contextDataObj.put("deliveryId", deliveryId);
      contextDataObj.put("broadlogId", messageId);


      // Rastreia o evento de impressão da notificação push usando o Adobe Mobile SDK
      contextData.put("action", "7"); // 7 representa a impressão (impression)
      contextDataObj.put("action", "7"); // 7 representa a impressão (impression)

      MobileCore.trackAction("push_impression", contextData);
      MobileCore.collectMessageInfo(contextDataObj);

      // Rastreia o evento de clique da notificação push usando o Adobe Mobile SDK
      contextData.put("action", "2"); // 2 representa o clique (click)
      contextDataObj.put("action", "2"); // 2 representa o clique (click)
      MobileCore.trackAction("push_click", contextData);
      MobileCore.collectMessageInfo(contextDataObj);

      // Rastreia o evento de abertura da notificação push usando o Adobe Mobile SDK
      contextData.put("action", "1"); // 1 representa a abertura (open)
      contextDataObj.put("action", "1"); // 1 representa a abertura (open)
      MobileCore.trackAction("push_open", contextData);
      MobileCore.collectMessageInfo(contextDataObj);

    }

  }

}
