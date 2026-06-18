plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.griya"
    
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.example.griya"
        minSdk = flutter.minSdkVersion
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

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

// =================================================================
// KUNCI MUTLAK: Pencegat aktif agar Gradle tidak bisa mencuri versi baru
// =================================================================
configurations.all {
    resolutionStrategy.eachDependency {
        if (requested.group == "androidx.activity") {
            useVersion("1.8.0")
        }
        if (requested.group == "androidx.core") {
            useVersion("1.12.0")
        }
        if (requested.group == "androidx.navigationevent") {
            useVersion("1.0.0")
        }
        if (requested.group == "androidx.compose.runtime") {
            useVersion("1.5.0")
        }
    }
}
