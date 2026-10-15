import AppKit

let destination = CommandLine.arguments[1]
let size = 1024
let image = NSImage(size: NSSize(width: size, height: size))
image.lockFocus()
let bounds = NSRect(x: 0, y: 0, width: size, height: size)
NSColor(srgbRed: 0.025, green: 0.037, blue: 0.055, alpha: 1).setFill()
bounds.fill()
let gradient = NSGradient(starting: NSColor(srgbRed: 0.08, green: 0.14, blue: 0.20, alpha: 1), ending: NSColor(srgbRed: 0.02, green: 0.03, blue: 0.045, alpha: 1))!
gradient.draw(in: bounds, angle: -65)
let centre = CGPoint(x: 512, y: 512)
for index in 0..<5500 {
    let seed = sin(Double(index) * 127.1) * 43758.5453
    let q = seed - floor(seed)
    let seed2 = sin(Double(index) * 311.7 + 7) * 85734.1337
    let q2 = seed2 - floor(seed2)
    let theta = q * Double.pi * 2
    let lobe = abs(sin(theta))
    let radius = pow(q2, 0.48) * (110 + 280 * lobe)
    let x = centre.x + cos(theta) * radius * 0.85
    let y = centre.y + sin(theta) * radius
    let cyan = sin(theta) >= 0
    NSColor(srgbRed: cyan ? 0.40 : 0.73, green: cyan ? 0.91 : 0.64, blue: cyan ? 0.95 : 1, alpha: 0.35 + q2 * 0.5).setFill()
    let d = 2.5 + q2 * 3.5
    NSBezierPath(ovalIn: NSRect(x: x - d/2, y: y - d/2, width: d, height: d)).fill()
}
NSColor(srgbRed: 0.40, green: 0.91, blue: 0.95, alpha: 0.2).setStroke()
let circle = NSBezierPath(ovalIn: NSRect(x: 105, y: 105, width: 814, height: 814))
circle.lineWidth = 2; circle.stroke()
for index in 0..<18 {
    let a = Double(index) * 2.39996
    let r = sqrt(Double(index)) * 12
    let x = centre.x + cos(a) * r, y = centre.y + sin(a) * r
    NSColor(srgbRed: 1, green: 0.73, blue: 0.35, alpha: 1).setFill()
    NSBezierPath(ovalIn: NSRect(x: x - 10, y: y - 10, width: 20, height: 20)).fill()
}
image.unlockFocus()
let bitmap = NSBitmapImageRep(data: image.tiffRepresentation!)!
try bitmap.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: destination))
