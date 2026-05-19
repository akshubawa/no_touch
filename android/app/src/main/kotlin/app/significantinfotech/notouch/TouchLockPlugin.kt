package app.significantinfotech.notouch

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.content.ComponentName
import android.provider.Settings
import android.accessibilityservice.AccessibilityServiceInfo
import android.view.accessibility.AccessibilityManager
import androidx.core.content.ContextCompat
import app.significantinfotech.notouch.service.TouchLockForegroundService
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class TouchLockPlugin(
    private val context: Context,
) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private var eventSink: EventChannel.EventSink? = null

    fun register(flutterEngine: FlutterEngine) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL,
        ).setMethodCallHandler(this)

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            EVENT_CHANNEL,
        ).setStreamHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isOverlayGranted" -> result.success(canDrawOverlays())
            "openOverlaySettings" -> {
                openOverlaySettings()
                result.success(null)
            }
            "isAccessibilityEnabled" -> result.success(isAccessibilityServiceEnabled())
            "openAccessibilitySettings" -> {
                openAccessibilitySettings()
                result.success(null)
            }
            "getLockStatus" -> result.success(TouchLockState.status.name.lowercase())
            "startLock" -> {
                val delaySeconds = call.argument<Int>("delaySeconds") ?: 10
                val gestureName = call.argument<String>("unlockGesture") ?: "tripleTap"
                val gesture = UnlockGesture.fromName(gestureName)
                if (!canDrawOverlays()) {
                    result.error("NO_OVERLAY", "Overlay permission not granted", null)
                    return
                }
                TouchLockState.unlockGesture = gesture
                TouchLockState.eventEmitter = ::emitEvent
                TouchLockForegroundService.startCountdown(context, delaySeconds)
                result.success(null)
            }
            "stopLock" -> {
                TouchLockForegroundService.stop(context)
                result.success(null)
            }
            "cancelPending" -> {
                TouchLockForegroundService.cancelCountdown(context)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        TouchLockState.eventEmitter = ::emitEvent
        emitEvent(mapOf("type" to "status", "value" to TouchLockState.status.name.lowercase()))
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
        if (TouchLockState.eventEmitter === ::emitEvent) {
            TouchLockState.eventEmitter = null
        }
    }

    private fun emitEvent(payload: Map<String, Any?>) {
        val sink = eventSink ?: return
        ContextCompat.getMainExecutor(context).execute {
            sink.success(payload)
        }
    }

    private fun canDrawOverlays(): Boolean {
        return Settings.canDrawOverlays(context)
    }

    private fun openOverlaySettings() {
        val intent = Intent(
            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
            Uri.parse("package:${context.packageName}"),
        ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(intent)
    }

    private fun isAccessibilityServiceEnabled(): Boolean {
        val manager =
            context.getSystemService(Context.ACCESSIBILITY_SERVICE) as AccessibilityManager
        val target = ComponentName(context, TouchLockAccessibilityService::class.java)
        return manager.getEnabledAccessibilityServiceList(
            AccessibilityServiceInfo.FEEDBACK_ALL_MASK,
        ).any { info ->
            val service = info.resolveInfo.serviceInfo
            ComponentName(service.packageName, service.name) == target
        }
    }

    private fun openAccessibilitySettings() {
        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(intent)
    }

    companion object {
        const val CHANNEL = "app.significantinfotech.notouch/touch_lock"
        const val EVENT_CHANNEL = "app.significantinfotech.notouch/touch_lock_events"
    }
}
