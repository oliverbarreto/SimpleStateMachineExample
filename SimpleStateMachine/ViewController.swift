//
//  ViewController.swift
//  SimpleStateMachine
//
//  Created by David Oliver Barreto Rodríguez on 1/1/17.
//  Copyright © 2017 David Oliver Barreto Rodríguez. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: Model
    // SimpleStateMachine
    public var stateMachine: SimpleStateMachine<ViewController>!
    
    // Config Lights times
    let greenLightDuration = 10.0
    let redLightDuration = 10.0
    let orangeLightDuration = 2.5
    
    // MARK: IBOutlets & IBActions
    @IBOutlet weak var trafficLight: UIView!
    
  
    @IBAction func stop(_ sender: UIButton) {
        print("stop button pressed")
        stateMachine.state = .Stop
    }
    
    @IBAction func caution(_ sender: UIButton) {
        print("caution button pressed")
        stateMachine.state = .Caution
    }
    
    @IBAction func go(_ sender: UIButton) {
        print("go button pressed")
        stateMachine.state = .Go
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // View setup
        self.trafficLight.layer.cornerRadius = self.trafficLight.bounds.width / 2
        
        
        // State Machine Init
        let validStates:[StateMachineState: [StateMachineState]] = [.Go: [.Caution], .Caution: [.Stop], .Stop: [.Go]]
        self.stateMachine = SimpleStateMachine(initialState: .Stop, validTransitions: validStates, withDelegate: self)
        
        // Automate Lights Changes
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + greenLightDuration, execute: {
            self.stateMachine.state = .Go
        })
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


extension ViewController: SimpleStateMachineDelegateProtocol {
    
    typealias StateMachineState = TrafficLigthsStates
    
    // Defines the valid states
    enum TrafficLigthsStates: Int {
        case Stop, Go, Caution
    }
    
    func didTransition(fromState: ViewController.TrafficLigthsStates, toState: ViewController.TrafficLigthsStates) {
        
        var color = UIColor()
        switch (fromState, toState) {
        case (_, .Go):
            color = .green
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + greenLightDuration, execute: {
                self.stateMachine.state = .Caution
            })
        case (_, .Stop):
            color = .red
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + redLightDuration, execute: {
                self.stateMachine.state = .Go
            })
        case (_, .Caution):
            color = .orange
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + orangeLightDuration, execute: {
                self.stateMachine.state = .Stop
            })
        }
        
        
        UIView.animate(withDuration: 0.3) {
            self.trafficLight.backgroundColor = color
        }
        
    }

}


