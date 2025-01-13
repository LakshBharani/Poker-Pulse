//
//  ContentView.swift
//  TrackMyHand
//
//  Created by Laksh Bharani on 12/01/25.
//

import SwiftUI
import GoogleMobileAds

struct ContentView: View {
    init() {
        // Start Google Mobile Ads
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }
    
    var body: some View {
        VStack {
            HomeView()
            Spacer()
            AdBannerView(adUnitID: "ca-app-pub-3940256099942544/2934735716")
//            AdBannerView(adUnitID: "ca-app-pub-1765331819043429/6461110373")
                .frame(height: 50)
        }
    
    }
}

extension UIApplication {
    func getRootViewController() -> UIViewController? {
        guard let scene = connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            return nil
        }
        return window.rootViewController
    }
}

struct AdBannerView: UIViewRepresentable {
    let adUnitID: String

    func makeUIView(context: Context) -> GADBannerView {
        let bannerView = GADBannerView(adSize: GADAdSizeFromCGSize(CGSize(width: 320, height: 50))) // Set your desired banner ad size
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = UIApplication.shared.getRootViewController()
        bannerView.load(GADRequest())
        return bannerView
    }
    
    func updateUIView(_ uiView: GADBannerView, context: Context) {}
}

#Preview {
    ContentView()
}
