plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.kurszettel.kurszettel"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.kurszettel.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Fester Signierschlüssel: Der Bau bei GitHub legt die Schlüsseldatei aus den
    // Repository-Geheimnissen ab und nennt den Pfad in KZ_KEYSTORE. Fehlt sie
    // (lokaler Bau, Geheimnisse nicht gesetzt), wird mit dem Testschlüssel signiert.
    val kzKeystore: String? = System.getenv("KZ_KEYSTORE")
    val kzSigniert = kzKeystore != null && file(kzKeystore).exists()

    signingConfigs {
        if (kzSigniert) {
            create("release") {
                storeFile = file(kzKeystore!!)
                storeType = "pkcs12"
                storePassword = System.getenv("KZ_KEYSTORE_PASSWORD")
                keyAlias = "kurszettel"
                keyPassword = System.getenv("KZ_KEYSTORE_PASSWORD")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (kzSigniert) signingConfigs.getByName("release") else signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
