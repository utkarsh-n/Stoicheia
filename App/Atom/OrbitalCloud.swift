import Foundation

/// Hydrogen-like radial distributions plus one real angular basis shape per subshell.
/// Coordinates normalise each view's scale; this does not predict multi-electron atomic radii.
@MainActor enum OrbitalCloud {
    struct Sample { let x, y, z: Double; let positive: Bool }
    private static var cache: [String: [Sample]] = [:]
    static func samples(n: Int, l: Int) -> [Sample] {
        let key = "\(n)-\(l)"
        if let result = cache[key] { return result }
        let bins = 600
        let maximum = Double(n * n) * 4.5
        var cdf: [Double] = []
        var total = 0.0
        for i in 0..<bins {
            let r = (Double(i) + 0.5) / Double(bins) * maximum
            let radial = amplitude(n: n, l: l, radius: r)
            total += r * r * radial * radial
            cdf.append(total)
        }
        var result: [Sample] = []
        for i in 0..<4500 {
            let azimuth = noise(i, 1) * .pi * 2
            let y = noise(i, 2) * 2 - 1
            let planar = sqrt(max(0, 1 - y * y))
            let x = planar * cos(azimuth), z = planar * sin(azimuth)
            let angular = l == 0 ? 1 : l == 1 ? y : l == 2 ? 2 * x * y : 3 * sqrt(3) * x * y * z
            guard noise(i, 3) < angular * angular else { continue }
            let target = noise(i, 4) * total
            var low = 0, high = bins - 1
            while low < high {
                let middle = (low + high) / 2
                if cdf[middle] < target { low = middle + 1 } else { high = middle }
            }
            let physicalR = (Double(low) + noise(i, 5)) / Double(bins) * maximum
            let displayR = physicalR / (Double(n * n) * 3)
            result.append(Sample(x: x * displayR, y: y * displayR, z: z * displayR,
                                 positive: angular * amplitude(n: n, l: l, radius: physicalR) >= 0))
        }
        cache[key] = result
        return result
    }
    private static func amplitude(n: Int, l: Int, radius: Double) -> Double {
        let rho = 2 * radius / Double(n)
        let degree = n - l - 1
        let alpha = Double(2 * l + 1)
        var previous = 1.0
        var current = 1 + alpha - rho
        if degree == 0 { current = 1 }
        if degree >= 2 {
            for k in 2...degree {
                let next = ((Double(2 * k - 1) + alpha - rho) * current - (Double(k - 1) + alpha) * previous) / Double(k)
                previous = current; current = next
            }
        }
        return pow(rho, Double(l)) * exp(-rho / 2) * current
    }
    private static func noise(_ index: Int, _ salt: Double) -> Double {
        let value = sin(Double(index) * 127.1 + salt * 311.7) * 43758.5453
        return value - floor(value)
    }
}
