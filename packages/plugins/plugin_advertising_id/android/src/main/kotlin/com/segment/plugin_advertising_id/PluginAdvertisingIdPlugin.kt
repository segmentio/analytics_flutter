package com.segment.plugin_advertising_id

import android.content.Context
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import com.google.android.gms.ads.identifier.AdvertisingIdClient
import com.google.android.gms.common.GooglePlayServicesNotAvailableException
import android.util.Log
import io.flutter.plugin.common.StandardMethodCodec
import java.io.IOException

/** PluginAdvertisingIdPlugin */
class PluginAdvertisingIdPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var context: Context

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    val taskQueue =
      flutterPluginBinding.binaryMessenger.makeBackgroundTaskQueue()
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "plugin_advertising_id",
      StandardMethodCodec.INSTANCE,
      taskQueue)
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "getAdvertisingId") {
      try {
        val advertisingInfo = AdvertisingIdClient.getAdvertisingIdInfo(context)
        val isLimitAdTrackingEnabled = advertisingInfo.isLimitAdTrackingEnabled

        if (isLimitAdTrackingEnabled) {
          result.success(null)
          return
        }

        val id = advertisingInfo.id
        val advertisingId = id.toString()
        result.success(advertisingId)
      }
      catch (e: GooglePlayServicesNotAvailableException) {
        result.error("GooglePlayServicesNotAvailableException", e.toString(), "")
      }
      catch ( e: IOException) {
        result.error("IOException", e.toString(), "")
      }
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
