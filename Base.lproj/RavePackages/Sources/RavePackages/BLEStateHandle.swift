//
//  File.swift
//  
//
//  Created by SeanHuang on 4/19/24.
//
//This file has all the state transition to handle cases when ui and bluetooth are updating competitively
import Foundation

internal final class BLEMachine{
    private var stateActionMap : StateActionMap = [:]
    private var actionMap : ActionMap = [:]
    private var errorMap  : ErrorMap = [:]
    private var currentStatate : BLEState? = .online
    init(stateActionMap: StateActionMap, actionMap: ActionMap, errorMap: ErrorMap, currentStatate: BLEState? = nil) {
        self.stateActionMap = stateActionMap
        self.actionMap = actionMap
        self.errorMap = errorMap
        self.currentStatate = currentStatate
    }
    func transition(forEvent event: Event) throws -> Transition{
        
    }
    public func handle(event: Event) throws{
        let transition = try transition(forEvent: event)
        currentStatate = try transition()
    }
}

enum BLEState{
    case online
    case offline
    case scanning
    case reading
    case ready
    case rwnotify
    //case readssi
    
}

typealias Transition = ()throws -> (BLEState)

enum Event{
    
}

        


