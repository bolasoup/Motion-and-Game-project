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

class ViewController: UIViewController, ThresholdViewControllerDelegate {
    
    //MARK: =====class variables=====
    let activityManager = CMMotionActivityManager()
    let now = Date()
    let pedometer = CMPedometer()
    var threshold: Int = 10000
    let motion = CMMotionManager()
    var totalSteps: Float = 0.0 {
        willSet(newtotalSteps){
            DispatchQueue.main.async{
                self.stepsSlider.setValue(newtotalSteps, animated: true)
                self.stepsLabel.text = "Steps: \(newtotalSteps)"
                self.totalSteps = newtotalSteps
            }
        }
    }
    
    //MARK: =====UI Elements=====
    @IBOutlet weak var stepsSlider: UISlider!
    @IBOutlet weak var currentStepsLabel: UILabel!
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var ThresholdButton: UIButton!
    @IBOutlet weak var isWalking: UILabel!
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var gamePlayButton: UIButton!
    
    //MARK: =====View Lifecycle=====
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.totalSteps = 0.0
        self.startActivityMonitoring()
        self.startPedometerMonitoring()
        self.startMotionUpdates()
        displayStepsFromToday { todaySteps in
                DispatchQueue.main.async {
                    self.currentStepsLabel.text = "Steps today: \(todaySteps)"
                }
            }
        self.displayStepsFromYesterday()
        self.displayGoal()
        self.threshold = loadThreshold()
        print(self.threshold)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(self.threshold)
        self.displayGoal()
        checkIfGoalMet()
    }
    
    func saveThreshold(_ value: Int) {
        UserDefaults.standard.set(value, forKey: "dailyGoal")
    }
    
    func loadThreshold() -> Int {
        return UserDefaults.standard.integer(forKey: "dailyGoal")
    }
    
    func didEnterValue(_ value: Int) {
        self.threshold = value
        saveThreshold(value)
        self.displayGoal()
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
        guard let activity = activity else { return }
        
        DispatchQueue.main.async {
            var activityType = "Unknown"
            
            if activity.walking {
                activityType = "Walking"
            } else if activity.stationary {
                activityType = "Still"
            } else if activity.running {
                activityType = "Running"
            } else if activity.cycling {
                activityType = "Cycling"
            } else if activity.automotive {
                activityType = "Driving"
            }
            
            self.isWalking.text = "Activity: \(activityType)"
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
            checkIfGoalMet()
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
    
    func displayStepsFromToday(completion: @escaping (Float) -> Void) {
        let now = Date()
        let calendar = Calendar.current
        
        let from = calendar.startOfDay(for: now)
        
        self.pedometer.queryPedometerData(from: from, to: now) { (pedData: CMPedometerData?, error: Error?) in
            if let steps = pedData?.numberOfSteps {
                let todaySteps = steps.floatValue
                completion(todaySteps)  // Pass the step count to the completion handler
            } else {
                completion(0.0)  // In case of error, pass 0 steps
            }
        }
    }
    
    func displayGoal() -> Void {
        DispatchQueue.main.async {
            self.goalLabel.text = "Goal: \(self.threshold)"
        }
    }
    
    @IBAction func thresholdPressed(_ sender: Any) {
    }
    
    @IBAction func startGame(_ sender: Any) {
        if gamePlayButton.isEnabled {
            // Code to start the game
            print("Game Started")
        } else {
            // Show an alert or message indicating the goal has not been met
            showAlert("You need to meet your step goal to play the game.")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ThresholdViewController" {
            if let thresholdVC = segue.destination as? ThresholdViewController {
                thresholdVC.delegate = self
            }
        }
        if segue.identifier == "GameViewController" {
            if let controller = segue.destination as? GameViewController{
                let now = Date()
                let calendar = Calendar.current
                
                let from = calendar.startOfDay(for: now)
                
                self.pedometer.queryPedometerData(from: from, to: now) { (pedData: CMPedometerData?, error: Error?) in
                    if let steps = pedData?.numberOfSteps {
                        let todaySteps = steps.intValue
                        controller.totalScore = todaySteps  // Pass the step count to the completion handler
                    } else {
                        controller.totalScore = 0  // In case of error, pass 0 steps
                    }
                }                
            }
            
        }
    }
    
    //func to check if they can play game by meeting step goals
    func checkIfGoalMet() {
        displayStepsFromToday{ todaySteps in
            let goal = Float(self.threshold)  // Assume threshold is the user's goal
            
            if todaySteps >= goal {
                // Enable the button to go to the game
                DispatchQueue.main.async {
                    self.gamePlayButton.isEnabled = true
                }
            } else {
                // Disable the game button if the goal is not met
                DispatchQueue.main.async {
                    self.gamePlayButton.isEnabled = false
                }
            }
        }
    }
    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

