//
//  Recursive.swift
//  
//
//  Created by Markus Kasperczyk on 12.11.21.
//



public enum Recursive<Recursion : Symbol> : Symbol {
    
    public typealias Meaning = Recursion.Meaning
    
    case pure(Recursion.Meaning)
    case semiPure(Recursion)
    indirect case recursive(Self, (Recursion.Meaning) -> Self)
    
    public static func recursive(_ action: Recursion, _ transform: @escaping (Recursion.Meaning) -> Self) -> Self {
        .recursive(.semiPure(action), transform)
    }
    
    public static func recursive<T>(_ recursive: Self, _ transform: @escaping (T) -> T) -> Self where Recursion == Pure<T> {
        .recursive(recursive) {.pure(transform($0))}
    }
    
}
