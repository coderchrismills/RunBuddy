//
//  ContentView.swift
//  RunBuddy
//
//  Created by Richard Mills on 12/7/20.
//

import SwiftUI

struct ContentView: View {
    @Binding var runs: [Run]
    @State var selectedIndex: Int
    var body: some View {
        VStack {
            if runs.isEmpty {
                Text("No available runs")
            } else {
                RunCard(run: $runs[selectedIndex])
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(runs) { run in
                            RunTile(run: binding(for: run)) {
                                if let runIndex = getRunIndex(for: run) {
                                    selectedIndex = runIndex
                                }
                            }
                        }
                    }
                }.background(Color.gray)
            }
        }
        .foregroundColor(.white)
    }
    
    private func binding(for run: Run) -> Binding<Run> {
        guard let runIndex = getRunIndex(for: run) else {
            fatalError("Can't find run")
        }
        return $runs[runIndex]
    }
    
    private func getRunIndex(for run: Run) -> Int? {
        guard let runIndex = runs.firstIndex(where: {$0.id == run.id}) else {
            return nil
        }
        return runIndex
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(runs: .constant(Run.data), selectedIndex: 0)
    }
}
