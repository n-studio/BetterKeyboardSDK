# BetterKeyboardSDK

A quick way to implement default features in UITextView for Better Keyboard (by Solfanto) (https://itunes.apple.com/app/better-keyboard-by-solfanto/id1049294250?ls=1&mt=8).

[**Better Keyboard**](https://itunes.apple.com/app/better-keyboard-by-solfanto/id1049294250?ls=1&mt=8) is an iOS keyboard extension that simulates computer keyboards' shortcuts like `⌘+c`.
Unfortunately, the extension can't support the shortcuts by its own, the applications used with the keyboard must support the shortcuts as well.

If you own an iOS application, you can easily implement these shortcuts with this SDK. You can also read the source code and implement your own shortcuts.

If you own an iOS keyboard extension, we encourage you to also support shortcuts using the same API. *(documentation coming soon)*

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

BetterKeyboardSDK is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "BetterKeyboardSDK", git: "git@github.com:n-studio/BetterKeyboardSDK.git"
```

## Shortcuts

`⌘a: Select all`<br />
`⌘c: Copy`<br />
`⌘x: Cut`<br />
`⌘v: Paste`<br />
`⌘z: Undo`<br />
`⌘y: Redo`<br />
`⌘←: Select left`<br />
`⌘→: Select right`<br />
`⎋ or ␛: Escape (currently no effect)`

## Contribute

The API is still in draft, feel free to open issues to make feature suggestions or any comment/criticism.

If the keyboard extension [Better Keyboard (by Solfanto)](https://itunes.apple.com/app/better-keyboard-by-solfanto/id1049294250?ls=1&mt=8) itself has a bug, feel free to report it here.

## Author

Matthew Nguyen, Solfanto, Inc.

## License

BetterKeyboardSDK is available under the MIT license. See the LICENSE file for more info.
