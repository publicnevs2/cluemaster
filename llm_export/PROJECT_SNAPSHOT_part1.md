# Project Snapshot – 2025-08-16 15:43:20
- Git rev: `ca34c5f`
- Export format: one fenced section per file (`path` + content).

---
## analysis_options.yaml

```
# This file configures the analyzer, which statically analyzes Dart code to
# check for errors, warnings, and lints.
#
# The issues identified by the analyzer are surfaced in the UI of Dart-enabled
# IDEs (https://dart.dev/tools#ides-and-editors). The analyzer can also be
# invoked from the command line by running `flutter analyze`.

# The following line activates a set of recommended lints for Flutter apps,
# packages, and plugins designed to encourage good coding practices.
include: package:flutter_lints/flutter.yaml

linter:
  # The lint rules applied to this project can be customized in the
  # section below to disable rules from the `package:flutter_lints/flutter.yaml`
  # included above or to enable additional rules. A list of all available lints
  # and their documentation is published at https://dart.dev/lints.
  #
  # Instead of disabling a lint rule for the entire project in the
  # section below, it can also be suppressed for a single line of code
  # or a specific dart file by using the `// ignore: name_of_lint` and
  # `// ignore_for_file: name_of_lint` syntax on the line or in the file
  # producing the lint.
  rules:
    # avoid_print: false  # Uncomment to disable the `avoid_print` rule
    # prefer_single_quotes: true  # Uncomment to enable the `prefer_single_quotes` rule

# Additional information about this file can be found at
# https://dart.dev/guides/language/analysis-options
```

---
## android/app/build.gradle.kts

```
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.clue_master"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.clue_master"
        // HIER IST DIE FINALE ÄNDERUNG
        minSdkVersion(flutter.minSdkVersion)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
```

---
## android/app/src/debug/AndroidManifest.xml

```
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- The INTERNET permission is required for development. Specifically,
         the Flutter tool needs it to communicate with the running application
         to allow setting breakpoints, to provide hot reload, etc.
    -->
    <uses-permission android:name="android.permission.INTERNET"/>
</manifest>
```

---
## android/app/src/main/AndroidManifest.xml

```
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Bestehende Berechtigung -->
    <uses-permission android:name="android.permission.CAMERA" />

    <!-- NEUE BERECHTIGUNGEN FÜR GPS -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

    <application
        android:label="Mission Control"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:taskAffinity=""
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <!-- Specifies an Android theme to apply to this Activity as soon as
                 the Android process has started. This theme is visible to the user
                 while the Flutter UI initializes. After that, this theme continues
                 to determine the Window background behind the Flutter UI. -->
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"
              />
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        <!-- Don't delete the meta-data below.
             This is used by the Flutter tool to generate GeneratedPluginRegistrant.java -->
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
    <!-- Required to query activities that can process text, see:
         https://developer.android.com/training/package-visibility and
         https://developer.android.com/reference/android/content/Intent#ACTION_PROCESS_TEXT.

         In particular, this is used by the Flutter engine in io.flutter.plugin.text.ProcessTextPlugin. -->
    <queries>
        <intent>
            <action android:name="android.intent.action.PROCESS_TEXT"/>
            <data android:mimeType="text/plain"/>
        </intent>
    </queries>
</manifest>
```

---
## android/app/src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java

```
package io.flutter.plugins;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;
import io.flutter.Log;

import io.flutter.embedding.engine.FlutterEngine;

/**
 * Generated file. Do not edit.
 * This file is generated by the Flutter tool based on the
 * plugins that support the Android platform.
 */
@Keep
public final class GeneratedPluginRegistrant {
  private static final String TAG = "GeneratedPluginRegistrant";
  public static void registerWith(@NonNull FlutterEngine flutterEngine) {
    try {
      flutterEngine.getPlugins().add(new com.ryanheise.audio_session.AudioSessionPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin audio_session, com.ryanheise.audio_session.AudioSessionPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new dev.fluttercommunity.plus.device_info.DeviceInfoPlusPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin device_info_plus, dev.fluttercommunity.plus.device_info.DeviceInfoPlusPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new com.mr.flutter.plugin.filepicker.FilePickerPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin file_picker, com.mr.flutter.plugin.filepicker.FilePickerPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new com.hemanthraj.fluttercompass.FlutterCompassPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin flutter_compass, com.hemanthraj.fluttercompass.FlutterCompassPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new io.flutter.plugins.flutter_plugin_android_lifecycle.FlutterAndroidLifecyclePlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin flutter_plugin_android_lifecycle, io.flutter.plugins.flutter_plugin_android_lifecycle.FlutterAndroidLifecyclePlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new com.baseflow.geolocator.GeolocatorPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin geolocator_android, com.baseflow.geolocator.GeolocatorPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new io.flutter.plugins.imagepicker.ImagePickerPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin image_picker_android, io.flutter.plugins.imagepicker.ImagePickerPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new com.ryanheise.just_audio.JustAudioPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin just_audio, com.ryanheise.just_audio.JustAudioPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new dev.steenbakker.mobile_scanner.MobileScannerPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin mobile_scanner, dev.steenbakker.mobile_scanner.MobileScannerPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new io.flutter.plugins.pathprovider.PathProviderPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin path_provider_android, io.flutter.plugins.pathprovider.PathProviderPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new com.baseflow.permissionhandler.PermissionHandlerPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin permission_handler_android, com.baseflow.permissionhandler.PermissionHandlerPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new com.llfbandit.record.RecordPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin record_android, com.llfbandit.record.RecordPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new dev.fluttercommunity.plus.share.SharePlusPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin share_plus, dev.fluttercommunity.plus.share.SharePlusPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new fman.ge.smart_auth.SmartAuthPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin smart_auth, fman.ge.smart_auth.SmartAuthPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new com.benjaminabel.vibration.VibrationPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin vibration, com.benjaminabel.vibration.VibrationPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new io.flutter.plugins.videoplayer.VideoPlayerPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin video_player_android, io.flutter.plugins.videoplayer.VideoPlayerPlugin", e);
    }
  }
}
```

---
## android/app/src/main/kotlin/com/example/clue_master/MainActivity.kt

```
package com.example.clue_master

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity()
```

---
## android/app/src/main/res/drawable/launch_background.xml

```
<?xml version="1.0" encoding="utf-8"?>
<!-- Modify this file to customize your launch splash screen -->
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="@android:color/white" />

    <!-- You can insert your own image assets here -->
    <!-- <item>
        <bitmap
            android:gravity="center"
            android:src="@mipmap/launch_image" />
    </item> -->
</layer-list>
```

---
## android/app/src/main/res/drawable-v21/launch_background.xml

```
<?xml version="1.0" encoding="utf-8"?>
<!-- Modify this file to customize your launch splash screen -->
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="?android:colorBackground" />

    <!-- You can insert your own image assets here -->
    <!-- <item>
        <bitmap
            android:gravity="center"
            android:src="@mipmap/launch_image" />
    </item> -->
</layer-list>
```

---
## android/app/src/main/res/values/styles.xml

```
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- Theme applied to the Android Window while the process is starting when the OS's Dark Mode setting is off -->
    <style name="LaunchTheme" parent="@android:style/Theme.Light.NoTitleBar">
        <!-- Show a splash screen on the activity. Automatically removed when
             the Flutter engine draws its first frame -->
        <item name="android:windowBackground">@drawable/launch_background</item>
    </style>
    <!-- Theme applied to the Android Window as soon as the process has started.
         This theme determines the color of the Android Window while your
         Flutter UI initializes, as well as behind your Flutter UI while its
         running.

         This Theme is only used starting with V2 of Flutter's Android embedding. -->
    <style name="NormalTheme" parent="@android:style/Theme.Light.NoTitleBar">
        <item name="android:windowBackground">?android:colorBackground</item>
    </style>
</resources>
```

---
## android/app/src/main/res/values-night/styles.xml

```
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- Theme applied to the Android Window while the process is starting when the OS's Dark Mode setting is on -->
    <style name="LaunchTheme" parent="@android:style/Theme.Black.NoTitleBar">
        <!-- Show a splash screen on the activity. Automatically removed when
             the Flutter engine draws its first frame -->
        <item name="android:windowBackground">@drawable/launch_background</item>
    </style>
    <!-- Theme applied to the Android Window as soon as the process has started.
         This theme determines the color of the Android Window while your
         Flutter UI initializes, as well as behind your Flutter UI while its
         running.

         This Theme is only used starting with V2 of Flutter's Android embedding. -->
    <style name="NormalTheme" parent="@android:style/Theme.Black.NoTitleBar">
        <item name="android:windowBackground">?android:colorBackground</item>
    </style>
</resources>
```

---
## android/app/src/profile/AndroidManifest.xml

```
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- The INTERNET permission is required for development. Specifically,
         the Flutter tool needs it to communicate with the running application
         to allow setting breakpoints, to provide hot reload, etc.
    -->
    <uses-permission android:name="android.permission.INTERNET"/>
</manifest>
```

---
## android/build.gradle.kts

```
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
```

---
## android/gradle/wrapper/gradle-wrapper.properties

```
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.12-all.zip
```

---
## android/gradle.properties

```
org.gradle.jvmargs=-Xmx8G -XX:MaxMetaspaceSize=4G -XX:ReservedCodeCacheSize=512m -XX:+HeapDumpOnOutOfMemoryError
android.useAndroidX=true
android.enableJetifier=true
```

---
## android/gradlew.bat

```
@if "%DEBUG%" == "" @echo off
@rem ##########################################################################
@rem
@rem  Gradle startup script for Windows
@rem
@rem ##########################################################################

@rem Set local scope for the variables with windows NT shell
if "%OS%"=="Windows_NT" setlocal

@rem Add default JVM options here. You can also use JAVA_OPTS and GRADLE_OPTS to pass JVM options to this script.
set DEFAULT_JVM_OPTS=

set DIRNAME=%~dp0
if "%DIRNAME%" == "" set DIRNAME=.
set APP_BASE_NAME=%~n0
set APP_HOME=%DIRNAME%

@rem Find java.exe
if defined JAVA_HOME goto findJavaFromJavaHome

set JAVA_EXE=java.exe
%JAVA_EXE% -version >NUL 2>&1
if "%ERRORLEVEL%" == "0" goto init

echo.
echo ERROR: JAVA_HOME is not set and no 'java' command could be found in your PATH.
echo.
echo Please set the JAVA_HOME variable in your environment to match the
echo location of your Java installation.

goto fail

:findJavaFromJavaHome
set JAVA_HOME=%JAVA_HOME:"=%
set JAVA_EXE=%JAVA_HOME%/bin/java.exe

if exist "%JAVA_EXE%" goto init

echo.
echo ERROR: JAVA_HOME is set to an invalid directory: %JAVA_HOME%
echo.
echo Please set the JAVA_HOME variable in your environment to match the
echo location of your Java installation.

goto fail

:init
@rem Get command-line arguments, handling Windowz variants

if not "%OS%" == "Windows_NT" goto win9xME_args
if "%@eval[2+2]" == "4" goto 4NT_args

:win9xME_args
@rem Slurp the command line arguments.
set CMD_LINE_ARGS=
set _SKIP=2

:win9xME_args_slurp
if "x%~1" == "x" goto execute

set CMD_LINE_ARGS=%*
goto execute

:4NT_args
@rem Get arguments from the 4NT Shell from JP Software
set CMD_LINE_ARGS=%$

:execute
@rem Setup the command line

set CLASSPATH=%APP_HOME%\gradle\wrapper\gradle-wrapper.jar

@rem Execute Gradle
"%JAVA_EXE%" %DEFAULT_JVM_OPTS% %JAVA_OPTS% %GRADLE_OPTS% "-Dorg.gradle.appname=%APP_BASE_NAME%" -classpath "%CLASSPATH%" org.gradle.wrapper.GradleWrapperMain %CMD_LINE_ARGS%

:end
@rem End local scope for the variables with windows NT shell
if "%ERRORLEVEL%"=="0" goto mainEnd

:fail
rem Set variable GRADLE_EXIT_CONSOLE if you need the _script_ return code instead of
rem the _cmd.exe /c_ return code!
if  not "" == "%GRADLE_EXIT_CONSOLE%" exit 1
exit /b 1

:mainEnd
if "%OS%"=="Windows_NT" endlocal

:omega
```

---
## android/local.properties

```
sdk.dir=C:\\Users\\mail2\\AppData\\Local\\Android\\sdk
flutter.sdk=C:\\flutter
flutter.buildMode=release
flutter.versionName=1.0.0
flutter.versionCode=1
```

---
## android/settings.gradle.kts

```
pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.7.3" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

include(":app")
```

---
## assets/codes.json

```
{
  "codeA": {
    "type": "text",
    "content": "Gehe zum Brunnen hinter der Kapelle."
  },
  "codeB": {
    "type": "image",
    "content": "assets/images/image1.jpg",
    "description": "Dies ist ein Hinweistext unter dem Bild."
  },
  "codeC": {
    "type": "text",
    "content": "Suche die alte Holzbrücke am Fluss."
  },
  "code65D": {
    "type": "image",
    "content": "assets/images/image2.jpg"
  }
}
```

---
## assets/hunts.json

```
[
  {
    "name": "Meine erste Schnitzeljagd",
    "clues": {
      "START": {
        "solved": false,
        "type": "text",
        "content": "Willkommen zur Schnitzeljagd! Der erste Code ist 'RAETSEL1'.",
        "description": "Lies den Text genau.",
        "question": null,
        "answer": null,
        "options": null,
        "hint1": null,
        "hint2": null,
        "rewardText": null
      },
      "RAETSEL1": {
        "solved": false,
        "type": "image",
        "content": "assets/images/image1.jpg",
        "description": "Schau dir diesen Mann genau an.",
        "question": "Welche Farbe hat die Kappe dieser Person?",
        "answer": "Schwarz",
        "options": [
          "Blau",
          "Schwarz",
          "Grün"
        ],
        "hint1": "Es ist eine dunkle Farbe.",
        "hint2": "Die Farbe beginnt mit S.",
        "rewardText": "Sehr gut! Der nächste Code lautet 'BRUNNEN'."
      }
    }
  }
]
```

---
## ios/Flutter/flutter_export_environment.sh

```
#!/bin/sh
# This is a generated file; do not edit or check into version control.
export "FLUTTER_ROOT=c:\flutter"
export "FLUTTER_APPLICATION_PATH=C:\Users\mail2\clue_master"
export "COCOAPODS_PARALLEL_CODE_SIGN=true"
export "FLUTTER_TARGET=lib\main.dart"
export "FLUTTER_BUILD_DIR=build"
export "FLUTTER_BUILD_NAME=1.0.0"
export "FLUTTER_BUILD_NUMBER=1"
export "FLUTTER_CLI_BUILD_MODE=debug"
export "DART_OBFUSCATION=false"
export "TRACK_WIDGET_CREATION=true"
export "TREE_SHAKE_ICONS=false"
export "PACKAGE_CONFIG=.dart_tool/package_config.json"
```

---
## ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json

```
{
  "images" : [
    {
      "size" : "20x20",
      "idiom" : "iphone",
      "filename" : "Icon-App-20x20@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "20x20",
      "idiom" : "iphone",
      "filename" : "Icon-App-20x20@3x.png",
      "scale" : "3x"
    },
    {
      "size" : "29x29",
      "idiom" : "iphone",
      "filename" : "Icon-App-29x29@1x.png",
      "scale" : "1x"
    },
    {
      "size" : "29x29",
      "idiom" : "iphone",
      "filename" : "Icon-App-29x29@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "29x29",
      "idiom" : "iphone",
      "filename" : "Icon-App-29x29@3x.png",
      "scale" : "3x"
    },
    {
      "size" : "40x40",
      "idiom" : "iphone",
      "filename" : "Icon-App-40x40@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "40x40",
      "idiom" : "iphone",
      "filename" : "Icon-App-40x40@3x.png",
      "scale" : "3x"
    },
    {
      "size" : "60x60",
      "idiom" : "iphone",
      "filename" : "Icon-App-60x60@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "60x60",
      "idiom" : "iphone",
      "filename" : "Icon-App-60x60@3x.png",
      "scale" : "3x"
    },
    {
      "size" : "20x20",
      "idiom" : "ipad",
      "filename" : "Icon-App-20x20@1x.png",
      "scale" : "1x"
    },
    {
      "size" : "20x20",
      "idiom" : "ipad",
      "filename" : "Icon-App-20x20@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "29x29",
      "idiom" : "ipad",
      "filename" : "Icon-App-29x29@1x.png",
      "scale" : "1x"
    },
    {
      "size" : "29x29",
      "idiom" : "ipad",
      "filename" : "Icon-App-29x29@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "40x40",
      "idiom" : "ipad",
      "filename" : "Icon-App-40x40@1x.png",
      "scale" : "1x"
    },
    {
      "size" : "40x40",
      "idiom" : "ipad",
      "filename" : "Icon-App-40x40@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "76x76",
      "idiom" : "ipad",
      "filename" : "Icon-App-76x76@1x.png",
      "scale" : "1x"
    },
    {
      "size" : "76x76",
      "idiom" : "ipad",
      "filename" : "Icon-App-76x76@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "83.5x83.5",
      "idiom" : "ipad",
      "filename" : "Icon-App-83.5x83.5@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "1024x1024",
      "idiom" : "ios-marketing",
      "filename" : "Icon-App-1024x1024@1x.png",
      "scale" : "1x"
    }
  ],
  "info" : {
    "version" : 1,
    "author" : "xcode"
  }
}
```

---
## ios/Runner/Assets.xcassets/LaunchImage.imageset/Contents.json

```
{
  "images" : [
    {
      "idiom" : "universal",
      "filename" : "LaunchImage.png",
      "scale" : "1x"
    },
    {
      "idiom" : "universal",
      "filename" : "LaunchImage@2x.png",
      "scale" : "2x"
    },
    {
      "idiom" : "universal",
      "filename" : "LaunchImage@3x.png",
      "scale" : "3x"
    }
  ],
  "info" : {
    "version" : 1,
    "author" : "xcode"
  }
}
```

---
## ios/Runner/Assets.xcassets/LaunchImage.imageset/README.md

```
# Launch Screen Assets

You can customize the launch screen with your own desired assets by replacing the image files in this directory.

You can also do it by opening your Flutter project's Xcode project with `open ios/Runner.xcworkspace`, selecting `Runner/Assets.xcassets` in the Project Navigator and dropping in the desired images.
```

---
## lib/core/services/clue_service.dart

```
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

// NEUER IMPORT für unser neues Datenmodell
import '../../data/models/hunt_progress.dart';
import '../../data/models/hunt.dart';
import '../../data/models/clue.dart';

class ClueService {
  static const String _huntsFileName = 'hunts.json';
  static const String _settingsFileName = 'admin_settings.json';
  // NEUER DATEINAME für die Statistik-Historie
  static const String _progressHistoryFileName = 'progress_history.json';

  Future<List<Hunt>> loadHunts() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_huntsFileName');
    try {
      if (!await file.exists()) {
        final assetJson = await rootBundle.loadString('assets/$_huntsFileName');
        await file.writeAsString(assetJson);
      }
      final jsonStr = await file.readAsString();
      final List<dynamic> decodedList = jsonDecode(jsonStr);
      return decodedList.map((json) => Hunt.fromJson(json)).toList();
    } catch (e) {
      // ignore: avoid_print
      print("❌ Fehler beim Laden der Schnitzeljagden: $e");
      return [];
    }
  }

  Future<void> saveHunts(List<Hunt> hunts) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_huntsFileName');
    final List<Map<String, dynamic>> jsonList =
        hunts.map((hunt) => hunt.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
    // ignore: avoid_print
    print("💾 Alle Schnitzeljagden gespeichert.");
  }

  Future<void> resetHuntProgress(Hunt hunt) async {
    final allHunts = await loadHunts();
    final huntIndex = allHunts.indexWhere((h) => h.name == hunt.name);

    if (huntIndex != -1) {
      allHunts[huntIndex].clues.forEach((code, clue) {
        clue.solved = false;
        clue.hasBeenViewed = false;
      });
      await saveHunts(allHunts);
      // ignore: avoid_print
      print("🔄 Fortschritt für '${hunt.name}' zurückgesetzt.");
    }
  }

  // =======================================================
  // NEUE METHODEN für die Statistik-Historie
  // =======================================================

  /// **Speichert einen neuen abgeschlossenen Spielfortschritt in der Historie.**
  Future<void> saveHuntProgress(HuntProgress progress) async {
    final allProgress = await loadHuntProgress();
    allProgress.add(progress);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_progressHistoryFileName');
    final List<Map<String, dynamic>> jsonList =
        allProgress.map((p) => p.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
    // ignore: avoid_print
    print("🏆 Neuer Erfolg für '${progress.huntName}' in der Ruhmeshalle gespeichert.");
  }

  /// **Lädt die Liste aller bisherigen Spielfortschritte aus der Datei.**
  Future<List<HuntProgress>> loadHuntProgress() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_progressHistoryFileName');
    try {
      if (!await file.exists()) {
        return [];
      }
      final jsonStr = await file.readAsString();
      if (jsonStr.isEmpty) {
        return [];
      }
      final List<dynamic> decodedList = jsonDecode(jsonStr);
      return decodedList.map((json) => HuntProgress.fromJson(json)).toList();
    } catch (e) {
      // ignore: avoid_print
      print("❌ Fehler beim Laden der Statistik-Historie: $e");
      return [];
    }
  }

  Future<void> exportHunt(Hunt hunt, BuildContext context) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final archive = Archive();
      final mediaFilesToPack = <File>{};

      final exportHunt = Hunt.fromJson(hunt.toJson());
      final Map<String, Clue> updatedClues = {};

      for (var entry in exportHunt.clues.entries) {
        final clue = entry.value;
        String newContent = clue.content;

        if (clue.content.startsWith('file://')) {
          final file = File(clue.content.replaceFirst('file://', ''));
          if (await file.exists()) {
            mediaFilesToPack.add(file);
            newContent = 'media/${file.path.split('/').last}';
          } else {
            // ignore: avoid_print
            print("⚠️ Datei nicht gefunden, wird ignoriert: ${file.path}");
          }
        }
        
        final clueJson = clue.toJson();
        clueJson['content'] = newContent;
        clueJson['solved'] = false;
        clueJson['hasBeenViewed'] = false;
        updatedClues[entry.key] = Clue.fromJson(entry.key, clueJson);
      }
      exportHunt.clues = updatedClues;

      for (var file in mediaFilesToPack) {
        final bytes = await file.readAsBytes();
        archive.addFile(
            ArchiveFile('media/${file.path.split('/').last}', bytes.length, bytes));
      }

      final huntJsonString = jsonEncode(exportHunt.toJson());
      archive.addFile(
          ArchiveFile('hunt.json', huntJsonString.length, utf8.encode(huntJsonString)));

      final zipEncoder = ZipEncoder();
      final zipData = zipEncoder.encode(archive);
      if (zipData == null) {
        throw Exception("Fehler beim Erstellen der ZIP-Datei.");
      }

      final sanitizedHuntName = hunt.name.replaceAll(RegExp(r'[\\/*?:"<>|]'), '_');
      final exportFile = File('${tempDir.path}/$sanitizedHuntName.cluemaster');
      await exportFile.writeAsBytes(zipData);

      final box = context.findRenderObject() as RenderBox?;
      await Share.shareXFiles(
        [XFile(exportFile.path)],
        text: 'Hier ist die Schnitzeljagd "${hunt.name}"!',
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
    } catch (e) {
      // ignore: avoid_print
      print("❌ Fehler beim Exportieren der Jagd: $e");
      rethrow;
    }
  }

  Future<String?> importHunt() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result == null || result.files.single.path == null) {
      return null;
    }

    try {
      final importFile = File(result.files.single.path!);
      
      if (!importFile.path.toLowerCase().endsWith('.cluemaster')) {
          throw Exception("Die ausgewählte Datei ist keine .cluemaster-Datei.");
      }

      final bytes = await importFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      final huntJsonFile = archive.findFile('hunt.json');
      if (huntJsonFile == null) throw Exception("Datei 'hunt.json' nicht im Archiv gefunden.");
      
      final huntJsonString = utf8.decode(huntJsonFile.content as List<int>);
      final importedHuntData = jsonDecode(huntJsonString);
      Hunt huntToSave = Hunt.fromJson(importedHuntData);

      final appDir = await getApplicationDocumentsDirectory();
      for (var file in archive.files) {
        if (file.name.startsWith('media/')) {
          final mediaFile = File('${appDir.path}/${file.name}');
          await mediaFile.create(recursive: true);
          await mediaFile.writeAsBytes(file.content as List<int>);
        }
      }

      final Map<String, Clue> updatedClues = {};
      for (var entry in huntToSave.clues.entries) {
        final clue = entry.value;
        String newContent = clue.content;
        if (clue.content.startsWith('media/')) {
          newContent = 'file://${appDir.path}/${clue.content}';
        }
        final clueJson = clue.toJson();
        clueJson['content'] = newContent;
        updatedClues[entry.key] = Clue.fromJson(entry.key, clueJson);
      }
      huntToSave.clues = updatedClues;

      final allHunts = await loadHunts();
      
      if (allHunts.any((h) => h.name.toLowerCase() == huntToSave.name.toLowerCase())) {
        String originalName = huntToSave.name;
        int counter = 1;
        String newName;
        do {
          newName = '$originalName ($counter)';
          counter++;
        } while (allHunts.any((h) => h.name.toLowerCase() == newName.toLowerCase()));
        
        huntToSave = Hunt(
          name: newName,
          clues: huntToSave.clues,
          briefingText: huntToSave.briefingText,
          briefingImageUrl: huntToSave.briefingImageUrl,
          targetTimeInMinutes: huntToSave.targetTimeInMinutes,
        );
      }

      allHunts.add(huntToSave);
      await saveHunts(allHunts);
      
      return huntToSave.name;
    } catch (e) {
      // ignore: avoid_print
      print("❌ Fehler beim Importieren der Jagd: $e");
      return "ERROR";
    }
  }

  Future<String> loadAdminPassword() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_settingsFileName');
      if (await file.exists()) {
        final jsonStr = await file.readAsString();
        final Map<String, dynamic> settings = jsonDecode(jsonStr);
        return settings['admin_password'] ?? 'admin123';
      } else {
        return 'admin123';
      }
    } catch (e) {
      // ignore: avoid_print
      print("❌ Fehler beim Laden des Admin-Passworts: $e");
      return 'admin123';
    }
  }

  Future<void> saveAdminPassword(String password) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_settingsFileName');
    final settings = {'admin_password': password};
    await file.writeAsString(jsonEncode(settings));
    // ignore: avoid_print 
    print("🔑 Admin-Passwort aktualisiert.");
  }
}
```

---
## lib/core/services/sound_service.dart

```
// lib/core/services/sound_service.dart

