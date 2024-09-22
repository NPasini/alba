//
//  SpinnerView.swift
//  imageDownloader
//
//  Created by nicolo.pasini on 22/09/24.
//

import SwiftUI

struct SpinnerView: View {
    private let color: Color
    
    var body: some View {
        ProgressView()
            .progressViewStyle(
                CircularProgressViewStyle(tint: color)
            )
            .scaleEffect(2.0, anchor: .center)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    // Simulates a delay in content loading
                    // Perform transition to the next view here
                }
            }
    }
    
    init(color: Color) {
        self.color = color
    }
}

#Preview("SpinnerView") {
    VStack(spacing: 30) {
        SpinnerView(color: .gray)
        SpinnerView(color: .blue)
    }
}
