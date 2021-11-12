//
//  Either.swift
//  
//
//  Created by Markus Kasperczyk on 12.11.21.
//



public enum Either<S1 : Symbol, S2 : Symbol> : Symbol where S1.Meaning == S2.Meaning {
    
    public typealias Meaning = S1.Meaning
    
    case either(S1)
    case or(S2)
    
}


public enum Either3<S1 : Symbol, S2 : Symbol, S3 : Symbol> : Symbol where S1.Meaning == S2.Meaning, S2.Meaning == S3.Meaning {
    
    public typealias Meaning = S1.Meaning
    
    case first(S1)
    case second(S2)
    case third(S3)
    
}


public enum Either4<S1 : Symbol, S2 : Symbol, S3 : Symbol, S4 : Symbol> : Symbol where
S1.Meaning == S2.Meaning, S2.Meaning == S3.Meaning, S3.Meaning == S4.Meaning {
    
    public typealias Meaning = S1.Meaning
    
    case first(S1)
    case second(S2)
    case third(S3)
    case fourth(S4)
    
}


public enum Either5<S1 : Symbol, S2 : Symbol, S3 : Symbol, S4 : Symbol, S5 : Symbol> : Symbol where
S1.Meaning == S2.Meaning, S2.Meaning == S3.Meaning, S3.Meaning == S4.Meaning, S4.Meaning == S5.Meaning {
    
    public typealias Meaning = S1.Meaning
    
    case first(S1)
    case second(S2)
    case third(S3)
    case fourth(S4)
    case fifth(S5)
    
}