import 'package:just_audio/just_audio.dart';

// Enum MUSS außerhalb der Klasse deklariert werden.
enum SoundEffect {
  success,
  failure,
  clueUnlocked,
  buttonClick,
  appStart
}

class SoundService {
  final AudioPlayer _player = AudioPlayer();

  // Die Map, die unsere Enum-Werte auf die Dateinamen abbildet.
  final Map<SoundEffect, String> _soundFiles = {
    SoundEffect.success: 'assets/audio/success.mp3',
    SoundEffect.failure: 'assets/audio/failure.mp3',
    SoundEffect.clueUnlocked: 'assets/audio/clue_unlocked.mp3',
    SoundEffect.buttonClick: 'assets/audio/button_click.mp3',
    SoundEffect.appStart: 'assets/audio/app_start.mp3',
  };

  Future<void> playSound(SoundEffect sound) async {
    try {
      final assetPath = _soundFiles[sound];
      if (assetPath != null) {
        if (_player.playing) {
          await _player.stop();
        }
        await _player.setAsset(assetPath);
        await _player.play();
      }
    } catch (e) {
      // Dieser Print-Befehl ist nützlich für die Fehlersuche.
      // ignore: avoid_print
      print("Fehler beim Abspielen von Sound '$sound': $e");
    }
  }

  void dispose() {
    _player.dispose();
  }
}
```

---
## lib/data/models/clue.dart

```
// lib/data/models/clue.dart

// SECTION: Enums für Rätsel-Typen und Effekte
enum RiddleType {
  TEXT,
  MULTIPLE_CHOICE,
  GPS,
  DECISION, // NEU: Der Typ für Entscheidungs-Rätsel
}

enum ImageEffect {
  NONE,
  PUZZLE,
  INVERT_COLORS,
  BLACK_AND_WHITE,
}

enum TextEffect {
  NONE,
  MORSE_CODE,
  REVERSE,
  NO_VOWELS,
  MIRROR_WORDS,
}

// SECTION: Clue Klasse
class Clue {
  // --- Kerneigenschaften ---
  final String code;
  bool solved;
  bool hasBeenViewed;

  // --- HINWEIS (Was der Spieler immer sieht) ---
  final String type;
  final String content;
  final String? description;
  final String? backgroundImagePath;
  final ImageEffect imageEffect;
  final TextEffect textEffect;

  // --- OPTIONALES RÄTSEL ---
  final String? question;
  final RiddleType riddleType;
  final String? answer;
  final List<String>? options;
  final String? hint1;
  final String? hint2;
  final double? latitude;
  final double? longitude;
  final double? radius;

  // --- BELOHNUNG & NÄCHSTER SCHRITT ---
  final String? rewardText;
  final String? nextClueCode;
  final bool isFinalClue;
  final bool autoTriggerNextClue;
  
  // ============================================================
  // NEU: Feld für das Entscheidungs-Rätsel
  // ============================================================
  /// Speichert die Ziel-Codes für ein Entscheidungs-Rätsel.
  /// Die Reihenfolge muss der `options`-Liste entsprechen.
  final List<String>? decisionNextClueCodes;

  // --- Inventar-System Felder ---
  final String? rewardItemId;
  final String? requiredItemId;

  // --- Zeitgesteuerte Trigger Felder ---
  final int? timedTriggerAfterSeconds;
  final String? timedTriggerMessage;
  final String? timedTriggerRewardItemId;
  final String? timedTriggerNextClueCode;


  // SECTION: Konstruktor
  Clue({
    required this.code,
    this.solved = false,
    this.hasBeenViewed = false,
    required this.type,
    required this.content,
    this.description,
    this.backgroundImagePath,
    this.imageEffect = ImageEffect.NONE,
    this.textEffect = TextEffect.NONE,
    this.question,
    this.riddleType = RiddleType.TEXT,
    this.answer,
    this.options,
    this.hint1,
    this.hint2,
    this.latitude,
    this.longitude,
    this.radius,
    this.rewardText,
    this.nextClueCode,
    this.isFinalClue = false,
    this.autoTriggerNextClue = true,
    this.rewardItemId,
    this.requiredItemId,
    this.timedTriggerAfterSeconds,
    this.timedTriggerMessage,
    this.timedTriggerRewardItemId,
    this.timedTriggerNextClueCode,
    this.decisionNextClueCodes, // NEU im Konstruktor
  });

  // SECTION: Hilfs-Methoden (Getters)
  bool get isRiddle => question != null && question!.isNotEmpty;
  bool get isGpsRiddle => isRiddle && riddleType == RiddleType.GPS;
  bool get isMultipleChoice => isRiddle && riddleType == RiddleType.MULTIPLE_CHOICE;
  // NEU: Getter zur einfachen Identifizierung
  bool get isDecisionRiddle => isRiddle && riddleType == RiddleType.DECISION;


  // SECTION: JSON-Konvertierung
  factory Clue.fromJson(String code, Map<String, dynamic> json) {
    return Clue(
      code: code,
      solved: json['solved'] ?? false,
      hasBeenViewed: json['hasBeenViewed'] ?? false,
      type: json['type'],
      content: json['content'],
      description: json['description'],
      backgroundImagePath: json['backgroundImagePath'],
      imageEffect: ImageEffect.values.firstWhere(
          (e) => e.toString() == json['imageEffect'],
          orElse: () => ImageEffect.NONE),
      textEffect: TextEffect.values.firstWhere(
          (e) => e.toString() == json['textEffect'],
          orElse: () => TextEffect.NONE),
      question: json['question'],
      riddleType: RiddleType.values.firstWhere(
          (e) => e.toString() == json['riddleType'], orElse: () {
        if (json['options'] != null && (json['options'] as List).isNotEmpty) {
          return RiddleType.MULTIPLE_CHOICE;
        }
        return RiddleType.TEXT;
      }),
      answer: json['answer'],
      options: json['options'] != null ? List<String>.from(json['options']) : null,
      // NEU: Liest die Ziel-Codes aus der JSON
      decisionNextClueCodes: json['decisionNextClueCodes'] != null ? List<String>.from(json['decisionNextClueCodes']) : null,
      hint1: json['hint1'],
      hint2: json['hint2'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      radius: json['radius'],
      rewardText: json['rewardText'],
      nextClueCode: json['nextClueCode'],
      isFinalClue: json['isFinalClue'] ?? false,
      autoTriggerNextClue: json['autoTriggerNextClue'] ?? true,
      rewardItemId: json['rewardItemId'],
      requiredItemId: json['requiredItemId'],
      timedTriggerAfterSeconds: json['timedTriggerAfterSeconds'],
      timedTriggerMessage: json['timedTriggerMessage'],
      timedTriggerRewardItemId: json['timedTriggerRewardItemId'],
      timedTriggerNextClueCode: json['timedTriggerNextClueCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'solved': solved,
      'hasBeenViewed': hasBeenViewed,
      'type': type,
      'content': content,
      if (description != null) 'description': description,
      if (backgroundImagePath != null) 'backgroundImagePath': backgroundImagePath,
      'imageEffect': imageEffect.toString(),
      'textEffect': textEffect.toString(),
      if (question != null) 'question': question,
      'riddleType': riddleType.toString(),
      if (answer != null) 'answer': answer,
      if (options != null) 'options': options,
      // NEU: Schreibt die Ziel-Codes in die JSON
      if (decisionNextClueCodes != null) 'decisionNextClueCodes': decisionNextClueCodes,
      if (hint1 != null) 'hint1': hint1,
      if (hint2 != null) 'hint2': hint2,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (radius != null) 'radius': radius,
      if (rewardText != null) 'rewardText': rewardText,
      if (nextClueCode != null) 'nextClueCode': nextClueCode,
      'isFinalClue': isFinalClue,
      'autoTriggerNextClue': autoTriggerNextClue,
      if (rewardItemId != null) 'rewardItemId': rewardItemId,
      if (requiredItemId != null) 'requiredItemId': requiredItemId,
      if (timedTriggerAfterSeconds != null) 'timedTriggerAfterSeconds': timedTriggerAfterSeconds,
      if (timedTriggerMessage != null) 'timedTriggerMessage': timedTriggerMessage,
      if (timedTriggerRewardItemId != null) 'timedTriggerRewardItemId': timedTriggerRewardItemId,
      if (timedTriggerNextClueCode != null) 'timedTriggerNextClueCode': timedTriggerNextClueCode,
    };
  }
}
```

---
## lib/data/models/hunt.dart

```
// lib/data/models/hunt.dart

import 'clue.dart';
import 'item.dart';

// Die GeofenceTrigger-Klasse bleibt hier unverändert
class GeofenceTrigger {
  final String id;
  final double latitude;
  final double longitude;
  final double radius;
  final String message;
  final String? rewardItemId;
  final String? rewardClueCode;
  bool hasBeenTriggered;

  GeofenceTrigger({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.message,
    this.rewardItemId,
    this.rewardClueCode,
    this.hasBeenTriggered = false,
  });

  factory GeofenceTrigger.fromJson(Map<String, dynamic> json) {
    return GeofenceTrigger(
      id: json['id'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      radius: json['radius'],
      message: json['message'],
      rewardItemId: json['rewardItemId'],
      rewardClueCode: json['rewardClueCode'],
      hasBeenTriggered: json['hasBeenTriggered'] ?? false,
    );
  }
// .
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'message': message,
      if (rewardItemId != null) 'rewardItemId': rewardItemId,
      if (rewardClueCode != null) 'rewardClueCode': rewardClueCode,
      'hasBeenTriggered': hasBeenTriggered,
    };
  }
}

class Hunt {
  final String name;
  Map<String, Clue> clues;
  final String? briefingText;
  final String? briefingImageUrl;
  final int? targetTimeInMinutes;

  // ============================================================
  // KORREKTUR: 'final' wurde hier entfernt, um die Map änderbar zu machen
  // ============================================================
  Map<String, Item> items;

  final List<String> startingItemIds;
  final List<GeofenceTrigger> geofenceTriggers;

  Hunt({
    required this.name,
    this.clues = const {},
    this.briefingText,
    this.briefingImageUrl,
    this.targetTimeInMinutes,
    this.items = const {},
    this.startingItemIds = const [],
    this.geofenceTriggers = const [],
  });

  factory Hunt.fromJson(Map<String, dynamic> json) {
    final cluesData = json['clues'] as Map<String, dynamic>;
    final cluesMap = cluesData.map(
      (code, clueJson) => MapEntry(code, Clue.fromJson(code, clueJson)),
    );

    final itemsData = json['items'] as Map<String, dynamic>? ?? {};
    final itemsMap = itemsData.map(
      (id, itemJson) => MapEntry(id, Item.fromJson(itemJson..['id'] = id)),
    );

    return Hunt(
      name: json['name'],
      clues: cluesMap,
      briefingText: json['briefingText'] as String?,
      briefingImageUrl: json['briefingImageUrl'] as String?,
      targetTimeInMinutes: json['targetTimeInMinutes'] as int?,
      items: itemsMap,
      startingItemIds: json['startingItemIds'] != null
          ? List<String>.from(json['startingItemIds'])
          : [],
      geofenceTriggers: json['geofenceTriggers'] != null
          ? (json['geofenceTriggers'] as List)
              .map((triggerJson) => GeofenceTrigger.fromJson(triggerJson))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    final cluesJson = clues.map(
      (code, clue) => MapEntry(code, clue.toJson()),
    );
    final geofenceTriggersJson =
        geofenceTriggers.map((trigger) => trigger.toJson()).toList();

    final itemsJson = items.map(
      (id, item) => MapEntry(id, item.toJson()),
    );

    return {
      'name': name,
      'briefingText': briefingText,
      'briefingImageUrl': briefingImageUrl,
      if (targetTimeInMinutes != null) 'targetTimeInMinutes': targetTimeInMinutes,
      'items': itemsJson,
      'startingItemIds': startingItemIds,
      'geofenceTriggers': geofenceTriggersJson,
      'clues': cluesJson,
    };
  }
}
```

---
## lib/data/models/hunt_progress.dart

```
// lib/data/models/hunt_progress.dart

class HuntProgress {
  final String huntName;
  DateTime? startTime;
  DateTime? endTime;
  int failedAttempts;
  int hintsUsed;
  double distanceWalkedInMeters;

  // ============================================================
  // NEU: Das Inventar des Spielers ("Rucksack")
  // ============================================================
  /// Eine Menge (Set) der IDs aller gesammelten Items.
  /// Ein Set wird verwendet, um Duplikate automatisch zu verhindern.
  Set<String> collectedItemIds;

  final String progressId;

  HuntProgress({
    required this.huntName,
    this.startTime,
    this.endTime,
    this.failedAttempts = 0,
    this.hintsUsed = 0,
    this.distanceWalkedInMeters = 0.0,
    // NEU: Initialisiert das Inventar als leeres Set.
    this.collectedItemIds = const {},
    String? progressId,
  }) : progressId = progressId ?? DateTime.now().toIso8601String();

  Duration get duration {
    if (startTime != null && endTime != null) {
      return endTime!.difference(startTime!);
    }
    if (startTime != null) {
      return DateTime.now().difference(startTime!);
    }
    return Duration.zero;
  }

  factory HuntProgress.fromJson(Map<String, dynamic> json) {
    return HuntProgress(
      huntName: json['huntName'],
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      failedAttempts: json['failedAttempts'] ?? 0,
      hintsUsed: json['hintsUsed'] ?? 0,
      distanceWalkedInMeters: (json['distanceWalkedInMeters'] as num?)?.toDouble() ?? 0.0,
      // NEU: Liest die Item-IDs aus der JSON-Datei.
      collectedItemIds: json['collectedItemIds'] != null
          ? Set<String>.from(json['collectedItemIds'])
          : {},
      progressId: json['progressId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'huntName': huntName,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'failedAttempts': failedAttempts,
      'hintsUsed': hintsUsed,
      'distanceWalkedInMeters': distanceWalkedInMeters,
      // NEU: Schreibt die Item-IDs in die JSON-Datei.
      'collectedItemIds': collectedItemIds.toList(),
      'progressId': progressId,
    };
  }
}
```

---
## lib/data/models/item.dart

```
// lib/data/models/item.dart

// Definiert die verschiedenen Arten von Inhalten, die ein Item haben kann.
// Wir fügen hier schon 'interactive_widget' für die Zukunft hinzu.
enum ItemContentType { text, image, audio, video, interactive_widget }

class Item {
  // --- KERN-EIGENSCHAFTEN ---

  /// Eindeutige ID, um das Item zu identifizieren (z.B. "morse-code-tabelle").
  final String id;

  /// Der Name, der im Inventar angezeigt wird (z.B. "Morsecode-Tabelle").
  final String name;

  /// Der Pfad zum kleinen Vorschaubild für die Rucksack-Übersicht.
  final String thumbnailPath;


  // --- INHALTS-EIGENSCHAFTEN ---

  /// Der Typ des Hauptinhalts (Text, Bild, Audio, Video etc.).
  final ItemContentType contentType;

  /// Der eigentliche Inhalt. Bei Text ist es der Text selbst.
  /// Bei Medien (Bild, Audio, Video) ist es der Pfad zur Datei.
  /// Bei interaktiven Widgets ist es eine Kennung (z.B. "caesar_cipher").
  final String content;


  // --- STORY & LORE ---

  /// Eine optionale, kurze Beschreibung oder "Flavor Text".
  final String? description;

  /// Optionaler Text, der angezeigt wird, wenn der Spieler das Item "genauer untersucht".
  /// Perfekt für versteckte Hinweise oder Story-Details.
  final String? examineText;


  const Item({
    required this.id,
    required this.name,
    required this.thumbnailPath,
    required this.contentType,
    required this.content,
    this.description,
    this.examineText,
  });

  // --- JSON-KONVERTIERUNG (für die Speicherung) ---
  // Damit wir die Items in einer Konfigurationsdatei speichern können.

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      thumbnailPath: json['thumbnailPath'],
      contentType: ItemContentType.values.firstWhere(
        (e) => e.toString() == json['contentType'],
        orElse: () => ItemContentType.text, // Fallback
      ),
      content: json['content'],
      description: json['description'],
      examineText: json['examineText'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'thumbnailPath': thumbnailPath,
      'contentType': contentType.toString(),
      'content': content,
      'description': description,
      'examineText': examineText,
    };
  }
}
```

---
## lib/features/admin/admin_change_password_screen.dart

```
// ============================================================
// SECTION: Imports
// ============================================================
import 'package:flutter/material.dart';
import '../../core/services/clue_service.dart';

// ============================================================
// SECTION: AdminChangePasswordScreen Widget
// ============================================================
class AdminChangePasswordScreen extends StatefulWidget {
  const AdminChangePasswordScreen({super.key});

