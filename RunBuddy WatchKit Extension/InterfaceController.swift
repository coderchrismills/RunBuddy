//
//  InterfaceController.swift
//  RunBuddy WatchKit Extension
//
//  Created by Richard Mills on 1/25/20.
//  Copyright © 2020 Lazy Gardener. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    @IBOutlet weak var tableView: WKInterfaceTable!
    
    var plan: [Run] = []
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        if let path = Bundle.main.path(forResource: "run", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let runs = jsonResult["runs"] as? [Any] {
                    for runJson in runs {
                        if let runDictionary = runJson as? Dictionary<String, AnyObject> {
                            let run = Run(dict: runDictionary)
                            plan.append(run)
                        }
                    }
                }
            } catch {
                // handle error
                print(error.localizedDescription)
            }
        }
        
        tableView.setNumberOfRows(plan.count, withRowType: "RunRow")
        
        for index in 0..<tableView.numberOfRows {
            guard let controller = tableView.rowController(at: index) as? RunRowController else { continue }
            controller.run = plan[index]
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
