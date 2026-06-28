import AppKit
import SwiftUI

final class NotificationPanelController {
    static let shared = NotificationPanelController()

    private var panels: [UUID: NSPanel] = [:]
    private var panelOrder: [UUID] = []

    private let panelWidth: CGFloat = 370
    private let panelHeight: CGFloat = 88
    private let margin: CGFloat = 16
    private let spacing: CGFloat = 8

    private init() {}

    func show(id: UUID, title: String, message: String, soundName: String?) {
        if panels[id] != nil {
            dismiss(id: id, postNotification: false)
        }

        let banner = NotificationBannerView(
            title: title,
            message: message,
            onDismiss: { [weak self] in
                self?.dismiss(id: id, postNotification: true)
            }
        )
        let hosting = NSHostingView(rootView: banner)

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: panelWidth, height: panelHeight),
            styleMask: [.nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        panel.level = .normal
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.isMovableByWindowBackground = false
        panel.isReleasedWhenClosed = false
        panel.hidesOnDeactivate = false
        panel.titlebarAppearsTransparent = true
        panel.titleVisibility = .hidden
        panel.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
        panel.contentView = hosting

        // Size to fit the SwiftUI content
        let fittingSize = hosting.fittingSize
        panel.setContentSize(NSSize(width: panelWidth, height: fittingSize.height))

        panels[id] = panel
        panelOrder.append(id)

        let position = positionForIndex(panelOrder.count - 1, height: fittingSize.height)
        panel.setFrameOrigin(position)
        panel.orderFront(nil)

        playSound(named: soundName)
    }

    func dismiss(id: UUID, postNotification: Bool = true) {
        guard let panel = panels.removeValue(forKey: id) else { return }
        panelOrder.removeAll { $0 == id }
        panel.close()

        if postNotification {
            NotificationCenter.default.post(
                name: NotificationService.oneTimeFiredNotification,
                object: id
            )
        }

        repositionPanels()
    }

    // MARK: - Private

    private func positionForIndex(_ index: Int, height: CGFloat) -> NSPoint {
        guard let screen = NSScreen.main else { return .zero }
        let visibleFrame = screen.visibleFrame
        let x = visibleFrame.maxX - panelWidth - margin

        var yOffset: CGFloat = 0
        for i in 0..<index {
            let h = panels[panelOrder[i]]?.frame.height ?? panelHeight
            yOffset += h + spacing
        }

        let y = visibleFrame.maxY - margin - yOffset - height
        return NSPoint(x: x, y: y)
    }

    private func repositionPanels() {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.25
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            for (index, id) in panelOrder.enumerated() {
                guard let panel = panels[id] else { continue }
                let position = positionForIndex(index, height: panel.frame.height)
                panel.animator().setFrameOrigin(position)
            }
        }
    }

    private func playSound(named name: String?) {
        if let name = name, !name.isEmpty {
            NSSound(named: NSSound.Name(name))?.play()
        } else {
            NSSound.beep()
        }
    }
}
