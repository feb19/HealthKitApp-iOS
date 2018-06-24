//
//  ViewController.swift
//  ActivityRingApp
//
//  Created by Nobuhiro Takahashi on 2018/06/21.
//  Copyright © 2018年 Nobuhiro Takahashi. All rights reserved.
//

import UIKit
import HealthKit
import HealthKitUI

class ViewController: UIViewController {

    var store: HKHealthStore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        auth()
    }
    
    func auth() {
        store = HKHealthStore()
        
        let objectTypes: Set<HKObjectType> = [
            HKObjectType.activitySummaryType()
        ]
        
        store.requestAuthorization(toShare: nil, read: objectTypes) { (success, error) in
            
            // Authorization request finished, hopefully the user allowed access!
            
            self.getSummary()
        }
    }
    
    func show(activitySummaries: [HKActivitySummary]) {
        
//        let summary = HKActivitySummary()
        
        // ムーヴ 
//        summary.activeEnergyBurnedGoal = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: 200.0)
//        summary.activeEnergyBurned = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: 150.0)
//
        // エクササイズ
//        summary.appleExerciseTime = HKQuantity(unit: HKUnit.hour(), doubleValue: 0.5)
//        summary.appleExerciseTimeGoal = HKQuantity(unit: HKUnit.hour(), doubleValue: 1.0)
//
        // スタンド
//        summary.appleStandHours = HKQuantity(unit: HKUnit.count(), doubleValue: 2)
//        summary.appleStandHoursGoal = HKQuantity(unit: HKUnit.count(), doubleValue: 8)
        
        for index in 0..<activitySummaries.count {
            let ringView = HKActivityRingView(frame: CGRect(x: 120*(index % 3), y: Int(120*floor(Double(index/3))), width: 120, height: 120))
            let activitySummary = activitySummaries[index]
            ringView.setActivitySummary(activitySummary, animated: true)
            print("move: \(activitySummary.activeEnergyBurned) / \(activitySummary.activeEnergyBurnedGoal)")
            print("exercise: \(activitySummary.appleExerciseTime) / \(activitySummary.appleExerciseTimeGoal)")
            print("stand: \(activitySummary.appleStandHours) / \(activitySummary.appleStandHoursGoal)")
            self.view.addSubview(ringView)
        }
    }
    
    func getSummary() {
        guard let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian) else {
            fatalError("*** This should never fail. ***")
        }
        
        let endDate = NSDate()
        
        guard let startDate = calendar.date(byAdding: .day, value: -7, to: endDate as Date, options: []) else {
            fatalError("*** unable to calculate the start date ***")
        }
        
        let units: NSCalendar.Unit = [.day, .month, .year, .era]
        
        var startDateComponents = calendar.components(units, from: startDate)
        startDateComponents.calendar = calendar as Calendar
        
        var endDateComponents = calendar.components(units, from: endDate as Date)
        endDateComponents.calendar = calendar as Calendar
        
        
        // Create the predicate for the query
        let summariesWithinRange = HKQuery.predicate(forActivitySummariesBetweenStart: startDateComponents, end: endDateComponents)
        
        // Build the query
        let query = HKActivitySummaryQuery(predicate: summariesWithinRange) { (query, summaries, error) -> Void in
            guard let activitySummaries = summaries else {
                guard let queryError = error else {
                    fatalError("*** Did not return a valid error object. ***")
                }
                
                // Handle the error here...
                
                return
            }
            
            // Do something with the summaries here...
            self.show(activitySummaries: activitySummaries)
        }
        
        // Run the query
        store.execute(query)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

