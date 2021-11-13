# Free

This repo is based on my blog post on [Free Monads](https://medium.com/@markus_25434/monads-for-free-in-swift-6a5246d0ef4b) in swift.


## TL;DR

```swift

import Free

struct PrintLine : Symbol {
  typealias Meaning = Void
  let message : String
}

struct GetLine : Symbol {
  typealias Meaning = String
}


let example = PrintLine(message: "What is the answer to life, the universe and everything?")
                          .flatMap(GetLine.init)
                          .map{(answer) -> PrintLine in 
                                PrintLine(message: Int(answer) == 42 ? "Yay!" : "Nope...")
                            }
                            
// now interpret

protocol AsyncInterpretation : Interpretation {

   func runAsync() async -> Meaning

}

extension PrintLine : AsyncInterpretation {

   func runAsync() {
      print(message)
   }

}


extension GetLine : AsyncInterpretation {

  func runAsync() async -> String {
     
     await Task.sleep(nanoseconds: UInt64(1e9 * 60 * 60 * 24 * 365.25 * 7.5 * 1e9))
     return "42"
     
  }

}


func test() {

  Task.detached {
    await example.runAsync()
  }

}


```

## Installation

Step 1: Add this package as a dependency
Step 2: Install Sourcery
Step 3: Read a tutorial how to run sourcery. The most important options are
  - manually
  - as a deamon
  - as a run script phase before compile sources (this is my preferred option as you only have to set this up once)
  - with commandline args
  - with a yaml file
Step 4: Copy+paste the below template into a .stencil file that you use as your template for code generation (you can fine tune this to your needs):

```stencil


import Free

public protocol Interpretation : Symbol {}


extension Pure : Interpretation {}
extension Map : Interpretation {}
extension FlatMap : Interpretation {}
extension Recursive : Interpretation {}
extension Either : Interpretation {}
extension Either3 : Interpretation {}
extension Either4 : Interpretation {}
extension Either5 : Interpretation {}

{% for proto in types.protocols|public %}{% if proto.based.Interpretation %}

extension Pure : {{proto.name}} {
    
    {% for variable in proto.variables|instance %}
    @inlinable
    public var {{variable.name}} : {{variable.typeName}} {
        .pure(meaning)
    }
    {%endfor%}
    {% for method in proto.methods|instance %}
    
    @inlinable
    public func {{method.name}} -> {{method.returnTypeName}} {
        .pure(meaning)
    }
    {%endfor%}
    
}


extension Map : {{proto.name}} where Base : {{proto.name}} {
    {% for variable in proto.variables|instance %}
    
    @inlinable
    public var {{variable.name}} : {{variable.typeName}} {
        base.{{variable.name}}.map(transform)
    }
    {%endfor%}
    {% for method in proto.methods|instance %}
    
    @inlinable
    public func {{method.name}} -> {{method.returnTypeName}} {
        base.{{method.name}}.map(transform)
    }
    {%endfor%}
    
}


extension FlatMap : {{proto.name}} where Base : {{proto.name}}, Next : {{proto.name}} {
    {% for variable in proto.variables|instance %}
    
    @inlinable
    public var {{variable.name}} : {{variable.typeName}} {
        base.{{variable.name}}
        .flatMap{transform($0).{{variable.name}}}
    }
    {%endfor%}
    {% for method in proto.methods|instance %}
    
    @inlinable
    public func {{method.name}} -> {{method.returnTypeName}} {
        base.{{method.name}}
        .flatMap{transform($0).{{method.name}}}
    }
    {%endfor%}
    
}


extension Recursive : {{proto.name}} where Recursion : {{proto.name}}  {
    
    {% for variable in proto.variables|instance %}
    @inlinable
    public var {{variable.name}} : {{variable.typeName}} {
        
        switch self {
        case .pure(let value):
            return .pure(value)
        case .semiPure(let value):
            return value.{{variable.name}}
        case .recursive(let rec, let transform):
            return rec.{{variable.name}}
            .flatMap{transform($0).{{variable.name}}}
        }
        
    }
    {%endfor%}
    {% for method in proto.methods|instance %}
    
    @inlinable
    public func {{method.name}} -> {{method.returnTypeName}} {
        
        switch self {
        case .pure(let value):
            return .pure(value)
        case .semiPure(let value):
            return value.{{method.name}}
        case .recursive(let rec, let transform):
            return rec.{{method.name}}
            .flatMap{transform($0).{{method.name}}}
        }
        
    }
    {%endfor%}
    
}


extension Either : {{proto.name}} where S1 : {{proto.name}}, S2 : {{proto.name}} {
    
    {% for variable in proto.variables|instance %}
    @inlinable
    public var {{variable.name}} : {{variable.typeName}} {
        
        switch self {
        case .either(let s1):
            return s1.{{variable.name}}
        case .or(let s2):
            return s2.{{variable.name}}
        }
        
    }
    {%endfor%}
    {% for method in proto.methods|instance %}
    
    @inlinable
    public func {{method.name}} -> {{method.returnTypeName}} {
        
        switch self {
        case .either(let s1):
            return s1.{{method.name}}
        case .or(let s2):
            return s2.{{method.name}}
        }
    }
    {%endfor%}
    
}


extension Either3 : {{proto.name}} where S1 : {{proto.name}}, S2 : {{proto.name}}, S3 : {{proto.name}} {
    
    {% for variable in proto.variables|instance %}
    @inlinable
    public var {{variable.name}} : {{variable.typeName}} {
        
        switch self {
        case .first(let s1):
            return s1.{{variable.name}}
        case .second(let s2):
            return s2.{{variable.name}}
        case .third(let s3):
            return s3.{{variable.name}}
        }
        
    }
    {%endfor%}
    {% for method in proto.methods|instance %}
    
    @inlinable
    public func {{method.name}} -> {{method.returnTypeName}} {
        
        switch self {
        case .first(let s1):
            return s1.{{method.name}}
        case .second(let s2):
            return s2.{{method.name}}
        case .third(let s3):
            return s3.{{method.name}}
        }
    }
    {%endfor%}
    
}


extension Either4 : {{proto.name}} where S1 : {{proto.name}}, S2 : {{proto.name}},
S3 : {{proto.name}}, S4 : {{proto.name}} {
    
    {% for variable in proto.variables|instance %}
    @inlinable
    public var {{variable.name}} : {{variable.typeName}} {
        
        switch self {
        case .first(let s1):
            return s1.{{variable.name}}
        case .second(let s2):
            return s2.{{variable.name}}
        case .third(let s3):
            return s3.{{variable.name}}
        case .fourth(let s4):
            return s4.{{variable.name}}
        }
        
    }
    {%endfor%}
    {% for method in proto.methods|instance %}
    
    @inlinable
    public func {{method.name}} -> {{method.returnTypeName}} {
        
        switch self {
        case .first(let s1):
            return s1.{{method.name}}
        case .second(let s2):
            return s2.{{method.name}}
        case .third(let s3):
            return s3.{{method.name}}
        case .fourth(let s4):
            return s4.{{method.name}}
        }
    }
    {%endfor%}
    
}


extension Either5 : {{proto.name}} where S1 : {{proto.name}}, S2 : {{proto.name}},
S3 : {{proto.name}}, S4 : {{proto.name}} , S5 : {{proto.name}} {
    
    {% for variable in proto.variables|instance %}
    @inlinable
    public var {{variable.name}} : {{variable.typeName}} {
        
        switch self {
        case .first(let s1):
            return s1.{{variable.name}}
        case .second(let s2):
            return s2.{{variable.name}}
        case .third(let s3):
            return s3.{{variable.name}}
        case .fourth(let s4):
            return s4.{{variable.name}}
        case .fifth(let s5):
            return s5.{{variable.name}}
        }
        
    }
    {%endfor%}
    {% for method in proto.methods|instance %}
    
    @inlinable
    public func {{method.name}} -> {{method.returnTypeName}} {
        
        switch self {
        case .first(let s1):
            return s1.{{method.name}}
        case .second(let s2):
            return s2.{{method.name}}
        case .third(let s3):
            return s3.{{method.name}}
        case .fourth(let s4):
            return s4.{{method.name}}
        case .fifth(let s5):
            return s5.{{method.name}}
        }
    }
    {%endfor%}
    
}

{% endif %}{% endfor %}
{% for proto in types.protocols|internal %}{% if proto.based.Interpretation %}

extension Pure : {{proto.name}} {
    
    {% for variable in proto.variables|instance %}
    @usableFromInline
    var {{variable.name}} : {{variable.typeName}} {
        .pure(meaning)
    }
    {%endfor%}
    {% for method in proto.methods|instance %}
    
    @usableFromInline
    func {{method.name}} -> {{method.returnTypeName}} {
        .pure(meaning)
    }
    {%endfor%}
    
}


extension Map : {{proto.name}} where Base : {{proto.name}} {
    {% for variable in proto.variables|instance %}
    
    @usableFromInline
    var {{variable.name}} : {{variable.typeName}} {
        base.{{variable.name}}.map(transform)
    }
    {%endfor%}
    {% for method in proto.methods|instance %}
    
    @usableFromInline
    func {{method.name}} -> {{method.returnTypeName}} {
        base.{{method.name}}.map(transform)
    }
    {%endfor%}
    
}


extension FlatMap : {{proto.name}} where Base : {{proto.name}}, Next : {{proto.name}} {
    {% for variable in proto.variables|instance %}
    
    @usableFromInline
    var {{variable.name}} : {{variable.typeName}} {
        base.{{variable.name}}
        .flatMap{transform($0).{{variable.name}}}
    }
    {%endfor%}
    {% for method in proto.methods|instance %}
    
    @usableFromInline
    func {{method.name}} -> {{method.returnTypeName}} {
        base.{{method.name}}
        .flatMap{transform($0).{{method.name}}}
    }
    {%endfor%}
    
}


extension Recursive : {{proto.name}} where Recursion : {{proto.name}}  {
    
    {% for variable in proto.variables|instance %}
    @usableFromInline
    var {{variable.name}} : {{variable.typeName}} {
        
        switch self {
        case .pure(let value):
            return .pure(value)
        case .semiPure(let value):
            return value.{{variable.name}}
        case .recursive(let rec, let transform):
            return rec.{{variable.name}}
            .flatMap{transform($0).{{variable.name}}}
        }
        
    }
    {%endfor%}
    {% for method in proto.methods|instance %}
    
    @usableFromInline
    func {{method.name}} -> {{method.returnTypeName}} {
        
        switch self {
        case .pure(let value):
            return .pure(value)
        case .semiPure(let value):
            return value.{{method.name}}
        case .recursive(let rec, let transform):
            return rec.{{method.name}}
            .flatMap{transform($0).{{method.name}}}
        }
        
    }
    {%endfor%}
    
}


extension Either : {{proto.name}} where S1 : {{proto.name}}, S2 : {{proto.name}} {
    
    {% for variable in proto.variables|instance %}
    @usableFromInline
    var {{variable.name}} : {{variable.typeName}} {
        
        switch self {
        case .either(let s1):
            return s1.{{variable.name}}
        case .or(let s2):
            return s2.{{variable.name}}
        }
        
    }
    {%endfor%}
    {% for method in proto.methods|instance %}
    
    @usableFromInline
    func {{method.name}} -> {{method.returnTypeName}} {
        
        switch self {
        case .either(let s1):
            return s1.{{method.name}}
        case .or(let s2):
            return s2.{{method.name}}
        }
    }
    {%endfor%}
    
}


extension Either3 : {{proto.name}} where S1 : {{proto.name}}, S2 : {{proto.name}}, S3 : {{proto.name}} {
    
    {% for variable in proto.variables|instance %}
    @usableFromInline
    var {{variable.name}} : {{variable.typeName}} {
        
        switch self {
        case .first(let s1):
            return s1.{{variable.name}}
        case .second(let s2):
            return s2.{{variable.name}}
        case .third(let s3):
            return s3.{{variable.name}}
        }
        
    }
    {%endfor%}
    {% for method in proto.methods|instance %}
    
    @usableFromInline
    func {{method.name}} -> {{method.returnTypeName}} {
        
        switch self {
        case .first(let s1):
            return s1.{{method.name}}
        case .second(let s2):
            return s2.{{method.name}}
        case .third(let s3):
            return s3.{{method.name}}
        }
    }
    {%endfor%}
    
}


extension Either4 : {{proto.name}} where S1 : {{proto.name}}, S2 : {{proto.name}},
S3 : {{proto.name}}, S4 : {{proto.name}} {
    
    {% for variable in proto.variables|instance %}
    @usableFromInline
    var {{variable.name}} : {{variable.typeName}} {
        
        switch self {
        case .first(let s1):
            return s1.{{variable.name}}
        case .second(let s2):
            return s2.{{variable.name}}
        case .third(let s3):
            return s3.{{variable.name}}
        case .fourth(let s4):
            return s4.{{variable.name}}
        }
        
    }
    {%endfor%}
    {% for method in proto.methods|instance %}
    
    @usableFromInline
    func {{method.name}} -> {{method.returnTypeName}} {
        
        switch self {
        case .first(let s1):
            return s1.{{method.name}}
        case .second(let s2):
            return s2.{{method.name}}
        case .third(let s3):
            return s3.{{method.name}}
        case .fourth(let s4):
            return s4.{{method.name}}
        }
    }
    {%endfor%}
    
}


extension Either5 : {{proto.name}} where S1 : {{proto.name}}, S2 : {{proto.name}},
S3 : {{proto.name}}, S4 : {{proto.name}} , S5 : {{proto.name}} {
    
    {% for variable in proto.variables|instance %}
    @usableFromInline
    var {{variable.name}} : {{variable.typeName}} {
        
        switch self {
        case .first(let s1):
            return s1.{{variable.name}}
        case .second(let s2):
            return s2.{{variable.name}}
        case .third(let s3):
            return s3.{{variable.name}}
        case .fourth(let s4):
            return s4.{{variable.name}}
        case .fifth(let s5):
            return s5.{{variable.name}}
        }
        
    }
    {%endfor%}
    {% for method in proto.methods|instance %}
    
    @usableFromInline
    func {{method.name}} -> {{method.returnTypeName}} {
        
        switch self {
        case .first(let s1):
            return s1.{{method.name}}
        case .second(let s2):
            return s2.{{method.name}}
        case .third(let s3):
            return s3.{{method.name}}
        case .fourth(let s4):
            return s4.{{method.name}}
        case .fifth(let s5):
            return s5.{{method.name}}
        }
    }
    {%endfor%}
    
}

{% endif %}{% endfor %}

```
