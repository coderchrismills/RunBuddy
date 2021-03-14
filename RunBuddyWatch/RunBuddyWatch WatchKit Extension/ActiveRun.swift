//
//  ActiveRun.swift
//  RunBuddy
//
//  Created by Chris Mills on 12/21/20.
//

import SwiftUI

struct ActiveRun: View {
    @Binding var run: Run
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center) {
                Text("\(run.runInMinutes):00")
                    .font(.title)
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.20)
                    .padding(.bottom)
                Spacer()
                Button(action: toggleRunState) {
                    Text("Pause")
                        .font(.title2)
                        .foregroundColor(Color.white)
                }
                .frame(width: geometry.size.width, height: geometry.size.height * 0.80)
                .buttonStyle(PlainButtonStyle())
                .padding(2)
                .background(Color.blue)
                .clipShape(Circle())
            }
        }
    }
    
    private func toggleRunState() {
        
    }
}

struct ActiveRun_Previews: PreviewProvider {
    static var previews: some View {
        ActiveRun(run: .constant(Run.data[0]))
    }
}
