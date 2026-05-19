package app.significantinfotech.notouch

import android.accessibilityservice.AccessibilityService
import android.view.KeyEvent
import android.view.accessibility.AccessibilityEvent

class TouchLockAccessibilityService : AccessibilityService() {

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        // Reserved for future: auto-enable in kids apps / video players.
    }

    override fun onInterrupt() = Unit

    override fun onKeyEvent(event: KeyEvent): Boolean {
        if (TouchLockState.status != LockStatus.ACTIVE) return super.onKeyEvent(event)
        if (TouchLockState.unlockGesture != UnlockGesture.VOLUME_KEYS) return super.onKeyEvent(event)

        when (event.keyCode) {
            KeyEvent.KEYCODE_VOLUME_UP,
            KeyEvent.KEYCODE_VOLUME_DOWN -> {
                TouchLockState.onVolumeKey(
                    event.keyCode,
                    event.action == KeyEvent.ACTION_DOWN,
                )
                return true
            }
        }
        return super.onKeyEvent(event)
    }
}
