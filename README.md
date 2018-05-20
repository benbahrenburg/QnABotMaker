# QnA Bot Maker
__iOS Library for working with the Microsoft QnA Maker Bot Service__

Convenience library for working with Microsoft's QnA Maker Service.  Microsoft QnA Maker Service lets you create FAQ Bots quickly.  The QnABotMaker library enables you to use the QnA Maker Service directly from within your iOS app.  Before getting started pleaes check out Microsoft [QnA Maker](https://qnamaker.ai).

## Getting Started

Before you get started using this library you will need to create a QnA "Service" using Microsoft's [QnA Maker](https://qnamaker.ai).

Once you have published your QnA Service you will see a <b>Sample HTTP request</b> similar to the one shown below. 

~~~
POST /knowledgebases/581bd885-5588403d-9935fe3cd325c503/generateAnswer
Host: https://testbot.azurewebsites.net/qnamaker
Authorization: EndpointKey aa000344-9998-4d3b-9df3-52bf7c4f7ffd
Content-Type: application/json
{"question":"hi"}
~~~

The QnABotMaker library needs a few of these parameters in order to connect to the [QnA Maker](https://qnamaker.ai) service.

1) First we need to know your host value.  This is the url provided with the host key. An example of this is the highlighted shown below.

Host: <b>https://testbot.azurewebsites.net/qnamaker</b>

2) Next we need your <b>knowledgebase identifier</b> or <b>knowledgebaseID</b>, this is the highlighted shown below.

POST /knowledgebases/<b>581bd885-5588403d-9935fe3cd325c503</b>/generateAnswer

3) The last configuration element we need is your endpoint key value, this is the highlighted shown below.

Authorization: EndpointKey <b>aa000344-9998-4d3b-9df3-52bf7c4f7ffd</b>

4) Finally, you will use these parameters when creating an new instance of the QnAService struct as shown in the below example

```swift

let bot = QnAService(host: "https://testbot.azurewebsites.net/qnamaker", knowledgebaseID: "5581bd885-5588403d-9935fe3cd325c503", endpointKey: "aa000344-9998-4d3b-9df3-52bf7c4f7ffd")


```

## Requirements

* Xcode 9.1 or newer
* Swift 4.1
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
    .Package(url: "https://github.com/benbahrenburg/QnABotMaker.git", majorVersion: 1)
]
```

## Using

Using QnABotMaker couldn't be easier.  You simply create a new instance of the library and provide the <b>askQuestion</b> function with a question.  The completion hander, <b>completionHandler</b>, will provide the QnA answers or an error if necessary.

The following shows the library inaction.

```swift

let bot = QnAService(host: "YOUR-HOST-URL", knowledgebaseID: "YOUR-KB-ID", endpointKey: "YOUR-ENDPOINT-KEY")

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
