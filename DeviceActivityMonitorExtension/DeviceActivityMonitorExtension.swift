//
//  DeviceActivityMonitorExtension.swift
//  DeviceActivityMonitorExtension
//
//  Created by IPS-177  on 02/12/23.
//

import DeviceActivity
import ManagedSettings
import Foundation
import UserNotifications
import SwiftUI
import FamilyControls


// Optionally override any of the functions below.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    
    @AppStorage("shieldedApp", store: UserDefaults(suiteName: "group.com.Avinash.ScreenTDemo")) var shieldedApps = FamilyActivitySelection()
    
    var context: NSExtensionContext?
    let store = ManagedSettingsStore()
    
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        print("intervalDidStart for: \(activity.rawValue)")
        
        let store = ManagedSettingsStore()
        store.shield.applications = FamilyActivitySelection().applicationTokens
        // Handle the start of the interval.
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        print("intervalDidEnd for: \(activity.rawValue)")
        // Handle the end of the interval.
    }
    
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        
        print("eventDidReachThreshold")
        
        let store = ManagedSettingsStore()
        store.shield.applications = shieldedApps.applicationTokens
        store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(shieldedApps.categoryTokens, except: Set())
        
        let content = UNMutableNotificationContent()
        content.title = "Time's Up!"
        content.subtitle = "Answer questions to get more time."
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1,
                                                        repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: trigger)
        UNUserNotificationCenter.current().add(request)
        
        let notificationName = CFNotificationName("group.com.Avinash.ScreenTDemo" as CFString)
        let notificationCenter = CFNotificationCenterGetDarwinNotifyCenter()
        CFNotificationCenterPostNotification(notificationCenter, notificationName, nil, nil, true)
        
        if let context = context,
           let url = URL(string: "timeout://event-did-reach-threshold") {
            context.open(url, completionHandler: nil)
        }
    }
    
    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
        
        // Handle the warning before the interval starts.
    }
    
    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
        
        // Handle the warning before the interval ends.
    }
    
    override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventWillReachThresholdWarning(event, activity: activity)
        
        // Handle the warning before the event reaches its threshold.
    }
    func beginRequest(with context: NSExtensionContext) {
        print("beginRequest with: \(context)")
        self.context = context
    }
}
extension FamilyActivitySelection: RawRepresentable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
            let result = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
            let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}
