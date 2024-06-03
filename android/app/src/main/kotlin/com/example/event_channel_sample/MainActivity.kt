package com.example.event_channel_sample

import android.annotation.SuppressLint
import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import java.text.SimpleDateFormat
import java.util.*

class MainActivity : FlutterActivity() {
    // イベントチャネルの名前を定義
    private val timeEventChannelName = "com.example.eventChannel.timeEventChannel"
    private val stringEventChannelName = "com.example.eventChannel.stringEventChannel"
    private lateinit var timeEventChannel: EventChannel
    private lateinit var stringEventChannel: EventChannel

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // FlutterEngineがnullでないことを確認してからイベントチャネルを設定
        flutterEngine.dartExecutor.binaryMessenger.let { messenger ->
            // イベントチャネルを設定
            setUpTimeEventChannel(messenger)
            setUpStringEventChannel(messenger)
        }
    }

    // Timeイベントチャネルを設定して、定期的に現在時刻を送信する
    private fun setUpTimeEventChannel(messenger: BinaryMessenger) {
        timeEventChannel = EventChannel(messenger, timeEventChannelName)
        timeEventChannel.setStreamHandler(TimeStreamHandler())
    }
    // Stringイベントチャネルを設定して、定期的に静的な文字列メッセージを送信する
    private fun setUpStringEventChannel(messenger: BinaryMessenger) {
        stringEventChannel = EventChannel(messenger, stringEventChannelName)
        stringEventChannel.setStreamHandler(StringStreamHandler())
    }
}

// TimeStreamHandlerクラスの定義
class TimeStreamHandler : EventChannel.StreamHandler {
    // メインスレッドでイベントを処理するためのハンドラ
    private val handler = Handler(Looper.getMainLooper())
    private var runnable: Runnable? = null

    // イベントシンクを宣言（後で初期化される）
    private var eventSink: EventChannel.EventSink? = null

    @SuppressLint("SimpleDateFormat")
    override fun onListen(arguments: Any?, sink: EventChannel.EventSink) {
        eventSink = sink
        // 毎秒時刻を送信するためのRunnableを定義
        runnable = object : Runnable {
            override fun run() {
                val dateFormat = SimpleDateFormat("HH:mm:ss")
                val time = dateFormat.format(Date())
                eventSink?.success(time)
                // 1秒後に再度このRunnableを実行
                handler.postDelayed(this, 1000)
            }
        }
        // 1秒後に最初の実行を開始
        handler.postDelayed(runnable!!, 1000)
    }

    override fun onCancel(arguments: Any?) {
        // Runnableをキャンセルしてリソースを解放
        runnable?.let { handler.removeCallbacks(it) }
        runnable = null
        eventSink = null
    }
}

// StringStreamHandlerクラスの定義
class StringStreamHandler : EventChannel.StreamHandler {
    // メインスレッドでイベントを処理するためのハンドラ
    private val handler = Handler(Looper.getMainLooper())
    private var runnable: Runnable? = null

    // イベントシンクを宣言（後で初期化される）
    private var eventSink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, sink: EventChannel.EventSink) {
        eventSink = sink
        // 毎秒静的な文字列を送信するためのRunnableを定義
        runnable = object : Runnable {
            override fun run() {
                eventSink?.success("Hello from native!")
                // 1秒後に再度このRunnableを実行
                handler.postDelayed(this, 1000)
            }
        }
        // 1秒後に最初の実行を開始
        handler.postDelayed(runnable!!, 1000)
    }

    override fun onCancel(arguments: Any?) {
        // Runnableをキャンセルしてリソースを解放
        runnable?.let { handler.removeCallbacks(it) }
        runnable = null
        eventSink = null
    }
}