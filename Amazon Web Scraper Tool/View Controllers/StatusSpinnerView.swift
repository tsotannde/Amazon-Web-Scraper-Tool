//
//  StatusSpinnerView.swift
//  Amazon Web Scrapper
//
//  Created by tsotannde on 5/6/25.
//

import SwiftUI

struct SpinningStatusIcon: View {
    var body: some View {
        Image(systemName: "progress.indicator")
            .symbolEffect(.rotate.wholeSymbol, options: .repeat(.continuous))
            .foregroundColor(.gray)
            .font(.system(size: 12))
    }
}



