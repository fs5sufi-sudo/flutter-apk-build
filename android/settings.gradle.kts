
pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        val localProperties = file("local.properties")
        if (localProperties.exists()) {
            localProperties.inputStream().use { properties.load(it) }
        }
        val flutterSdk = properties.getProperty("flutter.sdk")
        if (flutterSdk != null) return@run flutterSdk

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
    // استفاده از نسخه 8.1.0 (سازگارترین نسخه با فلاتر فعلی)
    id("com.android.application") version "8.1.0" apply false
    // استفاده از نسخه 1.8.22 (بدون باگ‌های نسخه 1.9)
    id("org.jetbrains.kotlin.android") version "1.8.22" apply false
}

include(":app")
