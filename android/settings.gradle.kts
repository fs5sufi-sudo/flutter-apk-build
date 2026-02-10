pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        val localProperties = file("local.properties")
        if (localProperties.exists()) {
            localProperties.inputStream().use { properties.load(it) }
        }
        
        // اول سعی کن از فایل لوکال بخونی
        val flutterSdk = properties.getProperty("flutter.sdk")
        if (flutterSdk != null) return@run flutterSdk

        // اگر نبود (مثل توی گیت‌هاب)، از متغیر محیطی بخون
        val flutterRoot = System.getenv("FLUTTER_ROOT")
        if (flutterRoot != null) return@run flutterRoot

        error("flutter.sdk not set in local.properties nor FLUTTER_ROOT environment variable")
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
    id("com.android.application") version "8.1.0" apply false
    id("org.jetbrains.kotlin.android") version "1.8.22" apply false
}

include(":app")
