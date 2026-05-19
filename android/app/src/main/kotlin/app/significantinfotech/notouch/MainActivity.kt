package app.significantinfotech.notouch

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var touchLockPlugin: TouchLockPlugin? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        touchLockPlugin = TouchLockPlugin(applicationContext).also {
            it.register(flutterEngine)
        }
    }
}
