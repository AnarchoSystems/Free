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

- Step 1: Add this package as a dependency in XCode: in the Files menu, choose "Add Packages...", paste the link to this repo into the search bar and confirm.
- Step 2: Install Sourcery. With homebrew, all you need to do is to run ```brew install sourcery``` in the terminal.
- Step 3: Add a run script phase to your build phases right before compile sources. Paste the following script:

```bash
/opt/homebrew/bin/sourcery --templates ${BUILD_DIR%Build/*}SourcePackages/checkouts/Free/Templates --sources ${SRCROOT}/${PRODUCT_NAME} --output ${SRCROOT}/Generated
```

Attention: depending on your system, hombrew might have put sourcery elsewhere, so you may need to adjust this a little bit.
- Step 4: Uncheck the "Based on dependency analysis" box in your run script phase.
- Step 5: Compile for the first time. A Folder ```Generated``` should have appeared in the folder where your ```.xcodeproj``` project is located. Add this folder and its contents to the project.
