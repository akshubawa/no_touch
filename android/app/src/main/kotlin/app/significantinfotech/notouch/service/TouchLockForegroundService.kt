package app.significantinfotech.notouch.service

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import androidx.core.app.NotificationCompat
import app.significantinfotech.notouch.LockStatus
import app.significantinfotech.notouch.MainActivity
import app.significantinfotech.notouch.R
import app.significantinfotech.notouch.TouchLockState
import app.significantinfotech.notouch.overlay.TouchOverlayManager

class TouchLockForegroundService : Service() {

    private val handler = Handler(Looper.getMainLooper())
    private var overlayManager: TouchOverlayManager? = null
    private var countdownRunnable: Runnable? = null
    private var remainingSeconds: Int = 0

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START_COUNTDOWN -> {
                remainingSeconds = intent.getIntExtra(EXTRA_DELAY_SECONDS, 10)
                startCountdownInternal()
            }
            ACTION_ACTIVATE_NOW -> activateLock()
            ACTION_STOP -> stopInternal()
            ACTION_CANCEL_COUNTDOWN -> cancelCountdownInternal()
        }
        return START_STICKY
    }

    private fun startCountdownInternal() {
        cancelCountdownInternal()
        TouchLockState.updateStatus(LockStatus.COUNTDOWN)
        startForeground(NOTIFICATION_ID, buildNotification(isCountdown = true))

        countdownRunnable = object : Runnable {
            override fun run() {
                TouchLockState.updateCountdown(remainingSeconds)
                updateNotification(isCountdown = true)
                if (remainingSeconds <= 0) {
                    activateLock()
                    return
                }
                remainingSeconds -= 1
                handler.postDelayed(this, 1000L)
            }
        }
        handler.post(countdownRunnable!!)
    }

    private fun activateLock() {
        cancelCountdownInternal()
        TouchLockState.updateStatus(LockStatus.ACTIVE)
        overlayManager = TouchOverlayManager(this).also { it.show() }
        startForeground(NOTIFICATION_ID, buildNotification(isCountdown = false))
    }

    private fun cancelCountdownInternal() {
        countdownRunnable?.let { handler.removeCallbacks(it) }
        countdownRunnable = null
        if (TouchLockState.status == LockStatus.COUNTDOWN) {
            TouchLockState.updateStatus(LockStatus.IDLE)
            TouchLockState.updateCountdown(0)
        }
    }

    private fun stopInternal() {
        cancelCountdownInternal()
        overlayManager?.hide()
        overlayManager = null
        TouchLockState.resetVolumeKeys()
        TouchLockState.updateStatus(LockStatus.IDLE)
        TouchLockState.updateCountdown(0)
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    private fun buildNotification(isCountdown: Boolean): Notification {
        createChannel()
        val launchIntent = PendingIntent.getActivity(
            this,
            0,
            Intent(this, MainActivity::class.java),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val title = if (isCountdown) {
            getString(R.string.notification_countdown_title, remainingSeconds)
        } else {
            getString(R.string.notification_active_title)
        }

        val text = if (isCountdown) {
            getString(R.string.notification_countdown_text)
        } else {
            getString(R.string.notification_active_text)
        }

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_touch_shield)
            .setContentTitle(title)
            .setContentText(text)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setContentIntent(launchIntent)
            .build()
    }

    private fun updateNotification(isCountdown: Boolean) {
        val manager = getSystemService(NotificationManager::class.java)
        manager.notify(NOTIFICATION_ID, buildNotification(isCountdown))
    }

    private fun createChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val channel = NotificationChannel(
            CHANNEL_ID,
            getString(R.string.notification_channel_name),
            NotificationManager.IMPORTANCE_LOW,
        ).apply {
            description = getString(R.string.notification_channel_description)
        }
        getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
    }

    companion object {
        private const val CHANNEL_ID = "touch_lock_channel"
        private const val NOTIFICATION_ID = 7321

        private const val ACTION_START_COUNTDOWN = "app.significantinfotech.notouch.START_COUNTDOWN"
        private const val ACTION_ACTIVATE_NOW = "app.significantinfotech.notouch.ACTIVATE_NOW"
        private const val ACTION_STOP = "app.significantinfotech.notouch.STOP"
        private const val ACTION_CANCEL_COUNTDOWN = "app.significantinfotech.notouch.CANCEL_COUNTDOWN"
        private const val EXTRA_DELAY_SECONDS = "delay_seconds"

        fun startCountdown(context: Context, delaySeconds: Int) {
            val intent = Intent(context, TouchLockForegroundService::class.java).apply {
                action = ACTION_START_COUNTDOWN
                putExtra(EXTRA_DELAY_SECONDS, delaySeconds)
            }
            startForegroundCompat(context, intent)
        }

        fun stop(context: Context) {
            val intent = Intent(context, TouchLockForegroundService::class.java).apply {
                action = ACTION_STOP
            }
            context.startService(intent)
        }

        fun cancelCountdown(context: Context) {
            val intent = Intent(context, TouchLockForegroundService::class.java).apply {
                action = ACTION_CANCEL_COUNTDOWN
            }
            context.startService(intent)
        }
    }
}

private fun startForegroundCompat(context: Context, intent: Intent) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        context.startForegroundService(intent)
    } else {
        context.startService(intent)
    }
}
