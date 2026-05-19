package app.significantinfotech.notouch.overlay

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.PixelFormat
import android.os.Handler
import android.os.Looper
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.ImageView
import android.app.AlertDialog
import androidx.core.content.ContextCompat
import app.significantinfotech.notouch.R
import app.significantinfotech.notouch.TouchLockStateHolder
import app.significantinfotech.notouch.UnlockGesture
import app.significantinfotech.notouch.TouchLockState

@SuppressLint("ClickableViewAccessibility")
class TouchOverlayManager(private val context: Context) {

    private val windowManager =
        context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
    private val mainHandler = Handler(Looper.getMainLooper())

    private var blockerView: View? = null
    private var floatingView: ImageView? = null

    private var tapCount = 0
    private var lastTapAt = 0L
    private var longPressTriggered = false
    private val longPressRunnable = Runnable {
        if (TouchLockState.unlockGesture == UnlockGesture.LONG_PRESS) {
            longPressTriggered = true
            TouchLockStateHolder.requestUnlockConfirmation()
        }
    }

    fun show() {
        if (blockerView != null) return
        TouchLockStateHolder.requestUnlockConfirmation = ::showUnlockConfirmation
        addBlockerOverlay()
        addFloatingOverlay()
    }

    fun hide() {
        removeView(blockerView)
        removeView(floatingView)
        blockerView = null
        floatingView = null
        mainHandler.removeCallbacks(longPressRunnable)
        tapCount = 0
        longPressTriggered = false
    }

    private fun addBlockerOverlay() {
        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT,
        ).apply {
            gravity = Gravity.TOP or Gravity.START
        }

        val view = object : FrameLayout(context) {
            override fun onTouchEvent(event: MotionEvent): Boolean = true
        }.apply {
            setBackgroundColor(0x01000000)
            isClickable = true
            isFocusable = false
        }

        windowManager.addView(view, params)
        blockerView = view
    }

    private fun addFloatingOverlay() {
        val size = (56 * context.resources.displayMetrics.density).toInt()
        val margin = (16 * context.resources.displayMetrics.density).toInt()

        val params = WindowManager.LayoutParams(
            size,
            size,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT,
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = margin
            y = (margin * 4)
        }

        val icon = ImageView(context).apply {
            setImageResource(R.mipmap.ic_launcher)
            background = ContextCompat.getDrawable(context, R.drawable.floating_icon_bg)
            scaleType = ImageView.ScaleType.CENTER_INSIDE
            setPadding(size / 6, size / 6, size / 6, size / 6)
            contentDescription = context.getString(R.string.floating_unlock_description)
            setOnTouchListener(FloatingTouchListener(params))
        }

        windowManager.addView(icon, params)
        floatingView = icon
    }

    private inner class FloatingTouchListener(
        private val layoutParams: WindowManager.LayoutParams,
    ) : View.OnTouchListener {
        private var initialX = 0
        private var initialY = 0
        private var touchX = 0f
        private var touchY = 0f

        override fun onTouch(v: View, event: MotionEvent): Boolean {
            when (event.actionMasked) {
                MotionEvent.ACTION_DOWN -> {
                    initialX = layoutParams.x
                    initialY = layoutParams.y
                    touchX = event.rawX
                    touchY = event.rawY
                    longPressTriggered = false
                    if (TouchLockState.unlockGesture == UnlockGesture.LONG_PRESS) {
                        mainHandler.postDelayed(longPressRunnable, 3000L)
                    }
                    return true
                }
                MotionEvent.ACTION_MOVE -> {
                    layoutParams.x = initialX + (touchX - event.rawX).toInt()
                    layoutParams.y = initialY + (event.rawY - touchY).toInt()
                    floatingView?.let { windowManager.updateViewLayout(it, layoutParams) }
                    return true
                }
                MotionEvent.ACTION_UP -> {
                    mainHandler.removeCallbacks(longPressRunnable)
                    val moved = kotlin.math.abs(event.rawX - touchX) > 10 ||
                        kotlin.math.abs(event.rawY - touchY) > 10
                    if (!moved && !longPressTriggered) {
                        handleTap()
                    }
                    return true
                }
                MotionEvent.ACTION_CANCEL -> {
                    mainHandler.removeCallbacks(longPressRunnable)
                    return true
                }
            }
            return false
        }
    }

    private fun handleTap() {
        when (TouchLockState.unlockGesture) {
            UnlockGesture.TRIPLE_TAP -> {
                val now = System.currentTimeMillis()
                if (now - lastTapAt > 600) tapCount = 0
                lastTapAt = now
                tapCount += 1
                if (tapCount >= 3) {
                    tapCount = 0
                    TouchLockStateHolder.requestUnlockConfirmation()
                }
            }
            UnlockGesture.LONG_PRESS -> Unit
            UnlockGesture.VOLUME_KEYS -> Unit
        }
    }

    private fun showUnlockConfirmation() {
        mainHandler.post {
            val dialog = AlertDialog.Builder(context)
                .setTitle(R.string.unlock_dialog_title)
                .setMessage(R.string.unlock_dialog_message)
                .setPositiveButton(R.string.unlock_confirm) { _, _ ->
                    app.significantinfotech.notouch.service.TouchLockForegroundService.stop(context)
                }
                .setNegativeButton(R.string.unlock_cancel, null)
                .create()
            dialog.window?.setType(WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY)
            dialog.show()
        }
    }

    private fun removeView(view: View?) {
        if (view == null) return
        try {
            windowManager.removeView(view)
        } catch (_: Exception) {
        }
    }
}