  @override
  State<AdminChangePasswordScreen> createState() =>
      _AdminChangePasswordScreenState();
}

// ============================================================
// SECTION: State-Klasse
// ============================================================
class _AdminChangePasswordScreenState
    extends State<AdminChangePasswordScreen> {
  // ============================================================
  // SECTION: State & Controller
  // ============================================================

  // GlobalKey zur Validierung des Formulars.
  final _formKey = GlobalKey<FormState>();

  // Controller für die Eingabefelder.
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Instanz des Services, um das Passwort zu speichern und zu laden.
  final _clueService = ClueService();

  // ============================================================
  // SECTION: Logik
  // ============================================================

  /// Speichert das neue Passwort, wenn alle Validierungen erfolgreich sind.
  Future<void> _changePassword() async {
    // 1. Führe die synchrone Formularvalidierung durch (neues Passwort, Bestätigung etc.).
    if (!_formKey.currentState!.validate()) {
      return; // Beenden, wenn das Formular ungültig ist.
    }

    // 2. Lade das gespeicherte Passwort.
    final storedPassword = await _clueService.loadAdminPassword();
    final currentPassword = _currentPasswordController.text.trim();

    // 3. Prüfe, ob das eingegebene aktuelle Passwort korrekt ist.
    if (currentPassword != storedPassword) {
      // Zeige eine Fehlermeldung an, wenn das Passwort falsch ist.
      // Der 'mounted'-Check ist eine Sicherheitsmaßnahme in async-Methoden.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Das aktuelle Passwort ist nicht korrekt.'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Beenden, wenn das Passwort nicht stimmt.
    }

    // 4. Wenn alles korrekt ist, speichere das neue Passwort.
    await _clueService.saveAdminPassword(_newPasswordController.text.trim());

    // Zeige eine Erfolgsmeldung an und schließe den Bildschirm.
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Passwort erfolgreich geändert!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  // ============================================================
  // SECTION: UI-Aufbau (build-Methode)
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin-Passwort ändern')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Eingabefeld für das aktuelle Passwort
            TextFormField(
              controller: _currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Aktuelles Passwort'),
              // Der Validator prüft jetzt nur noch, ob das Feld leer ist.
              // Die eigentliche Passwort-Prüfung erfolgt in _changePassword.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Bitte gib das aktuelle Passwort ein.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Eingabefeld für das neue Passwort
            TextFormField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Neues Passwort'),
              validator: (value) {
                if (value == null || value.length < 6) {
                  return 'Das Passwort muss mindestens 6 Zeichen lang sein.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Eingabefeld zur Bestätigung des neuen Passworts
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration:
                  const InputDecoration(labelText: 'Neues Passwort bestätigen'),
              validator: (value) {
                if (value != _newPasswordController.text) {
                  return 'Die Passwörter stimmen nicht überein.';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Speicher-Button
            ElevatedButton(
              onPressed: _changePassword,
              child: const Text('Passwort speichern'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---
## lib/features/admin/admin_dashboard_screen.dart

```
// lib/features/admin/admin_dashboard_screen.dart

import 'package:flutter/material.dart';
import '../../core/services/clue_service.dart';
import '../../data/models/clue.dart';
import '../../data/models/hunt.dart';
import 'admin_editor_screen.dart';
import 'admin_item_list_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final Hunt hunt;

  const AdminDashboardScreen({super.key, required this.hunt});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final ClueService _clueService = ClueService();
  late Hunt _currentHunt;

  @override
  void initState() {
    super.initState();
    _currentHunt = widget.hunt;
  }

  Future<void> _refreshHunt() async {
    final allHunts = await _clueService.loadHunts();
    if (mounted) {
      setState(() {
        _currentHunt = allHunts.firstWhere((h) => h.name == widget.hunt.name);
      });
    }
  }

  Future<void> _saveClueChanges(Map<String, Clue> updatedClues) async {
    final allHunts = await _clueService.loadHunts();
    final index = allHunts.indexWhere((h) => h.name == _currentHunt.name);
    if (index != -1) {
      allHunts[index].clues = updatedClues;
      await _clueService.saveHunts(allHunts);
      await _refreshHunt();
    }
  }

  Future<void> _deleteClue(String code) async {
    if (!mounted) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Löschen bestätigen'),
        content: Text('Station "$code" wirklich löschen?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Löschen')),
        ],
      ),
    );
    if (confirm == true) {
      final updatedClues = Map<String, Clue>.from(_currentHunt.clues)..remove(code);
      await _saveClueChanges(updatedClues);
    }
  }

  Future<void> _openEditor({String? codeToEdit}) async {
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return AdminEditorScreen(
            // =======================================================
            // KORREKTUR HIER: Übergibt die gesamte Jagd an den Editor
            // =======================================================
            hunt: _currentHunt,
            codeToEdit: codeToEdit,
            existingClue: codeToEdit != null ? _currentHunt.clues[codeToEdit] : null,
            existingCodes: _currentHunt.clues.keys.toList(),
            onSave: (updatedMap) async {
              final updatedClues = Map<String, Clue>.from(_currentHunt.clues);
              if (codeToEdit != null && updatedMap.keys.first != codeToEdit) {
                updatedClues.remove(codeToEdit);
              }
              updatedClues.addAll(updatedMap);
              await _saveClueChanges(updatedClues);
            },
          );
        },
      ),
    );
  }

  Future<void> _resetSolvedFlags() async {
    final updatedClues = Map<String, Clue>.from(_currentHunt.clues);
    for (var clue in updatedClues.values) {
      clue.solved = false;
      clue.hasBeenViewed = false;
    }
    await _saveClueChanges(updatedClues);
  }

  Future<void> _navigateToItemLibrary() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminItemListScreen(hunt: _currentHunt),
      ),
    );
    await _refreshHunt();
  }

  @override
  Widget build(BuildContext context) {
    final clues = _currentHunt.clues;
    final codes = clues.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard: ${_currentHunt.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Fortschritt zurücksetzen',
            onPressed: _resetSolvedFlags,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Neue Station'),
        onPressed: () => _openEditor(),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: const Icon(Icons.inventory_2_outlined, color: Colors.amber),
              title: const Text('Item-Bibliothek verwalten'),
              subtitle: Text('${_currentHunt.items.length} Items in dieser Jagd'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _navigateToItemLibrary,
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.flag_outlined),
                const SizedBox(width: 8),
                Text(
                  'Stationen',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: codes.length,
              itemBuilder: (_, i) {
                final code = codes[i];
                final clue = clues[code]!;

                String subtitleText = 'Typ: ${clue.type}';
                if (clue.isRiddle) {
                  subtitleText += ' (Rätsel)';
                }

                return ListTile(
                  title: Text(code),
                  subtitle: Text(subtitleText),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit_note), onPressed: () => _openEditor(codeToEdit: code)),
                      IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: () => _deleteClue(code)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

---
## lib/features/admin/admin_editor_screen.dart

```
// lib/features/admin/admin_editor_screen.dart

import 'dart:io';
import 'package:clue_master/data/models/hunt.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:record/record.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/clue.dart';
import 'widgets/clue_basic_info_section.dart';
import 'widgets/clue_content_section.dart';
import 'widgets/clue_riddle_section.dart'; // NEUER IMPORT

class AdminEditorScreen extends StatefulWidget {
  final Hunt hunt;
  final String? codeToEdit;
  final Clue? existingClue;
  final Function(Map<String, Clue>) onSave;
  final List<String> existingCodes;

  const AdminEditorScreen({
    super.key,
    required this.hunt,
    this.codeToEdit,
    this.existingClue,
    required this.onSave,
    this.existingCodes = const [],
  });

  @override
  State<AdminEditorScreen> createState() => _AdminEditorScreenState();
}

class _AdminEditorScreenState extends State<AdminEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  final _audioRecorder = AudioRecorder();
  final _uuid = Uuid();
  bool _isRecording = false;

  // --- Basis-Controller ---
  final _codeController = TextEditingController();
  String _type = 'text';
  final _contentController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isFinalClue = false;
  ImageEffect _imageEffect = ImageEffect.NONE;
  TextEffect _textEffect = TextEffect.NONE;

  // --- Rätsel-Controller ---
  bool _isRiddle = false;
  RiddleType _riddleType = RiddleType.TEXT;
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  final _option1Controller = TextEditingController();
  final _option2Controller = TextEditingController();
  final _option3Controller = TextEditingController();
  final _option4Controller = TextEditingController();
  final _hint1Controller = TextEditingController();
  final _hint2Controller = TextEditingController();
  final _rewardTextController = TextEditingController();
  final _nextClueCodeController = TextEditingController();
  bool _autoTriggerNextClue = true;

  // --- Item-Controller ---
  String? _selectedRewardItemId;
  String? _selectedRequiredItemId;

  // --- Controller für Entscheidungs-Rätsel ---
  final _decisionCode1Controller = TextEditingController();
  final _decisionCode2Controller = TextEditingController();
  final _decisionCode3Controller = TextEditingController();
  final _decisionCode4Controller = TextEditingController();

  // --- GPS-Controller ---
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _radiusController = TextEditingController();
  bool _isFetchingLocation = false;
  String? _backgroundImagePath;

  @override
  void initState() {
    super.initState();
    if (widget.existingClue != null) {
      final clue = widget.existingClue!;
      _codeController.text = clue.code;
      _type = clue.type;
      _contentController.text = clue.content;
      _descriptionController.text = clue.description ?? '';
      _isFinalClue = clue.isFinalClue;
      _imageEffect = clue.imageEffect;
      _textEffect = clue.textEffect;
      _isRiddle = clue.isRiddle;
      _backgroundImagePath = clue.backgroundImagePath;
      _selectedRequiredItemId = clue.requiredItemId;

      if (clue.isRiddle) {
        _questionController.text = clue.question!;
        _rewardTextController.text = clue.rewardText ?? '';
        _riddleType = clue.riddleType;
        _nextClueCodeController.text = clue.nextClueCode ?? '';
        _autoTriggerNextClue = clue.autoTriggerNextClue;
        _selectedRewardItemId = clue.rewardItemId;

        if (clue.riddleType == RiddleType.GPS) {
          _latitudeController.text = clue.latitude?.toString() ?? '';
          _longitudeController.text = clue.longitude?.toString() ?? '';
          _radiusController.text = clue.radius?.toString() ?? '';
        } else if (clue.isDecisionRiddle) {
          _option1Controller.text = clue.options![0];
          _decisionCode1Controller.text = clue.decisionNextClueCodes![0];
          _option2Controller.text = clue.options!.length > 1 ? clue.options![1] : '';
          _decisionCode2Controller.text = clue.decisionNextClueCodes!.length > 1 ? clue.decisionNextClueCodes![1] : '';
          _option3Controller.text = clue.options!.length > 2 ? clue.options![2] : '';
          _decisionCode3Controller.text = clue.decisionNextClueCodes!.length > 2 ? clue.decisionNextClueCodes![2] : '';
          _option4Controller.text = clue.options!.length > 3 ? clue.options![3] : '';
          _decisionCode4Controller.text = clue.decisionNextClueCodes!.length > 3 ? clue.decisionNextClueCodes![3] : '';
        } else {
          _answerController.text = clue.answer ?? '';
          _hint1Controller.text = clue.hint1 ?? '';
          _hint2Controller.text = clue.hint2 ?? '';
          if (clue.isMultipleChoice) {
            _riddleType = RiddleType.MULTIPLE_CHOICE;
            _option1Controller.text = clue.options![0];
            _option2Controller.text = clue.options!.length > 1 ? clue.options![1] : '';
            _option3Controller.text = clue.options!.length > 2 ? clue.options![2] : '';
            _option4Controller.text = clue.options!.length > 3 ? clue.options![3] : '';
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _contentController.dispose();
    _descriptionController.dispose();
    _questionController.dispose();
    _answerController.dispose();
    _option1Controller.dispose();
    _option2Controller.dispose();
    _option3Controller.dispose();
    _option4Controller.dispose();
    _hint1Controller.dispose();
    _hint2Controller.dispose();
    _rewardTextController.dispose();
    _nextClueCodeController.dispose();
    _audioRecorder.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _radiusController.dispose();
    _decisionCode1Controller.dispose();
    _decisionCode2Controller.dispose();
    _decisionCode3Controller.dispose();
    _decisionCode4Controller.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final options = [
        _option1Controller.text.trim(),
        _option2Controller.text.trim(),
        _option3Controller.text.trim(),
        _option4Controller.text.trim(),
      ].where((o) => o.isNotEmpty).toList();

      final decisionCodes = [
        _decisionCode1Controller.text.trim(),
        _decisionCode2Controller.text.trim(),
        _decisionCode3Controller.text.trim(),
        _decisionCode4Controller.text.trim(),
      ].sublist(0, options.length);

      final clue = Clue(
        code: _codeController.text.trim(),
        type: _type,
        content: _contentController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        isFinalClue: _isFinalClue,
        imageEffect: _type == 'image' ? _imageEffect : ImageEffect.NONE,
        textEffect: _type == 'text' ? _textEffect : TextEffect.NONE,
        question: _isRiddle ? _questionController.text.trim() : null,
        rewardText: _isRiddle && _rewardTextController.text.trim().isNotEmpty ? _rewardTextController.text.trim() : null,
        nextClueCode: _isRiddle && _nextClueCodeController.text.trim().isNotEmpty ? _nextClueCodeController.text.trim() : null,
        autoTriggerNextClue: _autoTriggerNextClue,
        rewardItemId: _isRiddle ? _selectedRewardItemId : null,
        requiredItemId: _selectedRequiredItemId,
        riddleType: _isRiddle ? _riddleType : RiddleType.TEXT,
        answer: _isRiddle && _riddleType != RiddleType.GPS && _riddleType != RiddleType.DECISION ? _answerController.text.trim() : null,
        options: _isRiddle && (_riddleType == RiddleType.MULTIPLE_CHOICE || _riddleType == RiddleType.DECISION) ? options : null,
        decisionNextClueCodes: _isRiddle && _riddleType == RiddleType.DECISION ? decisionCodes : null,
        hint1: _isRiddle && _riddleType != RiddleType.GPS && _riddleType != RiddleType.DECISION && _hint1Controller.text.trim().isNotEmpty ? _hint1Controller.text.trim() : null,
        hint2: _isRiddle && _riddleType != RiddleType.GPS && _riddleType != RiddleType.DECISION && _hint2Controller.text.trim().isNotEmpty ? _hint2Controller.text.trim() : null,
        latitude: _isRiddle && _riddleType == RiddleType.GPS ? double.tryParse(_latitudeController.text) : null,
        longitude: _isRiddle && _riddleType == RiddleType.GPS ? double.tryParse(_longitudeController.text) : null,
        radius: _isRiddle && _riddleType == RiddleType.GPS ? double.tryParse(_radiusController.text) : null,
        backgroundImagePath: _isRiddle && _riddleType == RiddleType.GPS ? _backgroundImagePath : null,
      );

      final updatedMap = {clue.code: clue};
      widget.onSave(updatedMap);
      Navigator.pop(context);
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      var permission = await Permission.location.request();
      if (permission.isGranted) {
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        setState(() {
          _latitudeController.text = position.latitude.toString();
          _longitudeController.text = position.longitude.toString();
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Standort-Berechtigung wurde verweigert.'),
            backgroundColor: Colors.red,
          ));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Standort konnte nicht abgerufen werden: $e'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) {
        setState(() => _isFetchingLocation = false);
      }
    }
  }

  Future<void> _pickMedia(ImageSource source) async {
    XFile? mediaFile;
    if (_type == 'image') {
      mediaFile = await _imagePicker.pickImage(source: source);
    } else if (_type == 'video') {
      mediaFile = await _imagePicker.pickVideo(source: source);
    }
    if (mediaFile != null) {
      await _saveMediaFile(mediaFile.path, mediaFile.name, _contentController);
    }
  }

  Future<void> _toggleRecording() async {
    if (await _audioRecorder.isRecording()) {
      final path = await _audioRecorder.stop();
      if (path != null) {
        await _saveMediaFile(path, 'audio_aufnahme.m4a', _contentController);
      }
      if (mounted) {
        setState(() => _isRecording = false);
      }
    } else {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        await _audioRecorder.start(const RecordConfig(), path: '${dir.path}/temp_audio');
        if (mounted) {
          setState(() => _isRecording = true);
        }
      }
    }
  }

  Future<void> _saveMediaFile(String originalPath, String originalName, TextEditingController controller) async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_$originalName';
    final newPath = '${dir.path}/$fileName';
    await File(originalPath).copy(newPath);
    if (mounted) {
      setState(() {
        controller.text = 'file://$newPath';
      });
    }
  }

  Future<void> _pickGpsBackgroundImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) return;

    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileExtension = path.extension(image.path);
      final String newFileName = '${_uuid.v4()}$fileExtension';
      final String savedImagePath = path.join(appDir.path, newFileName);

      await File(image.path).copy(savedImagePath);

      if (mounted) {
        setState(() {
          _backgroundImagePath = savedImagePath;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Speichern des Bildes: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.codeToEdit != null ? 'Station bearbeiten' : 'Neue Station'),
        actions: [IconButton(onPressed: _save, icon: const Icon(Icons.save))],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ClueBasicInfoSection(
              codeController: _codeController,
              codeToEdit: widget.codeToEdit,
              existingCodes: widget.existingCodes,
              selectedRequiredItemId: _selectedRequiredItemId,
              hunt: widget.hunt,
              onRequiredItemChanged: (itemId) {
                setState(() {
                  _selectedRequiredItemId = itemId;
                });
              },
            ),
            const Divider(height: 40, thickness: 1),
            ClueContentSection(
              type: _type,
              onTypeChanged: (value) => setState(() {
                _type = value!;
                _contentController.clear();
              }),
              contentController: _contentController,
              descriptionController: _descriptionController,
              imageEffect: _imageEffect,
              onImageEffectChanged: (value) => setState(() => _imageEffect = value!),
              textEffect: _textEffect,
              onTextEffectChanged: (value) => setState(() => _textEffect = value!),
              isRecording: _isRecording,
              onPickMedia: _pickMedia,
              onToggleRecording: _toggleRecording,
            ),
            const Divider(height: 40, thickness: 1),
            CheckboxListTile(
              title: const Text('Optionales Rätsel hinzufügen'),
              subtitle: const Text('Der Spieler muss nach dem Inhalt eine Aufgabe lösen.'),
              value: _isRiddle,
              onChanged: (value) => setState(() => _isRiddle = value ?? false),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            if (_isRiddle)
              ClueRiddleSection(
                questionController: _questionController,
                answerController: _answerController,
                hint1Controller: _hint1Controller,
                hint2Controller: _hint2Controller,
                option1Controller: _option1Controller,
                option2Controller: _option2Controller,
                option3Controller: _option3Controller,
                option4Controller: _option4Controller,
                decisionCode1Controller: _decisionCode1Controller,
                decisionCode2Controller: _decisionCode2Controller,
                decisionCode3Controller: _decisionCode3Controller,
                decisionCode4Controller: _decisionCode4Controller,
                latitudeController: _latitudeController,
                longitudeController: _longitudeController,
                radiusController: _radiusController,
                rewardTextController: _rewardTextController,
                nextClueCodeController: _nextClueCodeController,
                riddleType: _riddleType,
                isFetchingLocation: _isFetchingLocation,
                backgroundImagePath: _backgroundImagePath,
                selectedRewardItemId: _selectedRewardItemId,
                isFinalClue: _isFinalClue,
                autoTriggerNextClue: _autoTriggerNextClue,
                hunt: widget.hunt,
                onRiddleTypeChanged: (value) => setState(() => _riddleType = value!),
                onGetCurrentLocation: _getCurrentLocation,
                onPickGpsBackgroundImage: _pickGpsBackgroundImage,
                onRemoveGpsBackgroundImage: () => setState(() => _backgroundImagePath = null),
                onRewardItemChanged: (itemId) => setState(() => _selectedRewardItemId = itemId),
                onFinalClueChanged: (value) => setState(() => _isFinalClue = value ?? false),
                onAutoTriggerChanged: (value) => setState(() => _autoTriggerNextClue = value ?? true),
              ),
          ],
        ),
      ),
    );
  }
}
```

---
## lib/features/admin/admin_hunt_list_screen.dart

```
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../../core/services/clue_service.dart';
import '../../data/models/hunt.dart';
import 'admin_dashboard_screen.dart';
import 'admin_change_password_screen.dart';
import 'admin_hunt_settings_screen.dart';

class AdminHuntListScreen extends StatefulWidget {
  const AdminHuntListScreen({super.key});

  @override
  State<AdminHuntListScreen> createState() => _AdminHuntListScreenState();
}

class _AdminHuntListScreenState extends State<AdminHuntListScreen> {
  final ClueService _clueService = ClueService();
  List<Hunt> _hunts = [];

  @override
  void initState() {
    super.initState();
    _loadHunts();
  }

  Future<void> _loadHunts() async {
    final loadedHunts = await _clueService.loadHunts();
    if (mounted) {
      setState(() => _hunts = loadedHunts);
    }
  }

  Future<void> _navigateToHuntSettings(Hunt? hunt) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AdminHuntSettingsScreen(
          hunt: hunt,
          existingHuntNames: _hunts
              .where((h) => h.name != hunt?.name)
              .map((h) => h.name)
              .toList(),
        ),
      ),
    );

    if (result == true) {
      _loadHunts();
    }
  }

  void _navigateToDashboard(Hunt hunt) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminDashboardScreen(hunt: hunt),
      ),
    ).then((_) => _loadHunts());
  }

  Future<void> _deleteHunt(Hunt huntToDelete) async {
    final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Jagd löschen?'),
              content: Text(
                  'Möchtest du die Schnitzeljagd "${huntToDelete.name}" wirklich endgültig löschen?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Abbrechen')),
                TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Löschen')),
              ],
            ));

    if (confirm == true) {
      _hunts.removeWhere((hunt) => hunt.name == huntToDelete.name);
      await _clueService.saveHunts(_hunts);
      _loadHunts();
    }
  }

  Future<void> _importHunt() async {
    final result = await _clueService.importHunt();
    if (!mounted) return;

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Import abgebrochen.')),
      );
    } else if (result == "EXISTS") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Fehler: Eine Jagd mit diesem Namen existiert bereits.'),
            backgroundColor: Colors.orange),
      );
    } else if (result == "ERROR") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Fehler: Die Datei konnte nicht importiert werden. Bitte stelle sicher, dass es eine gültige .cluemaster-Datei ist.'),
            backgroundColor: Colors.red),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Die Jagd "$result" wurde erfolgreich importiert.'),
            backgroundColor: Colors.green),
      );
      _loadHunts();
    }
  }

  Future<void> _exportHuntWithFeedback(Hunt hunt) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${hunt.name}" wird zum Teilen vorbereitet...'),
        duration: const Duration(seconds: 4),
      ),
    );

    try {
      await _clueService.exportHunt(hunt, context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Exportieren: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // =======================================================
    // KORRIGIERTER TEIL: `WillPopScope` wurde hinzugefügt
    // =======================================================
    return WillPopScope(
      onWillPop: () async {
        // Sende das `true`-Signal an den HuntSelectionScreen zurück.
        Navigator.of(context).pop(true);
        // Verhindere das Standard-Zurück-Verhalten, da wir es manuell auslösen.
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const AutoSizeText(
            'Meine Schnitzeljagden',
            maxLines: 1,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.file_download),
              tooltip: 'Jagd importieren',
              onPressed: _importHunt,
            ),
            IconButton(
              icon: const Icon(Icons.lock_outline),
              tooltip: 'Passwort ändern',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AdminChangePasswordScreen()),
                );
              },
            ),
          ],
        ),
        body: _hunts.isEmpty
            ? const Center(
                child: Text(
                    'Keine Schnitzeljagden gefunden. Erstelle oder importiere eine neue!'),
              )
            : ListView.builder(
                itemCount: _hunts.length,
                itemBuilder: (context, index) {
                  final hunt = _hunts[index];
                  return ListTile(
                    title: Text(hunt.name),
                    subtitle: Text('${hunt.clues.length} Stationen'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.share, color: Colors.blue),
                          tooltip: 'Jagd teilen/exportieren',
                          onPressed: () => _exportHuntWithFeedback(hunt),
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings),
                          tooltip: 'Jagd-Einstellungen (Name, Briefing)',
                          onPressed: () => _navigateToHuntSettings(hunt),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          tooltip: 'Stationen bearbeiten',
                          onPressed: () => _navigateToDashboard(hunt),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Jagd löschen',
                          onPressed: () => _deleteHunt(hunt),
                        ),
                      ],
                    ),
                    onTap: () => _navigateToDashboard(hunt),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _navigateToHuntSettings(null),
          label: const Text('Neue Jagd'),
          icon: const Icon(Icons.add),
        ),
      ), 
    );
  }
}
```

---
## lib/features/admin/admin_hunt_settings_screen.dart

```
// lib/features/admin/admin_hunt_settings_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/services/clue_service.dart';
import '../../data/models/hunt.dart';
import '../../data/models/item.dart'; // NEU: Item-Modell importieren

class AdminHuntSettingsScreen extends StatefulWidget {
  final Hunt? hunt;
  final List<String> existingHuntNames;

  const AdminHuntSettingsScreen({
    super.key,
    this.hunt,
    this.existingHuntNames = const [],
  });

  @override
  State<AdminHuntSettingsScreen> createState() =>
      _AdminHuntSettingsScreenState();
}

