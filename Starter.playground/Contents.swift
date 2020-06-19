import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()

example(of: "filter") {
  // 1 Create publisher
  let numbers = (1...10).publisher
  
  // 2
  numbers
    .filter { $0.isMultiple(of: 3) } //only allow multiple of 3 values
    .sink(receiveValue: { n in
      print("\(n) is a multiple of 3!")
    })
    .store(in: &subscriptions)
}

//——— Example of: filter ———
//3 is a multiple of 3!
//6 is a multiple of 3!
//9 is a multiple of 3!

example(of: "removeDuplicates") {
  // 1
  let words = "hey hey there! want to listen to mister mister ?"
                  .components(separatedBy: " ")
                  .publisher
  // 2
  words
    .removeDuplicates()//remove the duplicates in an array
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)
}

//——— Example of: removeDuplicates ———
//hey
//there!
//want
//to
//listen
//to
//mister

example(of: "compactMap") {
  // 1
  let strings = ["a", "1.24", "3",
                 "def", "45", "0.23"].publisher
  
  // 2
  strings
    .compactMap { Float($0) } //attemps to initialize a float from each individual string
    .sink(receiveValue: {
      // 3
      print($0)
    })
    .store(in: &subscriptions)
}

//——— Example of: compactMap ———
//1.24
//3.0
//45.0
//0.23

example(of: "ignoreOutput") {
  // 1
  let numbers = (1...10_000).publisher
  
  // 2
  numbers
    .ignoreOutput() //ommits all values and emits only the completion event
    .sink(receiveCompletion: { print("Completed with: \($0)") },
          receiveValue: { print($0) })
    .store(in: &subscriptions)
}

//——— Example of: ignoreOutput ———
//Completed with: finished

example(of: "first(where:)") {
  // 1
  let numbers = (1...9).publisher
  
  // 2
  numbers
    .print("numbers") //it prints the state of the publisher every time it sends a value
    .first(where: { $0 % 2 == 0 }) //find the first emmited value that is even. It sends a cancellation thorugh the subscription after finding the first even.
    .sink(receiveCompletion: { print("Completed with: \($0)") },
          receiveValue: { print($0) })
    .store(in: &subscriptions)
}

//——— Example of: first(where:) ———
//numbers: receive subscription: (1...9)
//numbers: request unlimited
//numbers: receive value: (1)
//numbers: receive value: (2)
//numbers: receive cancel
//2
//Completed with: finished

example(of: "last(where:)") {
  // 1
  let numbers = (1...9).publisher
  
  // 2
  numbers
    .print("numbers")
    .last(where: { $0 % 2 == 0 })
    .sink(receiveCompletion: { print("Completed with: \($0)") },
          receiveValue: { print($0) })
    .store(in: &subscriptions)
}

//——— Example of: last(where:) ———
//numbers: receive subscription: (1...9)
//numbers: request unlimited
//numbers: receive value: (1)
//numbers: receive value: (2)
//numbers: receive value: (3)
//numbers: receive value: (4)
//numbers: receive value: (5)
//numbers: receive value: (6)
//numbers: receive value: (7)
//numbers: receive value: (8)
//numbers: receive value: (9)
//numbers: receive finished
//8
//Completed with: finished

example(of: "last(where:) 2") {
  let numbers = PassthroughSubject<Int, Never>()
  
  numbers
    .last(where: { $0 % 2 == 0 })
    .sink(receiveCompletion: { print("Completed with: \($0)") },
          receiveValue: { print($0) })
    .store(in: &subscriptions)
  
  numbers.send(1)
  numbers.send(2)
  numbers.send(3)
  numbers.send(4)
  numbers.send(5)
  numbers.send(completion: .finished) //Without this line.. it will not print nothing.
}

//——— Example of: last(where:) 2 ———
//As expected, since the publisher never completes, there’s no way to determine the last value matching the criteria.

example(of: "dropFirst") {
  // 1
  let numbers = (1...10).publisher
  
  // 2
  numbers
    .dropFirst(8) //it will drop the first 8 values.
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)
}

//——— Example of: dropFirst ———
//9
//10

example(of: "drop(while:)") {
  // 1
  let numbers = (1...10).publisher
  
  // 2
  numbers
    .drop(while: { $0 % 5 != 0 }) // Use drop(while:) to wait for the first value that is divisible by five. As soon as the condition is met, values will start flowing through the operator and won’t be dropped anymore.
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)
}

//——— Example of: drop(while:) ———
//5
//6
//7
//8
//9
//10

example(of: "drop(while:) 2") {
  // 1
  let numbers = (1...10).publisher
  
  // 2
  numbers
    .drop(while: {
      print("x")
      return $0 % 5 != 0
    })
    .sink(receiveCompletion: { print($0)},
          receiveValue: { print($0)})
    .store(in: &subscriptions)
}

//——— Example of: drop(while:) ———
//x
//x
//x
//x
//x
//5
//6
//7
//8
//9
//10


example(of: "drop(untilOutputFrom:)") {
  // 1
  let isReady = PassthroughSubject<Void, Never>()
  let taps = PassthroughSubject<Int, Never>()
  
  // 2
  taps
    .drop(untilOutputFrom: isReady) //on the isReady starts publishing values, the taps publisher starts sending values
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)
  
  // 3
  (1...5).forEach { n in
    taps.send(n)
    
    if n == 3 {
      isReady.send()
    }
  }
}

//——— Example of: drop(untilOutputFrom:) ———
//4
//5

example(of: "prefix") {
  // 1
  let numbers = (5...10).publisher
  
  // 2
  numbers
    .prefix(2) //allow the emission of only the first two values
    .sink(receiveCompletion: { print("Completed with: \($0)") },
          receiveValue: { print($0) })
    .store(in: &subscriptions)
}

//——— Example of: prefix ———
//5
//6
//Completed with: finished

example(of: "prefix(while:)") {
  // 1
  let numbers = (1...10).publisher
  
  // 2
  numbers
    .prefix(while: { $0 < 3 }) //“As soon as a value equal to or larger than 3 is emitted, the publisher completes.
    .sink(receiveCompletion: { print("Completed with: \($0)") },
          receiveValue: { print($0) })
    .store(in: &subscriptions)
}

//——— Example of: prefix(while:) ———
//1
//2
//Completed with: finished

example(of: "prefix(untilOutputFrom:)") {
  // 1
  let isReady = PassthroughSubject<Void, Never>()
  let taps = PassthroughSubject<Int, Never>()
  
  // 2
  taps
    .prefix(untilOutputFrom: isReady)
    .sink(receiveCompletion: { print("Completed with: \($0)") },
          receiveValue: { print($0) })
    .store(in: &subscriptions)
  
  // 3
  (1...5).forEach { n in
    
    taps.send(n)
    if n == 2 {
      isReady.send()
    }
  }
}

//——— Example of: prefix(untilOutputFrom:) ———
//1
//2
//Completed with: finished

/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.
