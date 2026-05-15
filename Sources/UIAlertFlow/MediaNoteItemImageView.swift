//
//  MediaNoteItemImageView.swift
//  UIAlertFlow
//
//  Created by Mohammed Ashour on 15.05.26.
//  Licensed under the MIT License.
//

import UIKit

final class MediaNoteItemImageView: UIView {
    private let imageUrl: URL
    private let imageView = UIImageView()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private var loadTask: URLSessionDataTask?

    init(imageUrl: URL) {
        self.imageUrl = imageUrl
        super.init(frame: .zero)
        setUp()
        loadImage()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        loadTask?.cancel()
    }

    private func setUp() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true

        addSubview(imageView)
        addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    private func loadImage() {
        activityIndicator.startAnimating()

        loadTask = URLSession.shared.dataTask(with: imageUrl) { [weak self] data, _, _ in
            DispatchQueue.main.async {
                guard let self else { return }
                self.activityIndicator.stopAnimating()

                if let data, let image = UIImage(data: data) {
                    self.imageView.image = image
                } else {
                    self.showPlaceholder()
                }
            }
        }
        loadTask?.resume()
    }

    private func showPlaceholder() {
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)
        imageView.image = UIImage(systemName: "photo.on.rectangle.angled", withConfiguration: config)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .secondaryLabel
    }
}
