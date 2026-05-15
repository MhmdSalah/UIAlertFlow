//
//  MediaNoteItemDetailsView.swift
//  UIAlertFlow
//
//  Created by Mohammed Ashour on 15.05.26.
//  Licensed under the MIT License.
//

import UIKit

final class MediaNoteItemDetailsView: UIView {
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()

    init(title: LocalizedStringResource, description: LocalizedStringResource) {
        super.init(frame: .zero)
        titleLabel.text = title.uiAlertFlowResolved
        descriptionLabel.text = description.uiAlertFlowResolved
        setUp()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUp() {
        titleLabel.font = .preferredFont(forTextStyle: .title3).with(weight: .bold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0

        descriptionLabel.font = .preferredFont(forTextStyle: .body)
        descriptionLabel.textColor = .label
        descriptionLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .leading

        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30),
        ])
    }
}

private extension UIFont {
    func with(weight: UIFont.Weight) -> UIFont {
        let descriptor = fontDescriptor.addingAttributes([
            .traits: [UIFontDescriptor.TraitKey.weight: weight],
        ])
        return UIFont(descriptor: descriptor, size: pointSize)
    }
}