class _AdminHuntSettingsScreenState extends State<AdminHuntSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clueService = ClueService();
  final _imagePicker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _briefingTextController;
  late TextEditingController _targetTimeController;
  String? _briefingImagePath;

  // ============================================================
  // NEU: State für die ausgewählten Start-Items
  // ============================================================
  late Set<String> _selectedStartItemIds;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.hunt?.name ?? '');
    _briefingTextController =
        TextEditingController(text: widget.hunt?.briefingText ?? '');
    _targetTimeController = TextEditingController(
      text: widget.hunt?.targetTimeInMinutes?.toString() ?? '',
    );
    _briefingImagePath = widget.hunt?.briefingImageUrl;

    // NEU: Initialisiert das Set mit den bereits vorhandenen Start-Items
    _selectedStartItemIds = Set<String>.from(widget.hunt?.startingItemIds ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _briefingTextController.dispose();
    _targetTimeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = pickedFile.path.split('/').last;
      final savedImage =
          await File(pickedFile.path).copy('${appDir.path}/$fileName');
      setState(() {
        _briefingImagePath = 'file://${savedImage.path}';
      });
    }
  }

  Future<void> _saveHunt() async {
    if (_formKey.currentState!.validate()) {
      final allHunts = await _clueService.loadHunts();

      final targetTimeText = _targetTimeController.text.trim();
      final int? targetTime =
          targetTimeText.isNotEmpty ? int.tryParse(targetTimeText) : null;

      final updatedHunt = Hunt(
        name: _nameController.text.trim(),
        briefingText: _briefingTextController.text.trim().isEmpty
            ? null
            : _briefingTextController.text.trim(),
        briefingImageUrl: _briefingImagePath,
        targetTimeInMinutes: targetTime,
        clues: widget.hunt?.clues ?? {},
        // ============================================================
        // NEU: Speichert die Item-Daten mit ab
        // ============================================================
        items: widget.hunt?.items ?? {}, // Behält die Item-Bibliothek bei
        startingItemIds: _selectedStartItemIds.toList(), // Speichert die Auswahl
      );

      if (widget.hunt == null) {
        allHunts.add(updatedHunt);
      } else {
        final index = allHunts.indexWhere((h) => h.name == widget.hunt!.name);
        if (index != -1) {
          allHunts[index] = updatedHunt;
        }
      }

      await _clueService.saveHunts(allHunts);
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hole alle verfügbaren Items für die Checkliste
    final allAvailableItems = widget.hunt?.items.values.toList() ?? [];
    allAvailableItems.sort((a,b) => a.name.compareTo(b.name));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hunt == null
            ? 'Neue Jagd erstellen'
            : 'Jagd-Einstellungen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveHunt,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name der Jagd',
                hintText: 'z.B. Schatzsuche im Park',
              ),
              validator: (value) {
                final name = value?.trim() ?? '';
                if (name.isEmpty) {
                  return 'Der Name darf nicht leer sein.';
                }
                if (widget.existingHuntNames.any((element) =>
                    element.toLowerCase() == name.toLowerCase() &&
                    name.toLowerCase() != widget.hunt?.name.toLowerCase())) {
                  return 'Eine Jagd mit diesem Namen existiert bereits.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _targetTimeController,
              decoration: const InputDecoration(
                labelText: 'Optionale Zielzeit (in Minuten)',
                hintText: 'z.B. 60 für eine Stunde',
                prefixIcon: Icon(Icons.timer_outlined),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            
            // ============================================================
            // NEU: Sektion für die Start-Ausrüstung
            // ============================================================
            const SizedBox(height: 24),
            Text('Start-Ausrüstung', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (allAvailableItems.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text('Du musst zuerst Items in der Item-Bibliothek anlegen, um sie hier auswählen zu können.', textAlign: TextAlign.center),
              )
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: allAvailableItems.map((item) {
                      return CheckboxListTile(
                        title: Text(item.name),
                        subtitle: Text(item.id, style: const TextStyle(color: Colors.grey)),
                        value: _selectedStartItemIds.contains(item.id),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _selectedStartItemIds.add(item.id);
                            } else {
                              _selectedStartItemIds.remove(item.id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
            // ============================================================
            
            const SizedBox(height: 24),
            Text('Optionales Missions-Briefing', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _briefingTextController,
              decoration: const InputDecoration(
                labelText: 'Story-Einleitung',
                hintText: 'Agent 00Sven, Ihre Mission...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              maxLines: 6,
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade700),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _briefingImagePath != null
                  ? Image.file(File(_briefingImagePath!.replaceFirst('file://', '')), fit: BoxFit.cover)
                  : const Center(child: Text('Kein Briefing-Bild')),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text('Bild auswählen'),
                ),
                const SizedBox(width: 8),
                if (_briefingImagePath != null)
                  TextButton.icon(
                    onPressed: () => setState(() => _briefingImagePath = null),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Bild entfernen'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

---
## lib/features/admin/admin_item_editor_screen.dart

```
// lib/features/admin/admin_item_editor_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../../data/models/item.dart';

class AdminItemEditorScreen extends StatefulWidget {
  final Item? existingItem;
  final List<String> existingItemIds;
  final Function(Item) onSave;

  const AdminItemEditorScreen({
    super.key,
    this.existingItem,
    required this.existingItemIds,
    required this.onSave,
  });

  @override
  State<AdminItemEditorScreen> createState() => _AdminItemEditorScreenState();
}

class _AdminItemEditorScreenState extends State<AdminItemEditorScreen> {
  final _formKey = GlobalKey<FormState>();

  // =======================================================
  // NEU: Controller und State-Variablen für Medien
  // =======================================================
  final _imagePicker = ImagePicker();
  final _audioRecorder = AudioRecorder();
  bool _isRecording = false;

  late TextEditingController _idController;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _examineTextController;
  late TextEditingController _contentController;
  late ItemContentType _selectedContentType;

  bool get _isEditing => widget.existingItem != null;

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    _idController = TextEditingController(text: item?.id ?? '');
    _nameController = TextEditingController(text: item?.name ?? '');
    _descriptionController = TextEditingController(text: item?.description ?? '');
    _examineTextController = TextEditingController(text: item?.examineText ?? '');
    _contentController = TextEditingController(text: item?.content ?? '');
    _selectedContentType = item?.contentType ?? ItemContentType.text;
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _examineTextController.dispose();
    _contentController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  // =======================================================
  // NEU: Methoden zum Auswählen und Speichern von Medien
  // =======================================================
  Future<void> _pickMedia(ImageSource source) async {
    XFile? mediaFile;
    if (_selectedContentType == ItemContentType.image) {
      mediaFile = await _imagePicker.pickImage(source: source, imageQuality: 80);
    } else if (_selectedContentType == ItemContentType.video) {
      mediaFile = await _imagePicker.pickVideo(source: source);
    }
    if (mediaFile != null) {
      await _saveMediaFile(mediaFile.path, mediaFile.name);
    }
  }

  Future<void> _toggleRecording() async {
    if (await _audioRecorder.isRecording()) {
      final path = await _audioRecorder.stop();
      if (path != null) {
        await _saveMediaFile(path, 'audio_aufnahme.m4a');
      }
      if (mounted) setState(() => _isRecording = false);
    } else {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        await _audioRecorder.start(const RecordConfig(),
            path: '${dir.path}/temp_audio');
        if (mounted) setState(() => _isRecording = true);
      }
    }
  }

  Future<void> _saveMediaFile(String originalPath, String originalName) async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_$originalName';
    final newPath = '${dir.path}/$fileName';
    await File(originalPath).copy(newPath);
    if (mounted) {
      setState(() {
        _contentController.text = 'file://$newPath';
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newItem = Item(
        id: _idController.text.trim(),
        name: _nameController.text.trim(),
        thumbnailPath: 'assets/items/placeholder.png', // Platzhalter
        contentType: _selectedContentType,
        content: _contentController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        examineText: _examineTextController.text.trim().isEmpty
            ? null
            : _examineTextController.text.trim(),
      );

      widget.onSave(newItem);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Item bearbeiten' : 'Neues Item erstellen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Speichern',
            onPressed: _submitForm,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _idController,
                decoration: const InputDecoration(
                  labelText: 'Eindeutige ID',
                  hintText: 'z.B. schluessel_rot (keine Leerzeichen)',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Die ID darf nicht leer sein.';
                  }
                  if (value.contains(' ')) {
                    return 'Die ID darf keine Leerzeichen enthalten.';
                  }
                  if (!_isEditing && widget.existingItemIds.contains(value.trim())) {
                    return 'Diese ID wird bereits verwendet.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Anzeigename',
                  hintText: 'z.B. Roter Schlüssel',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Der Name darf nicht leer sein.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text('Inhalt & Aussehen',
                  style: Theme.of(context).textTheme.titleLarge),
              const Divider(),
              const SizedBox(height: 16),
              DropdownButtonFormField<ItemContentType>(
                value: _selectedContentType,
                items: const [
                  DropdownMenuItem(value: ItemContentType.text, child: Text('Text')),
                  DropdownMenuItem(value: ItemContentType.image, child: Text('Bild')),
                  DropdownMenuItem(value: ItemContentType.audio, child: Text('Audio')),
                  DropdownMenuItem(value: ItemContentType.video, child: Text('Video')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedContentType = value;
                      _contentController.clear();
                    });
                  }
                },
                decoration: const InputDecoration(labelText: 'Typ des Inhalts'),
              ),
              const SizedBox(height: 16),
              _buildMediaContentField(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Beschreibung (Flavor Text)',
                  hintText: 'z.B. Ein alter, rostiger Schlüssel.',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _examineTextController,
                decoration: const InputDecoration(
                  labelText: '"Untersuchen"-Text (optionaler Hinweis)',
                  hintText:
                      'z.B. Bei genauerer Betrachtung siehst du die Gravur "Keller".',
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaContentField() {
    switch (_selectedContentType) {
      case ItemContentType.text:
        return TextFormField(
          controller: _contentController,
          decoration: const InputDecoration(labelText: 'Inhalt (Text)'),
          maxLines: 4,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Inhalt erforderlich' : null,
        );
      case ItemContentType.image:
      case ItemContentType.video:
        return Column(
          children: [
            TextFormField(
              controller: _contentController,
              readOnly: true,
              decoration: InputDecoration(labelText: 'Dateipfad (${_selectedContentType.name})'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Datei erforderlich' : null,
            ),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              ElevatedButton.icon(
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galerie'),
                  onPressed: () => _pickMedia(ImageSource.gallery)),
              ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Kamera'),
                  onPressed: () => _pickMedia(ImageSource.camera)),
            ]),
          ],
        );
      case ItemContentType.audio:
        return Column(
          children: [
            TextFormField(
              controller: _contentController,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Dateipfad (audio)'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Datei erforderlich' : null,
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: Icon(_isRecording ? Icons.stop : Icons.mic),
              label: Text(_isRecording ? 'Stopp' : 'Aufnehmen'),
              onPressed: _toggleRecording,
              style: ElevatedButton.styleFrom(
                  backgroundColor: _isRecording ? Colors.red : null),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
```

---
## lib/features/admin/admin_item_list_screen.dart

```
// lib/features/admin/admin_item_list_screen.dart

import 'package:flutter/material.dart';
import '../../core/services/clue_service.dart';
import '../../data/models/hunt.dart';
import '../../data/models/item.dart';
import 'admin_item_editor_screen.dart'; // NEU: Import für den Editor

class AdminItemListScreen extends StatefulWidget {
  final Hunt hunt;

  const AdminItemListScreen({super.key, required this.hunt});

  @override
  State<AdminItemListScreen> createState() => _AdminItemListScreenState();
}

class _AdminItemListScreenState extends State<AdminItemListScreen> {
  final ClueService _clueService = ClueService();
  late Map<String, Item> _items;

  @override
  void initState() {
    super.initState();
    _items = Map.from(widget.hunt.items);
  }

  // ============================================================
  // NEU: Logik zum Speichern der Änderungen
  // ============================================================
  Future<void> _saveChanges() async {
    final allHunts = await _clueService.loadHunts();
    final index = allHunts.indexWhere((h) => h.name == widget.hunt.name);
    if (index != -1) {
      allHunts[index].items = _items;
      await _clueService.saveHunts(allHunts);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Änderungen gespeichert.'), duration: Duration(seconds: 1)),
      );
    }
  }

  // ============================================================
  // NEU: Logik zum Öffnen des Editors (für Neu & Bearbeiten)
  // ============================================================
  Future<void> _openItemEditor({Item? existingItem}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminItemEditorScreen(
          existingItem: existingItem,
          existingItemIds: _items.keys.toList(),
          onSave: (newItem) {
            setState(() {
              // Wenn ein Item bearbeitet wird und seine ID sich geändert hat,
              // müssen wir das alte Item zuerst entfernen.
              if (existingItem != null && existingItem.id != newItem.id) {
                _items.remove(existingItem.id);
              }
              _items[newItem.id] = newItem;
            });
            _saveChanges();
          },
        ),
      ),
    );
  }
  
  // ============================================================
  // NEU: Logik zum Löschen eines Items
  // ============================================================
  Future<void> _deleteItem(Item item) async {
     final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Löschen bestätigen'),
        content: Text('Item "${item.name}" wirklich löschen? Es wird auch aus allen Hinweisen entfernt, die es als Belohnung oder Bedingung nutzen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('LÖSCHEN')),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _items.remove(item.id);
      });
      // TODO: Später hier die Logik ergänzen, um die Item-ID aus allen Clues zu entfernen.
      await _saveChanges();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedItems = _items.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return Scaffold(
      appBar: AppBar(
        title: Text('Items für: ${widget.hunt.name}'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Neues Item'),
        onPressed: () => _openItemEditor(), // Ruft jetzt den Editor auf
      ),
      body: _items.isEmpty
          ? const Center(
              child: Text(
                'Noch keine Items erstellt.\nTippe auf das "+", um dein erstes Item anzulegen.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: sortedItems.length,
              itemBuilder: (context, index) {
                final item = sortedItems[index];
                return ListTile(
                  leading: const Icon(Icons.inventory_2_outlined, size: 40),
                  title: Text(item.name),
                  subtitle: Text('ID: ${item.id}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_note),
                        tooltip: 'Bearbeiten',
                        onPressed: () => _openItemEditor(existingItem: item), // Ruft Editor auf
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        tooltip: 'Löschen',
                        onPressed: () => _deleteItem(item), // Ruft Löschen auf
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
```

---
## lib/features/admin/admin_login_screen.dart

```
// ============================================================
// SECTION: Imports
// ============================================================
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/services/clue_service.dart';
import 'admin_hunt_list_screen.dart'; // NEU: Importiere den neuen Hunt-List-Screen.
// import 'admin_dashboard_screen.dart'; // ALTER IMPORT: Wird nicht mehr direkt benötigt.

// ============================================================
// SECTION: AdminLoginScreen Widget
// ============================================================
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

// ============================================================
// SECTION: State-Klasse
// ============================================================
class _AdminLoginScreenState extends State<AdminLoginScreen> {
  // ============================================================
  // SECTION: State & Controller
  // ============================================================
  final TextEditingController _passwordController = TextEditingController();
  final ClueService _clueService = ClueService();
  String? _errorText;

  // ============================================================
  // SECTION: Logik
  // ============================================================
  void _checkPassword() async {
    final enteredPassword = _passwordController.text.trim();
    final storedPassword = await _clueService.loadAdminPassword();

    final today = DateTime.now();
    final formattedDate = DateFormat('ddMMyyyy').format(today);
    final backupPassword = 'admin$formattedDate';

    if (enteredPassword == storedPassword || enteredPassword == backupPassword) {
      // ============================================================
      // KORREKTUR: Das Navigationsziel wurde geändert.
      // Statt zum alten Dashboard navigieren wir jetzt zur neuen Liste der Schnitzeljagden.
      // ============================================================
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminHuntListScreen()),
      );
    } else {
      setState(() {
        _errorText = 'Falsches Passwort';
      });
    }
  }

  // ============================================================
  // SECTION: UI-Aufbau (build-Methode)
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Login')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Admin-Zugang',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Passwort eingeben',
                errorText: _errorText,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _checkPassword(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkPassword,
              child: const Text('Einloggen'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---
## lib/features/admin/widgets/clue_basic_info_section.dart

```
// lib/features/admin/widgets/clue_basic_info_section.dart

import 'package:flutter/material.dart';
import '../../../data/models/hunt.dart';

class ClueBasicInfoSection extends StatelessWidget {
  final TextEditingController codeController;
  final String? codeToEdit;
  final List<String> existingCodes;
  final String? selectedRequiredItemId;
  final Hunt hunt;
  final Function(String?) onRequiredItemChanged;

  const ClueBasicInfoSection({
    super.key,
    required this.codeController,
    this.codeToEdit,
    required this.existingCodes,
    this.selectedRequiredItemId,
    required this.hunt,
    required this.onRequiredItemChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basis-Informationen',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: codeController,
          decoration: const InputDecoration(labelText: 'Eindeutiger Code der Station'),
          validator: (value) {
            final code = value?.trim() ?? '';
            if (code.isEmpty) return 'Der Code ist ein Pflichtfeld.';
            if (codeToEdit == null && existingCodes.contains(code)) {
              return 'Dieser Code existiert bereits.';
            }
            if (codeToEdit != null && code != codeToEdit && existingCodes.contains(code)) {
              return 'Dieser Code existiert bereits.';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        _buildItemDropdown(
          label: 'Benötigtes Item (optional)',
          hint: 'Spieler muss dieses Item besitzen, um den Inhalt zu sehen',
          currentValue: selectedRequiredItemId,
          onChanged: onRequiredItemChanged,
        ),
      ],
    );
  }

  Widget _buildItemDropdown({
    required String label,
    required String hint,
    required String? currentValue,
    required ValueChanged<String?> onChanged,
  }) {
    final items = hunt.items.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    final dropdownItems = [
      const DropdownMenuItem<String>(
        value: null,
        child: Text('Kein Item', style: TextStyle(fontStyle: FontStyle.italic)),
      ),
      ...items.map((item) {
        return DropdownMenuItem<String>(
          value: item.id,
          child: Text(item.name),
        );
      }),
    ];

    return DropdownButtonFormField<String>(
      value: currentValue,
      items: dropdownItems,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
    );
  }
}
```

---
## lib/features/admin/widgets/clue_content_section.dart

```
// lib/features/admin/widgets/clue_content_section.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/clue.dart';

class ClueContentSection extends StatelessWidget {
  final String type;
  final Function(String?) onTypeChanged;
  final TextEditingController contentController;
  final TextEditingController descriptionController;
  final ImageEffect imageEffect;
  final Function(ImageEffect?) onImageEffectChanged;
  final TextEffect textEffect;
  final Function(TextEffect?) onTextEffectChanged;
  final bool isRecording;
  final Function(ImageSource) onPickMedia;
  final VoidCallback onToggleRecording;

  const ClueContentSection({
    super.key,
    required this.type,
    required this.onTypeChanged,
    required this.contentController,
    required this.descriptionController,
    required this.imageEffect,
    required this.onImageEffectChanged,
    required this.textEffect,
    required this.onTextEffectChanged,
    required this.isRecording,
    required this.onPickMedia,
    required this.onToggleRecording,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Stations-Inhalt',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: type,
          items: const [
            DropdownMenuItem(value: 'text', child: Text('Text')),
            DropdownMenuItem(value: 'image', child: Text('Bild')),
            DropdownMenuItem(value: 'audio', child: Text('Audio')),
            DropdownMenuItem(value: 'video', child: Text('Video')),
          ],
          onChanged: onTypeChanged,
          decoration: const InputDecoration(labelText: 'Typ des Inhalts'),
        ),
        const SizedBox(height: 8),
        _buildMediaContentField(),
      ],
    );
  }

  Widget _buildMediaContentField() {
    return Column(
      children: [
        if (type == 'text')
          ...[
            TextFormField(
              controller: contentController,
              decoration: const InputDecoration(labelText: 'Inhalt (Text)'),
              maxLines: 3,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Inhalt erforderlich' : null,
            ),
            const SizedBox(height: 8),
            _buildTextEffectField(),
            TextFormField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Beschreibung (optional)')),
          ]
        else
          ...[
            TextFormField(
              controller: contentController,
              readOnly: true,
              decoration: InputDecoration(labelText: 'Dateipfad ($type)'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Datei erforderlich' : null,
            ),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              if (type == 'image' || type == 'video') ...[
                ElevatedButton.icon(icon: const Icon(Icons.photo_library), label: const Text('Galerie'), onPressed: () => onPickMedia(ImageSource.gallery)),
                ElevatedButton.icon(icon: const Icon(Icons.camera_alt), label: const Text('Kamera'), onPressed: () => onPickMedia(ImageSource.camera)),
              ],
              if (type == 'audio')
                ElevatedButton.icon(
                  icon: Icon(isRecording ? Icons.stop : Icons.mic),
                  label: Text(isRecording ? 'Stopp' : 'Aufnehmen'),
                  onPressed: onToggleRecording,
                  style: ElevatedButton.styleFrom(backgroundColor: isRecording ? Colors.red : null),
                ),
            ]),
            const SizedBox(height: 8),
            if (type == 'image')
              _buildImageEffectField(),
            TextFormField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Beschreibung (optional)')),
          ]
      ],
    );
  }

  Widget _buildImageEffectField() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: DropdownButtonFormField<ImageEffect>(
        value: imageEffect,
        items: const [
          DropdownMenuItem(value: ImageEffect.NONE, child: Text('Kein Effekt')),
          DropdownMenuItem(value: ImageEffect.PUZZLE, child: Text('Puzzle (9 Teile)')),
          DropdownMenuItem(value: ImageEffect.INVERT_COLORS, child: Text('Farben invertieren')),
          DropdownMenuItem(value: ImageEffect.BLACK_AND_WHITE, child: Text('Schwarz-Weiß')),
        ],
        onChanged: onImageEffectChanged,
        decoration: const InputDecoration(labelText: 'Optionaler Bild-Effekt'),
      ),
    );
  }

  Widget _buildTextEffectField() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: DropdownButtonFormField<TextEffect>(
        value: textEffect,
        items: const [
          DropdownMenuItem(value: TextEffect.NONE, child: Text('Kein Effekt')),
          DropdownMenuItem(value: TextEffect.MORSE_CODE, child: Text('Morsecode')),
          DropdownMenuItem(value: TextEffect.REVERSE, child: Text('Text rückwärts')),
          DropdownMenuItem(value: TextEffect.NO_VOWELS, child: Text('Ohne Vokale')),
          DropdownMenuItem(value: TextEffect.MIRROR_WORDS, child: Text('Wörter spiegeln')),
        ],
        onChanged: onTextEffectChanged,
        decoration: const InputDecoration(labelText: 'Optionaler Text-Effekt'),
      ),
    );
  }
}
```

---
## lib/features/admin/widgets/clue_riddle_section.dart

```
// lib/features/admin/widgets/clue_riddle_section.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/models/clue.dart';
import '../../../data/models/hunt.dart';

class ClueRiddleSection extends StatelessWidget {
  // Controllers
  final TextEditingController questionController;
  final TextEditingController answerController;
  final TextEditingController hint1Controller;
  final TextEditingController hint2Controller;
  final TextEditingController option1Controller;
  final TextEditingController option2Controller;
  final TextEditingController option3Controller;
  final TextEditingController option4Controller;
  final TextEditingController decisionCode1Controller;
  final TextEditingController decisionCode2Controller;
  final TextEditingController decisionCode3Controller;
  final TextEditingController decisionCode4Controller;
  final TextEditingController latitudeController;
  final TextEditingController longitudeController;
  final TextEditingController radiusController;
  final TextEditingController rewardTextController;
  final TextEditingController nextClueCodeController;

  // State Variables
  final RiddleType riddleType;
  final bool isFetchingLocation;
  final String? backgroundImagePath;
  final String? selectedRewardItemId;
  final bool isFinalClue;
  final bool autoTriggerNextClue;
  final Hunt hunt;

  // Callbacks
  final Function(RiddleType?) onRiddleTypeChanged;
  final VoidCallback onGetCurrentLocation;
  final VoidCallback onPickGpsBackgroundImage;
  final VoidCallback onRemoveGpsBackgroundImage;
  final Function(String?) onRewardItemChanged;
  final Function(bool?) onFinalClueChanged;
  final Function(bool?) onAutoTriggerChanged;

  const ClueRiddleSection({
    super.key,
    required this.questionController,
    required this.answerController,
    required this.hint1Controller,
    required this.hint2Controller,
    required this.option1Controller,
    required this.option2Controller,
    required this.option3Controller,
    required this.option4Controller,
    required this.decisionCode1Controller,
    required this.decisionCode2Controller,
    required this.decisionCode3Controller,
    required this.decisionCode4Controller,
    required this.latitudeController,
    required this.longitudeController,
    required this.radiusController,
    required this.rewardTextController,
    required this.nextClueCodeController,
    required this.riddleType,
    required this.isFetchingLocation,
    this.backgroundImagePath,
    this.selectedRewardItemId,
    required this.isFinalClue,
    required this.autoTriggerNextClue,
    required this.hunt,
    required this.onRiddleTypeChanged,
    required this.onGetCurrentLocation,
    required this.onPickGpsBackgroundImage,
    required this.onRemoveGpsBackgroundImage,
    required this.onRewardItemChanged,
    required this.onFinalClueChanged,
    required this.onAutoTriggerChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, 'Rätsel-Details'),
          TextFormField(
            controller: questionController,
            decoration: const InputDecoration(labelText: 'Aufgabenstellung / Frage', hintText: 'z.B. Welchen Weg schlägst du ein?'),
            validator: (v) => (v == null || v.isEmpty) ? 'Aufgabenstellung erforderlich' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<RiddleType>(
            value: riddleType,
            items: const [
              DropdownMenuItem(value: RiddleType.TEXT, child: Text('Text-Antwort')),
              DropdownMenuItem(value: RiddleType.MULTIPLE_CHOICE, child: Text('Multiple-Choice')),
              DropdownMenuItem(value: RiddleType.DECISION, child: Text('Entscheidung (Verzweigung)')),
              DropdownMenuItem(value: RiddleType.GPS, child: Text('GPS-Ort finden')),
            ],
            onChanged: onRiddleTypeChanged,
            decoration: const InputDecoration(labelText: 'Art des Rätsels'),
          ),
          const SizedBox(height: 16),
          if (riddleType == RiddleType.GPS)
            _buildGpsRiddleFields(context)
          else if (riddleType == RiddleType.DECISION)
            _buildDecisionRiddleFields(context)
          else
            _buildTextRiddleFields(context),
          const Divider(height: 40, thickness: 1),
          _buildSectionHeader(context, 'Belohnung & Nächster Schritt'),
          _buildItemDropdown(
            label: 'Belohnungs-Item (optional)',
            hint: 'Spieler erhält dieses Item nach dem Lösen des Rätsels',
            currentValue: selectedRewardItemId,
            onChanged: onRewardItemChanged,
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            title: const Text('Dies ist der finale Hinweis der Mission'),
            subtitle: const Text('Löst der Spieler dieses Rätsel, ist die Jagd beendet.'),
            value: isFinalClue,
            onChanged: onFinalClueChanged,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: rewardTextController,
            decoration: InputDecoration(
              labelText: isFinalClue ? 'Finaler Erfolgs-Text' : 'Belohnungs-Text (optional)',
              hintText: 'z.B. Gut gemacht, Agent!',
            ),
            maxLines: 3,
            validator: (v) {
              if (isFinalClue && (v == null || v.isEmpty)) {
                return 'Finaler Text ist für den letzten Hinweis erforderlich.';
              }
              return null;
            },
          ),
          if (!isFinalClue && riddleType != RiddleType.DECISION) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: nextClueCodeController,
              decoration: const InputDecoration(
                labelText: 'Code für nächsten Hinweis (optional)',
                hintText: 'z.B. ADLER3',
              ),
            ),
            CheckboxListTile(
              title: const Text('Nächsten Hinweis automatisch starten'),
              subtitle: const Text('Animiert die Eingabe des nächsten Codes.'),
              value: autoTriggerNextClue,
              onChanged: onAutoTriggerChanged,
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGpsRiddleFields(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: latitudeController,
          decoration: const InputDecoration(labelText: 'Breitengrad (Latitude)'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) => (v == null || v.isEmpty) ? 'Breitengrad erforderlich' : null,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: longitudeController,
          decoration: const InputDecoration(labelText: 'Längengrad (Longitude)'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) => (v == null || v.isEmpty) ? 'Längengrad erforderlich' : null,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: radiusController,
          decoration: const InputDecoration(labelText: 'Radius in Metern', hintText: 'z.B. 20'),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (v) => (v == null || v.isEmpty) ? 'Radius erforderlich' : null,
        ),
        const SizedBox(height: 16),
        Center(
          child: isFetchingLocation
              ? const CircularProgressIndicator()
              : ElevatedButton.icon(
                  icon: const Icon(Icons.my_location),
                  label: const Text('Aktuellen Standort eintragen'),
                  onPressed: onGetCurrentLocation,
                ),
        ),
        _buildGpsBackgroundSection(context),
      ],
    );
  }

  Widget _buildGpsBackgroundSection(BuildContext context) {
    final hasImage = backgroundImagePath != null && backgroundImagePath!.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
            child: Text(
              "GPS-Hintergrund (optional)",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          if (hasImage)
            Center(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.file(
                      File(backgroundImagePath!),
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    label: const Text('Bild entfernen', style: TextStyle(color: Colors.redAccent)),
                    onPressed: onRemoveGpsBackgroundImage,
                  ),
                ],
              ),
            )
          else
            Center(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: const Text('Hintergrundbild wählen'),
                onPressed: onPickGpsBackgroundImage,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDecisionRiddleFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text('Entscheidungs-Optionen & Ziel-Codes', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text('Gib bis zu 4 Optionen an. Für jede Option muss ein gültiger Ziel-Code einer anderen Station eingegeben werden.', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 16),
        _buildDecisionOptionRow(1, option1Controller, decisionCode1Controller),
        _buildDecisionOptionRow(2, option2Controller, decisionCode2Controller),
        _buildDecisionOptionRow(3, option3Controller, decisionCode3Controller),
        _buildDecisionOptionRow(4, option4Controller, decisionCode4Controller),
      ],
    );
  }

  Widget _buildDecisionOptionRow(int number, TextEditingController optionController, TextEditingController codeController) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: optionController,
              decoration: InputDecoration(labelText: 'Text für Option $number'),
              validator: (v) {
                if (codeController.text.isNotEmpty && (v == null || v.isEmpty)) {
                  return 'Text erforderlich';
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: codeController,
              decoration: InputDecoration(labelText: 'Ziel-Code für Option $number'),
              validator: (v) {
                if (optionController.text.isNotEmpty && (v == null || v.isEmpty)) {
                  return 'Ziel-Code erforderlich';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextRiddleFields(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: answerController,
          decoration: const InputDecoration(labelText: 'Korrekte Antwort'),
          validator: (v) => (v == null || v.isEmpty) ? 'Antwort erforderlich' : null,
        ),
        const SizedBox(height: 16),
        if (riddleType == RiddleType.MULTIPLE_CHOICE)
          _buildMultipleChoiceFields(context),
        const SizedBox(height: 16),
        _buildSectionHeader(context, 'Gestaffelte Hilfe (Optional)'),
        TextFormField(controller: hint1Controller, decoration: const InputDecoration(labelText: 'Hilfe nach 2 Fehlversuchen')),
        const SizedBox(height: 8),
        TextFormField(controller: hint2Controller, decoration: const InputDecoration(labelText: 'Hilfe nach 4 Fehlversuchen')),
      ],
    );
  }

  Widget _buildMultipleChoiceFields(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 8),
      Text('Multiple-Choice Optionen', style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 8),
      TextFormField(controller: option1Controller, decoration: const InputDecoration(labelText: 'Option 1')),
      const SizedBox(height: 8),
      TextFormField(controller: option2Controller, decoration: const InputDecoration(labelText: 'Option 2')),
      const SizedBox(height: 8),
      TextFormField(controller: option3Controller, decoration: const InputDecoration(labelText: 'Option 3')),
      const SizedBox(height: 8),
      TextFormField(controller: option4Controller, decoration: const InputDecoration(labelText: 'Option 4')),
    ]);
  }

  Widget _buildItemDropdown({
    required String label,
    required String hint,
    required String? currentValue,
    required ValueChanged<String?> onChanged,
  }) {
    final items = hunt.items.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    final dropdownItems = [
      const DropdownMenuItem<String>(
        value: null,
        child: Text('Kein Item', style: TextStyle(fontStyle: FontStyle.italic)),
      ),
      ...items.map((item) {
        return DropdownMenuItem<String>(
          value: item.id,
          child: Text(item.name),
        );
      }),
    ];

    return DropdownButtonFormField<String>(
      value: currentValue,
      items: dropdownItems,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20)),
    );
  }
}
```

---
## lib/features/clue/clue_detail_screen.dart

```
// lib/features/clue/clue_detail_screen.dart

