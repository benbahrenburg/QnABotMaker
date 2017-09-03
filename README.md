# QnABotMaker

Convenience library for working with Microsoft's QnA Maker Service

## Getting Started

Before you get started using this library you will need to create a QnA "Service" using Microsoft's [QnA Maker](https://qnamaker.ai)

Once you have published your QnA Service you will see a <b>Sample HTTP request</b> similar to the one shown below. 


POST /knowledgebases/<b>581bd885-5588403d-9935fe3cd325c503</b>/generateAnswer
Host: https://westus.api.cognitive.microsoft.com/qnamaker/v2.0
Ocp-Apim-Subscription-Key: <b>b73f2abc20784927a330c7ad9e354e86</b>
Content-Type: application/json
{"question":"hi"}


The QnABotMaker library needs a few of these parameters in order to connect to the [QnA Maker](https://qnamaker.ai) service.

First we need your <b>knowledgebase identifier</b> or <b>knowledgebaseID</b>, this is the highlighted shown below.

POST /knowledgebases/<b>581bd885-5588403d-9935fe3cd325c503</b>/generateAnswer


Next we will need your <b>Subscription Key</b> or <b>subscriptionKey</b>, this is the highlighted shown below.
Ocp-Apim-Subscription-Key: <b>b73f2abc20784927a330c7ad9e354e86</b>


Finally, you will use these parameters when creating an new instance of the QnABotMaker library as shown in the below example

```swift

let kbBot = QnABotMaker(knowledgebaseID: "581bd885-5588403d-9935fe3cd325c503", subscriptionKey: "b73f2abc20784927a330c7ad9e354e86")

```

## Requirements

* Xcode 8.2 or newer
* Swift 3.0
* iOS 9 or greater


## Installation

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


## Example

Using QnABotMaker couldn't be easier.  You simply create a new instance of the library and provide the <b>ask</b> function with a question.  The completion hander, <b>completionHandler</b>, will provide the QnA answers or an error if necessary.

The following shows the library inaction.

```swift

let kbBot = QnABotMaker(knowledgebaseID: "<<< MY KB ID >>>", subscriptionKey: "<<< MY SUBSCRIPTION KEY >>>")

kbBot.ask("hello", completionHandler: {(answers, error) in
    if let error = error {
        return print("error: \(error)")
    }
    if let answers = answers {
       print(answers)
    }
})

```

## Author

Ben Bahrenburg, @bencoding

## License

QnABotMaker is available under the MIT license. See the LICENSE file for more info.
