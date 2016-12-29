# [CalPal](http://calendarpal.me/)

CalPal is a tool that uses computer vision and optical character recognition to detect details from an event poster and autopopulate a calendar event.

##Installation Instructions
1. If you don't have Cocoa Pods already installed, install it using `sudo gem install cocoapods`.
  - You'll need to have [RubyGems][rubygems] installed in order to install CocoaPods.
2. Once that is complete, install the Podfile by running `pod install`.
3. Open the file `CalPal.xcworkspace` to edit

## Notes
OCR is done using the tesseract library for swift. The Pod is based on Tesseract 3.03, so it needs version 3.02 of the training data. See [Data files][datafiles] and make sure you download the appropriate version of the data files (the correct version is already included here). The Tesseract iOS framework is linked [here][tesseract-ios]

[getting-started]: https://cloud.google.com/vision/docs/getting-started
[cloud-console]: https://console.cloud.google.com
[billing]: https://console.cloud.google.com/billing?project=_
[enable-vision]: https://console.cloud.google.com/apis/api/vision.googleapis.com/overview?project=_
[api-key]: https://console.cloud.google.com/apis/credentials?project=_
[rubygems]: https://rubygems.org/pages/download
[datafiles]:https://github.com/tesseract-ocr/tesseract/wiki/Data-Files
[tesseract-ios]: https://github.com/gali8/Tesseract-OCR-iOS

##Credits
CalPal was made at Penn Apps XIV (Fall 2016) by Lucy Chai, Pia Kochar, Eric Li, and Kelly Tan.
