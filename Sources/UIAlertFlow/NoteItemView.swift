//
//  NoteItemView.swift
//  UIAlertFlow
//
//  Created by Mohammed Ashour on 15.05.26.
//  Licensed under the MIT License.
//

import UIKit

final class NoteItemView: UIView {
    private let item: UIAlertFlowItem
    private let configuration: UIAlertFlowConfiguration

    private var mediaVideoView: MediaNoteItemVideoView?

    init(item: UIAlertFlowItem, configuration: UIAlertFlowConfiguration) {
        self.item = item
        self.configuration = configuration
        super.init(frame: .zero)
        setUp()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setIsCurrent(_ isCurrent: Bool) {
        mediaVideoView?.setPlaying(isCurrent)
    }

    private var clipCornerRadius: CGFloat {
        if #available(iOS 26, *) {
            24
        } else {
            12
        }
    }

    private func setUp() {
        switch item {
        case .media(let mediaKind, let url, let title, let description):
            setUpMedia(
                mediaKind: mediaKind,
                url: url,
                title: title,
                description: description
            )
        case .list(let title, let rows):
            setUpList(title: title, rows: rows)
        }
    }

    private func setUpList(title: LocalizedStringResource, rows: [UIAlertFlowItem.ListRow]) {
        let listView = BulletListNoteItemView(
            title: title,
            rows: rows,
            accentColor: configuration.accentColor
        )
        listView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(listView)
        NSLayoutConstraint.activate([
            listView.topAnchor.constraint(equalTo: topAnchor),
            listView.leadingAnchor.constraint(equalTo: leadingAnchor),
            listView.trailingAnchor.constraint(equalTo: trailingAnchor),
            listView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    private func setUpMedia(
        mediaKind: UIAlertFlowItem.MediaKind,
        url: URL,
        title: LocalizedStringResource,
        description: LocalizedStringResource
    ) {
        let mediaContainer = UIView()
        mediaContainer.translatesAutoresizingMaskIntoConstraints = false
        let mediaWrapper = UIView()
        mediaWrapper.translatesAutoresizingMaskIntoConstraints = false
        mediaWrapper.backgroundColor = .clear

        mediaContainer.layer.cornerRadius = clipCornerRadius
        mediaContainer.layer.masksToBounds = true
        mediaWrapper.layer.shadowColor = UIColor.black.cgColor
        mediaWrapper.layer.shadowOpacity = 0.15
        mediaWrapper.layer.shadowRadius = 20
        mediaWrapper.layer.shadowOffset = .zero

        let mediaContent: UIView
        switch mediaKind {
        case .image:
            mediaContent = MediaNoteItemImageView(imageUrl: url)
        case .video:
            let videoView = MediaNoteItemVideoView(videoURL: url)
            mediaVideoView = videoView
            mediaContent = videoView
        }

        mediaContent.translatesAutoresizingMaskIntoConstraints = false
        mediaContainer.addSubview(mediaContent)
        mediaWrapper.addSubview(mediaContainer)

        NSLayoutConstraint.activate([
            mediaContent.topAnchor.constraint(equalTo: mediaContainer.topAnchor),
            mediaContent.leadingAnchor.constraint(equalTo: mediaContainer.leadingAnchor),
            mediaContent.trailingAnchor.constraint(equalTo: mediaContainer.trailingAnchor),
            mediaContent.bottomAnchor.constraint(equalTo: mediaContainer.bottomAnchor),

            mediaContainer.topAnchor.constraint(equalTo: mediaWrapper.topAnchor),
            mediaContainer.leadingAnchor.constraint(equalTo: mediaWrapper.leadingAnchor),
            mediaContainer.trailingAnchor.constraint(equalTo: mediaWrapper.trailingAnchor),
            mediaContainer.bottomAnchor.constraint(equalTo: mediaWrapper.bottomAnchor),
        ])

        let detailsView = MediaNoteItemDetailsView(title: title, description: description)
        detailsView.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [mediaWrapper, detailsView])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center

        addSubview(stack)

        let mediaPadding: CGFloat = 16
        let mediaWidth = mediaWrapper.widthAnchor.constraint(equalToConstant: 268)
        mediaWidth.priority = .required

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: mediaPadding),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: mediaPadding),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -mediaPadding),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -mediaPadding),
            mediaWidth,
            mediaWrapper.widthAnchor.constraint(equalTo: mediaWrapper.heightAnchor),
        ])

        layoutMediaSize(mediaWrapper: mediaWrapper, mediaPadding: mediaPadding, widthConstraint: mediaWidth)
    }

    private func layoutMediaSize(
        mediaWrapper: UIView,
        mediaPadding: CGFloat,
        widthConstraint: NSLayoutConstraint
    ) {
        let updateSize: () -> Void = { [weak self] in
            guard let self else { return }
            let availableWidth = self.bounds.width - mediaPadding * 2
            let containerWidth = min(max(availableWidth, 268), 440)
            widthConstraint.constant = containerWidth
        }

        if bounds.width > 0 {
            updateSize()
        }

        registerForLayoutUpdates(updateSize)
    }

    private var layoutUpdateHandler: (() -> Void)?

    private func registerForLayoutUpdates(_ handler: @escaping () -> Void) {
        layoutUpdateHandler = handler
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutUpdateHandler?()
    }
}