import 'dart:async';
import 'package:clue_master/features/clue/gps_navigation_screen.dart';
import 'package:clue_master/features/shared/game_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:clue_master/features/clue/mission_evaluation_screen.dart';

import '../../core/services/clue_service.dart';
import '../../core/services/sound_service.dart';
import '../../data/models/clue.dart';
import '../../data/models/hunt.dart';
import '../../data/models/hunt_progress.dart';
import '../shared/media_widgets.dart';

class ClueDetailScreen extends StatefulWidget {
  final Hunt hunt;
  final Clue clue;
  final HuntProgress huntProgress;

  const ClueDetailScreen({
    super.key,
    required this.hunt,
    required this.clue,
    required this.huntProgress,
  });

  @override
  State<ClueDetailScreen> createState() => _ClueDetailScreenState();
}

class _ClueDetailScreenState extends State<ClueDetailScreen> {
  final _answerController = TextEditingController();
  final _clueService = ClueService();
  final _scrollController = ScrollController();
  final _soundService = SoundService();

  bool _isSolved = false;
  String? _errorMessage;
  bool _contentVisible = false;
  int _localFailedAttempts = 0;
  bool _hint1Triggered = false;
  bool _hint2Triggered = false;
  Timer? _stopwatchTimer;
  Duration _elapsedDuration = Duration.zero;
  bool _hasAccess = false;

  @override
  void initState() {
    super.initState();
    _checkAccess();
    _isSolved = widget.clue.solved;

    if (_hasAccess && !widget.clue.hasBeenViewed) {
      widget.clue.hasBeenViewed = true;
      _saveHuntProgressInHuntFile(widget.clue);
    }

    _startStopwatch();

    Timer(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _contentVisible = true);
    });
  }

  @override
  void dispose() {
    _answerController.dispose();
    _scrollController.dispose();
    _soundService.dispose();
    _stopwatchTimer?.cancel();
    super.dispose();
  }

  void _checkAccess() {
    final requiredItemId = widget.clue.requiredItemId;
    if (requiredItemId == null || requiredItemId.isEmpty) {
      _hasAccess = true;
      return;
    }
    _hasAccess = widget.huntProgress.collectedItemIds.contains(requiredItemId);
  }

  void _startStopwatch() {
    if (widget.huntProgress.startTime == null || _stopwatchTimer?.isActive == true) return;
    _elapsedDuration = widget.huntProgress.duration;
    _stopwatchTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final duration = widget.huntProgress.duration;
      if (mounted) {
        setState(() {
          _elapsedDuration = duration;
        });
      }
    });
  }

  Future<void> _saveHuntProgressInHuntFile(Clue clueToSave) async {
    final allHunts = await _clueService.loadHunts();
    final huntIndex = allHunts.indexWhere((h) => h.name == widget.hunt.name);
    if (huntIndex != -1) {
      final clueKey = clueToSave.code;
      if (allHunts[huntIndex].clues.containsKey(clueKey)) {
        allHunts[huntIndex].clues[clueKey] = clueToSave;
        await _clueService.saveHunts(allHunts);
      }
    }
  }

  void _checkAnswer({String? userAnswer}) async {
    final correctAnswer = widget.clue.answer?.trim().toLowerCase();
    final providedAnswer = (userAnswer ?? _answerController.text).trim().toLowerCase();

    if (correctAnswer == providedAnswer) {
      await _solveRiddle();
    } else {
      Vibration.vibrate(pattern: [0, 200, 100, 200]);
      _soundService.playSound(SoundEffect.failure);
      setState(() {
        _localFailedAttempts++;
        widget.huntProgress.failedAttempts++;
        _errorMessage = 'Leider falsch. Versuch es nochmal!';
      });

      Timer(const Duration(seconds: 3), () {
        if (mounted) {
          _answerController.clear();
          setState(() => _errorMessage = null);
        }
      });
    }
  }

  void _startGpsNavigation() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => GpsNavigationScreen(clue: widget.clue),
      ),
    );

    if (result == true) {
      await _solveRiddle();
    }
  }

  Future<void> _solveRiddle() async {
    if (!mounted || _isSolved) return;

    Vibration.vibrate(duration: 100);
    _soundService.playSound(SoundEffect.success);

    _awardItemReward();

    widget.clue.solved = true;
    await _saveHuntProgressInHuntFile(widget.clue);

    if (mounted) {
      setState(() {
        _isSolved = true;
      });
    }

    if (widget.clue.isFinalClue) {
      widget.huntProgress.endTime = DateTime.now();
      _stopwatchTimer?.cancel();

      if (mounted) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => MissionEvaluationScreen(
                  hunt: widget.hunt,
                  progress: widget.huntProgress,
                ),
              ),
            );
          }
        });
      }
    }
  }
  
  // ============================================================
  // NEU: Logik für die Entscheidung
  // ============================================================
  /// Behandelt die Auswahl einer Entscheidung, löst das Rätsel und navigiert weiter.
  Future<void> _makeDecision(int choiceIndex) async {
    if (!mounted || _isSolved) return;

    // Eine Entscheidung zu treffen, gilt als das Lösen des Rätsels.
    Vibration.vibrate(duration: 50);
    _soundService.playSound(SoundEffect.buttonClick);
    
    // Führe die Standard-Aktionen beim Lösen aus (z.B. Item-Belohnung geben)
    _awardItemReward();

    widget.clue.solved = true;
    await _saveHuntProgressInHuntFile(widget.clue);

    if (mounted) {
      setState(() {
        _isSolved = true;
      });
    }

    // Finde den passenden nächsten Code basierend auf der getroffenen Wahl.
    String? nextCode;
    if (widget.clue.decisionNextClueCodes != null && widget.clue.decisionNextClueCodes!.length > choiceIndex) {
      nextCode = widget.clue.decisionNextClueCodes![choiceIndex];
    }
    
    // Gehe zurück zum HomeScreen und übergebe den neuen Code für die Animation.
    if (mounted) {
      Navigator.of(context).pop(nextCode);
    }
  }

  void _awardItemReward() {
    final rewardItemId = widget.clue.rewardItemId;
    if (rewardItemId != null && rewardItemId.isNotEmpty) {
      if (widget.huntProgress.collectedItemIds.add(rewardItemId)) {
        final item = widget.hunt.items[rewardItemId];
        final itemName = item?.name ?? 'unbekannter Gegenstand';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.inventory_2_outlined, color: Colors.amber),
                const SizedBox(width: 8),
                Text('Gegenstand erhalten: $itemName'),
              ],
            ),
            backgroundColor: Colors.green[800],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GameHeader(
        hunt: widget.hunt,
        huntProgress: widget.huntProgress,
        elapsedTime: _elapsedDuration,
      ),
      body: _hasAccess 
          ? _buildClueContent() 
          : _buildAccessDeniedScreen(),
    );
  }

  Widget _buildClueContent() {
    final bool hasNextCode = _isSolved && (widget.clue.nextClueCode?.isNotEmpty ?? false);
    final String buttonText = hasNextCode ? 'Zur nächsten Station' : 'Nächsten Code eingeben';
    
    // Der "Weiter"-Button am Ende wird bei Entscheidungs-Rätseln nicht angezeigt.
    final bool showPrimaryButton = !widget.clue.isDecisionRiddle && (!widget.clue.isRiddle || _isSolved);

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              child: AnimatedOpacity(
                opacity: _contentVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Column(
                  children: [
                    buildMediaWidgetForClue(clue: widget.clue),
                    const SizedBox(height: 16),
                    if (widget.clue.isRiddle) ...[
                      const Divider(
                          height: 24, thickness: 1, color: Colors.white24),
                      if (_isSolved)
                        _buildRewardWidget()
                      else
                        _buildRiddleWidget(),
                    ]
                  ],
                ),
              ),
            ),
          ),
          if (showPrimaryButton)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  Vibration.vibrate(duration: 50);
                  _soundService.playSound(SoundEffect.buttonClick);
                  Navigator.of(context).pop(widget.clue.nextClueCode);
                },
                child: Text(buttonText),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildAccessDeniedScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 80, color: Colors.red.shade300),
            const SizedBox(height: 16),
            const Text(
              'Zugriff gesperrt',
              style: TextStyle(fontSize: 24, color: Colors.white, fontFamily: 'SpecialElite'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Du benötigst einen bestimmten Gegenstand, um diese Information entschlüsseln zu können. Suche an anderen Orten weiter.',
              style: TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
             ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Zurück zur Code-Eingabe'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardWidget() {
     return Card(
      color: Colors.green.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline,
                color: Colors.greenAccent.withOpacity(0.8), size: 40),
            const SizedBox(height: 12),
            Text(
              widget.clue.rewardText ?? 'Gut gemacht!',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiddleWidget() {
    switch (widget.clue.riddleType) {
      case RiddleType.GPS:
        return _buildGpsRiddlePrompt();
      case RiddleType.MULTIPLE_CHOICE:
        return _buildTextualRiddleWidget(isMultipleChoice: true);
      // ============================================================
      // NEU: Behandelt den neuen Rätseltyp
      // ============================================================
      case RiddleType.DECISION:
        return _buildDecisionRiddleWidget();
      case RiddleType.TEXT:
      default:
        return _buildTextualRiddleWidget(isMultipleChoice: false);
    }
  }

  // ============================================================
  // NEU: Widget zum Anzeigen der Entscheidungs-Buttons
  // ============================================================
  Widget _buildDecisionRiddleWidget() {
    return Column(
      children: [
        Text(
          widget.clue.question!,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        // Erzeugt für jede definierte Option einen Button
        ...List.generate(widget.clue.options?.length ?? 0, (index) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            child: ElevatedButton(
              onPressed: () => _makeDecision(index),
              child: Text(widget.clue.options![index], style: const TextStyle(fontSize: 16)),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildGpsRiddlePrompt() {
    return Column(
      children: [
        Text(
          widget.clue.question!,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          icon: const Icon(Icons.explore_outlined),
          label: const Text('Navigation zum Zielort starten'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(fontSize: 16),
          ),
          onPressed: _startGpsNavigation,
        ),
      ],
    );
  }

  Widget _buildTextualRiddleWidget({required bool isMultipleChoice}) {
    if (_localFailedAttempts >= 2 && widget.clue.hint1 != null && !_hint1Triggered) {
      widget.huntProgress.hintsUsed++;
      _hint1Triggered = true;
    }
    if (_localFailedAttempts >= 4 && widget.clue.hint2 != null && !_hint2Triggered) {
      widget.huntProgress.hintsUsed++;
      _hint2Triggered = true;
    }

    return Column(
      children: [
        Text(
          widget.clue.question!,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        isMultipleChoice
            ? _buildMultipleChoiceOptions()
            : _buildTextAnswerField(),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(_errorMessage!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 16)),
          ),
        if (_localFailedAttempts >= 2 && widget.clue.hint1 != null)
          _buildHintCard(1, widget.clue.hint1!),
        if (_localFailedAttempts >= 4 && widget.clue.hint2 != null)
          _buildHintCard(2, widget.clue.hint2!),
      ],
    );
  }

  Widget _buildMultipleChoiceOptions() {
     return Column(
      children: (widget.clue.options ?? []).map((option) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: ElevatedButton(
            onPressed: () => _checkAnswer(userAnswer: option),
            child: Text(option, style: const TextStyle(fontSize: 16)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextAnswerField() {
     return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _answerController,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(hintText: 'Antwort...'),
            onSubmitted: (_) => _checkAnswer(),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
            ],
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          style: IconButton.styleFrom(backgroundColor: Colors.amber),
          icon: const Icon(Icons.send, color: Colors.black),
          onPressed: () => _checkAnswer(),
        ),
      ],
    );
  }

  Widget _buildHintCard(int level, String hintText) {
     return Card(
      margin: const EdgeInsets.only(top: 24),
      color: Colors.amber.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            const Icon(Icons.lightbulb_outline, color: Colors.amber),
            const SizedBox(width: 12),
            Expanded(child: Text("Hilfe $level: $hintText")),
          ],
        ),
      ),
    ); 
  }
}
```

---
## lib/features/clue/clue_list_screen.dart

```
// lib/features/clue/clue_list_screen.dart

import 'package:clue_master/features/home/home_screen.dart';
import 'package:flutter/material.dart';
import '../../data/models/clue.dart';
import '../../data/models/hunt.dart';
import '../../data/models/hunt_progress.dart';
import 'clue_detail_screen.dart';

class ClueListScreen extends StatefulWidget {
  final Hunt hunt;
  final HuntProgress huntProgress;

  const ClueListScreen({
    super.key,
    required this.hunt,
    required this.huntProgress,
  });

  @override
  State<ClueListScreen> createState() => _ClueListScreenState();
}

class _ClueListScreenState extends State<ClueListScreen> {
  @override
  Widget build(BuildContext context) {
    final viewedEntries = widget.hunt.clues.entries
        .where((entry) => entry.value.hasBeenViewed)
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Scaffold(
      appBar: AppBar(title: const Text('Missions-Logbuch')),
      body: viewedEntries.isEmpty
          ? const Center(child: Text('Noch keine Hinweise gefunden.'))
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    itemCount: viewedEntries.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final code = viewedEntries[index].key;
                      final clue = viewedEntries[index].value;

                      IconData leadingIcon;
                      switch (clue.type) {
                        case 'text':
                          leadingIcon = Icons.description_outlined;
                          break;
                        case 'image':
                          leadingIcon = Icons.image_outlined;
                          break;
                        case 'audio':
                          leadingIcon = Icons.audiotrack_outlined;
                          break;
                        case 'video':
                          leadingIcon = Icons.movie_outlined;
                          break;
                        default:
                          leadingIcon = Icons.visibility_outlined;
                      }

                      if (clue.isGpsRiddle) {
                        leadingIcon = Icons.location_on_outlined;
                      } else if (clue.isRiddle) {
                        leadingIcon = Icons.extension_outlined;
                      }

                      // =======================================================
                      // NEUE LOGIK FÜR DEN UNTERTITEL
                      // =======================================================
                      Widget subtitleWidget;
                      final originalSubtitleText = Text(
                        clue.question ?? clue.description ?? clue.content,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );

                      if (clue.solved &&
                          clue.nextClueCode != null &&
                          clue.nextClueCode!.isNotEmpty) {
                        subtitleWidget = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            originalSubtitleText,
                            const SizedBox(height: 4),
                            Text(
                              'Nächster Code: ${clue.nextClueCode}',
                              style: TextStyle(
                                  color: Colors.amber[300],
                                  fontStyle: FontStyle.italic),
                            ),
                          ],
                        );
                      } else {
                        subtitleWidget = originalSubtitleText;
                      }
                      // =======================================================

                      return ListTile(
                        leading: Icon(
                          leadingIcon,
                          color: clue.solved ? Colors.greenAccent : Colors.white,
                        ),
                        title: Text('Code: $code'),
                        subtitle: subtitleWidget, // Hier das neue Widget einfügen
                        trailing: clue.solved
                            ? const Icon(Icons.check_circle,
                                color: Colors.greenAccent)
                            : (clue.isRiddle
                                ? const Icon(Icons.lock_open_outlined)
                                : null),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ClueDetailScreen(
                                hunt: widget.hunt,
                                clue: clue,
                                huntProgress: widget.huntProgress,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                // =======================================================
                // NEU: BUTTON AM ENDE DER LISTE
                // =======================================================
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      Navigator.of(context).popUntil(
                          ModalRoute.withName(HomeScreen.routeName));
                    },
                    icon: const Icon(Icons.keyboard_outlined),
                    label: const Text('Neuen Code eingeben'),
                  ),
                ),
              ],
            ),
    );
  }
}
```

---
## lib/features/clue/gps_navigation_screen.dart

```
// lib/features/clue/gps_navigation_screen.dart

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:clue_master/data/models/clue.dart'; // Passe den Import-Pfad ggf. an

class GpsNavigationScreen extends StatefulWidget {
  final Clue clue;

  const GpsNavigationScreen({super.key, required this.clue});

  @override
  State<GpsNavigationScreen> createState() => _GpsNavigationScreenState();
}

class _GpsNavigationScreenState extends State<GpsNavigationScreen> {
  StreamSubscription<Position>? _positionStream;
  StreamSubscription<CompassEvent>? _compassStream;

  double _distanceInMeters = double.infinity;
  double? _heading = 0; // Für die Kompass-Ausrichtung
  bool _isNearby = false;

  @override
  void initState() {
    super.initState();
    _startListeningToLocation();
    _startListeningToCompass();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _compassStream?.cancel();
    super.dispose();
  }

  void _startListeningToCompass() {
    // Nur starten, wenn das Event-Stream verfügbar ist
    if (FlutterCompass.events != null) {
      _compassStream = FlutterCompass.events!.listen((CompassEvent event) {
        if (mounted) { // Sicherstellen, dass das Widget noch im Baum ist
          setState(() {
            _heading = event.heading;
          });
        }
      });
    }
  }

  void _startListeningToLocation() async {
    // Deine bisherige Logik zum Starten des Location-Services bleibt größtenteils gleich.
    // Wichtig ist, dass die Berechtigungen etc. hier korrekt abgefragt werden.
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Handle den Fall, dass die Ortungsdienste deaktiviert sind
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Handle den Fall, dass die Berechtigung verweigert wurde
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Handle den Fall, dass die Berechtigung dauerhaft verweigert wurde
      return;
    }

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 1, // Aktualisiert bei jeder Meter-Änderung
    );

    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      if (position != null && widget.clue.latitude != null && widget.clue.longitude != null && mounted) {
        setState(() {
          _distanceInMeters = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            widget.clue.latitude!,
            widget.clue.longitude!,
          );
          _isNearby = _distanceInMeters <= (widget.clue.radius ?? 15);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lade das Hintergrundbild nur, wenn ein Pfad vorhanden ist
    final backgroundImage = widget.clue.backgroundImagePath != null && widget.clue.backgroundImagePath!.isNotEmpty
        ? FileImage(File(widget.clue.backgroundImagePath!))
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.clue.description ?? 'GPS-Navigation'),
        backgroundColor: Colors.transparent, // Transparent machen
        elevation: 0,
      ),
      extendBodyBehindAppBar: true, // Lässt den Body hinter die AppBar rücken
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Das Hintergrundbild (wenn vorhanden)
          if (backgroundImage != null)
            Image(
              image: backgroundImage,
              fit: BoxFit.cover,
              // Dunkler Filter für bessere Lesbarkeit des Vordergrunds
              color: Colors.black.withOpacity(0.3),
              colorBlendMode: BlendMode.darken,
            ),
          
          // Wenn kein Bild da ist, ein Standard-Gradient
          if (backgroundImage == null)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade800, Colors.black],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              ),
            ),

          // 2. Die Kompassnadel
          Center(
            child: Transform.rotate(
              // Rotiert die Nadel basierend auf dem Kompass-Heading
              // Die Umrechnung in Bogenmaß (radians) ist wichtig
              angle: ((_heading ?? 0) * (pi / 180) * -1),
              child: Image.asset(
                'assets/images/compass_needle.png', // Pfad zur Kompassnadel-Grafik
                width: 250,
                height: 250,
              ),
            ),
          ),
          
          // 3. Die UI-Elemente (Distanz, Button etc.)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                 const Spacer(flex: 2),
                Text(
                  'Distanz zum Ziel',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    shadows: [const Shadow(blurRadius: 8, color: Colors.black87)],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _distanceInMeters == double.infinity 
                      ? 'berechne...' 
                      : '${_distanceInMeters.toStringAsFixed(0)} Meter',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: _isNearby ? Colors.greenAccent : Colors.white,
                        fontWeight: FontWeight.w900,
                        shadows: [const Shadow(blurRadius: 10, color: Colors.black)],
                      ),
                ),
                const Spacer(flex: 3), // Schiebt den unteren Teil nach unten
                if (_isNearby)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.lock_open),
                    label: const Text('Hinweis freischalten'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      // Signalisiert der vorherigen Seite, dass das GPS-Rätsel gelöst ist
                      Navigator.pop(context, true); 
                    },
                  ),
                const SizedBox(height: 60), // Platz am unteren Rand
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

---
## lib/features/clue/mission_evaluation_screen.dart

```
// lib/features/clue/mission_evaluation_screen.dart

import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

import '../../data/models/hunt.dart';
import '../../data/models/hunt_progress.dart';
import '../../core/services/clue_service.dart';

class MissionEvaluationScreen extends StatefulWidget {
  final Hunt hunt;
  final HuntProgress progress;

  const MissionEvaluationScreen({
    super.key,
    required this.hunt,
    required this.progress,
  });

  @override
  State<MissionEvaluationScreen> createState() => _MissionEvaluationScreenState();
}

class _MissionEvaluationScreenState extends State<MissionEvaluationScreen> {
  late ConfettiController _confettiController;
  final ClueService _clueService = ClueService();
  late double _score;
  late String _scoreExplanation;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 10));
    _calculateAndSaveScore();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _calculateAndSaveScore() {
    double score = 100.0;
    List<String> deductions = [];

    final hintDeduction = widget.progress.hintsUsed * 5.0;
    if (hintDeduction > 0) {
      score -= hintDeduction;
      deductions.add('Hinweise: -${hintDeduction.toInt()}%');
    }

    final targetTime = widget.hunt.targetTimeInMinutes;
    if (targetTime != null && targetTime > 0) {
      final actualDurationInMinutes = widget.progress.duration.inMinutes;

      if (actualDurationInMinutes > targetTime) {
        final overtimePercentage = (actualDurationInMinutes / targetTime) - 1.0;

        if (overtimePercentage >= 0.20) {
          score -= 20;
          deductions.add('Zeit: -20%');
        } else if (overtimePercentage >= 0.10) {
          score -= 10;
          deductions.add('Zeit: -10%');
        }
      }
    }

    _score = max(0, score);

    if (deductions.isEmpty) {
      _scoreExplanation = 'Perfekte Runde!';
    } else {
      _scoreExplanation = 'Basis: 100% | ${deductions.join(' | ')}';
    }

    if (_score >= 80) {
      _confettiController.play();
    }

    _clueService.saveHuntProgress(widget.progress);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }
  
  String _formatDistance(double meters) {
    if (meters < 10) {
      return "0 m";
    }
    if (meters < 1000) {
      return '${meters.toInt()} m';
    } else {
      final kilometers = meters / 1000;
      return '${kilometers.toStringAsFixed(1)} km';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'MISSION ERFOLGREICH!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.hunt.clues.values.firstWhere((c) => c.isFinalClue).rewardText ??
                          'Du hast es geschafft!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Divider(height: 48, thickness: 1),
                    Text(
                      'DEINE AUSWERTUNG',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 24),
                    _buildStatRow(
                      icon: Icons.timer,
                      label: 'Deine Zeit',
                      value: _formatDuration(widget.progress.duration),
                    ),
                    if (widget.hunt.targetTimeInMinutes != null) ...[
                      const SizedBox(height: 12),
                      _buildStatRow(
                        icon: Icons.flag_outlined,
                        label: 'Zielzeit',
                        // =======================================================
                        // HIER IST DIE ÄNDERUNG
                        // Wandelt die Minuten in eine Duration um und formatiert sie.
                        // =======================================================
                        value: _formatDuration(Duration(minutes: widget.hunt.targetTimeInMinutes!)),
                      ),
                    ],
                    const SizedBox(height: 12),
                    _buildStatRow(
                      icon: Icons.directions_walk,
                      label: 'Distanz (m)',
                      value: _formatDistance(widget.progress.distanceWalkedInMeters),
                    ),
                    const SizedBox(height: 12),
                    _buildStatRow(
                      icon: Icons.error_outline,
                      label: 'Fehlversuche',
                      value: widget.progress.failedAttempts.toString(),
                    ),
                    const SizedBox(height: 12),
                    _buildStatRow(
                      icon: Icons.lightbulb_outline,
                      label: 'Genutzte Hinweise',
                      value: widget.progress.hintsUsed.toString(),
                    ),
                    const Divider(height: 48, thickness: 1),
                    Text(
                      'GESAMT-SCORE:',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_score.toInt()}%',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _scoreExplanation,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 48),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      ),
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      child: const Text('Neue Jagd auswählen', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(width: 16),
        Text(label, style: const TextStyle(fontSize: 18)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ],
    );
  }
}
```

---
## lib/features/clue/mission_success_screen.dart

