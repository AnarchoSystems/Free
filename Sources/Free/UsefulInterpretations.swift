//
//  UsefulInterpretations.swift
//  
//
//  Created by Markus Kasperczyk on 15.11.21.
//


#if compiler(>=5.5) && canImport(_Concurrency)

/// Types conforming to ```Config``` define values that can be stored in the ```Dependencies```. If no value is stored, an appropriate default value will be computed from other dependencies.
public protocol Config {
    
    associatedtype Value
    
    /// Computes an appropriate default value given the rest of the environment.
    /// - Parameters:
    ///     - environment: The dependency graph that needs a default value.
    @MainActor
    static func value(given environment: Dependencies) -> Value
    
}


/// Types conforming to ```Config``` define values that can be stored in the ```Dependencies```. If no value is stored, the static default value from this protocol will be assumed.
public protocol Dependency : Config where StaticValue == Value {
    associatedtype StaticValue
    
    /// The default value, if nothing else is stored.
    static var defaultValue : StaticValue {get}
}


public extension Dependency {
    @MainActor
    static func value(given: Dependencies) -> Value {
        defaultValue
    }
}


/// ```Dependencies``` Wrap the app's constants configured from outside. Values can be accessed via a subscript taking a type that conforms to ```Config```:
/// ```
/// public extension Dependencies {
///
///   var myValue : MyType {
///         get {self[MyKey.self]}
///         set {self[MyKey.self] = newValue}
///   }
///
/// }
/// ```
/// - Note: If you read a value that isn't stored in the underlying dictionary, the default value is assumed. The value will then be memoized and shared across all copies. As a result, if the dependency itself has reference semantics, it will be retained after the first read.
/// - Important: The way memoization is implemented requires properties to be read on the main thread. Failing to read not-yet memoized dependencies on the main thread is undefined behavior and may lead to crashes due to overlapping memory access.
@MainActor
public struct Dependencies {
    
    @usableFromInline
    var dict = SwiftMutableDict()
    
    @inlinable
    @MainActor
    public subscript<Key : Config>(key: Key.Type) -> Key.Value {
        get {
            if let result = dict.dict[String(describing: key)] as? Key.Value {
                return result
            }
            else {
                let result = Key.value(given: self)
                //memoization -- reference semantics is appropriate
                dict.dict[String(describing: key)] = result
                return result
            }
        }
        set {
            if
                !isKnownUniquelyReferenced(&dict) {
                self.dict = dict.copy()
            }
            dict.dict[String(describing: key)] = newValue
        }
    }
    
    @MainActor
    func hasStoredValue<Key : Config>(for key: Key.Type) -> Bool {
        dict.dict[String(describing: key)] != nil
    }
    
}

@usableFromInline
class SwiftMutableDict {
    @usableFromInline
    @MainActor
    var dict : [String : Any] = [:]
    @inlinable
    init(){}
    @inlinable
    @MainActor
    func copy() -> SwiftMutableDict {
        let result = SwiftMutableDict()
        result.dict = dict
        return result
    }
}

@available(iOS 15.0, macOS 12, tvOS 15.0, watchOS 8.0, *)
public protocol AsyncInterpretable : Symbol {
    
    func runUnsafe(_ env: Dependencies) async throws -> Meaning
    
}


@available(iOS 15.0, macOS 12, tvOS 15.0, watchOS 8.0, *)
extension Pure : AsyncInterpretable {
    
    public func runUnsafe(_ env: Dependencies) async throws -> Meaning {
        meaning
    }
    
}


@available(iOS 15.0, macOS 12, tvOS 15.0, watchOS 8.0, *)
extension Map : AsyncInterpretable where Base : AsyncInterpretable {
    
    public func runUnsafe(_ env: Dependencies) async throws -> Meaning {
        try await transform(base.runUnsafe(env))
    }
    
}


@available(iOS 15.0, macOS 12, tvOS 15.0, watchOS 8.0, *)
extension FlatMap : AsyncInterpretable where Base : AsyncInterpretable, Next : AsyncInterpretable {
    
    public func runUnsafe(_ env: Dependencies) async throws -> Next.Meaning {
        try await transform(base.runUnsafe(env)).runUnsafe(env)
    }
    
}


