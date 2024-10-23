//
//  ViewController.swift
//  Commotion
//
//  Created by Eric Larson on 9/6/16.
//  Copyright © 2016 Eric Larson. All rights reserved.
//

import UIKit
import CoreMotion
import Foundation

class ViewController: UIViewController {
    //bola
    
    //MARK: =====class variables=====
    let activityManager = CMMotionActivityManager()
    let now = Date()
    //let from = now.addingTimeInterval(-60*60*24)
    let pedometer = CMPedometer()
    let motion = CMMotionManager()
    var totalSteps: Float = 0.0 {
        willSet(newtotalSteps){
            DispatchQueue.main.async{
                self.stepsSlider.setValue(newtotalSteps, animated: true)
                self.stepsLabel.text = "Steps: \(newtotalSteps)"
            }
        }
    }
    
    //MARK: =====UI Elements=====
    @IBOutlet weak var stepsSlider: UISlider!
    @IBOutlet weak var currentStepsLabel: UILabel!
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var isWalking: UILabel!
    
    //stuff needed for daily step goal
    @IBOutlet weak var goalTextField: UITextField!  // Input field for the user to set goal
    @IBOutlet weak var remainingStepsLabel: UILabel! // Displays remaining steps
    @IBOutlet weak var setGoalButton: UIButton!      // Button to save the goal
    
    
    //MARK: =====View Lifecycle=====
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.totalSteps = 0.0
        self.startActivityMonitoring()
        self.startPedometerMonitoring()
        self.startMotionUpdates()
        self.displayStepsFromToday()
        self.displayStepsFromYesterday()
        
        goalTextField.text = "\(loadDailyGoal())"
        updateRemainingSteps()
    }
    
    
    // MARK: =====Raw Motion Functions=====
    func startMotionUpdates(){
        // some internal inconsistency here: we need to ask the device manager for device 
        
        // TODO: should we be doing this from the MAIN queue? You will need to fix that!!!....
        if self.motion.isDeviceMotionAvailable{
            self.motion.startDeviceMotionUpdates(to: OperationQueue.main,
                                                 withHandler: self.handleMotion)
        }
    }
    
    func handleMotion(_ motionData:CMDeviceMotion?, error:Error?){
        if let gravity = motionData?.gravity {
            let rotation = atan2(gravity.x, gravity.y) - Double.pi
            self.isWalking.transform = CGAffineTransform(rotationAngle: CGFloat(rotation))
        }
    }
    
    // MARK: =====Activity Methods=====
    func startActivityMonitoring(){
        // is activity is available
        if CMMotionActivityManager.isActivityAvailable(){
            // update from this queue (should we use the MAIN queue here??.... )
            self.activityManager.startActivityUpdates(to: OperationQueue.main, withHandler: self.handleActivity)
        }
        
    }
    
    func handleActivity(_ activity:CMMotionActivity?)->Void{
        // unwrap the activity and disp
        if let unwrappedActivity = activity {
            DispatchQueue.main.async{
                self.isWalking.text = "Walking: \(unwrappedActivity.walking)\n Still: \(unwrappedActivity.stationary)"
            }
        }
    }
    
    // MARK: =====Pedometer Methods=====
    func startPedometerMonitoring(){
        //separate out the handler for better readability
        if CMPedometer.isStepCountingAvailable(){
            pedometer.startUpdates(from: Date(),
                                   withHandler: handlePedometer)
        }
    }
    
    //ped handler
    func handlePedometer(_ pedData:CMPedometerData?, error:Error?)->(){
        if let steps = pedData?.numberOfSteps {
            self.totalSteps = steps.floatValue
            updateRemainingSteps()
        }
    }
    
    
    func displayStepsFromYesterday() -> Void {
        let now = Date()  // Define 'now'
        let from = now.addingTimeInterval(-60*60*24)
        
        self.pedometer.queryPedometerData(from: from, to: now) { (pedData: CMPedometerData?, error: Error?) in
            
            let aggregated_string = "Steps: \(pedData?.numberOfSteps ?? 0)"
            
            DispatchQueue.main.async {
                self.stepsLabel.text = aggregated_string
            }
        }
    }
    
    func displayStepsFromToday() -> Void {
        let now = Date()
        let calendar = Calendar.current
        
        let from = calendar.startOfDay(for: now)
        
        self.pedometer.queryPedometerData(from: from, to: now) {
            (pedData: CMPedometerData?, error: Error?) in
            
            let aggregated_string = "Steps: \(pedData?.numberOfSteps ?? 0)"
            
            DispatchQueue.main.async {
                self.currentStepsLabel.text = aggregated_string
            }
        }
    }
    
    let goalKey = "dailyGoal"

    // Function to save step goal
    @IBAction func setGoalButtonTapped(_ sender: UIButton) {
        if let goalText = goalTextField.text, let goal = Float(goalText) {
            UserDefaults.standard.set(goal, forKey: goalKey)
            updateRemainingSteps()  // Update it
        }
    }

    // Function to load the daily goal when the app starts
    func loadDailyGoal() -> Float {
        return UserDefaults.standard.float(forKey: goalKey)  // Load the goal (0.0 if not set)
    }
    
    //func to update steps remaining
    func updateRemainingSteps() {
        let dailyGoal = loadDailyGoal()  // Load the saved goal
        let remainingSteps = dailyGoal - totalSteps  // Calculate remaining steps
        remainingStepsLabel.text = "Remaining Steps: \(max(remainingSteps, 0))"
    }

}

