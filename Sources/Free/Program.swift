//
//  Program.swift
//  
//
//  Created by Markus Kasperczyk on 13.11.21.
//



public protocol Program : Symbol where Meaning == Body.Meaning {
    
    associatedtype Body : Symbol
    var body : Body {get}
    
}
