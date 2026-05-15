//
//  ViewController.swift
//  UIAlertFlowExample
//
//  Created by Mohammed Ashour on 15.05.26.
//  Licensed under the MIT License.
//

import UIKit
import UIAlertFlow

final class ViewController: UIViewController {
    private var uiAlertFlow: UIAlertFlowSheetController!
    private let showSheetButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "UIAlertFlow Example"
        view.backgroundColor = .systemBackground

        uiAlertFlow = UIAlertFlowSheetController(
            items: SheetContent.sample,
            onDismiss: {
                print("Sheet dismissed")
            },
            configuration: .init(
                nextButtonLabel: "Next",
                doneButtonLabel: "Got it",
                accentColor: .systemBlue
            )
        )
        uiAlertFlow.attach(to: self)

        setUpShowSheetButton()
    }

    private func setUpShowSheetButton() {
        var config = UIButton.Configuration.filled()
        config.title = "Show sheet"
        config.image = UIImage(systemName: "sparkles")
        config.imagePadding = 8
        config.cornerStyle = .large
        config.baseBackgroundColor = .systemBlue
        config.baseForegroundColor = .white

        showSheetButton.configuration = config
        showSheetButton.translatesAutoresizingMaskIntoConstraints = false
        showSheetButton.addTarget(self, action: #selector(showSheetTapped), for: .touchUpInside)

        view.addSubview(showSheetButton)

        NSLayoutConstraint.activate([
            showSheetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            showSheetButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            showSheetButton.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            showSheetButton.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),
        ])
    }

    @objc private func showSheetTapped() {
        uiAlertFlow.present()
    }
}
