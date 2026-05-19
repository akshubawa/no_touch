package app.significantinfotech.notouch

enum class LockStatus {
    IDLE,
    COUNTDOWN,
    ACTIVE,
}

enum class UnlockGesture {
    TRIPLE_TAP,
    LONG_PRESS,
    VOLUME_KEYS,
    ;

    companion object {
        fun fromName(name: String): UnlockGesture {
            return when (name) {
                "longPress" -> LONG_PRESS
                "volumeKeys" -> VOLUME_KEYS
                else -> TRIPLE_TAP
            }
        }
    }
}

object TouchLockState {
    @Volatile
    var status: LockStatus = LockStatus.IDLE

    @Volatile
    var countdownSeconds: Int = 0

    @Volatile
    var unlockGesture: UnlockGesture = UnlockGesture.TRIPLE_TAP

    @Volatile
    var volumeUpPressed: Boolean = false

    @Volatile
    var volumeDownPressed: Boolean = false

    var eventEmitter: ((Map<String, Any?>) -> Unit)? = null

    fun updateStatus(newStatus: LockStatus) {
        status = newStatus
        eventEmitter?.invoke(mapOf("type" to "status", "value" to newStatus.name.lowercase()))
    }

    fun updateCountdown(seconds: Int) {
        countdownSeconds = seconds
        eventEmitter?.invoke(mapOf("type" to "countdown", "value" to seconds))
    }

    fun resetVolumeKeys() {
        volumeUpPressed = false
        volumeDownPressed = false
    }

    fun onVolumeKey(keyCode: Int, isPressed: Boolean) {
        if (unlockGesture != UnlockGesture.VOLUME_KEYS || status != LockStatus.ACTIVE) return
        when (keyCode) {
            android.view.KeyEvent.KEYCODE_VOLUME_UP -> volumeUpPressed = isPressed
            android.view.KeyEvent.KEYCODE_VOLUME_DOWN -> volumeDownPressed = isPressed
        }
        if (volumeUpPressed && volumeDownPressed) {
            TouchLockStateHolder.requestUnlockConfirmation()
            resetVolumeKeys()
        }
        if (!isPressed) {
            // Release either key resets combo tracking for next attempt.
            if (keyCode == android.view.KeyEvent.KEYCODE_VOLUME_UP) volumeUpPressed = false
            if (keyCode == android.view.KeyEvent.KEYCODE_VOLUME_DOWN) volumeDownPressed = false
        }
    }
}

/** Indirection so accessibility service can trigger unlock without circular deps. */
object TouchLockStateHolder {
    var requestUnlockConfirmation: () -> Unit = {}
}
