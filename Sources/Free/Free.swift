//
//  Free.swift
//  
//
//  Created by Markus Kasperczyk on 12.11.21.
//


public protocol Symbol {
    associatedtype Meaning
}


public struct Pure<Meaning> : Symbol {
    public let meaning : Meaning
    public init(_ meaning: Meaning) {self.meaning = meaning}
}


public struct Map<Base : Symbol, Meaning> : Symbol {
    
    public let base : Base
    public let transform : (Base.Meaning) -> Meaning
    
}


public extension Symbol {
    
    func map<T>(_ transform: @escaping (Meaning) -> T) -> Map<Self, T> {
        Map(base: self, transform: transform)
    }
    
}


public struct FlatMap<Base : Symbol, Next : Symbol> : Symbol {
    
    public typealias Meaning = Next.Meaning
    
    public let base : Base
    public let transform : (Base.Meaning) -> Next
    
}


public extension Symbol {
    
    func flatMap<Next : Symbol>(_ transform: @escaping (Meaning) -> Next) -> FlatMap<Self, Next> {
        FlatMap(base: self, transform: transform)
    }
    
}
