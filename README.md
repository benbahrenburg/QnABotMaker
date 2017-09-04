# QnA Bot Maker
__iOS Library for working with the Microsoft QnA Maker Bot Service__

Convenience library for working with Microsoft's QnA Maker Service.  Microsoft QnA Maker Service lets you create FAQ Bots quickly.  The QnABotMaker library enables you to use the QnA Maker Service directly from within your iOS app.  Before getting started pleaes check out Microsoft [QnA Maker](https://qnamaker.ai).

## Getting Started

Before you get started using this library you will need to create a QnA "Service" using Microsoft's [QnA Maker](https://qnamaker.ai).

Once you have published your QnA Service you will see a <b>Sample HTTP request</b> similar to the one shown below. 

~~~
POST /knowledgebases/581bd885-5588403d-9935fe3cd325c503/generateAnswer
Host: https://westus.api.cognitive.microsoft.com/qnamaker/v2.0
Ocp-Apim-Subscription-Key: b73f2abc20784927a330c7ad9e354e86
Content-Type: application/json
{"question":"hi"}
~~~

The QnABotMaker library needs a few of these parameters in order to connect to the [QnA Maker](https://qnamaker.ai) service.

1) First we need your <b>knowledgebase identifier</b> or <b>knowledgebaseID</b>, this is the highlighted shown below.

POST /knowledgebases/<b>581bd885-5588403d-9935fe3cd325c503</b>/generateAnswer

2) Next we will need your <b>Subscription Key</b> or <b>subscriptionKey</b>, this is the highlighted shown below.

Ocp-Apim-Subscription-Key: <b>b73f2abc20784927a330c7ad9e354e86</b>

3) Finally, you will use these parameters when creating an new instance of the QnAService struct as shown in the below example

```swift

let bot = QnAService(knowledgebaseID: "581bd885-5588403d-9935fe3cd325c503", subscriptionKey: "b73f2abc20784927a330c7ad9e354e86")

```

## Requirements

* Xcode 8.2 or newer
* Swift 3.0
* iOS 10 or greater


## Installation

__Cocoapods__

QnABotMaker is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "QnABotMaker"
```

__Carthage__

```
github "benbahrenburg/QnABotMaker"
```

__Manually__

Copy all `*.swift` files contained in `QnABotMaker/Classes/` directory into your project. 

__Swift Package Manager__

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler. It is in early development, but Alamofire does support its use on supported platforms. 

Once you have your Swift package set up, adding Alamofire as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .Package(url: "https://github.com/Alamofire/Alamofire.git", majorVersion: 4)
]
```

## Using

Using QnABotMaker couldn't be easier.  You simply create a new instance of the library and provide the <b>askQuestion</b> function with a question.  The completion hander, <b>completionHandler</b>, will provide the QnA answers or an error if necessary.

The following shows the library inaction.

```swift

let bot = QnAService(knowledgebaseID: "YOUR-KB-ID", subscriptionKey: "YOUR-SUBSCRIPTION-KEY")

bot.askQuestion("hello", completionHandler: {(answers, error) in
    if let error = error {
        return print("error: \(error)")
    }
    if let answers = answers {
       print(answers)
    }
})

```

## Author

Ben Bahrenburg, [@bencoding](https://twitter.com/bencoding)

## License

QnABotMaker is available under the MIT license. See the [LICENSE file](https://github.com/benbahrenburg/QnABotMaker/blob/master/LICENSE) for more info.
