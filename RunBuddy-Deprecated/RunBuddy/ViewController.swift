//
//  ViewController.swift
//  RunBuddy
//
//  Created by Richard Mills on 1/25/20.
//  Copyright © 2020 Lazy Gardener. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var descriptionView: PlanDescriptionView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var plan:[Run] = []
    var currentRun: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        plan = Run.getAllRuns()
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return plan.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlanCollectionCell", for: indexPath)
        if let planCell = cell as? PlanCollectionCell {
            planCell.configure(run: plan[indexPath.row], isSelected: indexPath.row == currentRun)
        }
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let previousRun = currentRun
        currentRun = indexPath.row
        if previousRun != currentRun {
            let previousIndexPath = IndexPath(row: previousRun, section: 0)
            descriptionView.configure(run: plan[indexPath.row])
            collectionView.reloadItems(at: [previousIndexPath, indexPath])
        }
    }
}


extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
}

class PlanDescriptionView: UIView {
    @IBOutlet weak var dayTitle: UILabel!
    @IBOutlet weak var runDescription: UILabel!
    @IBOutlet weak var walkDescription: UILabel!
    @IBOutlet weak var repeatDescription: UILabel!
    
    let weekdays = Calendar.autoupdatingCurrent.weekdaySymbols
    
    func configure(run: Run) {
        dayTitle.text = "Week \(run.week): \(weekdays[run.day % 7])"
        dayTitle.textColor = .text
        
        let runTime = run.run
        if runTime > 0 {
            runDescription.text = "Run: \(run.runTitle)"
        } else {
            runDescription.text = ""
        }
        runDescription.textColor = .text
        
        let walkTime = run.walk
        if walkTime > 0 {
            walkDescription.text = "Walk: \(run.walkTitle)"
        } else {
            walkDescription.text = run.title
        }
        
        walkDescription.textColor = .text
        
        let repeatCount = run.repeatCount
        let mileTarget = run.mileTarget
        
        if repeatCount > 0 || mileTarget > 0 {
            if repeatCount > 0 {
                repeatDescription.text = "Repeat: \(repeatCount)x"
            } else {
                repeatDescription.text = "Mile target: \(mileTarget) Miles"
            }
        } else {
            repeatDescription.text = ""
        }
        
        repeatDescription.textColor = .text
        
        self.backgroundColor = run.color
    }
}

class PlanCollectionCell: UICollectionViewCell {
    @IBOutlet weak var weekTitle: UILabel!
    @IBOutlet weak var dayTitle: UILabel!
    @IBOutlet weak var dayTypeLabel: UILabel!
    @IBOutlet weak var selectedView: UIView!
    
    func configure(run: Run, isSelected: Bool) {
        
        selectedView.isHidden = !isSelected
        
        weekTitle.text = "Week \(run.week)"
        weekTitle.textColor = .text
        
        dayTitle.text = "Day \(run.day)"
        dayTitle.textColor = .text
        
        dayTypeLabel.text = run.title
        dayTypeLabel.textColor = .text
        
        self.contentView.backgroundColor = run.color
        
        self.layer.cornerRadius = 8
    }
}
