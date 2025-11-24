plugins {
    alias(libs.plugins.android.application)
}

android {
    namespace = "com.example.litteratcc"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.example.litteratcc"
        minSdk = 24
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    buildFeatures {
        viewBinding = true
    }
    viewBinding{
        enable =true
    }
}

dependencies {
    implementation ("com.squareup.okhttp3:logging-interceptor:4.9.3")
    implementation(libs.retrofit.v310snapshot)
       implementation(libs.converter.gson.vlatestversion)
      implementation(libs.retrofit)
     implementation(libs.converter.gson)
    implementation (libs.logging.interceptor)
    implementation(libs.material)
    implementation(libs.appcompat)
    implementation(libs.activity)
    implementation(libs.constraintlayout)
    implementation(libs.navigation.fragment)
    implementation(libs.navigation.ui)
    testImplementation(libs.junit)
    androidTestImplementation(libs.ext.junit)
    androidTestImplementation(libs.espresso.core)
    implementation ("androidx.security:security-crypto:1.1.0")
    implementation("com.google.mlkit:barcode-scanning:17.3.0")

    implementation (libs.glide)
    annotationProcessor (libs.compiler)

        // CameraX core library using the camera2 implementation

        // The following line is optional, as the core library is included indirectly by camera-camera2
        implementation ("androidx.camera:camera-core:1.5.0-rc01")
        implementation ("androidx.camera:camera-camera2:1.5.0-rc01")
        // If you want to additionally use the CameraX Lifecycle library
        implementation ("androidx.camera:camera-lifecycle:1.5.0-rc01")
        // If you want to additionally use the CameraX VideoCapture library
        implementation ("androidx.camera:camera-video:1.5.0-rc01")
        // If you want to additionally use the CameraX View class
        implementation ("androidx.camera:camera-view:1.5.0-rc01")
        // If you want to additionally add CameraX ML Kit Vision Integration
        implementation ("androidx.camera:camera-mlkit-vision:1.5.0-rc01")
        // If you want to additionally use the CameraX Extensions library
        implementation ("androidx.camera:camera-extensions:1.5.0-rc01")
        implementation ("com.journeyapps:zxing-android-embedded:4.3.0")  // última versão estável
        implementation ("com.google.zxing:core:3.5.2")




}
