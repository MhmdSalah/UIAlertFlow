<p align="center">
  <img src="Assets/logo.png" alt="UIAlertFlow logo" width="84" height="84" />
</p>

<h1 align="center">UIAlertFlow</h1>

<p align="center">A UIKit package for presenting rich, paged sheet flows in iOS apps.</p>

<p align="center">
    <img src="https://img.shields.io/badge/iOS-17.0+-2980b9.svg" />
    <img src="https://img.shields.io/badge/iPadOS-17.0+-8e44ad.svg" />
    <img src="https://img.shields.io/badge/UIKit-Only-2c3e50.svg" />
</p>

UIAlertFlow is written for **UIKit**. It lets you present a clean paged sheet from any `UIViewController`, with support for list pages, image pages, video pages, paging indicators, configurable button labels, accent colors, and a dismiss callback.

This package is inspired by the SwiftUI package [mykolaharmash/notelet.git](https://github.com/mykolaharmash/notelet.git).

## Installation

Install UIAlertFlow using Swift Package Manager.

1. Open your app project in Xcode.
2. Choose **File -> Add Package Dependencies...**.
3. Enter this repository URL:

```text
https://github.com/MhmdSalah/UIAlertFlow.git
```

4. Select the package.
5. Add `UIAlertFlow` to your app target.

## Quick Start

Import `UIAlertFlow`, define your sheet pages, create a `UIAlertFlowSheetController`, attach it to your view controller, then call `present()`.

```swift
import UIKit
import UIAlertFlow

final class ContentViewController: UIViewController {
    private var uiAlertFlow: UIAlertFlowSheetController!

    private let items: [UIAlertFlowItem] = [
        .list(
            title: "Highlights",
            rows: [
                .init(
                    symbolSystemName: "sparkles",
                    title: "Polished interface",
                    description: "A cleaner layout with smoother navigation."
                ),
                .init(
                    symbolSystemName: "bolt.fill",
                    title: "Faster actions",
                    description: "Common tasks now take fewer taps."
                )
            ]
        ),
        .media(
            kind: .image,
            url: URL(string: "https://example.com/preview.jpg")!,
            title: "Visual preview",
            description: "Show users an image with supporting text."
        ),
        .media(
            kind: .video,
            url: URL(string: "https://example.com/demo.mp4")!,
            title: "Short walkthrough",
            description: "Play a short video directly inside the sheet."
        )
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        uiAlertFlow = UIAlertFlowSheetController(items: items)
        uiAlertFlow.attach(to: self)
    }

    @objc private func showSheet() {
        uiAlertFlow.present()
    }
}
```

## Convenience Helper

You can also create and retain the controller through the `UIViewController` extension.

```swift
override func viewDidLoad() {
    super.viewDidLoad()

    configureUIAlertFlowSheet(items: items)
}

@objc private func showSheet() {
    uiAlertFlowSheetController?.present()
}
```

## Items

A sheet is built from an array of `UIAlertFlowItem` values. Each item becomes one page in the sheet. Users can move between pages with the button or by swiping horizontally.

`UIAlertFlowItem` supports:

* `.list`
* `.media(kind: .image)`
* `.media(kind: .video)`

`UIAlertFlowItem` and its nested types conform to `Codable`, so you can also load sheet content from a local file or remote response.

## List Page

Use a list page for a compact set of rows. Each row includes an SF Symbol, title, and description.

```swift
let items: [UIAlertFlowItem] = [
    .list(
        title: "What's included",
        rows: [
            .init(
                symbolSystemName: "lock.shield.fill",
                title: "Privacy controls",
                description: "Give users a clear summary of privacy-related changes."
            ),
            .init(
                symbolSystemName: "bell.badge.fill",
                title: "Smarter alerts",
                description: "Explain important updates in a focused, readable way."
            )
        ]
    )
]
```

All text values use `LocalizedStringResource`, so they can participate in string catalog localization.

## Image Page

Use an image page when visual context matters.

```swift
let items: [UIAlertFlowItem] = [
    .media(
        kind: .image,
        url: URL(string: "https://example.com/screenshot.jpg")!,
        title: "New dashboard",
        description: "Give users a quick visual look at the updated screen."
    )
]
```

Images are displayed in a square container with aspect fill. Square images, or images with the main subject near the center, work best.

## Video Page

Use a video page for walkthroughs, feature previews, or short tutorials.

```swift
let items: [UIAlertFlowItem] = [
    .media(
        kind: .video,
        url: URL(string: "https://example.com/walkthrough.mp4")!,
        title: "Feature walkthrough",
        description: "Show the flow in motion without leaving the sheet."
    )
]
```

For best results, use a direct HTTPS video URL that returns a streamable video response such as `video/mp4`.

## Dismiss Callback

`UIAlertFlowSheetController` accepts an optional `onDismiss` closure.

```swift
let controller = UIAlertFlowSheetController(
    items: items,
    onDismiss: {
        print("Sheet dismissed")
    }
)

controller.attach(to: self)
```

## Configuration

Customize the button labels and accent color with `UIAlertFlowConfiguration`.

```swift
let controller = UIAlertFlowSheetController(
    items: items,
    configuration: .init(
        nextButtonLabel: "Continue",
        doneButtonLabel: "Done",
        accentColor: .systemOrange
    )
)

controller.attach(to: self)
```

## Requirements

* iOS 17.0+
* iPadOS 17.0+
* UIKit
* Swift Package Manager
