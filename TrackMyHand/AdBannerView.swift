//
//  AdBannerView.swift
//  TrackMyHand
//
//  Created by Laksh Bharani on 12/01/25.
//

import SwiftUI
import GoogleMobileAds

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
        let bannerView = GADBannerView(adSize: GADAdSizeFromCGSize(CGSize(width: 320, height: 50)))
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = UIApplication.shared.getRootViewController()
        bannerView.load(GADRequest())
        return bannerView
    }
    
    func updateUIView(_ uiView: GADBannerView, context: Context) {}
}

struct PlacableAdBanner: View {
    @State private var adSettings: AdSettings?
    @StateObject private var firestoreService = FirestoreService()
    var adIdentifier: String
    
    var body: some View {
        VStack {
            if adSettings?.adEnabled == true && adSettings != nil {
                Spacer()
                AdBannerView(adUnitID: adSettings!.id)
            }
        }
        .frame(height: adSettings?.adEnabled ?? false ? (adSettings?.height ?? 0) : 0)
        .onAppear {
            firestoreService.fetchAdSettings(adIdentifier: adIdentifier) { result in
                if let adSettings = result {
                    self.adSettings = adSettings
                }
            }
        }
    }
}

#Preview {
    AdBannerView(adUnitID: "ca-app-pub-3940256099942544/2934735716")
    // ca-app-pub-3940256099942544/9214589741 -- test
    // ca-app-pub-3940256099942544/2934735716 -- real
}
