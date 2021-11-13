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

- Step 1: Add this package as a dependency
- Step 2: Install Sourcery
- Step 3: Read a tutorial how to run sourcery. The most important options are
  - manually
  - as a deamon
  - as a run script phase before compile sources (this is my preferred option as you only have to set this up once)
  - with commandline args
  - with a yaml file
- Step 4: Copy+paste the Templates folder in this repo to a position of your liking (you can fine tune the templates in there to your needs) and run sourcery
