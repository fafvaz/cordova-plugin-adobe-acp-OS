package com.adobe.marketing.mobile.cordova;
import android.content.Intent;
import android.os.Bundle;
import android.widget.Toast;
import android.net.Uri;

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
    String deepLink = data.get("uri");  // Adicione esta linha para obter o deep link


    System.out.println("### deliveryId ###");
    System.out.println(deliveryId);
    System.out.println("### messageId ###");
    System.out.println(messageId);
    System.out.println("### acsDeliveryTracking ###");
    System.out.println(acsDeliveryTracking);
    System.out.println("### deepLink ###");
    System.out.println(deepLink);
    

    if (acsDeliveryTracking == null) {
      acsDeliveryTracking = "on";
    }

    // Adiciona os dados necessários ao HashMap

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

      // Adicione o deep link à Intent se estiver presente
      Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(deepLink));
      intent.putExtra("uri", deepLink);
      intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);

       startActivity(intent);

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
