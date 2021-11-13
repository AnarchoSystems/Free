//
//  Interpretation.swift
//  
//
//  Created by Markus Kasperczyk on 13.11.21.
//


public protocol Interpretation : Symbol {}


extension Pure : Interpretation {}
extension Map : Interpretation {}
extension FlatMap : Interpretation {}
extension Recursive : Interpretation {}


extension Either : Interpretation where S1 : Symbol, S2 : Symbol {}
extension Either3 : Interpretation where S1 : Symbol, S2 : Symbol, S3 : Symbol {}
extension Either4 : Interpretation where S1 : Symbol, S2 : Symbol, S3 : Symbol, S4 : Symbol {}
extension Either5 : Interpretation where S1 : Symbol, S2 : Symbol, S3 : Symbol, S4 : Symbol, S5 : Symbol {}
