//
//  ThresholdViewController.swift
//  Commotion
//
//  Created by Travis Peck on 10/23/24.
//  Copyright © 2024 Eric Larson. All rights reserved.
//

import UIKit

protocol ThresholdViewControllerDelegate: AnyObject {
    func didEnterValue(_ value: Int)
}

class ThresholdViewController: UIViewController {

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var thresholdField: UITextField!
    
    weak var delegate : ThresholdViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Threshold"
        // Do any additional setup after loading the view.
    }
    

    @IBAction func saveButtonTapped(_ sender: UIButton) {
        if let text = thresholdField.text {
            delegate?.didEnterValue(Int(text) ?? 0)
        }
        navigationController?.popViewController(animated: true)
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
