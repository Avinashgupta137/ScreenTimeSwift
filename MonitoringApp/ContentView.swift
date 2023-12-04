//
//  ContentView.swift
//  MonitoringApp
//
//  Created by IPS-177  on 02/12/23.
//

import SwiftUI
import FamilyControls
import DeviceActivity
import ManagedSettings

struct ContentView: View {
    
    @AppStorage("shieldedApp", store: UserDefaults(suiteName: "group.com.Avinash.ScreenTDemo")) var shieldedApps = FamilyActivitySelection()
    
    @State var isShieldedAppPickerPresented = false
    
    var body: some View {
        VStack {
            Text("Time Out")
                .font(.title)
                .padding()
            
            Button {
                Task {
                    do {
                        try await AuthorizationCenter.shared.requestAuthorization(for: .child)
                        print("Success")

                                _ = AuthorizationCenter.shared.$authorizationStatus
                                    .sink() {_ in
                                    switch AuthorizationCenter.shared.authorizationStatus {
                                    case .notDetermined:
                                        print("not determined")
                                    case .denied:
                                        print("denied")
                                    case .approved:
                                        print("approved")
                                    @unknown default:
                                        break
                                    }
                                }
                    }
                    catch {
                        print("error for screentime is \(error)")
                    }
                }
            } label: {
                Text("Request Authorization")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.blue)
            
            Button {
                requestNotificationPermission()
                
            } label: {
                Text("Request Notifications Permission")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.blue)
            
            Button {
                isShieldedAppPickerPresented.toggle()
            } label: {
                Text("Select Apps to Shield")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.red)
            
            Button {
                shieldedApps = FamilyActivitySelection()
//                startDeviceActivityMonitoring(includeUsageThreshold: false)
                stopMonitoring()
//                startDeviceActivityMonitoring()
            } label: {
                Text("Reset Shielded Apps")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.green)
            
            Button {
                startDeviceActivityMonitoring()
                
            } label: {
                Text("Grant Time for Selected Apps")
                    .font(.headline)
            }
//            .disabled(shieldedApps.applicationTokens.isEmpty)
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.indigo)
            
            Text("Apps are given 10 seconds of use.")
                .font(.subheadline)
        }
        .familyActivityPicker(isPresented: $isShieldedAppPickerPresented,
                              selection: $shieldedApps)
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .badge, .sound])
        { success, error in
            if success {
                print("Notification permission approved.")
                
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    private func startDeviceActivityMonitoring(includeUsageThreshold: Bool = true) {
        // APP: Monitor a DeviceActivitySchedule
        let dateComponents = Calendar.current.dateComponents([.hour, .minute, .second],
                                                             from: Date())
        print("dateComponents: \(dateComponents)")
        
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: dateComponents.hour,
                                          minute: dateComponents.minute,
                                          second: dateComponents.second),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )
        
        let event = DeviceActivityEvent(applications: shieldedApps.applicationTokens,
                                        threshold: DateComponents(second: 10))
        
        let center = DeviceActivityCenter()
        do {
            try center.startMonitoring(.daily,
                                       during: schedule,
                                       events: includeUsageThreshold ? [.tenSeconds : event] : [:])
            print("Monitoring started")
        } catch {
            print("Unexpected error: \(error).")
        }
    }
    private func stopMonitoring() {
        let center = DeviceActivityCenter()
        center.stopMonitoring()
        MyMonitor.shared.intervalDidEnd(for: DeviceActivityName.daily)
    }
    
}

extension DeviceActivityName {
    static let daily = Self("daily")
}

extension DeviceActivityEvent.Name {
    static let tenSeconds = Self("threshold.seconds.ten")
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
