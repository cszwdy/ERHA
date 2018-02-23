//
//  StateStore.swift
//  ERHA
//
//  Created by Emiaostein on 05/02/2018.
//  Copyright © 2018 Emiaostein. All rights reserved.
//

import Foundation

protocol EventType {}
protocol StateType {}
protocol OperationType {}

class StateStore<Action: EventType, State: StateType, Command: OperationType> {
    
    private var preState: State?
    private var stateDidChanged:((_ old: State?, _ new: State, Command?)->())?
    private let reduce: (Action, State) -> (State, Command?)
    
    init(reduce: @escaping (Action, State) -> (State, Command?)) {
        self.reduce = reduce
    }
    
    func dispatch(_ action: Action) {
        guard let old = preState else {return}
        let (state, command) = reduce(action, old)
        preState = state
        if let changed = stateDidChanged {
            changed(old, state, command)
        }
    }
    
    func addObserver(initialState: State, command: Command?, stateDidChanged: @escaping (_ old: State?, _ new: State, Command?)->()) {
        self.preState = initialState
        self.stateDidChanged = stateDidChanged
        stateDidChanged(nil, initialState, command)
    }
    
    func removeObserver() {
        stateDidChanged = nil
    }
}
