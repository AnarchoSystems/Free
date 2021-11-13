//
//  Either.swift
//  
//
//  Created by Markus Kasperczyk on 12.11.21.
//



public enum Either<S1, S2> {
    
    case either(S1)
    case or(S2)
    
}


public extension Either where S1 == S2 {
    
    func get() -> S1 {
        switch self {
        case .either(let s1):
            return s1
        case .or(let s2):
            return s2
        }
    }
    
}


extension Either : Symbol where S1 : Symbol, S2 : Symbol {
    
    public typealias Meaning = Either<S1.Meaning, S2.Meaning>
    
}


public enum Either3<S1, S2, S3> {
    
    case first(S1)
    case second(S2)
    case third(S3)
    
}


public extension Either3 where S1 == S2, S2 == S3 {
    
    func get() -> S1 {
        switch self {
        case .first(let s1):
            return s1
        case .second(let s2):
            return s2
        case .third(let s3):
            return s3
        }
    }
    
}


extension Either3 : Symbol where S1 : Symbol, S2 : Symbol, S3 : Symbol {
    
    public typealias Meaning = Either3<S1.Meaning, S2.Meaning, S3.Meaning>
    
}


public enum Either4<S1, S2, S3, S4> {
    
    case first(S1)
    case second(S2)
    case third(S3)
    case fourth(S4)
    
}


public extension Either4 where S1 == S2, S2 == S3, S3 == S4 {
    
    func get() -> S1 {
        switch self {
        case .first(let s1):
            return s1
        case .second(let s2):
            return s2
        case .third(let s3):
            return s3
        case .fourth(let s4):
            return s4
        }
    }
    
}


extension Either4 : Symbol where S1 : Symbol, S2 : Symbol, S3 : Symbol, S4 : Symbol {
    
    public typealias Meaning = Either4<S1.Meaning, S2.Meaning, S3.Meaning, S4.Meaning>
    
}


public enum Either5<S1, S2, S3, S4, S5> {
    
    case first(S1)
    case second(S2)
    case third(S3)
    case fourth(S4)
    case fifth(S5)
    
}


public extension Either5 where S1 == S2, S2 == S3, S3 == S4, S4 == S5 {
    
    func get() -> S1 {
        switch self {
        case .first(let s1):
            return s1
        case .second(let s2):
            return s2
        case .third(let s3):
            return s3
        case .fourth(let s4):
            return s4
        case .fifth(let s5):
            return s5
        }
    }
    
}


extension Either5 : Symbol where S1 : Symbol, S2 : Symbol, S3 : Symbol, S4 : Symbol, S5 : Symbol {
    
    public typealias Meaning = Either5<S1.Meaning, S2.Meaning, S3.Meaning, S4.Meaning, S5.Meaning>
    
}
