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
        self.displayGoal()
        print(self.threshold)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(self.threshold)
        self.displayGoal()
    }
    
    func didEnterValue(_ value: Int) {
        self.threshold = value
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
    
    func displayGoal() -> Void {
        DispatchQueue.main.async {
            self.goalLabel.text = "Goal: \(self.threshold)"
        }
    }
    
    @IBAction func thresholdPressed(_ sender: Any) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ThresholdViewController" {
            if let thresholdVC = segue.destination as? ThresholdViewController {
                thresholdVC.delegate = self
            }
        }
    }
}

