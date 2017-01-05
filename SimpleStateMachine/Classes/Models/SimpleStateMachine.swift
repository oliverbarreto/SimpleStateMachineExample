//
//  SimpleStateMachine.swift
//  SimpleStateMachine
//
//  Created by David Oliver Barreto Rodríguez on 1/1/17.
//  Copyright © 2017 David Oliver Barreto Rodríguez. All rights reserved.
//
//  The MIT License (MIT)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


import Foundation


//MARK: - Protocol: Simple State Machine Delegate Protocol
protocol SimpleStateMachineDelegateProtocol: class {
    
    // Defines the States of the Machine and the events that trigger transitions
    // We make them be hashable so we can pass in a dictionary with the list of valid transitions
    associatedtype StateMachineState: Hashable
    associatedtype StateMachineEvent: Hashable
    
    
    // Used to notify the delegate that a valid transition from state A to B has happened, so it is able to perform somthing upon that change
    func didTransition(fromState: StateMachineState, toState: StateMachineState, withEvent event:StateMachineEvent)
}



//MARK: Class: Simple -GENERIC- State Machine class
class SimpleStateMachine<P: SimpleStateMachineDelegateProtocol> {
    
    // MARK: -Conformance to SimpleStateMachineDelegateProtocol
    // =============================================================================
    
    // Delegate: the State Machine MUST have a delegate, thus... no Optional
    private unowned let delegate: P
    
    
    
    // MARK: - State Machine
    // =============================================================================
    
    // Initial State
    private var initialState: P.StateMachineState

    // Stores the logic of the State Machine in the form of a set of P.StateMachineEvent: (P.StateMachineState,P.StateMachineState) passed bye the delegate in a dictionary at initialization time
    typealias StateMachineTransitions = [P.StateMachineEvent: (P.StateMachineState,P.StateMachineState)]
    private var eventsLogic: StateMachineTransitions
    
    // Full Init
    public init(initialState: P.StateMachineState, transitionEventsList: StateMachineTransitions, withDelegate delegate: P) {
        
        self.initialState = initialState
        self._state = initialState
        self.eventsLogic = transitionEventsList
        self.delegate = delegate
    }

    
    
    //  Determines if a transition is valid from the StateMachine valid events diccionary passed at initialization
    private func isValidTransition(withEvent event: P.StateMachineEvent) -> Bool {
        
        // If the event exists associated to the current state...
        if let fromState = eventsLogic[event]?.0 as P.StateMachineState! {
            return fromState == self._state ? true : false
        }
        return false
    }
    
    
    
    // Current Valid State
    private var _state: P.StateMachineState
    
    
    
    // MARK: Public API
    // =============================================================================
    
    // Resets the State Machine to its initial state
    public func resetStateMachine() {
        self._state = self.initialState
    }
    
    // Open API to call transitions on the State Machine
    public func transition(withEvent event: P.StateMachineEvent) {
        if isValidTransition(withEvent: event) {
            if let toState = eventsLogic[event]?.1 as P.StateMachineState! {
                let oldValue = self._state
                
                self._state = toState
                delegate.didTransition(fromState: oldValue, toState: toState, withEvent: event)
            }
        } else {
            // error handling...
            print("Invalid transition: Cannot Transition with Event: \(event), from State: \(_state)")
        }
    }
    
    
    
    
    // MARK: Description
    // =============================================================================
    
    // Printing Descriptions of Status and Valid Transitions... TODO: they can be drawn
    public func stateDescription()-> String {
        let str = "Current State: \(self._state)"
        return str
    }
    public func validStateTransitionsDescription()-> String {
        let str = "Valid States: \(eventsLogic)"
        return str
    }
}
