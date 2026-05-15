//
//  MediaNoteItemVideoView.swift
//  UIAlertFlow
//
//  Created by Mohammed Ashour on 15.05.26.
//  Licensed under the MIT License.
//

import AVKit
import UIKit

final class MediaNoteItemVideoView: UIView {
    private let videoURL: URL
    private var isPlaying = false

    private let playerView = VideoPlayerView()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    private var player: AVQueuePlayer?
    private var playerLooper: AVPlayerLooper?
    private var videoStatusObserver: NSKeyValueObservation?

    init(videoURL: URL) {
        self.videoURL = videoURL
        super.init(frame: .zero)
        setUp()
        prepareVideo()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        videoStatusObserver?.invalidate()
        player?.pause()
    }

    func setPlaying(_ playing: Bool) {
        guard isPlaying != playing else { return }
        isPlaying = playing
        updatePlaybackState()
    }

    private func setUp() {
        playerView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()

        addSubview(playerView)
        addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            playerView.topAnchor.constraint(equalTo: topAnchor),
            playerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            playerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])

        playerView.alpha = 0
    }

    private func prepareVideo() {
        videoStatusObserver?.invalidate()
        videoStatusObserver = nil

        activityIndicator.startAnimating()
        playerView.alpha = 0

        let asset = AVURLAsset(url: videoURL)
        let playerItem = AVPlayerItem(asset: asset)
        playerItem.preferredForwardBufferDuration = 2.0

        let queuePlayer = AVQueuePlayer(playerItem: playerItem)
        queuePlayer.automaticallyWaitsToMinimizeStalling = true

        videoStatusObserver = queuePlayer.observe(\.currentItem?.status, options: [.initial, .new]) { [weak self] observedPlayer, _ in
            DispatchQueue.main.async {
                guard let self else { return }
                switch observedPlayer.currentItem?.status {
                case .readyToPlay:
                    self.activityIndicator.stopAnimating()
                    self.playerView.alpha = 1
                case .failed:
                    self.activityIndicator.stopAnimating()
                    print("UIAlertFlow video failed to load:", observedPlayer.currentItem?.error?.localizedDescription ?? "Unknown error")
                default:
                    break
                }
            }
        }

        player = queuePlayer
        playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        playerView.player = queuePlayer

        updatePlaybackState()
    }

    private func updatePlaybackState() {
        if isPlaying {
            player?.play()
        } else {
            player?.pause()
        }
    }
}

private final class VideoPlayerView: UIView {
    override static var layerClass: AnyClass { AVPlayerLayer.self }

    var playerLayer: AVPlayerLayer {
        layer as! AVPlayerLayer
    }

    var player: AVPlayer? {
        get { playerLayer.player }
        set { playerLayer.player = newValue }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        playerLayer.videoGravity = .resizeAspectFill
        clipsToBounds = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
