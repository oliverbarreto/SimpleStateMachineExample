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
    var stateMachine: SimpleStateMachine<ViewController>!

    
    // Config Lights times
    let greenLightDuration = 10.0
    let redLightDuration = 10.0
    let orangeLightDuration = 2.5
    
    // MARK: IBOutlets & IBActions
    @IBOutlet weak var trafficLight: UIView!
    
  
    @IBAction func stop(_ sender: UIButton) {
        print("stop button pressed")
        stateMachine.transition(withEvent: .SetStop)
    }
    
    @IBAction func caution(_ sender: UIButton) {
        print("caution button pressed")
        stateMachine.transition(withEvent: .SetCaution)
    }
    
    @IBAction func go(_ sender: UIButton) {
        print("go button pressed")
        stateMachine.transition(withEvent: .SetGo)
    }
    
    
    // MARK: ViewDidLoad Life-Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // View setup
        self.trafficLight.layer.cornerRadius = self.trafficLight.bounds.width / 2
        
        
        // State Machine Initialization (maight be instersting exploring the creation of a schema struct that fully describes the State Machine init???)
        let validStates:[StateMachineState: [StateMachineState]] =
            [
             .Go: [.Caution],
             .Caution: [.Stop],
             .Stop: [.Go]
            ]
        
        let validEvents:[StateMachineEvent] =
            [.SetStop,
             .SetCaution,
             .SetGo
        ]
        
        let validTransitionEvents: [StateMachineEvent: (StateMachineState,StateMachineState)] = [
            .SetStop: (.Caution, .Stop),
            .SetCaution:(.Go,.Caution),
            .SetGo: (.Stop, .Go)
            ]
        self.stateMachine = SimpleStateMachine(initialState: .Stop, transitionEventsList: validTransitionEvents, withDelegate: self)
        
        // Automate Lights Changes
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + greenLightDuration, execute: {
            self.stateMachine.transition(withEvent: .SetGo)
        })
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}



// MARK: Extension to Conform to SimpleStateMachineDelegateProtocol
extension ViewController: SimpleStateMachineDelegateProtocol {
    
    typealias StateMachineState = TrafficLigthsStates
    typealias StateMachineEvent = TrafficLigthsEvents
    
    // Defines the valid states
    enum TrafficLigthsStates {
        case Stop, Go, Caution
        
        var description: String {
            
            switch self {
            case .Caution:
                return "Caution"
            case .Stop:
                return "Stop"
            case .Go:
                return "Go"
            }
        }
    }
    
    // Defines the valid events triggering valid transitions (FromState, ToState) tuples
    enum TrafficLigthsEvents {
        case SetStop
        case SetGo
        case SetCaution

        var description: String {
            
            switch self {
            case .SetStop:
                return "SetStop"
            case .SetCaution:
                return "SetCaution"
            case .SetGo:
                return "SetGo"
            }
        }
    }
    
    func didTransition(fromState: ViewController.TrafficLigthsStates, toState: ViewController.TrafficLigthsStates, withEvent event: ViewController.StateMachineEvent) {
        
        var color = UIColor()
        
        
        
        // Switch events instead of from:to State pairs
        switch (fromState, toState) {
        case (_, .Go):
            color = .green
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + greenLightDuration, execute: {
                self.stateMachine.transition(withEvent: .SetCaution)
            })
        case (_, .Stop):
            color = .red
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + redLightDuration, execute: {
                self.stateMachine.transition(withEvent: .SetGo)
            })
        case (_, .Caution):
            color = .orange
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + orangeLightDuration, execute: {
                self.stateMachine.transition(withEvent: .SetStop)
        })
        }
        
        UIView.animate(withDuration: 0.3) {
            self.trafficLight.backgroundColor = color
        }
        
    }

}


