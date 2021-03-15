//
//  ContentView.swift
//  RunBuddyWatch WatchKit Extension
//
//  Created by Chris Mills on 3/12/21.
//

import SwiftUI

struct ContentView: View {
    @Binding var runs: [Run]
    @State var selectedIndex: Int = 0
    @State var isLinkActive = false
    @State private var navBarHidden = true
    @EnvironmentObject var runSession: RunSession
    
    var body: some View {
        NavigationView {
            if runs.isEmpty {
                Text("No available runs")
            } else {
                List {
                    ForEach(runs) { run in
                        if run.type == .run {
                            NavigationLink(destination: ActiveRun(run: binding(for: run))) {
                                RunCard(run: binding(for: run))
                            }
                        } else {
                            RunCard(run: binding(for: run))
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
                .ignoresSafeArea()
                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            }
        }
        .navigationBarTitle("")
        .navigationBarHidden(self.navBarHidden)
        .onAppear(perform: {
            self.navBarHidden = true
        })
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
        ContentView(runs: .constant(Run.data)).environmentObject(RunSession())
    }
}
