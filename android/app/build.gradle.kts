import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// 读取 android/key.properties（不纳入版本控制）。
// 缺失时回退到 debug 签名，保证未配置正式签名时 `flutter run --release` 仍可用。
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseSigning = keystorePropertiesFile.exists()
if (hasReleaseSigning) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

android {
    namespace = "com.oliver.rent_book"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.oliver.rent_book"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://flutter.dev/to/review-gradle-config#apk-splits)
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Release 仅保留 arm64-v8a 原生库，显著减小 APK 体积；
        // Debug 构建不限制 ABI，以便在 x86_64 模拟器上运行。
        ndk {
            if (gradle.startParameter.taskNames.any { it.contains("Release") || it.contains("release") }) {
                abiFilters.add("arm64-v8a")
            }
        }
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = keystoreProperties.getProperty("storeFile")?.let { file(it) }
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                // 兜底：仅用于本地调试打包，正式发布前请配置 key.properties。
                signingConfigs.getByName("debug")
            }
        }
    }

    packaging {
        jniLibs {
            // 双保险：排除非 arm64 的残余插件原生库（仅 release）。
            // 注意：debug 构建需要 x86_64 模拟器支持，不能全局排除。
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
