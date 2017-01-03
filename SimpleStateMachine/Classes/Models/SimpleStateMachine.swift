//
//  SimpleStateMachine.swift
//  SimpleStateMachine
//
//  Created by David Oliver Barreto Rodríguez on 1/1/17.
//  Copyright © 2017 David Oliver Barreto Rodríguez. All rights reserved.
//

import Foundation


//: Simple State Machine Delegate Protocol
protocol SimpleStateMachineDelegateProtocol: class {
    
    // Defines the future States of the Machine
    // make this be hashable so we can pass in a dictionary with the list of valid transitions
    associatedtype StateMachineState: Hashable
    
    // Used to notify the delegate that a valid transition from state A to B has happened, so it is able to perform somthing upon that change
    func didTransition(fromState: StateMachineState, toState: StateMachineState)
    
    // This version does not use previous function:
    // func shouldTransitionFromCurrentState(toState: StateMachineState) -> Bool
    // It uses an Array of valid states stored as a property in the SimpleStateMachine Class:
    // private let validStateTransitions: [P.StateMachineState: [P.StateMachineState]]
}



//: Simple -GENERIC- State Machine
class SimpleStateMachine<P: SimpleStateMachineDelegateProtocol>  {
    
    // Delegate
    private unowned let delegate: P
    
    // State Machine Config defined with a list of Valid Machine States
    private let validStateTransitions: [P.StateMachineState: [P.StateMachineState]]
    
    
    // Current Valid State
    private var _state: P.StateMachineState {
        didSet {
            delegate.didTransition(fromState: oldValue, toState: _state)
        }
    }
    
    // Facade of Internal State
    var state: P.StateMachineState {
        get {
            return _state
        }
        set {
            if isValidTransition(toState: newValue) {
                print("Transitionning from \(_state) to new state \(newValue)")
                _state = newValue
                
            } else {
                // error handling...
                print("Invalid transition: Cannot Transition from \(_state) to state \(newValue)")
            }
        }
    }
    
    // Full Init
    init(initialState: P.StateMachineState, validTransitions: [P.StateMachineState: [P.StateMachineState]], withDelegate delegate: P) {
        self._state = initialState  //set the facade -primitive- to avoid calling the delegate
        self.validStateTransitions = validTransitions
        self.delegate = delegate
    }
    
    
    //  Determines if a transition is valid from the StateMachine array passed at initialization
    private func isValidTransition(toState: P.StateMachineState) -> Bool {
        let shouldTransition = (validStateTransitions[_state]?.contains(toState))! ? true :  false
        return shouldTransition
    }
    
    // Printing Descriptions of Status and Valid Transitions... TODO: they can be drawn
    public func stateDescription()-> String {
        let str = "Current State: \(_state)"
        return str
    }
    public func validStateTransitionsDescription()-> String {
        let str = "Valid States: \(validStateTransitions)"
        return str
    }
}
