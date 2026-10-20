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

var ACPCampaign = (function () {
  var exec = require('cordova/exec');
  var ACPCampaign = (typeof exports !== 'undefined' && exports) || {};
  var PLUGIN_NAME = 'ACPCampaign_Cordova';
  var TYPE_ID = 'fiscalnumber'; // Default TYPE_ID; can be overridden by app config
  // ===========================================================================
  // public APIs
  // ===========================================================================

  // Gets the current Analytics extension version.
  ACPCampaign.extensionVersion = function (success, error) {
    var FUNCTION_NAME = 'extensionVersion';

    if (success && !isFunction(success)) {
      printNotAFunction('success', FUNCTION_NAME);
      return;
    }

    if (error && !isFunction(error)) {
      printNotAFunction('error', FUNCTION_NAME);
      return;
    }

    exec(success, error, PLUGIN_NAME, FUNCTION_NAME, []);
  };
 
  // Sends the push identifier and optional user data to Adobe.
  ACPCampaign.setPushIdentifier = function (deviceToken, emailAddress, contextData, success, error) {
    var FUNCTION_NAME = 'setPushIdentifier';
    if (success && !isFunction(success)) {
      printNotAFunction('success', FUNCTION_NAME);
      return;
    }
    if (error && !isFunction(error)) {
      printNotAFunction('error', FUNCTION_NAME);
      return;
    }

    if (contextData && !isObject(contextData)) {
      contextData = {};
    }

    exec(success, error, PLUGIN_NAME, FUNCTION_NAME, [deviceToken, emailAddress, contextData]);
  
  };

  ACPCampaign.loadAdobe = function (deviceToken, emailAddress, success, error) {

    var FUNCTION_NAME = 'loadAdobe';
    exec(success, error, PLUGIN_NAME, FUNCTION_NAME, [deviceToken, emailAddress]);
};

  if (typeof document !== 'undefined') {
    document.addEventListener('deviceready', function () {
      if (typeof cordova === 'undefined' || cordova.platformId !== 'android') {
        return;
      }

      var firebasePlugin = window.FirebasePlugin;
      if (!firebasePlugin || (!isFunction(firebasePlugin.getToken) && !isFunction(firebasePlugin.onTokenRefresh))) {
        firebasePlugin = window.fp;
      }
      if (!firebasePlugin || (!isFunction(firebasePlugin.getToken) && !isFunction(firebasePlugin.onTokenRefresh))) {
        console.warn('ACPCampaign: Android Firebase token forwarding is unavailable; install the Firebase plugin or call setPushIdentifier directly.');
        return;
      }

      var forwardToken = function (token) {
        if (!isString(token) || !token.trim()) {
          console.error('ACPCampaign: Firebase returned an empty push token.');
          return;
        }
        // Trim the token and forward it with TYPE_ID and empty context data
        exec(null, function (error) {
          console.error('ACPCampaign: failed to forward the Firebase token to Adobe.', error);
        }, PLUGIN_NAME, 'setPushIdentifier', [token.trim(), TYPE_ID, {}]);
      };

      // Forward the CURRENT token right away: onTokenRefresh only fires when the
      // token changes, so subscribing alone never delivers an existing token.
      if (isFunction(firebasePlugin.getToken)) {
        try {
          var tokenResult = firebasePlugin.getToken(forwardToken, function (error) {
            console.warn('ACPCampaign: failed to fetch the Firebase token.', error);
          });
          // Some Firebase plugins expose getToken() as a Promise instead.
          if (tokenResult && typeof tokenResult.then === 'function') {
            tokenResult.then(forwardToken).catch(function (error) {
              console.warn('ACPCampaign: failed to fetch the Firebase token.', error);
            });
          }
        } catch (e) {
          console.warn('ACPCampaign: getToken threw an error.', e);
        }
      }

      // Also forward later token refreshes.
      if (isFunction(firebasePlugin.onTokenRefresh)) {
        firebasePlugin.onTokenRefresh(forwardToken, function (error) {
          console.error('ACPCampaign: failed to subscribe to Firebase token updates.', error);
        });
      }
    }, false);
  }

  return ACPCampaign;
})();



// ===========================================================================
// helper functions
// ===========================================================================
function isString(value) {
  return typeof value === 'string' || value instanceof String;
}

function isObject(value) {
  return value && typeof value === 'object' && value.constructor === Object;
}

function printNotAString(paramName, functionName) {
  console.log("Ignoring call to '" + functionName + "'. The '" + paramName + "' parameter is required to be a String.");
}

function isFunction(value) {
  return typeof value === 'function';
}

function printNotAFunction(paramName, functionName) {
  console.log("Ignoring call to '" + functionName + "'. The '" + paramName + "' parameter is required to be a function.");
}

module.exports = ACPCampaign;
