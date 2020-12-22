//
//  RunTile.swift
//  RunBuddy
//
//  Created by Chris Mills on 12/21/20.
//

import SwiftUI

struct RunTile: View {
    @Binding var run: Run
    var selectAction: () -> Void
    var body: some View {
        Button(action: selectAction) {
            VStack {
                Text("Week \(run.week)")
                Text("Day \(run.day)")
                Text("\(run.title)")
            }
            .padding()
            .background(run.color)
            .foregroundColor(.white)
        }
    }
}

struct RunTile_Previews: PreviewProvider {
    static var previews: some View {
        RunTile(run: .constant(Run.data[0]), selectAction: {})
    }
}
