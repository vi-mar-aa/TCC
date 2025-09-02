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
}

dependencies {
    implementation ("com.squareup.okhttp3:logging-interceptor:4.9.3")
    implementation(libs.retrofit.v310snapshot)
       implementation(libs.converter.gson.vlatestversion)
      implementation(libs.retrofit)
     implementation(libs.converter.gson)
    implementation (libs.logging.interceptor)
    implementation(libs.zxing.android.embedded)
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
    implementation (libs.zxing.android.embedded)
    implementation ("com.google.zxing:core:3.4.1")


}
