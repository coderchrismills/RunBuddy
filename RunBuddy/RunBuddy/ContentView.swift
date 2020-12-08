//
//  ContentView.swift
//  RunBuddy
//
//  Created by Richard Mills on 12/7/20.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        GeometryReader { metrics in
            VStack {
                VStack(spacing: 16) {
                    Text("Week 13: Monday")
                        .font(.title)
                    Text("Run: 1 Minute")
                    Text("Walk 2 Minutes")
                    Text("Repeate: 10x")
                }
                .frame(width: metrics.size.width * 0.80, height: metrics.size.width * 0.80)
                .foregroundColor(Color.white)
                .background(Color("Run"))
                .padding(.leading, metrics.size.width * 0.10)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
