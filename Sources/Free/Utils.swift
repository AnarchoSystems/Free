//
//  Utils.swift
//  
//
//  Created by Markus Kasperczyk on 14.11.21.
//




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
