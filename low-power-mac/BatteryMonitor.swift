import Foundation
import IOKit.ps

struct BatteryInfo {
    let isCharging: Bool
    let percentage: Int
}

class BatteryMonitor {
    private var runLoopSource: CFRunLoopSource?
    private var callback: ((BatteryInfo) -> Void)?
    private let lowPowerThreshold = 20  // Threshold for enabling Low Power Mode

    init(callback: @escaping (BatteryInfo) -> Void) {
        self.callback = callback
        startMonitoring()
    }

    deinit {
        stopMonitoring()
    }

    private func startMonitoring() {
        let context = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        if let source = IOPSNotificationCreateRunLoopSource({ (context) in
            let monitor = Unmanaged<BatteryMonitor>
                .fromOpaque(context!)
                .takeUnretainedValue()
            monitor.getBatteryState()
        }, context)?.takeRetainedValue() {
            
            runLoopSource = source
            CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .defaultMode)
            getBatteryState()  // initial check
        }
    }

    private func stopMonitoring() {
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .defaultMode)
            runLoopSource = nil
        }
    }

    private func getBatteryState() {
        if let battery = BatteryMonitor.fetchBatteryInfo() {
            callback?(battery)
            handleLowPowerMode(battery: battery)
        }
    }

    private func handleLowPowerMode(battery: BatteryInfo) {
        if battery.isCharging {
            setLowPowerMode(enabled: false)
        } else if battery.percentage < lowPowerThreshold {
            setLowPowerMode(enabled: true)
        }
    }

    static func fetchBatteryInfo() -> BatteryInfo? {
        guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let sources: NSArray = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() else {
            return nil
        }

        for ps in sources {
            guard let info = IOPSGetPowerSourceDescription(snapshot, ps as CFTypeRef)?
                    .takeUnretainedValue() as? [String: Any] else {
                continue
            }
            
            if let capacity = info[kIOPSCurrentCapacityKey] as? Int,
               let max = info[kIOPSMaxCapacityKey] as? Int,
               let isCharging = info[kIOPSIsChargingKey] as? Bool {
                
                let percentage = Int((Double(capacity) / Double(max)) * 100)
                return BatteryInfo(isCharging: isCharging, percentage: percentage)
            }
        }
        return nil
    }
    
    private func setLowPowerMode(enabled: Bool) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["pmset", "-a", "lowpowermode", enabled ? "1" : "0"]

        do {
            try process.run()
            process.waitUntilExit()
            print("⚡️ Low Power Mode \(enabled ? "ENABLED" : "DISABLED")")
        } catch {
            print("❌ Failed to toggle Low Power Mode: \(error)")
        }
    }
}