```
import 'dart:io';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';
import '../../core/services/sound_service.dart';
import '../../data/models/clue.dart';

class MissionSuccessScreen extends StatefulWidget {
  final Clue finalClue;

  const MissionSuccessScreen({super.key, required this.finalClue});

  @override
  State<MissionSuccessScreen> createState() => _MissionSuccessScreenState();
}

class _MissionSuccessScreenState extends State<MissionSuccessScreen> {
  late ConfettiController _confettiController;
  final SoundService _soundService = SoundService();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 10));
    _playSoundSequence();
    _confettiController.play();
  }

  void _playSoundSequence() {
    // Spielt die Fanfare (success.mp3) ab.
    _soundService.playSound(SoundEffect.success);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _soundService.dispose();
    super.dispose();
  }

  void _exitToMainMenu() {
    // Spielt den App-Start-Sound ab, bevor zum Hauptmenü zurückgekehrt wird.
    _soundService.playSound(SoundEffect.appStart);
    // Navigiert ganz an den Anfang der App (zum HuntSelectionScreen).
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2, // schießt nach unten
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.05,
              shouldLoop: false,
              colors: const [
                Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  Text(
                    'MISSION ERFÜLLT!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'SpecialElite',
                      fontSize: 36,
                      color: Colors.amber.shade200,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Zeigt die finale Botschaft an
                  _buildMediaWidget(
                    type: widget.finalClue.type,
                    content: widget.finalClue.content,
                    description: widget.finalClue.rewardText, // Der Erfolgs-Text als Beschreibung
                  ),
                  const Spacer(flex: 3),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: _exitToMainMenu,
                    child: const Text('Zurück zur Auswahl'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Diese Widgets sind Kopien aus dem clue_detail_screen, um die finale Botschaft anzuzeigen.
Widget _buildMediaWidget({required String type, required String content, String? description}) {
  Widget mediaWidget;
  switch (type) {
    case 'text':
      mediaWidget = Text(content, style: const TextStyle(fontSize: 18), textAlign: TextAlign.center);
      break;
    case 'image':
      mediaWidget = content.startsWith('file://') ? Image.file(File(content.replaceFirst('file://', ''))) : Image.asset(content);
      break;
    case 'audio':
      return _AudioPlayerWidget(path: content, description: description);
    case 'video':
      return _VideoPlayerWidget(path: content, description: description);
    default:
      mediaWidget = const Center(child: Text('Unbekannter Inhaltstyp'));
  }
  return Column(children: [ mediaWidget, if (description != null && description.isNotEmpty) ...[ const SizedBox(height: 12), Text(description, style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic), textAlign: TextAlign.center), ], ],);
}

class _AudioPlayerWidget extends StatefulWidget {
  final String path;
  final String? description;
  const _AudioPlayerWidget({required this.path, this.description});
  @override
  State<_AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<_AudioPlayerWidget> {
  final _player = AudioPlayer();
  @override
  void initState() { super.initState(); _initPlayer(); }
  Future<void> _initPlayer() async { try { if (widget.path.startsWith('file://')) { await _player.setFilePath(widget.path.replaceFirst('file://', '')); } else { await _player.setAsset(widget.path); } } catch (e) { debugPrint("Fehler beim Laden der Audio-Datei: $e"); } }
  @override
  void dispose() { _player.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) { return Column(mainAxisAlignment: MainAxisAlignment.center, children: [ const Icon(Icons.audiotrack, size: 120, color: Colors.amber), const SizedBox(height: 24), StreamBuilder<PlayerState>(stream: _player.playerStateStream, builder: (context, snapshot) { final playerState = snapshot.data; final processingState = playerState?.processingState; final playing = playerState?.playing; if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering) { return const CircularProgressIndicator(); } else if (playing != true) { return IconButton(icon: const Icon(Icons.play_circle_fill, size: 80), color: Colors.amber, onPressed: _player.play); } else if (processingState != ProcessingState.completed) { return IconButton(icon: const Icon(Icons.pause_circle_filled, size: 80), color: Colors.amber, onPressed: _player.pause); } else { return IconButton(icon: const Icon(Icons.replay_circle_filled, size: 80), color: Colors.amber, onPressed: () => _player.seek(Duration.zero)); } }), const SizedBox(height: 8), const Text("Finale Audio-Botschaft"), ], ); }
}

class _VideoPlayerWidget extends StatefulWidget {
  final String path;
  final String? description;
  const _VideoPlayerWidget({required this.path, this.description});
  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  @override
  void initState() { super.initState(); final videoFile = File(widget.path.replaceFirst('file://', '')); _controller = VideoPlayerController.file(videoFile); _initializeVideoPlayerFuture = _controller.initialize(); _controller.setLooping(false); _controller.addListener(() { if (mounted) { setState(() {}); } }); }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) { return Column(mainAxisAlignment: MainAxisAlignment.center, children: [ Center(child: FutureBuilder(future: _initializeVideoPlayerFuture, builder: (context, snapshot) { if (snapshot.connectionState == ConnectionState.done) { return Container(constraints: const BoxConstraints(maxHeight: 400), child: AspectRatio(aspectRatio: _controller.value.aspectRatio, child: VideoPlayer(_controller))); } else { return const Center(child: CircularProgressIndicator()); } })), const SizedBox(height: 24), FloatingActionButton(backgroundColor: Colors.amber, foregroundColor: Colors.black, onPressed: () { setState(() { if (_controller.value.position >= _controller.value.duration) { _controller.seekTo(Duration.zero); _controller.play(); } else if (_controller.value.isPlaying) { _controller.pause(); } else { _controller.play(); } }); }, child: Icon(_controller.value.position >= _controller.value.duration ? Icons.replay : _controller.value.isPlaying ? Icons.pause : Icons.play_arrow)), ], ); }
}
```

---
## lib/features/clue/statistics_screen.dart

```
// lib/features/clue/statistics_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/services/clue_service.dart';
import '../../data/models/hunt.dart';
import '../../data/models/hunt_progress.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final ClueService _clueService = ClueService();
  late Future<List<dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    // Lade beide Datenquellen gleichzeitig, um Wartezeiten zu optimieren
    _dataFuture = Future.wait([
      _clueService.loadHuntProgress(),
      _clueService.loadHunts(),
    ]);
  }

  // Hilfsfunktion zur Formatierung der Dauer in HH:mm:ss
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Missions-Akte'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Fehler beim Laden der Akte: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Keine Daten gefunden.'));
          }

          final List<HuntProgress> progressHistory = snapshot.data![0];
          final List<Hunt> allHunts = snapshot.data![1];

          if (progressHistory.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'Du hast noch keine Missionen abgeschlossen. Deine Erfolge werden hier angezeigt.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                ),
              ),
            );
          }

          // Gruppiere die Erfolge nach dem Namen der Jagd
          final Map<String, List<HuntProgress>> groupedProgress = {};
          for (var progress in progressHistory) {
            groupedProgress.putIfAbsent(progress.huntName, () => []).add(progress);
          }
          
          return ListView(
            padding: const EdgeInsets.all(8.0),
            children: groupedProgress.entries.map((entry) {
              final huntName = entry.key;
              final progresses = entry.value;

              // Finde die beste Leistung (kürzeste Zeit) für diese Jagd
              progresses.sort((a, b) => a.duration.compareTo(b.duration));
              final bestProgress = progresses.first;
              
              final Hunt? huntData = allHunts.firstWhere(
                (h) => h.name == huntName,
                orElse: () => Hunt(name: huntName), // Fallback, falls Jagd gelöscht wurde
              );

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        huntName,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Divider(height: 24),
                      _buildStatRow(
                        icon: Icons.emoji_events,
                        label: 'Bestzeit',
                        value: _formatDuration(bestProgress.duration),
                        iconColor: Colors.amber,
                      ),
                      const SizedBox(height: 12),
                      _buildStatRow(
                        icon: Icons.error_outline,
                        label: 'Fehlversuche (beste Runde)',
                        value: bestProgress.failedAttempts.toString(),
                      ),
                       if (huntData?.targetTimeInMinutes != null) ...[
                        const SizedBox(height: 12),
                        _buildStatRow(
                          icon: Icons.timer_outlined,
                          label: 'Zielzeit',
                          value: '${huntData!.targetTimeInMinutes} Minuten',
                        ),
                       ],
                      const SizedBox(height: 12),
                       _buildStatRow(
                        icon: Icons.replay_outlined,
                        label: 'Absolvierte Missionen',
                        value: progresses.length.toString(),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildStatRow({required IconData icon, required String label, required String value, Color? iconColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: iconColor ?? Theme.of(context).colorScheme.primary, size: 22),
        const SizedBox(width: 16),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}
```

---
## lib/features/home/briefing_screen.dart

```
import 'dart:io';
import 'package:clue_master/data/models/hunt_progress.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import '../../core/services/sound_service.dart';
import '../../data/models/hunt.dart';
import 'home_screen.dart';

class BriefingScreen extends StatefulWidget {
  final Hunt hunt;

  const BriefingScreen({super.key, required this.hunt});

  @override
  State<BriefingScreen> createState() => _BriefingScreenState();
}

class _BriefingScreenState extends State<BriefingScreen> {
  final SoundService _soundService = SoundService();

  void _acceptMission() {
    Vibration.vibrate(duration: 50);
    _soundService.playSound(SoundEffect.buttonClick);

    final huntProgress = HuntProgress(
      huntName: widget.hunt.name,
      collectedItemIds: Set<String>.from(widget.hunt.startingItemIds),
    );

    String? firstClueCode;
    if (widget.hunt.clues.isNotEmpty) {
      final upperCaseCodes = widget.hunt.clues.keys.map((k) => k.toUpperCase()).toList();
      final originalCodes = widget.hunt.clues.keys.toList();
      int index = upperCaseCodes.indexOf('STARTX');
      if (index == -1) {
        index = upperCaseCodes.indexOf('START');
      }
      if (index != -1) {
        firstClueCode = originalCodes[index];
      } else {
        firstClueCode = originalCodes.first;
      }
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          // HIER WIRD DIE ROUTE BENANNT
          settings: const RouteSettings(name: HomeScreen.routeName),
          builder: (_) => HomeScreen(
                hunt: widget.hunt,
                huntProgress: huntProgress,
                codeToAnimate: firstClueCode,
              )),
    );
  }

  @override
  void dispose() {
    _soundService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (widget.hunt.briefingImageUrl != null)
            Image.file(
              File(widget.hunt.briefingImageUrl!.replaceFirst('file://', '')),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.black,
                  child: const Center(
                      child: Icon(Icons.error_outline,
                          color: Colors.red, size: 50)),
                );
              },
            ),
          Container(
            color: Colors.black.withOpacity(0.7),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  Text(
                    'Missions-Briefing',
                    style: TextStyle(
                      fontFamily: 'SpecialElite',
                      fontSize: 28,
                      color: Colors.amber.shade200,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Divider(color: Colors.white30, height: 32),
                  Expanded(
                    flex: 5,
                    child: SingleChildScrollView(
                      child: Text(
                        widget.hunt.briefingText ?? 'Kein Briefing verfügbar.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(flex: 1),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      textStyle: const TextStyle(
                          fontSize: 18, fontFamily: 'SpecialElite'),
                    ),
                    onPressed: _acceptMission,
                    child: const Text('MISSION ANNEHMEN'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

---
## lib/features/home/home_screen.dart

```
import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:clue_master/core/services/sound_service.dart';
import 'package:clue_master/features/shared/game_header.dart';
import 'package:clue_master/features/shared/qr_scanner_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pinput/pinput.dart';
import 'package:vibration/vibration.dart';

import '../../core/services/clue_service.dart';
//import '../../data/models/clue.dart';
import '../../data/models/hunt.dart';
import '../../data/models/hunt_progress.dart';
import '../clue/clue_detail_screen.dart';
import '../../main.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class HomeScreen extends StatefulWidget {
  // =======================================================
  // DIESE ZEILE IST DER GRUND FÜR DIE FEHLER. HIER WIRD SIE HINZUGEFÜGT.
  // =======================================================
  static const String routeName = '/home_screen';

  final Hunt hunt;
  final HuntProgress huntProgress;
  final String? codeToAnimate;

  const HomeScreen({
    super.key,
    required this.hunt,
    required this.huntProgress,
    this.codeToAnimate,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _codeFocusNode = FocusNode();
  final ClueService _clueService = ClueService();
  final SoundService _soundService = SoundService();

  late Hunt _currentHunt;
  late Map<String, String> _normalizedMap;
  bool _showError = false;
  bool _isBusy = false;

  late HuntProgress _huntProgress;
  Timer? _stopwatchTimer;
  Duration _elapsedDuration = Duration.zero;

  StreamSubscription<Position>? _positionStreamSubscription;
  Position? _lastPosition;

  @override
  void initState() {
    super.initState();
    _currentHunt = widget.hunt;
    _huntProgress = widget.huntProgress;

    _initializeClues();

    if (_huntProgress.startTime != null) {
      _startStopwatch();
      _startDistanceTracking();
    }

    if (widget.codeToAnimate != null && widget.codeToAnimate!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startCodeAnimation(widget.codeToAnimate!);
      });
    } else {
      _codeFocusNode.requestFocus();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    if (!_isBusy) {
      _refreshHuntData();
    }
    _startStopwatch();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _codeController.dispose();
    _codeFocusNode.dispose();
    _soundService.dispose();
    _stopwatchTimer?.cancel();
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  void _initializeClues() {
    _normalizedMap = {
      for (var code in _currentHunt.clues.keys) code.toLowerCase(): code,
    };
  }

  Future<void> _refreshHuntData() async {
    final allHunts = await _clueService.loadHunts();
    if (!mounted) return;
    final updatedHunt = allHunts.firstWhere((h) => h.name == widget.hunt.name,
        orElse: () => _currentHunt);
    setState(() {
      _currentHunt = updatedHunt;
      _initializeClues();
    });
  }

  void _startStopwatch() {
    if (_huntProgress.startTime == null || _stopwatchTimer?.isActive == true) return;

    _stopwatchTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _elapsedDuration = _huntProgress.duration;
        });
      }
    });
  }

  void _stopStopwatch() {
    _stopwatchTimer?.cancel();
  }

  Future<void> _startDistanceTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Standortdienste sind deaktiviert.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Standortberechtigung wurde verweigert.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('Standortberechtigung wurde permanent verweigert.');
      return;
    }

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
        (Position position) {
      if (!mounted) return;

      setState(() {
        if (_lastPosition != null) {
          final distance = Geolocator.distanceBetween(
            _lastPosition!.latitude,
            _lastPosition!.longitude,
            position.latitude,
            position.longitude,
          );
          _huntProgress.distanceWalkedInMeters += distance;
        }
        _lastPosition = position;
      });
    }, onError: (error) {
      debugPrint('Fehler bei der Standortabfrage: $error');
    });
  }

  void _startCodeAnimation(String code) {
    setState(() {
      _isBusy = true;
      _showError = false;
      _codeController.clear();
    });

    int charIndex = 0;
    Timer.periodic(const Duration(milliseconds: 250), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (charIndex < code.length) {
        _soundService.playSound(SoundEffect.buttonClick);
        setState(() {
          _codeController.text += code[charIndex];
        });
        charIndex++;
      } else {
        timer.cancel();
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            _processCode(code);
          }
        });
      }
    });
  }

  void _submitManualCode() {
    if (_isBusy) return;
    Vibration.vibrate(duration: 50);
    _soundService.playSound(SoundEffect.buttonClick);
    _processCode(_codeController.text);
  }

  Future<void> _processCode(String code) async {
    if (!_isBusy) {
      setState(() {
        _isBusy = true;
      });
    }

    final input = code.trim();
    if (input.isEmpty) {
      setState(() {
        _isBusy = false;
      });
      return;
    }

    final norm = input.toLowerCase();

    if (_normalizedMap.containsKey(norm)) {
      if (_huntProgress.startTime == null) {
        setState(() {
          _huntProgress.startTime = DateTime.now();
          _startStopwatch();
          _startDistanceTracking();
        });
      }

      if (!code.toUpperCase().contains('START')) {
        _soundService.playSound(SoundEffect.clueUnlocked);
      }
      final originalCode = _normalizedMap[norm]!;
      final clue = _currentHunt.clues[originalCode]!;

      if (!mounted) return;

      _stopStopwatch();

      final nextCodeFromClue = await Navigator.push<String>(
        context,
        MaterialPageRoute(
            builder: (_) => ClueDetailScreen(
                  hunt: _currentHunt,
                  clue: clue,
                  huntProgress: _huntProgress,
                )),
      );

      await _refreshHuntData();

      setState(() {
        _showError = false;
        _codeController.clear();
      });

      final nextCodeToProcess = nextCodeFromClue ?? clue.nextClueCode;
      if (nextCodeToProcess != null && nextCodeToProcess.isNotEmpty) {
        final previousClue = _currentHunt.clues[originalCode]!;
        if (previousClue.autoTriggerNextClue) {
          _startCodeAnimation(nextCodeToProcess);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Nächster Code freigeschaltet: $nextCodeToProcess')),
          );
          _codeFocusNode.requestFocus();
          setState(() {
            _isBusy = false;
          });
        }
      } else {
        _codeFocusNode.requestFocus();
        setState(() {
          _isBusy = false;
        });
      }
    } else {
      setState(() {
        _huntProgress.failedAttempts++;
      });

      _soundService.playSound(SoundEffect.failure);
      Vibration.vibrate(pattern: [0, 200, 100, 200]);
      setState(() {
        _showError = true;
        _codeController.clear();
        _isBusy = false;
      });
      _codeFocusNode.requestFocus();
    }
  }

  Future<void> _scanAndSubmit() async {
    if (_isBusy) return;
    final code = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
    );
    if (code != null && code.isNotEmpty) {
      _processCode(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontFamily: 'SpecialElite'),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[800]!),
        borderRadius: BorderRadius.circular(8),
        color: _isBusy ? Colors.amber.withOpacity(0.1) : Colors.grey[900],
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Colors.amber),
    );

    final errorPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Colors.redAccent),
    );

    return Scaffold(
      appBar: GameHeader(
        hunt: _currentHunt,
        huntProgress: _huntProgress,
        elapsedTime: _elapsedDuration,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const AutoSizeText(
                'Missions-Code eingeben:',
                style: TextStyle(fontSize: 24),
                maxLines: 1,
              ),
              const SizedBox(height: 24),
              Pinput(
                controller: _codeController,
                focusNode: _codeFocusNode,
                length: 6,
                keyboardType: TextInputType.text,
                inputFormatters: [
                  UpperCaseTextFormatter(),
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                ],
                enabled: !_isBusy,
                onCompleted: (pin) => _submitManualCode(),
                onChanged: (_) {
                  if (_showError) setState(() => _showError = false);
                },
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                errorPinTheme: errorPinTheme,
                forceErrorState: _showError,
              ),
              SizedBox(
                height: 40,
                child: _showError
                    ? const Center(
                        child: Text(
                          'CODE UNGÜLTIG',
                          style: TextStyle(
                              color: Colors.redAccent, fontSize: 16),
                        ),
                      )
                    : null,
              ),
              const Text('oder'),
              const SizedBox(height: 8),
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: Colors.amber[200]),
                onPressed: _isBusy ? null : _scanAndSubmit,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('QR-Code scannen'),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
```

---
## lib/features/home/hunt_selection_screen.dart

```
// ignore_for_file: use_build_context_synchronously

import 'package:auto_size_text/auto_size_text.dart';
import 'package:clue_master/data/models/hunt_progress.dart';
import 'package:flutter/material.dart';
import '../../core/services/clue_service.dart';
import '../../data/models/hunt.dart';
import 'home_screen.dart';
import '../admin/admin_login_screen.dart';
import 'briefing_screen.dart';
import 'package:clue_master/features/clue/statistics_screen.dart';
import 'package:clue_master/features/shared/about_screen.dart';

class HuntSelectionScreen extends StatefulWidget {
  const HuntSelectionScreen({super.key});

  @override
  State<HuntSelectionScreen> createState() => _HuntSelectionScreenState();
}

class _HuntSelectionScreenState extends State<HuntSelectionScreen> {
  final ClueService _clueService = ClueService();
  List<Hunt> _hunts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHunts();
  }

  Future<void> _loadHunts() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final loadedHunts = await _clueService.loadHunts();
    if (mounted) {
      setState(() {
        _hunts = loadedHunts;
        _isLoading = false;
      });
    }
  }

  void _navigateToGame(Hunt hunt) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: HomeScreen.routeName),
        builder: (_) {
          if (hunt.briefingText != null &&
              hunt.briefingText!.trim().isNotEmpty) {
            return BriefingScreen(hunt: hunt);
          } else {
            final huntProgress = HuntProgress(
              huntName: hunt.name,
              collectedItemIds: Set<String>.from(hunt.startingItemIds),
            );
            return HomeScreen(
              hunt: hunt,
              huntProgress: huntProgress,
            );
          }
        },
      ),
    );
    _loadHunts();
  }

  void _selectHunt(Hunt hunt) async {
    final hasProgress = hunt.clues.values.any((clue) => clue.hasBeenViewed);

    if (hasProgress) {
      final choice = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Mission fortsetzen?'),
          content: const Text(
              'Du hast bei dieser Jagd bereits Fortschritt erzielt. Möchtest du weiterspielen oder von vorne beginnen?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'continue'),
              child: const Text('Fortsetzen'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'reset'),
              child: const Text('Neu starten'),
            ),
          ],
        ),
      );

      if (choice == 'reset') {
        await _clueService.resetHuntProgress(hunt);
        final allHunts = await _clueService.loadHunts();
        final freshHunt = allHunts.firstWhere((h) => h.name == hunt.name);
        _navigateToGame(freshHunt);
      } else if (choice == 'continue') {
        _navigateToGame(hunt);
      }
    } else {
      _navigateToGame(hunt);
    }
  }

  Future<void> _importHunt() async {
    final result = await _clueService.importHunt();
    if (!mounted) return;

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Import abgebrochen.')),
      );
    } else if (result == "ERROR") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Fehler: Die Datei konnte nicht importiert werden.'),
            backgroundColor: Colors.red),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Die Jagd "$result" wurde erfolgreich importiert.'),
            backgroundColor: Colors.green),
      );
      _loadHunts();
    }
  }

  void _navigateToAdmin() async {
    final refreshIsNeeded = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
    );

    if (refreshIsNeeded == true && mounted) {
      _loadHunts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AutoSizeText(
          'Schnitzeljagd auswählen',
          maxLines: 1,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Liste neu laden',
            onPressed: () {
              _loadHunts();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Liste wurde aktualisiert.'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.emoji_events_outlined),
            tooltip: 'Meine Erfolge',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatisticsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Über diese App',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: 'Admin-Bereich',
            onPressed: _navigateToAdmin,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hunts.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Keine Schnitzeljagden verfügbar. Bitte importiere eine .cluemaster Datei.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: _hunts.length,
                  itemBuilder: (context, index) {
                    final hunt = _hunts[index];
                    return ListTile(
                      title: Text(hunt.name),
                      subtitle: Text('${hunt.clues.length} Stationen'),
                      trailing: const Icon(Icons.play_arrow),
                      onTap: () => _selectHunt(hunt),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _importHunt,
        label: const Text('Jagd importieren'),
        icon: const Icon(Icons.file_download),
      ),
    );
  }
}
```

---
## lib/features/home/splash_screen.dart

```
import 'package:flutter/material.dart';
import 'hunt_selection_screen.dart';
import '../../core/services/sound_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SoundService _soundService = SoundService();

  @override
  void dispose() {
    _soundService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage(
                'assets/images/20211205_FamilienfotomitdemBärtigen.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withAlpha(102), // ca. 40% Abdunkelung
              BlendMode.darken,
            ),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Spacer(flex: 5),
              const Text(
                'Papa Svens\nMissionControl',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black,
                      offset: Offset(2.0, 2.0),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 5),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  textStyle: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                child: const Text('Mission starten!'),
                onPressed: () {
                  _soundService.playSound(SoundEffect.buttonClick);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HuntSelectionScreen()),
                  );
                },
              ),
              const Spacer(flex: 1),
              const Text(
                '(C) Sven Kompe, 2025',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
```

---
## lib/features/inventory/inventory_screen.dart

```
// lib/features/inventory/inventory_screen.dart

import 'package:flutter/material.dart';
import '../../data/models/hunt_progress.dart';
import '../../data/models/item.dart';
import '../../data/models/hunt.dart';
import 'item_detail_screen.dart'; // NEU: Import für den Detail-Screen

class InventoryScreen extends StatelessWidget {
  final Hunt hunt;
  final HuntProgress huntProgress;

  const InventoryScreen({
    super.key,
    required this.hunt,
    required this.huntProgress,
  });

  @override
  Widget build(BuildContext context) {
    final List<Item> collectedItems = huntProgress.collectedItemIds
        .map((itemId) => hunt.items[itemId]) 
        .where((item) => item != null)
        .cast<Item>()
        .toList();
    // Sortieren für eine konsistente Anzeige
    collectedItems.sort((a, b) => a.name.compareTo(b.name));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rucksack / Inventar'),
      ),
      body: collectedItems.isEmpty
          ? _buildEmptyState()
          : _buildItemGrid(context, collectedItems),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.backpack_outlined, size: 80, color: Colors.white38),
            SizedBox(height: 16),
            Text(
              'Dein Rucksack ist noch leer.',
              style: TextStyle(fontSize: 20, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Finde Gegenstände an Stationen oder auf deinem Weg. Sie könnten bei zukünftigen Rätseln entscheidend sein!',
              style: TextStyle(color: Colors.white54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemGrid(BuildContext context, List<Item> items) {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildItemTile(context, item);
      },
    );
  }

  Widget _buildItemTile(BuildContext context, Item item) {
    return GestureDetector(
      onTap: () {
        // ============================================================
        // GEÄNDERT: Öffnet jetzt den echten Detail-Screen
        // ============================================================
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ItemDetailScreen(item: item),
          ),
        );
      },
      child: Card(
        color: Colors.white.withOpacity(0.1),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  // Später wird hier Image.asset(item.thumbnailPath) stehen.
                  child: Icon(Icons.inventory_2_outlined, size: 40, color: Colors.amber[200]),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                item.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---
## lib/features/inventory/item_detail_screen.dart

```
// lib/features/inventory/item_detail_screen.dart

import 'package:flutter/material.dart';
import '../../data/models/item.dart';
import '../../data/models/clue.dart'; // NEU & WICHTIG: Import für Clue, ImageEffect etc.
import '../shared/media_widgets.dart';

class ItemDetailScreen extends StatelessWidget {
  final Item item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sektion 1: Der Hauptinhalt des Items (Bild, Video, etc.)
            Center(
              child: _buildMediaWidgetForItem(item),
            ),
            const SizedBox(height: 24),

            // Sektion 2: Die Beschreibung
            if (item.description != null && item.description!.isNotEmpty) ...[
              _buildSectionHeader(context, 'Beschreibung'),
              const SizedBox(height: 8),
              Text(
                item.description!,
                style: const TextStyle(fontSize: 16, height: 1.4),
              ),
              const SizedBox(height: 24),
            ],

            // Sektion 3: Der "Untersuchen"-Text für versteckte Hinweise
            if (item.examineText != null && item.examineText!.isNotEmpty) ...[
              _buildSectionHeader(context, 'Bei genauerer Betrachtung...'),
              const SizedBox(height: 8),
              Card(
                color: Colors.amber.withOpacity(0.15),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.amber),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.examineText!,
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Baut eine formatierte Überschrift für eine Sektion.
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.amber,
            fontFamily: 'SpecialElite',
          ),
    );
  }

  /// Diese Methode ist eine Kopie der Logik aus `media_widgets.dart`,
  /// aber speziell für `Item`-Objekte angepasst.
  Widget _buildMediaWidgetForItem(Item item) {
    String clueTypeString = item.contentType.toString().split('.').last;

    final dummyClue = Clue(
      code: 'dummy',
      type: clueTypeString,
      content: item.content,
      imageEffect: ImageEffect.NONE,
      textEffect: TextEffect.NONE,
    );

    return buildMediaWidgetForClue(clue: dummyClue);
  }
}
```

---
## lib/features/shared/about_screen.dart

```
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Über diese App'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'MissionControl',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SpecialElite',
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Version 1.0.0',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              SizedBox(height: 24),
              Text(
                'Eine interaktive Schnitzeljagd-Plattform, entwickelt für Abenteuer und Rätselspaß.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 40),
              Text(
                '(C) 2025 by Sven Kompe',
                style: TextStyle(fontSize: 14, color: Colors.white54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---
## lib/features/shared/game_header.dart

```
// lib/features/shared/game_header.dart

import 'package:clue_master/core/services/sound_service.dart';
import 'package:clue_master/features/admin/admin_login_screen.dart';
import 'package:flutter/material.dart';

// =======================================================
// NEU & WICHTIG: Dieser Import wird hinzugefügt
// =======================================================
import 'package:clue_master/features/home/home_screen.dart'; 
import 'package:clue_master/features/clue/clue_list_screen.dart';


import '../../data/models/hunt.dart';
import '../../data/models/hunt_progress.dart';
import '../inventory/inventory_screen.dart';

class GameHeader extends StatelessWidget implements PreferredSizeWidget {
  final Hunt hunt;
  final HuntProgress huntProgress;
  final Duration elapsedTime;

  const GameHeader({
    super.key,
    required this.hunt,
    required this.huntProgress,
    required this.elapsedTime,
  });

  @override
  Widget build(BuildContext context) {
    final soundService = SoundService();
    final totalClues = hunt.clues.length;
    final viewedClues = hunt.clues.values.where((c) => c.hasBeenViewed).length;
    final int itemCount = huntProgress.collectedItemIds.length;
    final String formattedTime =
        '${elapsedTime.inHours.toString().padLeft(2, '0')}:${(elapsedTime.inMinutes % 60).toString().padLeft(2, '0')}:${(elapsedTime.inSeconds % 60).toString().padLeft(2, '0')}';

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.black.withOpacity(0.8),
      elevation: 0,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hunt.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SpecialElite',
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatusElement(
                    icon: Icons.timer_outlined,
                    text: formattedTime,
                  ),
                  _buildStatusElement(
                    icon: Icons.flag_outlined,
                    text: 'Station: $viewedClues/$totalClues',
                  ),
                  Row(
                    children: [
                      _buildInventoryButton(context, itemCount, soundService),
                      _buildMenuButton(context, soundService),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusElement({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontFamily: 'SpecialElite',
          ),
        ),
      ],
    );
  }
  
  Widget _buildInventoryButton(BuildContext context, int itemCount, SoundService soundService) {
     return Badge(
      label: Text(itemCount.toString()),
      isLabelVisible: itemCount > 0,
      backgroundColor: Colors.blueGrey,
      textColor: Colors.white,
      smallSize: 8,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: IconButton(
        icon: const Icon(Icons.backpack_outlined),
        onPressed: () {
          soundService.playSound(SoundEffect.buttonClick);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => InventoryScreen(
                hunt: hunt,
                huntProgress: huntProgress,
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildMenuButton(BuildContext context, SoundService soundService) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.menu),
      onSelected: (value) {
        soundService.playSound(SoundEffect.buttonClick);
        if (value == 'code_entry') {
          // =======================================================
          // HIER IST DIE ENDGÜLTIGE KORREKTUR
          // =======================================================
          Navigator.of(context).popUntil(ModalRoute.withName(HomeScreen.routeName));
        } else if (value == 'list') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ClueListScreen(
                hunt: hunt,
                huntProgress: huntProgress,
              ),
            ),
          );
        } else if (value == 'admin') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AdminLoginScreen()
            ),
          );
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'code_entry',
          child: ListTile(
            leading: Icon(Icons.keyboard_return_outlined),
            title: Text('Code eingeben'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'list',
          child: ListTile(
            leading: Icon(Icons.list_alt_outlined),
            title: Text('Logbuch / Hinweise'),
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'admin',
          child: ListTile(
            leading: Icon(Icons.admin_panel_settings_outlined),
            title: Text('Admin-Bereich'),
          ),
        ),
      ],
    );
  }


  @override
  Size get preferredSize => const Size.fromHeight(80.0);
}
```

---
## lib/features/shared/media_widgets.dart

```
// lib/features/shared/media_widgets.dart

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:clue_master/data/models/clue.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';

// HINWEIS: Diese Datei ist jetzt die zentrale Anlaufstelle für alle
// Widgets, die Medieninhalte wie Text, Bilder, Audio und Video anzeigen.

Widget buildMediaWidgetForClue({required Clue clue}) {
  Widget mediaWidget;
  switch (clue.type) {
    case 'text':
      mediaWidget = _buildTextWidgetWithEffect(clue.content, clue.textEffect);
      break;
    case 'image':
      final image = clue.content.startsWith('file://')
          ? Image.file(File(clue.content.replaceFirst('file://', '')))
          : Image.asset(clue.content);

      switch (clue.imageEffect) {
        case ImageEffect.BLACK_AND_WHITE:
          mediaWidget = ColorFiltered(
            colorFilter: const ColorFilter.matrix([
              0.2126, 0.7152, 0.0722, 0, 0,
              0.2126, 0.7152, 0.0722, 0, 0,
              0.2126, 0.7152, 0.0722, 0, 0,
              0,      0,      0,      1, 0,
            ]),
            child: image,
          );
          break;
        case ImageEffect.INVERT_COLORS:
          mediaWidget = ColorFiltered(
            colorFilter: const ColorFilter.matrix([
              -1, 0,  0,  0, 255,
               0,-1,  0,  0, 255,
               0, 0, -1,  0, 255,
               0, 0,  0,  1, 0,
            ]),
            child: image,
          );
          break;
        case ImageEffect.PUZZLE:
          mediaWidget = ImagePuzzleWidget(imagePath: clue.content);
          break;
        case ImageEffect.NONE:
        default:
          mediaWidget = image;
      }
      break;
    case 'audio':
      mediaWidget = AudioPlayerWidget(path: clue.content);
      break;
    case 'video':
      mediaWidget = VideoPlayerWidget(path: clue.content);
      break;
    default:
      mediaWidget = const Center(child: Text('Unbekannter Inhaltstyp'));
  }

  return Column(
    children: [
      mediaWidget,
      if (clue.description != null && clue.description!.isNotEmpty) ...[
        const SizedBox(height: 12),
        Text(clue.description!,
            style:
                const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center),
      ],
    ],
  );
}

Widget _buildTextWidgetWithEffect(String content, TextEffect effect) {
  switch (effect) {
    case TextEffect.MORSE_CODE:
      return MorseCodeWidget(text: content);
    case TextEffect.REVERSE:
      return Text(content.split('').reversed.join(''),
          style: const TextStyle(fontSize: 18), textAlign: TextAlign.center);
    case TextEffect.NO_VOWELS:
      return Text(content.replaceAll(RegExp(r'[aeiouAEIOU]'), ''),
          style: const TextStyle(fontSize: 18), textAlign: TextAlign.center);
    case TextEffect.MIRROR_WORDS:
      final mirrored =
          content.split(' ').map((word) => word.split('').reversed.join('')).join(' ');
      return Text(mirrored,
          style: const TextStyle(fontSize: 18), textAlign: TextAlign.center);
    case TextEffect.NONE:
    default:
      return Text(content,
          style: const TextStyle(fontSize: 18), textAlign: TextAlign.center);
  }
}

class MorseCodeWidget extends StatelessWidget {
  final String text;
  const MorseCodeWidget({super.key, required this.text});

  static const Map<String, String> _morseCodeMap = {
    'A': '.-', 'B': '-...', 'C': '-.-.', 'D': '-..', 'E': '.', 'F': '..-.',
    'G': '--.', 'H': '....', 'I': '..', 'J': '.---', 'K': '-.-', 'L': '.-..',
    'M': '--', 'N': '-.', 'O': '---', 'P': '.--.', 'Q': '--.-', 'R': '.-.',
    'S': '...', 'T': '-', 'U': '..-', 'V': '...-', 'W': '.--', 'X': '-..-',
    'Y': '-.--', 'Z': '--..', '1': '.----', '2': '..---', '3': '...--',
    '4': '....-', '5': '.....', '6': '-....', '7': '--...', '8': '---..',
    '9': '----.', '0': '-----', ' ': '/'
  };

  String _toMorseCode(String input) {
    return input
        .toUpperCase()
        .split('')
        .map((char) => _morseCodeMap[char] ?? '')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          _toMorseCode(text),
          style: const TextStyle(fontSize: 24, fontFamily: 'SpecialElite'),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        IconButton(
          icon: const Icon(Icons.volume_up_outlined, size: 40),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'Akustische Morsecode-Wiedergabe ist noch in Entwicklung.'),
            ));
          },
        ),
      ],
    );
  }
}

