plugins {
    id("com.android.application")
    id("kotlin-android")
    // O plugin do Flutter sempre depois dos plugins Android/Kotlin
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.buscador_gif" // ⚠️ Lembre-se de atualizar com o seu namespace final
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.buscador_gif" // ⚠️ Atualize conforme seu projeto (ex: com.katriel.buscador_gif)
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // ⚠️ Aqui seria legal colocar seu signingConfig release depois.
            signingConfig = signingConfigs.getByName("debug")
            // Exemplo para ativar minificação futuramente:
            // isMinifyEnabled = true
            // proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}
