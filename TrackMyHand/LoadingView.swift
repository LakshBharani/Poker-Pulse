//
//  LoadingView.swift
//  TrackMyHand
//
//  Created by Laksh Bharani on 21/11/24.
//

import SwiftUI

struct LoadingView: View {
    var subTitle: String
    var body: some View {
        VStack {
            ProgressView()
                .padding()
            Text(subTitle)
        }
    }
}

#Preview {
    LoadingView(subTitle: "")
}
