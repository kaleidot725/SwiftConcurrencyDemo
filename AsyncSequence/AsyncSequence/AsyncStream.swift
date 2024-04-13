//
// AsyncStream.swift

import CoreLocation
import SwiftUI

struct AsyncStreamView: View {
    @StateObject
    private var locationManager: LocationManager

    init() {
        self._locationManager = StateObject(wrappedValue: LocationManager())
    }

    var body: some View {
        VStack {
            Text("緯度:\(locationManager.coordinate.latitude)\n経度:\(locationManager.coordinate.longitude)")
                .font(.largeTitle)

            List {
                Button {
                    locationManager.startLocation()
                } label: {
                    Text("位置情報読み取り開始")
                }

                Button {
                    locationManager.asyncThrowingStreamTask = Task {
                        do {
                            for try await coordinate in locationManager.locationsWithError {
                                print(coordinate)
                            }
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                } label: {
                    Text("AsyncThrowingStream使う")
                }
            }
        }
        .alert(Text("位置情報を許可してください"),
               isPresented: $locationManager.showAuthorizationAlert)
        {
            Button("OK") {}
        }
        .onAppear {
            locationManager.setup()
        }
        .onDisappear {
            locationManager.cleanup()
        }
    }
}

@MainActor
final class LocationManager: NSObject, ObservableObject {
    struct LocationError: Error {
        let message: String
    }

    @Published
    var showAuthorizationAlert: Bool = false

    @Published
    var coordinate: CLLocationCoordinate2D = .init()

    var asyncStreamTask: Task<Void, Never>?
    var asyncThrowingStreamTask: Task<Void, Never>?

    // Continuationで値を送信したり、キャンセルしたりするので、制御できるように内部にContinuationを保持する
    var locations: AsyncStream<CLLocationCoordinate2D> {
        AsyncStream { [weak self] continuation in
            self?.continuation = continuation
        }
    }

    // Continuationで値を送信したり、キャンセルしたりするので、制御できるように内部にContinuationを保持する
    var locationsWithError: AsyncThrowingStream<CLLocationCoordinate2D, Error> {
        AsyncThrowingStream { [weak self] continuation in
            guard let self = self else { return }
            // 認証状態に応じて処理を実行する、処理がもし拒否されていたら、すぐさまに終了する
            switch self.locationManager.authorizationStatus {
                case .notDetermined:
                    locationManager.requestWhenInUseAuthorization()
                case .denied,
                     .restricted:
                    continuation.finish(throwing: LocationError(message: "位置情報を許可してください"))
                default:
                    break
            }
            continuationWithError = continuation
        }
    }

    func setup() {
        locationManager.delegate = self
        switch locationManager.authorizationStatus {
            case .authorizedAlways,
                 .authorizedWhenInUse:
                break
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .denied,
                 .restricted:
                showAuthorizationAlert = true
            @unknown default:
                break
        }
    }

    func startLocation() {
        locationManager.startUpdatingLocation()
    }

    func stopLocation() {
        locationManager.stopUpdatingHeading()
        continuation?.finish()
        continuationWithError?.finish(throwing: nil)
    }

    func cleanup() {
        asyncStreamTask?.cancel()
        asyncThrowingStreamTask?.cancel()
    }

    private var continuation: AsyncStream<CLLocationCoordinate2D>.Continuation? {
        didSet {
            // シーケンスが終了したときの動作
            continuation?.onTermination = { @Sendable [weak self] _ in
                self?.locationManager.stopUpdatingLocation()
            }
        }
    }

    private var continuationWithError: AsyncThrowingStream<CLLocationCoordinate2D, Error>.Continuation? {
        didSet {
            // シーケンスが終了したときの動作
            continuationWithError?.onTermination = { @Sendable [weak self] _ in
                self?.locationManager.stopUpdatingLocation()
            }
        }
    }

    private let locationManager = CLLocationManager()
}

extension LocationManager: CLLocationManagerDelegate {
    // 更新されたらLocationから最新情報がもらえるので、各Cotinuationをyieldしていく
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else {
            continuationWithError?.finish(throwing: LocationError(message: "位置情報がありません"))
            return
        }
        coordinate = lastLocation.coordinate
        continuation?.yield(lastLocation.coordinate)
        continuationWithError?.yield(lastLocation.coordinate)
    }

    // もし認証状態が変わったら通知される、更新状況に応じてリクエストしたり、アラートを出したりする
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .denied,
                 .restricted:
                showAuthorizationAlert = true
            default:
                break
        }
    }
}
