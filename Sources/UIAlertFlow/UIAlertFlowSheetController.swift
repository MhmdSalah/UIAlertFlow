//
//  UIAlertFlowSheetController.swift
//  UIAlertFlow
//
//  Created by Mohammed Ashour on 15.05.26.
//  Licensed under the MIT License.
//

import UIKit

/// Presents sheet flows from a host view controller.
@MainActor
public final class UIAlertFlowSheetController {
    private let items: [UIAlertFlowItem]
    private let onDismiss: () -> Void
    private let configuration: UIAlertFlowConfiguration

    private weak var hostViewController: UIViewController?
    private weak var presentedSheet: UIAlertFlowSheetViewController?

    public init(
        items: [UIAlertFlowItem],
        onDismiss: @escaping () -> Void = {},
        configuration: UIAlertFlowConfiguration = .init()
    ) {
        self.items = items
        self.onDismiss = onDismiss
        self.configuration = configuration
    }

    /// Retain the controller for as long as the host view controller may present the sheet.
    public func attach(to viewController: UIViewController) {
        hostViewController = viewController
    }

    /// Presents the sheet when items exist.
    public func present() {
        guard presentedSheet == nil else { return }
        guard let hostViewController else { return }
        guard !items.isEmpty else { return }

        let sheet = UIAlertFlowSheetViewController(
            items: items,
            configuration: configuration
        )
        sheet.sheetDelegate = self
        presentedSheet = sheet
        hostViewController.present(sheet, animated: true)
    }

    /// Presents the sheet when items exist.
    @available(*, deprecated, renamed: "present()")
    public func presentIfNeeded() {
        present()
    }

    private func handleDismiss() {
        presentedSheet = nil
        onDismiss()
    }
}

extension UIAlertFlowSheetController: UIAlertFlowSheetViewControllerDelegate {
    func uiAlertFlowSheetViewControllerDidDismiss(_ controller: UIAlertFlowSheetViewController) {
        handleDismiss()
    }
}

public extension UIViewController {
    /// Creates and attaches a `UIAlertFlowSheetController`.
    @discardableResult
    func configureUIAlertFlowSheet(
        items: [UIAlertFlowItem],
        onDismiss: @escaping () -> Void = {},
        configuration: UIAlertFlowConfiguration = .init()
    ) -> UIAlertFlowSheetController {
        let controller = UIAlertFlowSheetController(
            items: items,
            onDismiss: onDismiss,
            configuration: configuration
        )
        controller.attach(to: self)
        objc_setAssociatedObject(
            self,
            &uiAlertFlowSheetControllerKey,
            controller,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
        return controller
    }

    /// The controller created by `configureUIAlertFlowSheet(items:onDismiss:configuration:)`, if any.
    var uiAlertFlowSheetController: UIAlertFlowSheetController? {
        objc_getAssociatedObject(self, &uiAlertFlowSheetControllerKey) as? UIAlertFlowSheetController
    }
}

nonisolated(unsafe) private var uiAlertFlowSheetControllerKey: UInt8 = 0
