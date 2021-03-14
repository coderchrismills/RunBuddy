//
//  RunData.swift
//  RunBuddy
//
//  Created by Chris Mills on 12/21/20.
//

import Foundation

class RunData: ObservableObject {
    @Published var runs: [Run] = []
    
    private static var fileURL: URL {
        guard let path = Bundle.main.path(forResource: "run", ofType: "json") else {
            fatalError("Unable to find run data")
        }
        return URL(fileURLWithPath: path)
    }
    
    func load() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let data = try? Data(contentsOf: Self.fileURL) else {
                #if DEBUG
                DispatchQueue.main.async {
                    self?.runs = Run.data
                }
                #endif
                return
            }
            
            guard let runData = try? JSONDecoder().decode([Run].self, from: data) else {
                fatalError("Unable to decode run data")
            }
            
            DispatchQueue.main.async {
                self?.runs = runData
            }
        }
    }
}