class ImagePuzzleWidget extends StatefulWidget {
  final String imagePath;
  const ImagePuzzleWidget({super.key, required this.imagePath});

  @override
  State<ImagePuzzleWidget> createState() => _ImagePuzzleWidgetState();
}

class _ImagePuzzleWidgetState extends State<ImagePuzzleWidget> {
  List<Uint8List>? _puzzlePieces;
  int? _selectedPieceIndex;

  @override
  void initState() {
    super.initState();
    _createPuzzle();
  }

  Future<void> _createPuzzle() async {
    Uint8List imageBytes;
    if (widget.imagePath.startsWith('file://')) {
      imageBytes =
          await File(widget.imagePath.replaceFirst('file://', '')).readAsBytes();
    } else {
      final byteData = await rootBundle.load(widget.imagePath);
      imageBytes = byteData.buffer.asUint8List();
    }

    final originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) return;

    final pieceWidth = originalImage.width ~/ 3;
    final pieceHeight = originalImage.height ~/ 3;
    final pieces = <Uint8List>[];
    for (int y = 0; y < 3; y++) {
      for (int x = 0; x < 3; x++) {
        final piece = img.copyCrop(originalImage,
            x: x * pieceWidth, y: y * pieceHeight, width: pieceWidth, height: pieceHeight);
        pieces.add(Uint8List.fromList(img.encodePng(piece)));
      }
    }

    pieces.shuffle(Random());

    setState(() {
      _puzzlePieces = pieces;
    });
  }

  void _onPieceTap(int index) {
    setState(() {
      if (_selectedPieceIndex == null) {
        _selectedPieceIndex = index;
      } else {
        final temp = _puzzlePieces![_selectedPieceIndex!];
        _puzzlePieces![_selectedPieceIndex!] = _puzzlePieces![index];
        _puzzlePieces![index] = temp;
        _selectedPieceIndex = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_puzzlePieces == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.0,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: 9,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _onPieceTap(index),
                child: Container(
                  decoration: BoxDecoration(
                    border: _selectedPieceIndex == index
                        ? Border.all(color: Colors.amber, width: 4)
                        : null,
                  ),
                  child: Image.memory(_puzzlePieces![index], fit: BoxFit.cover),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Tippe zwei Teile an, um sie zu tauschen.',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}

class AudioPlayerWidget extends StatefulWidget {
  final String path;
  const AudioPlayerWidget({super.key, required this.path});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      if (widget.path.startsWith('file://')) {
        final filePath = widget.path.replaceFirst('file://', '');
        await _player.setFilePath(filePath);
      } else {
        await _player.setAsset(widget.path);
      }
    } catch (e) {
      debugPrint("Fehler beim Laden der Audio-Datei: $e");
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.audiotrack, size: 120, color: Colors.amber),
        const SizedBox(height: 24),
        StreamBuilder<PlayerState>(
          stream: _player.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;

            if (processingState == ProcessingState.loading ||
                processingState == ProcessingState.buffering) {
              return const CircularProgressIndicator();
            } else if (playing != true) {
              return IconButton(
                icon: const Icon(Icons.play_circle_fill, size: 80),
                color: Colors.amber,
                onPressed: _player.play,
              );
            } else if (processingState != ProcessingState.completed) {
              return IconButton(
                icon: const Icon(Icons.pause_circle_filled, size: 80),
                color: Colors.amber,
                onPressed: _player.pause,
              );
            } else {
              return IconButton(
                icon: const Icon(Icons.replay_circle_filled, size: 80),
                color: Colors.amber,
                onPressed: () => _player.seek(Duration.zero),
              );
            }
          },
        ),
        const SizedBox(height: 8),
        const Text("Audio-Hinweis abspielen"),
      ],
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String path;
  const VideoPlayerWidget({super.key, required this.path});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    final videoFile = File(widget.path.replaceFirst('file://', ''));
    _controller = VideoPlayerController.file(videoFile);
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(false);
    _controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: FutureBuilder(
            future: _initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Container(
                  constraints: const BoxConstraints(maxHeight: 400),
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
        const SizedBox(height: 24),
        FloatingActionButton(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
          onPressed: () {
            setState(() {
              if (_controller.value.position >= _controller.value.duration) {
                _controller.seekTo(Duration.zero);
                _controller.play();
              } else if (_controller.value.isPlaying) {
                _controller.pause();
              } else {
                _controller.play();
              }
            });
          },
          child: Icon(
            _controller.value.position >= _controller.value.duration
                ? Icons.replay
                : _controller.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
          ),
        ),
      ],
    );
  }
}
```

---
## lib/features/shared/qr_scanner_screen.dart

```
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

// Wir wandeln das Widget in ein "StatefulWidget" um, damit es sich einen Zustand merken kann.
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  // Diese Variable ist unser "Gedächtnis". Am Anfang ist sie `false`.
  bool _isScanCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR-Code scannen')),
      body: MobileScanner(
        onDetect: (capture) {
          // Wir prüfen, ob wir nicht schon einen Code gescannt haben.
          if (!_isScanCompleted) {
            final List<Barcode> barcodes = capture.barcodes;
            if (barcodes.isNotEmpty) {
              final String? code = barcodes.first.rawValue;
              if (code != null && code.isNotEmpty) {
                // WICHTIG: Wir setzen die Variable sofort auf `true`.
                // Damit wird jeder weitere Scan in dieser Sitzung ignoriert.
                setState(() {
                  _isScanCompleted = true;
                });
                
                // Jetzt geben wir den Code sicher nur ein einziges Mal zurück.
                Navigator.pop(context, code);
              }
            }
          }
        },
      ),
    );
  }
}
```

---
## lib/main.dart

```
// lib/main.dart

import 'package:clue_master/features/home/splash_screen.dart';
import 'package:flutter/material.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() {
  runApp(const ClueMasterApp());
}

class ClueMasterApp extends StatelessWidget {
  const ClueMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MissionControl by Sven Kompe',
      theme: ThemeData(
        fontFamily: 'SpecialElite',
        brightness: Brightness.dark,
        primaryColor: Colors.amber,
        scaffoldBackgroundColor: const Color(0xFF212121),
        cardColor: const Color(0xFF303030),
        
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF303030),
          elevation: 4,
          centerTitle: true,
        ),

        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white70, fontSize: 16),
          bodyMedium: TextStyle(color: Colors.white70, fontSize: 14),
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(color: Colors.white),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF424242),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          hintStyle: TextStyle(color: Colors.grey[600]),
        ),
      ),
      home: const SplashScreen(),
      navigatorObservers: [routeObserver],
    );
  }
}
```

---
## linux/CMakeLists.txt

```
# Project-level configuration.
cmake_minimum_required(VERSION 3.13)
project(runner LANGUAGES CXX)

# The name of the executable created for the application. Change this to change
# the on-disk name of your application.
set(BINARY_NAME "clue_master")
# The unique GTK application identifier for this application. See:
# https://wiki.gnome.org/HowDoI/ChooseApplicationID
set(APPLICATION_ID "com.example.clue_master")

# Explicitly opt in to modern CMake behaviors to avoid warnings with recent
# versions of CMake.
cmake_policy(SET CMP0063 NEW)

# Load bundled libraries from the lib/ directory relative to the binary.
set(CMAKE_INSTALL_RPATH "$ORIGIN/lib")

# Root filesystem for cross-building.
if(FLUTTER_TARGET_PLATFORM_SYSROOT)
  set(CMAKE_SYSROOT ${FLUTTER_TARGET_PLATFORM_SYSROOT})
  set(CMAKE_FIND_ROOT_PATH ${CMAKE_SYSROOT})
  set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
  set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
  set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
  set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
endif()

# Define build configuration options.
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  set(CMAKE_BUILD_TYPE "Debug" CACHE
    STRING "Flutter build mode" FORCE)
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
    "Debug" "Profile" "Release")
endif()

# Compilation settings that should be applied to most targets.
#
# Be cautious about adding new options here, as plugins use this function by
# default. In most cases, you should add new options to specific targets instead
# of modifying this function.
function(APPLY_STANDARD_SETTINGS TARGET)
  target_compile_features(${TARGET} PUBLIC cxx_std_14)
  target_compile_options(${TARGET} PRIVATE -Wall -Werror)
  target_compile_options(${TARGET} PRIVATE "$<$<NOT:$<CONFIG:Debug>>:-O3>")
  target_compile_definitions(${TARGET} PRIVATE "$<$<NOT:$<CONFIG:Debug>>:NDEBUG>")
endfunction()

# Flutter library and tool build rules.
set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")
add_subdirectory(${FLUTTER_MANAGED_DIR})

# System-level dependencies.
find_package(PkgConfig REQUIRED)
pkg_check_modules(GTK REQUIRED IMPORTED_TARGET gtk+-3.0)

# Application build; see runner/CMakeLists.txt.
add_subdirectory("runner")

# Run the Flutter tool portions of the build. This must not be removed.
add_dependencies(${BINARY_NAME} flutter_assemble)

# Only the install-generated bundle's copy of the executable will launch
# correctly, since the resources must in the right relative locations. To avoid
# people trying to run the unbundled copy, put it in a subdirectory instead of
# the default top-level location.
set_target_properties(${BINARY_NAME}
  PROPERTIES
  RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/intermediates_do_not_run"
)


# Generated plugin build rules, which manage building the plugins and adding
# them to the application.
include(flutter/generated_plugins.cmake)


# === Installation ===
# By default, "installing" just makes a relocatable bundle in the build
# directory.
set(BUILD_BUNDLE_DIR "${PROJECT_BINARY_DIR}/bundle")
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX "${BUILD_BUNDLE_DIR}" CACHE PATH "..." FORCE)
endif()

