plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    
    id("com.google.gms.google-services")
    id("dev.flutter.flutter-gradle-plugin")
}

dependencies {
    // 1. Core library desugaring dependency (add this line)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")

    // 2. Import the Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:33.9.0"))
    // Example Firebase product (analytics)
    implementation("com.google.firebase:firebase-analytics")
    // ...other Firebase products
}

android {
    namespace = "com.example.app"
    compileSdk = 35
    ndkVersion = "28.0.12916984"

    compileOptions {
        // 3. Enable core library desugaring
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.app"
        minSdk = 21
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Signing with debug keys for now, so `flutter run --release` works
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
