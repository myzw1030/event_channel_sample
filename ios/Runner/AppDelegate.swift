import UIKit
import Flutter


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    // チャネル名を定義
    private let timeEventChannelName = "com.example.eventChannel.timeEventChannel"
    private let stringEventChannelName = "com.example.eventChannel.stringEventChannel"

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // FlutterViewControllerを取得
        guard let controller = window?.rootViewController as? FlutterViewController else {
            return false
        }
        // イベントチャネルを設定
        setUpTimeEventChannel(controller)
        setUpStringEventChannel(controller)

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // Timeイベントチャネルを設定して、定期的に現在時刻を送信する
    private func setUpTimeEventChannel(_ controller: FlutterViewController) {
        let timeEventChannel = FlutterEventChannel(name: timeEventChannelName, binaryMessenger: controller.binaryMessenger)
        timeEventChannel.setStreamHandler(TimeStreamHandler())
    }
    
    // Stringイベントチャネルを設定して、定期的に静的な文字列メッセージを送信する
    private func setUpStringEventChannel(_ controller: FlutterViewController) {
        let stringEventChannel = FlutterEventChannel(name: stringEventChannelName, binaryMessenger: controller.binaryMessenger)
        stringEventChannel.setStreamHandler(StringStreamHandler())
    }
}

// TimeHandlerクラスの定義
class TimeStreamHandler: NSObject, FlutterStreamHandler {
    private var timer: Timer?
    private var eventSink: FlutterEventSink?
    
    // タイマーを開始し、毎秒現在時刻を送信する
    func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
        // タイマーを設定
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            // 現在時刻をフォーマットして送信
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "HH:mm:ss"
            let time = dateFormat.string(from: Date())
            eventSink(time)
        }
        return nil
    }
    // ストリームがキャンセルされたときにタイマーを停止する
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        // タイマーを無効化
        timer?.invalidate()
        timer = nil
        eventSink = nil
        return nil
    }
}

// StringStreamHandlerクラスの定義
class StringStreamHandler: NSObject, FlutterStreamHandler {
    private var timer: Timer?
    
    // タイマーを開始し、毎秒静的な文字列を送信する
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            events("Hello from native!")
        }
        return nil
    }
    // ストリームがキャンセルされたときにタイマーを停止する
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        // タイマーを無効化
        timer?.invalidate()
        timer = nil
        return nil
    }
}
