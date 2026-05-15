//
//  SheetContent.swift
//  UIAlertFlowExample
//
//  Created by Mohammed Ashour on 15.05.26.
//  Licensed under the MIT License.
//

import Foundation
import UIAlertFlow

enum SheetContent {
    static let sample: [UIAlertFlowItem] = [
        .list(
            title: "Highlights",
            rows: [
                .init(
                    symbolSystemName: "wand.and.stars",
                    title: "New editor tools",
                    description: "More formatting options with fewer taps."
                ),
                .init(
                    symbolSystemName: "lock.shield.fill",
                    title: "Privacy update",
                    description: "Sensitive data handling is now stricter."
                ),
                .init(
                    symbolSystemName: "bell.badge.fill",
                    title: "Smarter notifications",
                    description: "Fewer pings, more of what matters to you."
                )
            ]
        ),
        .media(
            kind: .image,
            url: URL(string: "https://picsum.photos/800/800")!,
            title: "Refreshed home screen",
            description: "A cleaner layout with quicker access to your recent items."
        ),
        .media(
            kind: .video,
            url: URL(string: "https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/360/Big_Buck_Bunny_360_10s_1MB.mp4")!,
            title: "Collaboration preview",
            description: "Share a space and edit together in real time."
        )
    ]
}
