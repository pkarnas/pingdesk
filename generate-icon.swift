import AppKit
import Foundation

let iconsetPath = "PingDesk.iconset"
try? FileManager.default.createDirectory(atPath: iconsetPath, withIntermediateDirectories: true)

let entries: [(size: Int, filename: String)] = [
    (16,   "icon_16x16.png"),
    (32,   "icon_16x16@2x.png"),
    (32,   "icon_32x32.png"),
    (64,   "icon_32x32@2x.png"),
    (128,  "icon_128x128.png"),
    (256,  "icon_128x128@2x.png"),
    (256,  "icon_256x256.png"),
    (512,  "icon_256x256@2x.png"),
    (512,  "icon_512x512.png"),
    (1024, "icon_512x512@2x.png")
]

func makeIcon(size: Int) -> NSImage {
    let s = CGFloat(size)
    let image = NSImage(size: NSSize(width: s, height: s))
    image.lockFocus()

    // Orange gradient background
    let gradient = NSGradient(colors: [
        NSColor(red: 1.0, green: 0.62, blue: 0.05, alpha: 1.0),
        NSColor(red: 0.95, green: 0.35, blue: 0.0, alpha: 1.0)
    ])!
    let rect = NSRect(x: 0, y: 0, width: s, height: s)
    let radius = s * 0.22
    gradient.draw(in: NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius), angle: 90)

    // Bell SF Symbol in white
    let pointSize = s * 0.55
    let config = NSImage.SymbolConfiguration(pointSize: pointSize, weight: .medium)
        .applying(NSImage.SymbolConfiguration(paletteColors: [.white]))
    if let bell = NSImage(systemSymbolName: "bell.fill", accessibilityDescription: nil)?
        .withSymbolConfiguration(config) {
        let bx = (s - bell.size.width) / 2
        let by = (s - bell.size.height) / 2 + s * 0.02
        bell.draw(in: NSRect(x: bx, y: by, width: bell.size.width, height: bell.size.height),
                  from: .zero, operation: .sourceOver, fraction: 1.0)
    }

    image.unlockFocus()
    return image
}

for entry in entries {
    let img = makeIcon(size: entry.size)
    guard let tiff = img.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiff),
          let png = bitmap.representation(using: .png, properties: [:]) else {
        print("Failed: \(entry.filename)")
        continue
    }
    let path = "\(iconsetPath)/\(entry.filename)"
    try! png.write(to: URL(fileURLWithPath: path))
    print("✓ \(path)")
}

print("Done!")
