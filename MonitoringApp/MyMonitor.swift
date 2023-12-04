//
//  MyMonitor.swift
//  DeviceActivityCenter
//
//  Created by Nirav Patel on 21/11/23.
//

import UIKit
import MobileCoreServices
import ManagedSettings
import DeviceActivity
import SwiftUI
import FamilyControls


class MyMonitor: DeviceActivityMonitor {
    let store = ManagedSettingsStore()
    var context: NSExtensionContext?
    static let shared = MyMonitor()
    
    
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        print("interval did start")
       
//        let applications = model.selectionToDiscourage.applicationTokens
//                        if let object = UserDefaults.standard.object(forKey: "SelectedAppTokens") as? Data {
//                            let decoder = JSONDecoder()
//                            if let appTokens = try? decoder.decode(Set<ActivityCategoryToken>.self, from: object) {
//                                store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(appTokens, except: Set())
//                            }
//                        }
        store.dateAndTime.requireAutomaticDateAndTime = true
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.dateAndTime.requireAutomaticDateAndTime = false
    }
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        print("eventDidReachThreshold")
    }
}
