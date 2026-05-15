//
//  BulletListNoteItemView.swift
//  UIAlertFlow
//
//  Created by Mohammed Ashour on 15.05.26.
//  Licensed under the MIT License.
//

import UIKit

final class BulletListNoteItemView: UIView {
    init(
        title: LocalizedStringResource,
        rows: [UIAlertFlowItem.ListRow],
        accentColor: UIColor
    ) {
        super.init(frame: .zero)
        setUp(title: title, rows: rows, accentColor: accentColor)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUp(
        title: LocalizedStringResource,
        rows: [UIAlertFlowItem.ListRow],
        accentColor: UIColor
    ) {
        let titleLabel = UILabel()
        titleLabel.text = title.uiAlertFlowResolved
        titleLabel.font = .preferredFont(forTextStyle: .title1).with(weight: .bold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0

        let rowsStack = UIStackView()
        rowsStack.axis = .vertical
        rowsStack.spacing = 32
        rowsStack.alignment = .fill

        for row in rows {
            rowsStack.addArrangedSubview(makeRowView(row: row, accentColor: accentColor))
        }

        let contentStack = UIStackView(arrangedSubviews: [titleLabel, rowsStack])
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 40
        contentStack.alignment = .leading

        addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: topAnchor, constant: 64),
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -64),
        ])
    }

    private func makeRowView(
        row: UIAlertFlowItem.ListRow,
        accentColor: UIColor
    ) -> UIView {
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 32, weight: .semibold)
        let symbolView = UIImageView(image: UIImage(systemName: row.symbolSystemName, withConfiguration: symbolConfig))
        symbolView.tintColor = accentColor
        symbolView.contentMode = .scaleAspectFit
        symbolView.setContentHuggingPriority(.required, for: .horizontal)
        symbolView.setContentCompressionResistancePriority(.required, for: .horizontal)

        let rowTitleLabel = UILabel()
        rowTitleLabel.text = row.title.uiAlertFlowResolved
        rowTitleLabel.font = .preferredFont(forTextStyle: .body).with(weight: .semibold)
        rowTitleLabel.textColor = .label
        rowTitleLabel.numberOfLines = 0

        let rowDescriptionLabel = UILabel()
        rowDescriptionLabel.text = row.description.uiAlertFlowResolved
        rowDescriptionLabel.font = .preferredFont(forTextStyle: .body)
        rowDescriptionLabel.textColor = .secondaryLabel
        rowDescriptionLabel.numberOfLines = 0

        let textStack = UIStackView(arrangedSubviews: [rowTitleLabel, rowDescriptionLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.alignment = .leading

        let rowStack = UIStackView(arrangedSubviews: [symbolView, textStack])
        rowStack.axis = .horizontal
        rowStack.spacing = 18
        rowStack.alignment = .top

        symbolView.widthAnchor.constraint(equalToConstant: 48).isActive = true

        return rowStack
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
