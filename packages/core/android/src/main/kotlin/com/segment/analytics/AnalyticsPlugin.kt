package com.segment.analytics

import NativeContext
import NativeContextApi
import NativeContextApp
import NativeContextDevice
import NativeContextNetwork
import NativeContextOS
import NativeContextScreen
import android.Manifest
import android.annotation.SuppressLint
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.media.MediaDrm
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.PluginRegistry
import java.security.MessageDigest
import java.util.*


val WIDEVINE_UUID = UUID(-0x121074568629b532L, -0x5c37d8232ae2de13L)

/** AnalyticsPlugin */
class AnalyticsPlugin : FlutterPlugin, NativeContextApi, EventChannel.StreamHandler, ActivityAware,
    PluginRegistry.NewIntentListener {
    private var context: Context? = null
    private val pendingDeeplinkEventsQueue: Queue<Intent> = LinkedList()
    private fun ByteArray.toHexString() = joinToString("") { "%02x".format(it) }

    private val eventsChannel = "analytics/deep_link_events"
    private val referrerUrl: String? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        NativeContextApi.setUp(flutterPluginBinding.binaryMessenger, this)

        val eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, eventsChannel)
        eventChannel.setStreamHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        NativeContextApi.setUp(binding.binaryMessenger, null)
    }

    /**
     * Workaround for not able to get device id on Android 10 or above using DRM API
     * {@see https://stackoverflow.com/questions/58103580/android-10-imei-no-longer-available-on-api-29-looking-for-alternatives}
     * {@see https://developer.android.com/training/articles/user-data-ids}
     */
    private fun getUniqueId(): String? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.JELLY_BEAN_MR2)
            return null

        var wvDrm: MediaDrm? = null
        return try {
            wvDrm = MediaDrm(WIDEVINE_UUID)
            val wideVineId = wvDrm.getPropertyByteArray(MediaDrm.PROPERTY_DEVICE_UNIQUE_ID)
            val md = MessageDigest.getInstance("SHA-256")
            md.update(wideVineId)
            md.digest().toHexString()
        } catch (e: Exception) {
            null
        } finally {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                wvDrm?.close()
            } else @Suppress("DEPRECATION") {
                wvDrm?.release()
            }
        }
    }

    private var changeReceiver: BroadcastReceiver? = null

    private inline fun <reified T> getSystemService(context: Context, serviceConstant: String): T {
        return context.getSystemService(serviceConstant) as T
    }

    @SuppressLint("MissingPermission")
    override fun getContext(
        collectDeviceId: Boolean,
        callback: (Result<NativeContext>) -> Unit
    ) {
        val displayMetrics = context!!.resources.displayMetrics
        val packageManager = context!!.packageManager
        val packageInfo = packageManager.getPackageInfo(context!!.packageName, 0)
        val appBuild = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            packageInfo.longVersionCode.toString()
        } else {
            @Suppress("DEPRECATION")
            packageInfo.versionCode.toString()
        }
        val deviceId = if (collectDeviceId) {
            getUniqueId()
        } else {
            null
        }

        var wifiConnected: Boolean? = null
        var cellularConnected: Boolean? = null
        var bluetoothConnected: Boolean? = null

        if (context!!.checkCallingOrSelfPermission(Manifest.permission.ACCESS_NETWORK_STATE) == PackageManager.PERMISSION_GRANTED) {
            val connectivityManager =
                getSystemService<ConnectivityManager>(context!!, Context.CONNECTIVITY_SERVICE)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) @Suppress("DEPRECATION") {
                connectivityManager.allNetworks.forEach {
                    val capabilities = connectivityManager.getNetworkCapabilities(it)
                    // we don't know which network is which at this point, so using
                    // the or-map allows us to capture the value across all networks
                    wifiConnected =
                        capabilities?.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) ?: false
                    cellularConnected =
                        capabilities?.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) ?: false
                    bluetoothConnected =
                        capabilities?.hasTransport(NetworkCapabilities.TRANSPORT_BLUETOOTH) ?: false
                }
            } else @Suppress("DEPRECATION") {
                val wifiInfo =
                    connectivityManager.getNetworkInfo(ConnectivityManager.TYPE_WIFI)
                wifiConnected = wifiInfo?.isConnected ?: false

                val bluetoothInfo =
                    connectivityManager.getNetworkInfo(ConnectivityManager.TYPE_BLUETOOTH)
                bluetoothConnected = bluetoothInfo?.isConnected ?: false

                val cellularInfo =
                    connectivityManager.getNetworkInfo(ConnectivityManager.TYPE_MOBILE)
                cellularConnected = cellularInfo?.isConnected ?: false
            }
        }

        callback(
            Result.success(
                NativeContext(
                    app = NativeContextApp(
                        build = appBuild,

                        /* Retrieves the application name from the package info, using the application's label
                           (i.e., the app name displayed on the device). If the application name cannot be fetched
                           (e.g., due to a missing label or other issues), the fallback value "Unknown" will be used
                           to ensure the app doesn't break due to a null value.

                           Patch for for Github issue #147 - Replaced following line:
                           name = packageInfo.applicationInfo.loadLabel(packageManager).toString(), with the line below
                         */
                        name = packageInfo.applicationInfo?.loadLabel(packageManager)?.toString() ?: "Unknown",

                        namespace = packageInfo.packageName,
                        version = packageInfo.versionName
                    ),
                    device = NativeContextDevice(
                        id = deviceId,
                        manufacturer = Build.MANUFACTURER,
                        model = Build.MODEL,
                        name = Build.DEVICE,
                        type = "android"
                    ),
                    locale = Locale.getDefault().language + "-" + Locale.getDefault().country,
                    network = NativeContextNetwork(
                        cellular = cellularConnected,
                        wifi = wifiConnected,
                        bluetooth = bluetoothConnected,
                    ),
                    os = NativeContextOS(
                        name = "Android",
                        version = Build.VERSION.RELEASE,
                    ),
                    referrer = referrerUrl,
                    screen = NativeContextScreen(
                        height = displayMetrics.heightPixels.toLong(),
                        width = displayMetrics.widthPixels.toLong(),
                        density = displayMetrics.density.toDouble(),
                    ),
                    timezone = TimeZone.getDefault().id,
                    userAgent = System.getProperty("http.agent")
                )
            )
        )
    }

    @NonNull
    private fun createChangeReceiver(events: EventSink): BroadcastReceiver {
        return object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent) {
                val referringApplication = intent.getStringExtra("referring_application")
                // NOTE: assuming intent.getAction() is Intent.ACTION_VIEW
                val dataString: String? = intent.dataString
                if (dataString == null) {
                    events.error("UNAVAILABLE", "Link unavailable", null)
                } else {
                    val data = mapOf("url" to dataString, "referring_application" to referringApplication)
                    events.success(data)
                    referrerUrl = dataString
                }
            }
        }
    }

    private fun handleIntent(context: Context, intent: Intent) {
        val action = intent.action
        if (Intent.ACTION_VIEW == action) {
            if (changeReceiver != null) {
                changeReceiver!!.onReceive(context, intent)
            } else {
                pendingDeeplinkEventsQueue.add(intent.cloneFilter())
            }
        }
    }

    private fun processPendingDeeplinkEventsQueue() {
        if (this.context == null ||
            changeReceiver == null
        ) {
            return
        }
        while (pendingDeeplinkEventsQueue.isNotEmpty()) {
            val intent = pendingDeeplinkEventsQueue.poll()
            changeReceiver!!.onReceive(context, intent)
        }
    }

    override fun onListen(arguments: Any?, events: EventSink?) {
        if (events != null) {
            this.changeReceiver = createChangeReceiver(events)
            processPendingDeeplinkEventsQueue()
        }
    }

    override fun onCancel(arguments: Any?) {
        this.changeReceiver = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        binding.addOnNewIntentListener(this)
        if (this.context != null) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
                binding.activity.intent.putExtra(
                    "referring_application",
                    binding.activity.referrer.toString()
                )
            }
            this.handleIntent(this.context!!, binding.activity.intent)
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        binding.addOnNewIntentListener(this)
        if (this.context != null) {
            this.handleIntent(this.context!!, binding.activity.intent)
        }
    }

    override fun onDetachedFromActivity() {
    }

    override fun onNewIntent(intent: Intent): Boolean {
        if (this.context != null) {
            this.handleIntent(this.context!!, intent)
        }
        return false
    }
}
