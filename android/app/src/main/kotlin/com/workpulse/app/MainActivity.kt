package com.workpulse.app

import android.app.AppOpsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Process
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.workpulse.app/usage_access")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isGranted" -> result.success(isUsageAccessGranted())
                    "openSettings" -> {
                        startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
                        result.success(null)
                    }
                    "queryEvents" -> {
                        val start = call.argument<Number>("start")!!.toLong()
                        val end = call.argument<Number>("end")!!.toLong()
                        inBackground(result) { readUsageEvents(start, end) }
                    }
                    "appLabels" -> {
                        val packages = call.argument<List<String>>("packages").orEmpty()
                        inBackground(result) { packages.associateWith(::labelOf) }
                    }
                    "launchableApps" -> inBackground(result) {
                        packagesFor(Intent.CATEGORY_LAUNCHER)
                            .filter { it != packageName }
                            .map { mapOf("package" to it, "label" to labelOf(it)) }
                            .sortedBy { it.getValue("label").lowercase() }
                    }
                    "homePackages" -> inBackground(result) {
                        packagesFor(Intent.CATEGORY_HOME).toList()
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun inBackground(result: MethodChannel.Result, work: () -> Any) {
        Thread {
            try {
                val value = work()
                runOnUiThread { result.success(value) }
            } catch (_: Exception) {
                runOnUiThread { result.error("usage_failed", null, null) }
            }
        }.start()
    }

    /** Reads foreground transitions only, never content of any kind. */
    private fun readUsageEvents(start: Long, end: Long): List<Map<String, Any>> {
        val manager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val events = manager.queryEvents(start, end)
        val event = UsageEvents.Event()
        val output = ArrayList<Map<String, Any>>()
        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            val kind = when (event.eventType) {
                EVENT_RESUMED -> KIND_RESUMED
                EVENT_PAUSED -> KIND_PAUSED
                EVENT_SCREEN_OFF, EVENT_SHUTDOWN -> KIND_SCREEN_OFF
                else -> continue
            }
            output.add(
                mapOf("package" to event.packageName, "kind" to kind, "time" to event.timeStamp),
            )
        }
        return output
    }

    private fun packagesFor(category: String): Set<String> {
        val intent = Intent(Intent.ACTION_MAIN).addCategory(category)
        return packageManager.queryIntentActivities(intent, 0)
            .map { it.activityInfo.packageName }
            .toSet()
    }

    private fun labelOf(name: String): String = try {
        val info = packageManager.getApplicationInfo(name, 0)
        packageManager.getApplicationLabel(info).toString()
    } catch (_: PackageManager.NameNotFoundException) {
        name
    }

    private fun isUsageAccessGranted(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), packageName)
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), packageName)
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private companion object {
        const val EVENT_RESUMED = 1
        const val EVENT_PAUSED = 2
        const val EVENT_SCREEN_OFF = 16
        const val EVENT_SHUTDOWN = 26

        const val KIND_RESUMED = 0
        const val KIND_PAUSED = 1
        const val KIND_SCREEN_OFF = 2
    }
}
