//
//  Utils.swift
//  
//
//  Created by Markus Kasperczyk on 14.11.21.
//

import Foundation


public func repeatUntilGood<Action : Symbol>(maxIterations: UInt = .max,
                                                     action: @escaping @autoclosure () -> Action)
-> Map<Recursive<Action>, Void> where Action.Meaning == Discriminative<Void, Void> {
    
    repeatUntilGood(maxIterations: maxIterations, action: action())
        .map{$0.get()}
    
}


public func repeatUntilGood<Action : Symbol, Output>(maxIterations: UInt = .max,
                                                     action: @escaping @autoclosure () -> Action)
-> Recursive<Action> where Action.Meaning == Discriminative<Output, Void> {
    
    repeatUntilGood(maxIterations: maxIterations,
                    seed: (),
                    action: action)
    
}


public func repeatUntilGood<Seed, Action : Symbol>(maxIterations: UInt = .max,
                                                           seed: Seed,
                                                           action: @escaping (Seed) -> Action)
-> Map<Recursive<Action>, Seed> where Action.Meaning == Discriminative<Seed, Seed> {
    
    repeatUntilGood(maxIterations: maxIterations, seed: seed, action: action)
        .map{$0.get()}
    
}


public func repeatUntilGood<Seed, Action : Symbol, Output>(maxIterations: UInt = .max,
                                                           seed: Seed,
                                                           action: @escaping (Seed) -> Action)
-> Recursive<Action> where Action.Meaning == Discriminative<Output, Seed> {
    
    if maxIterations == 0 {
        return .pure(.bad(seed))
    }
    
    return .recursive(action(seed)) {result in
        
        switch result {
        case .good(let good):
            return .pure(.good(good))
        case .bad(let newSeed):
            return repeatUntilGood(maxIterations: maxIterations - 1,
                                   seed: newSeed,
                                   action: action)
        }
        
    }
    
}


public func repeatUntil<Cond : Symbol, Action : Symbol>(seed: Action.Meaning,
                                                        action: @escaping (Action.Meaning) -> Action,
                                                        until condition: @escaping (Action.Meaning) -> Cond)
-> Map<Recursive<Either<Map<Action, Cond.Meaning>, Cond>>, Action.Meaning>
where Cond.Meaning == Discriminative<Action.Meaning, Action.Meaning> {
    
    _repeatUntil(seed: seed, action: action, until: condition)
        .map{$0.get()}
    
}


func _repeatUntil<Cond : Symbol, Action : Symbol>(seed: Action.Meaning,
                                                  action: @escaping (Action.Meaning) -> Action,
                                                  until condition: @escaping (Action.Meaning) -> Cond)
-> Recursive<Either<Map<Action, Cond.Meaning>, Cond>>
where Cond.Meaning == Discriminative<Action.Meaning, Action.Meaning> {
    
    typealias CodePath = Either<Map<Action, Cond.Meaning>, Cond>
    
    let firstAct = CodePath.either(action(seed).map(Cond.Meaning.bad))
    
    return Recursive.recursive(firstAct) {result in
        
        let firstCheck = CodePath.or(condition(result.get()))
        
        return Recursive.recursive(firstCheck) {nextResult in
            
            switch nextResult {
                
            case .good(let val):
                
                return .pure(Cond.Meaning.good((val)))
                
            case .bad(let val):
                
                return _repeatUntil(seed: val,
                                    action: action,
                                    until: condition)
                
            }
            
        }
        
    }
    
}


public func whileCond<Cond : Symbol, Action : Symbol>(seed: Action.Meaning,
                                                      action: @escaping (Action.Meaning) -> Action,
                                                      while condition: @escaping (Action.Meaning) -> Cond)
-> Map<Recursive<Either<Map<Action, Cond.Meaning>, Cond>>, Action.Meaning> where Cond.Meaning == Discriminative<Action.Meaning, Action.Meaning>
{
    
    _whileCond(seed: seed, action: action, while: condition)
        .map{$0.get()}
    
}


func _whileCond<Cond : Symbol, Action : Symbol>(seed: Action.Meaning,
                                                action: @escaping (Action.Meaning) -> Action,
                                                while condition: @escaping (Action.Meaning) -> Cond)
-> Recursive<Either<Map<Action, Cond.Meaning>, Cond>>
where Cond.Meaning == Discriminative<Action.Meaning, Action.Meaning> {
    
    typealias CodePath = Either<Map<Action, Cond.Meaning>, Cond>
    
    let firstCheck = CodePath.or(condition(seed))
    
    return Recursive.recursive(firstCheck) {result in
        
        switch result {
            
        case .good(let val):
            
            return .pure(.good(val))
            
        case .bad(let val):
            
            let firstAct = CodePath.either(action(val).map(Cond.Meaning.bad))
            
            
            return .recursive(firstAct) {newValue in
                
                _whileCond(seed: newValue.get(),
                           action: action,
                           while: condition)
                
            }
            
        }
        
    }
    
    
}
