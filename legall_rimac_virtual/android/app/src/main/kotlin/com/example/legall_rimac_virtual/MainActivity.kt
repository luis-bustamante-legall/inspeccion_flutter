package pe.com.legall.inspeccion

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.os.PersistableBundle
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    private val CHANNEL = "https.legall_rimac_virtual/channel"
    private var startString: String? = null
    private val EVENTS = "https.legall_rimac_virtual/events"
    private var linksReceiver: BroadcastReceiver? = null

    override fun onCreate(savedInstanceState: Bundle?, persistentState: PersistableBundle?) {
        super.onCreate(savedInstanceState, persistentState)
        val intent = intent
        if (intent.dataString != null) {
            startString = intent.dataString
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        if (intent.action === Intent.ACTION_VIEW && intent.dataString != null) {
            linksReceiver?.onReceive(this.applicationContext, intent)
        }
    }

    fun createChangeReceiver(events: EventChannel.EventSink): BroadcastReceiver? {
        return object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                val dataString = intent.dataString ?:
                events.error("UNAVAILABLE", "Link unavailable", null)
                events.success(dataString)
            }
        }
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "initialLink") {
                if (startString == null && intent.dataString != null)
                    result.success(intent.dataString)
                else
                    result.success(startString)
            }
        }
        EventChannel(flutterEngine.dartExecutor, EVENTS).setStreamHandler(
                object : EventChannel.StreamHandler {
                    override fun onListen(args: Any?, events: EventChannel.EventSink) {
                        linksReceiver = createChangeReceiver(events)
                    }
                    override fun onCancel(args: Any?) {
                        linksReceiver = null
                    }
                }
        )
        GeneratedPluginRegistrant.registerWith(flutterEngine)
    }
}
