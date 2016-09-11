# CalPal

CalPal is a tool that uses computer vision and optical character recognition to detect details from an event poster and autopopulate a calendar event.

##Installation Instructions
1. If you don't have Cocoa Pods already installed, install it using `sudo gem install cocoapods`.
  - You'll need to have [RubyGems][rubygems] installed in order to install CocoaPods.
2. Once that is complete, install the Podfile by running `pod install`.
3. Enter an API key
  - Create a project (or use an existing one) in the [Cloud
    Console][cloud-console]
  - [Enable billing][billing] and the [Vision API][enable-vision].
  - Create an [API key][api-key], and save this for later 
  - More details can be found at [getting_started_doc][getting-started]
4. Open the file `CalPal.xcworkspace`
5. In the xcode editor, create an api key file in the same directory as the remaining .swift files: click on the inner CalPal folder in the folder hierarchy,  go to File > New > File ... then select Swift File and click Next. Name the file `APIkey.swift` and add the line `let API_KEY = "YOUR_API_KEY"` to the file.


[getting-started]: https://cloud.google.com/vision/docs/getting-started
[cloud-console]: https://console.cloud.google.com
[billing]: https://console.cloud.google.com/billing?project=_
[enable-vision]: https://console.cloud.google.com/apis/api/vision.googleapis.com/overview?project=_
[api-key]: https://console.cloud.google.com/apis/credentials?project=_
[rubygems]: https://rubygems.org/pages/download
