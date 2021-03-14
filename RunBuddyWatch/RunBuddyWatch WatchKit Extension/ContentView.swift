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
    
    var body: some View {
        NavigationView {
            if runs.isEmpty {
                Text("No available runs")
            } else {
                VStack() {
                    GeometryReader { geometry in
                        TabView(selection: $selectedIndex) {
                            ForEach(runs) { run in
                                if let runIndex = getRunIndex(for: run) {
                                    RunCard(run: binding(for: run))
                                        .frame(maxHeight: geometry.size.height * 0.8)
                                        .padding()
                                        .padding(.top, -58)
                                        .tag(runIndex)
                                }
                            }
                        }
                    }
                    .tabViewStyle(CarouselTabViewStyle())
                    
                    Button(action: {
                        self.isLinkActive = true
                        self.navBarHidden = true
                    }) {
                        Text("GO")
                            .font(.title2)
                            .foregroundColor(Color.white)
                    }
                    .buttonStyle(BorderedButtonStyle())
                    .padding(2)
                    .background(runs[selectedIndex].isRunDay ? Color.accent : Color.accentDisabled)
                    .clipShape(RoundedRectangle(cornerRadius: 21, style: .continuous))
                    .frame(maxHeight: 48)
                    .padding(.all)
                    .disabled(runs[selectedIndex].isRunDay == false)
  
                }
                .ignoresSafeArea()
                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                .background(NavigationLink(destination: ActiveRun(run: $runs[selectedIndex]), isActive: $isLinkActive) {
                    EmptyView()
                }
                .hidden())
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
        ContentView(runs: .constant(Run.data), selectedIndex: 0)
    }
}