@available(iOS 15.0, macOS 12, tvOS 15.0, watchOS 8.0, *)
extension Recursive : AsyncInterpretable where Recursion : AsyncInterpretable {
    
    public func runUnsafe(_ env: Dependencies) async throws -> Recursion.Meaning {
        
        switch self {
        case .pure(let result):
            return result
        case .semiPure(let recursion):
            return try await recursion.runUnsafe(env)
        case .recursive(let rec, let then):
            return try await then(rec.runUnsafe(env)).runUnsafe(env)
        }
        
    }
    
}


@available(iOS 15.0, macOS 12, tvOS 15.0, watchOS 8.0, *)
extension Discriminative : AsyncInterpretable where Good : AsyncInterpretable, Bad : AsyncInterpretable {
    
    public func runUnsafe(_ env: Dependencies) async throws -> Discriminative<Good.Meaning, Bad.Meaning> {
        
        switch self {
        case .good(let good):
            return try await .good(good.runUnsafe(env))
        case .bad(let bad):
            return try await .bad(bad.runUnsafe(env))
        }
        
    }
    
}


@available(iOS 15.0, macOS 12, tvOS 15.0, watchOS 8.0, *)
extension Either : AsyncInterpretable where S1 : AsyncInterpretable, S2 : AsyncInterpretable, S1.Meaning == S2.Meaning {
    
    public func runUnsafe(_ env: Dependencies) async throws -> S1.Meaning {
        
        switch self {
        case .either(let s1):
            return try await s1.runUnsafe(env)
        case .or(let s2):
            return try await s2.runUnsafe(env)
        }
        
    }
    
}


@available(iOS 15.0, macOS 12, tvOS 15.0, watchOS 8.0, *)
extension Either3 : AsyncInterpretable where S1 : AsyncInterpretable, S2 : AsyncInterpretable, S3 : AsyncInterpretable,
                                             S1.Meaning == S2.Meaning, S2.Meaning == S3.Meaning {
    
    public func runUnsafe(_ env: Dependencies) async throws -> S1.Meaning {
        
        switch self {
        case .first(let s1):
            return try await s1.runUnsafe(env)
        case .second(let s2):
            return try await s2.runUnsafe(env)
        case .third(let s3):
            return try await s3.runUnsafe(env)
        }
        
    }
    
}


@available(iOS 15.0, macOS 12, tvOS 15.0, watchOS 8.0, *)
extension Either4 : AsyncInterpretable where S1 : AsyncInterpretable, S2 : AsyncInterpretable, S3 : AsyncInterpretable, S4 : AsyncInterpretable,
S1.Meaning == S2.Meaning, S2.Meaning == S3.Meaning, S3.Meaning == S4.Meaning {
    
    public func runUnsafe(_ env: Dependencies) async throws -> S1.Meaning {
        
        switch self {
        case .first(let s1):
            return try await s1.runUnsafe(env)
        case .second(let s2):
            return try await s2.runUnsafe(env)
        case .third(let s3):
            return try await s3.runUnsafe(env)
        case .fourth(let s4):
            return try await s4.runUnsafe(env)
        }
        
    }
    
}


@available(iOS 15.0, macOS 12, tvOS 15.0, watchOS 8.0, *)
extension Either5 : AsyncInterpretable where S1 : AsyncInterpretable, S2 : AsyncInterpretable, S3 : AsyncInterpretable, S4 : AsyncInterpretable, S5 : AsyncInterpretable,
                                             S1.Meaning == S2.Meaning, S2.Meaning == S3.Meaning, S3.Meaning == S4.Meaning, S4.Meaning == S5.Meaning {
    
    public func runUnsafe(_ env: Dependencies) async throws -> S1.Meaning {
        
        switch self {
        case .first(let s1):
            return try await s1.runUnsafe(env)
        case .second(let s2):
            return try await s2.runUnsafe(env)
        case .third(let s3):
            return try await s3.runUnsafe(env)
        case .fourth(let s4):
            return try await s4.runUnsafe(env)
        case .fifth(let s5):
            return try await s5.runUnsafe(env)
        }
        
    }
    
}


@available(iOS 15.0, macOS 12, tvOS 15.0, watchOS 8.0, *)
public extension AsyncInterpretable {
    
    func runUnsafe() async throws -> Meaning {
        try await runUnsafe(Dependencies())
    }
    
}


#endif
