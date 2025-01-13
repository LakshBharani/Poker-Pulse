//
//  TrackMyHandApp.swift
//  TrackMyHand
//
//  Created by Laksh Bharani on 19/11/24.
//

import SwiftUI
import FirebaseCore
import GoogleMobileAds

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      GADMobileAds.sharedInstance().start(completionHandler: nil)
      FirebaseApp.configure()
      return true
  }
}


@main
struct TrackMyHandApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}
