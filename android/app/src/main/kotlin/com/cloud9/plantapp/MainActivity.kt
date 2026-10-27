package com.cloud9.plantapp

import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.util.Log
import androidx.biometric.BiometricManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {

    companion object {
        private const val CHANNEL = "com.cloud9.plantapp/deviceName"
        private const val CHANNEL3 = "com.cloud9.plantapp/settings"
    }

    private val deviceName: String
        get() = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
            Settings.Global.getString(contentResolver, Settings.Global.DEVICE_NAME) ?: "unknown"
        } else {
            "unknown"
        }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL3)
                .setMethodCallHandler { call, result ->
                    if (call.method == "openBiometricSettings") {
                        openFingerprintSettings()
                        result.success(null)
                    } else {
                        result.notImplemented()
                    }
                }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
                .setMethodCallHandler { call, result ->
                    when (call.method) {
                        "getDeviceName" -> result.success(deviceName)
                        "installapk" -> result.success(installapk())
                        else -> result.notImplemented()
                    }
                }
    }

    private fun openFingerprintSettings() {
        try {
            val biometricManager = BiometricManager.from(this)
            val canEnroll = biometricManager.canAuthenticate(
                    BiometricManager.Authenticators.BIOMETRIC_STRONG
            )

            val intent = when {
                canEnroll == BiometricManager.BIOMETRIC_ERROR_NONE_ENROLLED &&
                        Build.VERSION.SDK_INT >= Build.VERSION_CODES.R -> {
                    Intent(Settings.ACTION_BIOMETRIC_ENROLL).apply {
                        putExtra(
                                Settings.EXTRA_BIOMETRIC_AUTHENTICATORS_ALLOWED,
                                BiometricManager.Authenticators.BIOMETRIC_STRONG
                        )
                    }
                }

                Build.VERSION.SDK_INT >= 34 -> {
                    Intent(Settings.ACTION_FINGERPRINT_ENROLL)
                }

                else -> {
                    Intent(Settings.ACTION_SECURITY_SETTINGS)
                }
            }

            if (intent.resolveActivity(packageManager) != null) {
                startActivity(intent)
            } else {
                Log.e("MainActivity", "No settings activity found")
            }
        } catch (e: Exception) {
            Log.e("MainActivity", "Exception: ${e.message}")
        }
    }

    private fun installapk(): String {
        return try {
            val intent = Intent()
            intent.setClassName("package.name", "com.cloud9.plantapp")
            startActivity(intent)
            "Done"
        } catch (e: Exception) {
            Log.e("MainActivity", "Install APK error: ${e.message}")
            "Failed"
        }
    }
}

