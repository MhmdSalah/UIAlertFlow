//
//  Types.swift
//  UIAlertFlow
//
//  Created by Mohammed Ashour on 15.05.26.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

public enum UIAlertFlowItem: Sendable, Codable {
    case media(kind: MediaKind, url: URL, title: LocalizedStringResource, description: LocalizedStringResource)
    case list(title: LocalizedStringResource, rows: [ListRow])

    public enum MediaKind: Sendable, Codable {
        case image
        case video
    }

    public struct ListRow: Sendable, Codable {
        public init(symbolSystemName: String, title: LocalizedStringResource, description: LocalizedStringResource) {
            self.symbolSystemName = symbolSystemName
            self.title = title
            self.description = description
        }

        let symbolSystemName: String
        let title: LocalizedStringResource
        let description: LocalizedStringResource
    }
}

public struct UIAlertFlowConfiguration {
    let nextButtonLabel: LocalizedStringResource
    let doneButtonLabel: LocalizedStringResource
    let accentColor: UIColor

    public init(
        nextButtonLabel: LocalizedStringResource = "Next",
        doneButtonLabel: LocalizedStringResource = "Done",
        accentColor: UIColor = .systemBlue
    ) {
        self.nextButtonLabel = nextButtonLabel
        self.doneButtonLabel = doneButtonLabel
        self.accentColor = accentColor
    }
}
