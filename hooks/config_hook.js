module.exports = function (context) {
  //  const fs = require('fs');
    const _ = require('lodash');
    var fs = require('fs');
    var path = require('path');
   // var path = context.requireCordovaModule('path');
   // var fs = context.requireCordovaModule("fs");
   // var path = context.requireCordovaModule("path");
   // var path = require('path');

    const scheme = 'com.outsystemsenterprise.galpenergiadev.speechrecognitionsample';
    const insertIntent = `
    <queries>
        <intent>
            <action android:name="android.speech.RecognitionService" />
        </intent>
    </queries>
    `;
   
   /* const insertIntent = `
    <intent-filter>
        <action android:name="android.speech.RecognitionService"/>
    </intent-filter>
    `;
    */
   
   // const manifestPath = context.opts.projectRoot + '/platforms/android/AndroidManifest.xml';
    var manifestPath = path.join(context.opts.projectRoot, 'platforms/android/app/src/main/AndroidManifest.xml');

    const androidManifest = fs.readFileSync(manifestPath).toString();
   /* if (!androidManifest.includes(`android:scheme="${scheme}"`)) {
        const manifestLines = androidManifest.split(/\r?\n/);
        const lineNo = _.findIndex(manifestLines, (line) => line.includes('<manifest'));
        manifestLines.splice(lineNo + 1, 0, insertIntent);
        fs.writeFileSync(manifestPath, manifestLines.join('\n'));
    }*/
        const manifestLines = androidManifest.split(/\r?\n/);
        const lineNo = _.findIndex(manifestLines, (line) => line.includes('<manifest'));
        manifestLines.splice(lineNo + 1, 0, insertIntent);
        fs.writeFileSync(manifestPath, manifestLines.join('\n'));
}; 