# Start with a clean build bundle directory every time.
install(CODE "
  file(REMOVE_RECURSE \"${BUILD_BUNDLE_DIR}/\")
  " COMPONENT Runtime)

set(INSTALL_BUNDLE_DATA_DIR "${CMAKE_INSTALL_PREFIX}/data")
set(INSTALL_BUNDLE_LIB_DIR "${CMAKE_INSTALL_PREFIX}/lib")

install(TARGETS ${BINARY_NAME} RUNTIME DESTINATION "${CMAKE_INSTALL_PREFIX}"
  COMPONENT Runtime)

install(FILES "${FLUTTER_ICU_DATA_FILE}" DESTINATION "${INSTALL_BUNDLE_DATA_DIR}"
  COMPONENT Runtime)

install(FILES "${FLUTTER_LIBRARY}" DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
  COMPONENT Runtime)

foreach(bundled_library ${PLUGIN_BUNDLED_LIBRARIES})
  install(FILES "${bundled_library}"
    DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
    COMPONENT Runtime)
endforeach(bundled_library)

# Copy the native assets provided by the build.dart from all packages.
set(NATIVE_ASSETS_DIR "${PROJECT_BUILD_DIR}native_assets/linux/")
install(DIRECTORY "${NATIVE_ASSETS_DIR}"
   DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
   COMPONENT Runtime)

# Fully re-copy the assets directory on each build to avoid having stale files
# from a previous install.
set(FLUTTER_ASSET_DIR_NAME "flutter_assets")
install(CODE "
  file(REMOVE_RECURSE \"${INSTALL_BUNDLE_DATA_DIR}/${FLUTTER_ASSET_DIR_NAME}\")
  " COMPONENT Runtime)
install(DIRECTORY "${PROJECT_BUILD_DIR}/${FLUTTER_ASSET_DIR_NAME}"
  DESTINATION "${INSTALL_BUNDLE_DATA_DIR}" COMPONENT Runtime)

# Install the AOT library on non-Debug builds only.
if(NOT CMAKE_BUILD_TYPE MATCHES "Debug")
  install(FILES "${AOT_LIBRARY}" DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
    COMPONENT Runtime)
endif()
```

---
## linux/flutter/CMakeLists.txt

```
# This file controls Flutter-level build steps. It should not be edited.
cmake_minimum_required(VERSION 3.10)

set(EPHEMERAL_DIR "${CMAKE_CURRENT_SOURCE_DIR}/ephemeral")

# Configuration provided via flutter tool.
include(${EPHEMERAL_DIR}/generated_config.cmake)

# TODO: Move the rest of this into files in ephemeral. See
# https://github.com/flutter/flutter/issues/57146.

# Serves the same purpose as list(TRANSFORM ... PREPEND ...),
# which isn't available in 3.10.
function(list_prepend LIST_NAME PREFIX)
    set(NEW_LIST "")
    foreach(element ${${LIST_NAME}})
        list(APPEND NEW_LIST "${PREFIX}${element}")
    endforeach(element)
    set(${LIST_NAME} "${NEW_LIST}" PARENT_SCOPE)
endfunction()

# === Flutter Library ===
# System-level dependencies.
find_package(PkgConfig REQUIRED)
pkg_check_modules(GTK REQUIRED IMPORTED_TARGET gtk+-3.0)
pkg_check_modules(GLIB REQUIRED IMPORTED_TARGET glib-2.0)
pkg_check_modules(GIO REQUIRED IMPORTED_TARGET gio-2.0)

set(FLUTTER_LIBRARY "${EPHEMERAL_DIR}/libflutter_linux_gtk.so")

# Published to parent scope for install step.
set(FLUTTER_LIBRARY ${FLUTTER_LIBRARY} PARENT_SCOPE)
set(FLUTTER_ICU_DATA_FILE "${EPHEMERAL_DIR}/icudtl.dat" PARENT_SCOPE)
set(PROJECT_BUILD_DIR "${PROJECT_DIR}/build/" PARENT_SCOPE)
set(AOT_LIBRARY "${PROJECT_DIR}/build/lib/libapp.so" PARENT_SCOPE)

list(APPEND FLUTTER_LIBRARY_HEADERS
  "fl_basic_message_channel.h"
  "fl_binary_codec.h"
  "fl_binary_messenger.h"
  "fl_dart_project.h"
  "fl_engine.h"
  "fl_json_message_codec.h"
  "fl_json_method_codec.h"
  "fl_message_codec.h"
  "fl_method_call.h"
  "fl_method_channel.h"
  "fl_method_codec.h"
  "fl_method_response.h"
  "fl_plugin_registrar.h"
  "fl_plugin_registry.h"
  "fl_standard_message_codec.h"
  "fl_standard_method_codec.h"
  "fl_string_codec.h"
  "fl_value.h"
  "fl_view.h"
  "flutter_linux.h"
)
list_prepend(FLUTTER_LIBRARY_HEADERS "${EPHEMERAL_DIR}/flutter_linux/")
add_library(flutter INTERFACE)
target_include_directories(flutter INTERFACE
  "${EPHEMERAL_DIR}"
)
target_link_libraries(flutter INTERFACE "${FLUTTER_LIBRARY}")
target_link_libraries(flutter INTERFACE
  PkgConfig::GTK
  PkgConfig::GLIB
  PkgConfig::GIO
)
add_dependencies(flutter flutter_assemble)

# === Flutter tool backend ===
# _phony_ is a non-existent file to force this command to run every time,
# since currently there's no way to get a full input/output list from the
# flutter tool.
add_custom_command(
  OUTPUT ${FLUTTER_LIBRARY} ${FLUTTER_LIBRARY_HEADERS}
    ${CMAKE_CURRENT_BINARY_DIR}/_phony_
  COMMAND ${CMAKE_COMMAND} -E env
    ${FLUTTER_TOOL_ENVIRONMENT}
    "${FLUTTER_ROOT}/packages/flutter_tools/bin/tool_backend.sh"
      ${FLUTTER_TARGET_PLATFORM} ${CMAKE_BUILD_TYPE}
  VERBATIM
)
add_custom_target(flutter_assemble DEPENDS
  "${FLUTTER_LIBRARY}"
  ${FLUTTER_LIBRARY_HEADERS}
)
```

---
## linux/runner/CMakeLists.txt

```
cmake_minimum_required(VERSION 3.13)
project(runner LANGUAGES CXX)

# Define the application target. To change its name, change BINARY_NAME in the
# top-level CMakeLists.txt, not the value here, or `flutter run` will no longer
# work.
#
# Any new source files that you add to the application should be added here.
add_executable(${BINARY_NAME}
  "main.cc"
  "my_application.cc"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
)

# Apply the standard set of build settings. This can be removed for applications
# that need different build settings.
apply_standard_settings(${BINARY_NAME})

# Add preprocessor definitions for the application ID.
add_definitions(-DAPPLICATION_ID="${APPLICATION_ID}")

# Add dependency libraries. Add any application-specific dependencies here.
target_link_libraries(${BINARY_NAME} PRIVATE flutter)
target_link_libraries(${BINARY_NAME} PRIVATE PkgConfig::GTK)

target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")
```

---
## macos/Flutter/ephemeral/flutter_export_environment.sh

```
#!/bin/sh
# This is a generated file; do not edit or check into version control.
export "FLUTTER_ROOT=c:\flutter"
export "FLUTTER_APPLICATION_PATH=C:\Users\mail2\clue_master"
export "COCOAPODS_PARALLEL_CODE_SIGN=true"
export "FLUTTER_BUILD_DIR=build"
export "FLUTTER_BUILD_NAME=1.0.0"
export "FLUTTER_BUILD_NUMBER=1"
export "FLUTTER_CLI_BUILD_MODE=debug"
export "DART_OBFUSCATION=false"
export "TRACK_WIDGET_CREATION=true"
export "TREE_SHAKE_ICONS=false"
export "PACKAGE_CONFIG=.dart_tool/package_config.json"
```

---
## macos/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json

```
{
  "images" : [
    {
      "size" : "16x16",
      "idiom" : "mac",
      "filename" : "app_icon_16.png",
      "scale" : "1x"
    },
    {
      "size" : "16x16",
      "idiom" : "mac",
      "filename" : "app_icon_32.png",
      "scale" : "2x"
    },
    {
      "size" : "32x32",
      "idiom" : "mac",
      "filename" : "app_icon_32.png",
      "scale" : "1x"
    },
    {
      "size" : "32x32",
      "idiom" : "mac",
      "filename" : "app_icon_64.png",
      "scale" : "2x"
    },
    {
      "size" : "128x128",
      "idiom" : "mac",
      "filename" : "app_icon_128.png",
      "scale" : "1x"
    },
    {
      "size" : "128x128",
      "idiom" : "mac",
      "filename" : "app_icon_256.png",
      "scale" : "2x"
    },
    {
      "size" : "256x256",
      "idiom" : "mac",
      "filename" : "app_icon_256.png",
      "scale" : "1x"
    },
    {
      "size" : "256x256",
      "idiom" : "mac",
      "filename" : "app_icon_512.png",
      "scale" : "2x"
    },
    {
      "size" : "512x512",
      "idiom" : "mac",
      "filename" : "app_icon_512.png",
      "scale" : "1x"
    },
    {
      "size" : "512x512",
      "idiom" : "mac",
      "filename" : "app_icon_1024.png",
      "scale" : "2x"
    }
  ],
  "info" : {
    "version" : 1,
    "author" : "xcode"
  }
}
```

---
## mission_evaluation_screen.dart

```

```

---
## pubspec.yaml

```
name: clue_master
description: "A new Flutter project."
publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: '>=3.2.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  google_generative_ai: ^0.1.0 # Oder eine neuere Version, falls verfügbar.
  # GPS-Funktionalität
  geolocator: ^12.0.0
  flutter_compass: ^0.8.0
  permission_handler: ^11.3.1

  # NEU: Paket für Bildbearbeitung (Puzzle-Effekt)
  image: ^4.2.0

  path_provider: ^2.1.0
  cupertino_icons: ^1.0.0
  image_picker: ^1.0.0
  uuid: ^4.0.0
  record: ^5.0.0
  just_audio: ^0.9.36
  audio_session: ^0.1.0
  mobile_scanner: ^5.1.1
  video_player: ^2.8.6
  intl: ^0.19.0
  qr_flutter: ^4.1.0
  pinput: ^4.0.0
  vibration: ^3.1.3 # Deine stabile Version
  auto_size_text: ^3.0.0

  # Pakete für das Teilen
  archive: ^3.4.9
  share_plus: ^7.2.2

  # Paket für den Import
  file_picker: ^10.2.0
  
  confetti: ^0.7.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

dependency_overrides:
  record_linux: 1.1.1
  record_platform_interface: 1.3.0

flutter:
  uses-material-design: true
  assets:
    - assets/hunts.json
    - assets/codes.json
    - assets/images/
    - assets/audio/
    - assets/fonts/

  fonts:
    - family: SpecialElite
      fonts:
        - asset: assets/fonts/SpecialElite-Regular.ttf
```

---
## README.md

```
ClueMaster - Die interaktive Schnitzeljagd-App
Willkommen bei ClueMaster! Dieses Flutter-Projekt ist eine vielseitige und moderne Anwendung zur Erstellung und Durchführung von interaktiven Schnitzeljagden. Ob für Kindergeburtstage, Teambuilding-Events oder einfach nur zum Spaß mit Freunden – ClueMaster verwandelt jede Umgebung in ein spannendes Abenteuer.

🚀 Projektbeschreibung
ClueMaster ist in zwei Hauptbereiche unterteilt: eine intuitive Benutzeroberfläche für die Spieler und einen leistungsstarken, passwortgeschützten Admin-Bereich für den Organisator der Schnitzeljagd.

Das Ziel der App ist es, eine vollständig digitale und medienreiche Schnitzeljagd zu ermöglichen, bei der Hinweise nicht nur aus Text, sondern auch aus Bildern, Audio- und Videobotschaften bestehen können. Zusätzlich können Hinweise mit interaktiven Rätseln verknüpft werden, um das Erlebnis noch herausfordernder zu gestalten.

✨ Features
Für Spieler:
Einfache Code-Eingabe: Spieler geben einen Code ein, um den nächsten Hinweis freizuschalten.

QR-Code-Scanner: Alternativ kann ein an der Station versteckter QR-Code gescannt werden, um Tippfehler zu vermeiden.

Multimedia-Hinweise: Hinweise können als Text, Bild, Audioaufnahme oder sogar als kurzes Video angezeigt werden.

Interaktive Rätsel: An Hinweise können Fragen geknüpft sein, die erst richtig beantwortet werden müssen, um den Hinweis als "gelöst" zu markieren.

Fortschrittsanzeige: Eine Liste zeigt alle bereits gefundenen und gelösten Hinweise an.

Für den Organisator (Admin-Bereich):
Passwortgeschützt: Sicherer Zugang zur Verwaltung der Schnitzeljagd.

Vollständige Hinweis-Verwaltung: Hinweise können direkt in der App erstellt, bearbeitet und gelöscht werden.

Flexible Hinweis-Typen: Volle Unterstützung für Text, Bild, Audio, Video und optionale Rätsel.

Dynamische Medien: Bilder können aus der Galerie oder direkt von der Kamera aufgenommen werden. Audio kann direkt in der App aufgezeichnet und Videos aus der Galerie ausgewählt werden.

Spiel zurücksetzen: Mit einem Klick können alle Hinweise auf "ungelöst" zurückgesetzt werden, um die Schnitzeljagd erneut zu starten.

🛠️ Wie der Code funktioniert (Architektur)
Das Projekt ist in einer sauberen und erweiterbaren Ordnerstruktur organisiert, um die Wartung zu erleichtern.

lib/main.dart: Der Einstiegspunkt der Anwendung. Hier werden das App-Theme und die grundlegende Navigation initialisiert.

lib/data/models/clue.dart: Das Herzstück der App. Diese Datei definiert das Clue-Objekt, also den "Bauplan" für jeden Hinweis. Ein Clue enthält:

code: Der einzigartige Code des Hinweises (z.B. "GARTENTOR").

type: Definiert die Art des Hinweises (text, image, audio, video).

content: Der eigentliche Inhalt (der Text selbst oder der Dateipfad zum Medium).

description: Ein optionaler Untertitel.

solved: Ein Status, der anzeigt, ob der Hinweis gelöst wurde.

question & answer: Optionale Felder, die einen Hinweis zu einem Rätsel machen.

lib/core/services/clue_service.dart: Das "Gehirn" der Datenverwaltung. Dieser Service ist dafür verantwortlich, die codes.json-Datei aus dem Gerätespeicher zu lesen und wieder dorthin zu schreiben. Er sorgt dafür, dass alle Änderungen (neue Hinweise, gelöste Rätsel) persistent gespeichert werden.

lib/features/: Dieser Ordner enthält die Benutzeroberfläche, aufgeteilt nach Funktionen:

home/: Der Startbildschirm für die Spieler mit Code-Eingabe und QR-Scan-Option.

clue/: Die Bildschirme zur Anzeige der Hinweis-Details und der Liste der gefundenen Hinweise.

admin/: Alle Bildschirme für den passwortgeschützten Verwaltungsbereich.

shared/: Wiederverwendbare Widgets, wie z.B. der qr_scanner_screen.

assets/codes.json: Die "Datenbank" der App. Diese JSON-Datei enthält die Start-Hinweise und dient als Vorlage, die beim ersten App-Start in den beschreibbaren Speicher des Geräts kopiert wird.

💡 Zukünftige Ideen
Das Projekt hat eine solide Grundlage und kann leicht um weitere spannende Features erweitert werden:

GPS-basierte Hinweise: Schalte Hinweise erst frei, wenn der Spieler einen bestimmten geografischen Ort erreicht.

QR-Codes in der App erstellen: Generiere QR-Codes für deine Hinweise direkt im Admin-Menü, anstatt externe Tools zu verwenden.

Story & Theming: Gib deiner Schnitzeljagd ein Thema (z.B. Piraten, Agenten) und passe das Design der App entsprechend an.

Admin-Passwort ändern: Eine Funktion im Admin-Bereich, um das Passwort zu ändern.

Mehrere Schnitzeljagden: Eine Möglichkeit, verschiedene Schnitzeljagden zu speichern und zwischen ihnen zu wechseln.
```

---
## test/widget_test.dart

```
// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

//import 'package:clue_master/main.dart';

void main() {
  group('MyApp', () {
    testWidgets('Counter increments smoke test', (WidgetTester tester) async {
      // Build our app and trigger a frame.
    //  await tester.pumpWidget(const MyApp());

      // Verify that our counter starts at 0.
      expect(find.text('0'), findsOneWidget);
      expect(find.text('1'), findsNothing);

      // Tap the '+' icon and trigger a frame.
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Verify that our counter has incremented.
      expect(find.text('0'), findsNothing);
      expect(find.text('1'), findsOneWidget);
    });
  });
}
```

---
## web/manifest.json

```
{
    "name": "clue_master",
    "short_name": "clue_master",
    "start_url": ".",
    "display": "standalone",
    "background_color": "#0175C2",
    "theme_color": "#0175C2",
    "description": "A new Flutter project.",
    "orientation": "portrait-primary",
    "prefer_related_applications": false,
    "icons": [
        {
            "src": "icons/Icon-192.png",
            "sizes": "192x192",
            "type": "image/png"
        },
        {
            "src": "icons/Icon-512.png",
            "sizes": "512x512",
            "type": "image/png"
        },
        {
            "src": "icons/Icon-maskable-192.png",
            "sizes": "192x192",
            "type": "image/png",
            "purpose": "maskable"
        },
        {
            "src": "icons/Icon-maskable-512.png",
            "sizes": "512x512",
            "type": "image/png",
            "purpose": "maskable"
        }
    ]
}
```

---
## windows/CMakeLists.txt

```
# Project-level configuration.
cmake_minimum_required(VERSION 3.14)
project(clue_master LANGUAGES CXX)

# The name of the executable created for the application. Change this to change
# the on-disk name of your application.
set(BINARY_NAME "clue_master")

# Explicitly opt in to modern CMake behaviors to avoid warnings with recent
# versions of CMake.
cmake_policy(VERSION 3.14...3.25)

# Define build configuration option.
get_property(IS_MULTICONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(IS_MULTICONFIG)
  set(CMAKE_CONFIGURATION_TYPES "Debug;Profile;Release"
    CACHE STRING "" FORCE)
else()
  if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE "Debug" CACHE
      STRING "Flutter build mode" FORCE)
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
      "Debug" "Profile" "Release")
  endif()
endif()
# Define settings for the Profile build mode.
set(CMAKE_EXE_LINKER_FLAGS_PROFILE "${CMAKE_EXE_LINKER_FLAGS_RELEASE}")
set(CMAKE_SHARED_LINKER_FLAGS_PROFILE "${CMAKE_SHARED_LINKER_FLAGS_RELEASE}")
set(CMAKE_C_FLAGS_PROFILE "${CMAKE_C_FLAGS_RELEASE}")
set(CMAKE_CXX_FLAGS_PROFILE "${CMAKE_CXX_FLAGS_RELEASE}")

# Use Unicode for all projects.
add_definitions(-DUNICODE -D_UNICODE)

# Compilation settings that should be applied to most targets.
#
# Be cautious about adding new options here, as plugins use this function by
# default. In most cases, you should add new options to specific targets instead
# of modifying this function.
function(APPLY_STANDARD_SETTINGS TARGET)
  target_compile_features(${TARGET} PUBLIC cxx_std_17)
  target_compile_options(${TARGET} PRIVATE /W4 /WX /wd"4100")
  target_compile_options(${TARGET} PRIVATE /EHsc)
  target_compile_definitions(${TARGET} PRIVATE "_HAS_EXCEPTIONS=0")
  target_compile_definitions(${TARGET} PRIVATE "$<$<CONFIG:Debug>:_DEBUG>")
endfunction()

# Flutter library and tool build rules.
set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")
add_subdirectory(${FLUTTER_MANAGED_DIR})

# Application build; see runner/CMakeLists.txt.
add_subdirectory("runner")


# Generated plugin build rules, which manage building the plugins and adding
# them to the application.
include(flutter/generated_plugins.cmake)


# === Installation ===
# Support files are copied into place next to the executable, so that it can
# run in place. This is done instead of making a separate bundle (as on Linux)
# so that building and running from within Visual Studio will work.
set(BUILD_BUNDLE_DIR "$<TARGET_FILE_DIR:${BINARY_NAME}>")
# Make the "install" step default, as it's required to run.
set(CMAKE_VS_INCLUDE_INSTALL_TO_DEFAULT_BUILD 1)
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX "${BUILD_BUNDLE_DIR}" CACHE PATH "..." FORCE)
endif()

set(INSTALL_BUNDLE_DATA_DIR "${CMAKE_INSTALL_PREFIX}/data")
set(INSTALL_BUNDLE_LIB_DIR "${CMAKE_INSTALL_PREFIX}")

install(TARGETS ${BINARY_NAME} RUNTIME DESTINATION "${CMAKE_INSTALL_PREFIX}"
  COMPONENT Runtime)

install(FILES "${FLUTTER_ICU_DATA_FILE}" DESTINATION "${INSTALL_BUNDLE_DATA_DIR}"
  COMPONENT Runtime)

install(FILES "${FLUTTER_LIBRARY}" DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
  COMPONENT Runtime)

if(PLUGIN_BUNDLED_LIBRARIES)
  install(FILES "${PLUGIN_BUNDLED_LIBRARIES}"
    DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
    COMPONENT Runtime)
endif()

# Copy the native assets provided by the build.dart from all packages.
set(NATIVE_ASSETS_DIR "${PROJECT_BUILD_DIR}native_assets/windows/")
install(DIRECTORY "${NATIVE_ASSETS_DIR}"
   DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
   COMPONENT Runtime)

# Fully re-copy the assets directory on each build to avoid having stale files
# from a previous install.
set(FLUTTER_ASSET_DIR_NAME "flutter_assets")
install(CODE "
  file(REMOVE_RECURSE \"${INSTALL_BUNDLE_DATA_DIR}/${FLUTTER_ASSET_DIR_NAME}\")
  " COMPONENT Runtime)
install(DIRECTORY "${PROJECT_BUILD_DIR}/${FLUTTER_ASSET_DIR_NAME}"
  DESTINATION "${INSTALL_BUNDLE_DATA_DIR}" COMPONENT Runtime)

# Install the AOT library on non-Debug builds only.
install(FILES "${AOT_LIBRARY}" DESTINATION "${INSTALL_BUNDLE_DATA_DIR}"
  CONFIGURATIONS Profile;Release
  COMPONENT Runtime)
```

---
## windows/flutter/CMakeLists.txt

```
# This file controls Flutter-level build steps. It should not be edited.
cmake_minimum_required(VERSION 3.14)

set(EPHEMERAL_DIR "${CMAKE_CURRENT_SOURCE_DIR}/ephemeral")

# Configuration provided via flutter tool.
include(${EPHEMERAL_DIR}/generated_config.cmake)

# TODO: Move the rest of this into files in ephemeral. See
# https://github.com/flutter/flutter/issues/57146.
set(WRAPPER_ROOT "${EPHEMERAL_DIR}/cpp_client_wrapper")

# Set fallback configurations for older versions of the flutter tool.
if (NOT DEFINED FLUTTER_TARGET_PLATFORM)
  set(FLUTTER_TARGET_PLATFORM "windows-x64")
endif()

# === Flutter Library ===
set(FLUTTER_LIBRARY "${EPHEMERAL_DIR}/flutter_windows.dll")

# Published to parent scope for install step.
set(FLUTTER_LIBRARY ${FLUTTER_LIBRARY} PARENT_SCOPE)
set(FLUTTER_ICU_DATA_FILE "${EPHEMERAL_DIR}/icudtl.dat" PARENT_SCOPE)
set(PROJECT_BUILD_DIR "${PROJECT_DIR}/build/" PARENT_SCOPE)
set(AOT_LIBRARY "${PROJECT_DIR}/build/windows/app.so" PARENT_SCOPE)

list(APPEND FLUTTER_LIBRARY_HEADERS
  "flutter_export.h"
  "flutter_windows.h"
  "flutter_messenger.h"
  "flutter_plugin_registrar.h"
  "flutter_texture_registrar.h"
)
list(TRANSFORM FLUTTER_LIBRARY_HEADERS PREPEND "${EPHEMERAL_DIR}/")
add_library(flutter INTERFACE)
target_include_directories(flutter INTERFACE
  "${EPHEMERAL_DIR}"
)
target_link_libraries(flutter INTERFACE "${FLUTTER_LIBRARY}.lib")
add_dependencies(flutter flutter_assemble)

# === Wrapper ===
list(APPEND CPP_WRAPPER_SOURCES_CORE
  "core_implementations.cc"
  "standard_codec.cc"
)
list(TRANSFORM CPP_WRAPPER_SOURCES_CORE PREPEND "${WRAPPER_ROOT}/")
list(APPEND CPP_WRAPPER_SOURCES_PLUGIN
  "plugin_registrar.cc"
)
list(TRANSFORM CPP_WRAPPER_SOURCES_PLUGIN PREPEND "${WRAPPER_ROOT}/")
list(APPEND CPP_WRAPPER_SOURCES_APP
  "flutter_engine.cc"
  "flutter_view_controller.cc"
)
list(TRANSFORM CPP_WRAPPER_SOURCES_APP PREPEND "${WRAPPER_ROOT}/")

# Wrapper sources needed for a plugin.
add_library(flutter_wrapper_plugin STATIC
  ${CPP_WRAPPER_SOURCES_CORE}
  ${CPP_WRAPPER_SOURCES_PLUGIN}
)
apply_standard_settings(flutter_wrapper_plugin)
set_target_properties(flutter_wrapper_plugin PROPERTIES
  POSITION_INDEPENDENT_CODE ON)
set_target_properties(flutter_wrapper_plugin PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_link_libraries(flutter_wrapper_plugin PUBLIC flutter)
target_include_directories(flutter_wrapper_plugin PUBLIC
  "${WRAPPER_ROOT}/include"
)
add_dependencies(flutter_wrapper_plugin flutter_assemble)

# Wrapper sources needed for the runner.
add_library(flutter_wrapper_app STATIC
  ${CPP_WRAPPER_SOURCES_CORE}
  ${CPP_WRAPPER_SOURCES_APP}
)
apply_standard_settings(flutter_wrapper_app)
target_link_libraries(flutter_wrapper_app PUBLIC flutter)
target_include_directories(flutter_wrapper_app PUBLIC
  "${WRAPPER_ROOT}/include"
)
add_dependencies(flutter_wrapper_app flutter_assemble)

# === Flutter tool backend ===
# _phony_ is a non-existent file to force this command to run every time,
# since currently there's no way to get a full input/output list from the
# flutter tool.
set(PHONY_OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/_phony_")
set_source_files_properties("${PHONY_OUTPUT}" PROPERTIES SYMBOLIC TRUE)
add_custom_command(
  OUTPUT ${FLUTTER_LIBRARY} ${FLUTTER_LIBRARY_HEADERS}
    ${CPP_WRAPPER_SOURCES_CORE} ${CPP_WRAPPER_SOURCES_PLUGIN}
    ${CPP_WRAPPER_SOURCES_APP}
    ${PHONY_OUTPUT}
  COMMAND ${CMAKE_COMMAND} -E env
    ${FLUTTER_TOOL_ENVIRONMENT}
    "${FLUTTER_ROOT}/packages/flutter_tools/bin/tool_backend.bat"
      ${FLUTTER_TARGET_PLATFORM} $<CONFIG>
  VERBATIM
)
add_custom_target(flutter_assemble DEPENDS
  "${FLUTTER_LIBRARY}"
  ${FLUTTER_LIBRARY_HEADERS}
  ${CPP_WRAPPER_SOURCES_CORE}
  ${CPP_WRAPPER_SOURCES_PLUGIN}
  ${CPP_WRAPPER_SOURCES_APP}
)
```

---
## windows/runner/CMakeLists.txt

```
cmake_minimum_required(VERSION 3.14)
project(runner LANGUAGES CXX)

# Define the application target. To change its name, change BINARY_NAME in the
# top-level CMakeLists.txt, not the value here, or `flutter run` will no longer
# work.
#
# Any new source files that you add to the application should be added here.
add_executable(${BINARY_NAME} WIN32
  "flutter_window.cpp"
  "main.cpp"
  "utils.cpp"
  "win32_window.cpp"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
  "Runner.rc"
  "runner.exe.manifest"
)

# Apply the standard set of build settings. This can be removed for applications
# that need different build settings.
apply_standard_settings(${BINARY_NAME})

# Add preprocessor definitions for the build version.
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION=\"${FLUTTER_VERSION}\"")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MAJOR=${FLUTTER_VERSION_MAJOR}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MINOR=${FLUTTER_VERSION_MINOR}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_PATCH=${FLUTTER_VERSION_PATCH}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_BUILD=${FLUTTER_VERSION_BUILD}")

# Disable Windows macros that collide with C++ standard library functions.
target_compile_definitions(${BINARY_NAME} PRIVATE "NOMINMAX")

# Add dependency libraries and include directories. Add any application-specific
# dependencies here.
target_link_libraries(${BINARY_NAME} PRIVATE flutter flutter_wrapper_app)
target_link_libraries(${BINARY_NAME} PRIVATE "dwmapi.lib")
target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")

# Run the Flutter tool portions of the build. This must not be removed.
add_dependencies(${BINARY_NAME} flutter_assemble)
```
