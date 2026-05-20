//
//  StatusItemView.swift
//  ClashX
//
//  Created by CYC on 2018/6/23.
//  Copyright © 2018年 yichengchen. All rights reserved.
//

import AppKit
import Foundation

final class StatusItemView: NSObject, StatusItemViewProtocol {
    private static let speedTitleColumnWidth = 9

    private weak var statusItem: NSStatusItem?
    private var showsSpeed = true
    private var enableProxy = false
    private var uploadSpeedText = "0KB/s"
    private var downloadSpeedText = "0KB/s"

    static func create(statusItem: NSStatusItem?) -> StatusItemView {
        let view = StatusItemView(statusItem: statusItem)
        view.setupButton()
        return view
    }

    private init(statusItem: NSStatusItem?) {
        self.statusItem = statusItem
        super.init()
    }

    private func setupButton() {
        guard let button = statusItem?.button else {
            Logger.log("button = nil")
            AppDelegate.shared.openConfigFolder(self)
            return
        }

        button.image = StatusItemTool.menuImage
        button.imagePosition = .imageLeading
        button.imageScaling = .scaleProportionallyDown
        button.font = Self.speedTitleFont
        button.alignment = .left
        button.lineBreakMode = .byClipping
        button.title = ""
        updateViewStatus(enableProxy: false)
        renderTitle()
    }

    private static var speedTitleFont: NSFont {
        NSFont.monospacedSystemFont(ofSize: StatusItemTool.font.pointSize, weight: .regular)
    }

    private static func formatSpeedTitleLine(_ text: String) -> String {
        let clipped = String(text.prefix(speedTitleColumnWidth))
        let padding = max(0, speedTitleColumnWidth - clipped.count)
        return String(repeating: " ", count: padding) + clipped
    }

    private func renderTitle() {
        guard let button = statusItem?.button else { return }
        guard showsSpeed else {
            button.attributedTitle = NSAttributedString(string: "")
            button.title = ""
            return
        }

        let title = [
            Self.formatSpeedTitleLine(downloadSpeedText),
            Self.formatSpeedTitleLine(uploadSpeedText)
        ].joined(separator: "\n")
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .right
        paragraphStyle.lineBreakMode = .byClipping
        paragraphStyle.maximumLineHeight = 10
        paragraphStyle.minimumLineHeight = 10

        let color: NSColor = enableProxy
            ? .labelColor
            : NSColor.labelColor.withSystemEffect(.disabled)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: Self.speedTitleFont,
            .foregroundColor: color,
            .paragraphStyle: paragraphStyle,
            .baselineOffset: -1
        ]

        button.attributedTitle = NSAttributedString(string: title, attributes: attributes)
    }

    func updateSize(width: CGFloat) {
        statusItem?.length = width
    }

    func updateViewStatus(enableProxy: Bool) {
        self.enableProxy = enableProxy
        renderTitle()
    }

    func updateSpeedLabel(up: Int, down: Int) {
        guard showsSpeed else { return }

        let newUpText = SpeedUtils.getSpeedString(for: up)
        let newDownText = SpeedUtils.getSpeedString(for: down)
        guard newUpText != uploadSpeedText || newDownText != downloadSpeedText else { return }

        uploadSpeedText = newUpText
        downloadSpeedText = newDownText
        renderTitle()
    }

    func showSpeedContainer(show: Bool) {
        guard showsSpeed != show else { return }
        showsSpeed = show
        renderTitle()
    }
}
