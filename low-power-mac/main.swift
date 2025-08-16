//
//  main.swift
//  low-power-mac
//
//  Created by Jannik Leutgeb on 16/8/25.
//

import Foundation
import IOKit.ps

let monitor = BatteryMonitor { battery in
    print("🔋 Battery: \(battery.percentage)% - \(battery.isCharging ? "Charging" : "Not charging")")
}

RunLoop.current.run()
