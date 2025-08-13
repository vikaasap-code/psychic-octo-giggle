import SwiftUI

struct InterstellarHeroView: View {
    struct Star {
        let uv: SIMD2<Double]
        let depth: Double
        let phase: Double
        let baseSize: Double
    }

    var onCalculate: (() -> Void)? = nil
    var onCheckCompatibility: (() -> Void)? = nil

    @State private var start = Date()
    private let stars: [Star] = InterstellarHeroView.generateStars(count: 600, seed: 42)

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSince(start)

            ZStack {
                LinearGradient(colors: [Color(red: 0.02, green: 0.03, blue: 0.09),
                                        Color(red: 0.01, green: 0.02, blue: 0.06)],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                Canvas { context, size in
                    let time = CGFloat(t)
                    let bhCenter = CGPoint(
                        x: size.width * 0.62 + sin(time * 0.07) * 20,
                        y: size.height * 0.45 + cos(time * 0.09) * 16
                    )
                    let bhRadius = min(size.width, size.height) * 0.12
                    let lensStrength: CGFloat = 1800
                    let lensMaxDist: CGFloat = bhRadius * 2.4
                    let globalDrift = CGSize(width: time * 6, height: time * 2)

                    for star in stars {
                        var p = CGPoint(x: star.uv.x * size.width, y: star.uv.y * size.height)

                        p.x = wrap(p.x + globalDrift.width * (0.2 + 0.8 * (1 - star.depth)), max: size.width)
                        p.y = wrap(p.y + globalDrift.height * (0.15 + 0.5 * (1 - star.depth)), max: size.height)

                        let d = distance(p, bhCenter)
                        if d < lensMaxDist {
                            let dir = normalized(p - bhCenter)
                            let attenuation = smoothstep(edge0: lensMaxDist, edge1: bhRadius * 0.6, x: d)
                            let disp = dir * (lensStrength / max(d * d, 1)) * attenuation
                            p = p + disp
                        }

                        let twinkle = 0.7 + 0.3 * sin(CGFloat(star.phase) + time * (0.5 + 1.5 * star.depth))
                        let starSize = CGFloat(star.baseSize) * (0.6 + 0.7 * star.depth) * (0.9 + 0.2 * twinkle)
                        let opacity = min(1.0, 0.4 + 0.6 * twinkle)

                        var path = Path()
                        path.addEllipse(in: CGRect(x: p.x, y: p.y, width: starSize, height: starSize))
                        context.fill(path, with: .color(Color.white.opacity(opacity)))
                    }
                }
                .scaleEffect(1.02 + CGFloat(sin(t * 0.2)) * 0.02)

                BlackHoleLayer()
                OrbitsLayer()

                VStack(spacing: 16) {
                    Spacer().frame(height: 32)
                    Text("Астрология будущего")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(LinearGradient(colors: [Color.cyan, Color.purple, Color.pink],
                                                        startPoint: .leading, endPoint: .trailing))
                        .shadow(color: .black.opacity(0.7), radius: 10, x: 0, y: 6)

                    Text("Планеты на связи: найди свою совместимость")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))

                    Spacer()

                    VStack(spacing: 12) {
                        Button(action: { onCalculate?() }) {
                            Text("Рассчитать мою карту")
                                .font(.system(size: 17, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(colors: [Color.cyan, Color.purple, Color.pink],
                                                   startPoint: .leading, endPoint: .trailing)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .shadow(color: .purple.opacity(0.4), radius: 20, x: 0, y: 10)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 24)

                        Button(action: { onCheckCompatibility?() }) {
                            Text("Проверить совместимость")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                                .padding(.vertical, 14)
                                .frame(maxWidth: .infinity)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                                )
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)
                    }
                }
            }
            .preferredColorScheme(.dark)
        }
    }

    static func generateStars(count: Int, seed: UInt64) -> [Star] {
        var rng = SeededGenerator(seed: seed)
        return (0..<count).map { _ in
            Star(
                uv: SIMD2(Double.random(in: 0...1, using: &rng), Double.random(in: 0...1, using: &rng)),
                depth: Double.random(in: 0.0...1.0, using: &rng),
                phase: Double.random(in: 0.0...(.pi * 2), using: &rng),
                baseSize: Double.random(in: 0.7...2.0, using: &rng)
            )
        }
    }

    func wrap(_ value: CGFloat, max: CGFloat) -> CGFloat {
        var v = value.truncatingRemainder(dividingBy: max)
        if v < 0 { v += max }
        return v
    }

    func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        hypot(a.x - b.x, a.y - b.y)
    }

    func normalized(_ v: CGPoint) -> CGPoint {
        let l = max(0.0001, hypot(v.x, v.y))
        return CGPoint(x: v.x / l, y: v.y / l)
    }

    func smoothstep(edge0: CGFloat, edge1: CGFloat, x: CGFloat) -> CGFloat {
        let t = max(0, min(1, (edge0 - x) / (edge0 - edge1)))
        return t * t * (3 - 2 * t)
    }
}

private struct BlackHoleLayer: View {
    @State private var start = Date()

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSince(start)
            GeometryReader { geo in
                let size = geo.size
                let bhSize = min(size.width, size.height) * 0.36
                let center = CGPoint(
                    x: size.width * 0.62 + sin(t * 0.07) * 20,
                    y: size.height * 0.45 + cos(t * 0.09) * 16
                )

                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(colors: [
                                Color.clear,
                                Color.purple.opacity(0.15),
                                Color.pink.opacity(0.08),
                                Color.clear
                            ], center: .center, startRadius: 0, endRadius: bhSize * 0.9)
                        )
                        .frame(width: bhSize * 2.0, height: bhSize * 0.9)
                        .blur(radius: 24)
                        .offset(x: center.x - size.width/2, y: center.y - size.height/2)
                        .scaleEffect(x: 1.6, y: 0.55, anchor: .center)
                        .rotationEffect(.degrees(sin(t * 12) * 2))

                    Circle()
                        .strokeBorder(
                            AngularGradient(colors: [Color.cyan, Color.purple, Color.pink, Color.cyan],
                                            center: .center),
                            lineWidth: 2.2
                        )
                        .frame(width: bhSize * 1.8, height: bhSize * 0.78)
                        .blur(radius: 0.5)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.25), lineWidth: 0.5)
                                .frame(width: bhSize * 1.8, height: bhSize * 0.78)
                        )
                        .offset(x: center.x - size.width/2, y: center.y - size.height/2)
                        .scaleEffect(x: 1.5, y: 0.5, anchor: .center)
                        .rotationEffect(.degrees(t * 6))

                    Circle()
                        .fill(
                            RadialGradient(colors: [Color.black, Color.black.opacity(0.95), .clear],
                                           center: .center, startRadius: 0, endRadius: bhSize * 0.24)
                        )
                        .frame(width: bhSize * 0.5, height: bhSize * 0.5)
                        .offset(x: center.x - size.width/2, y: center.y - size.height/2)
                        .shadow(color: .black, radius: 20)
                }
                .compositingGroup()
                .blendMode(.plusLighter)
            }
            .allowsHitTesting(false)
        }
    }
}

private struct OrbitsLayer: View {
    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            ZStack {
                ForEach(0..<4) { i in
                    let w = min(size.width, size.height) * (0.55 + CGFloat(i) * 0.12)
                    let h = w * (0.45 + CGFloat(i) * 0.05)
                    RoundedRectangle(cornerRadius: w)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        .frame(width: w, height: h)
                        .rotationEffect(.degrees(Double(i) * 12))
                        .offset(x: size.width * 0.05, y: size.height * -0.05)
                }
            }
        }
        .allowsHitTesting(false)
    }
}

fileprivate struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { self.state = seed == 0 ? 0x123456789ABCDEF : seed }
    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}

private func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint { CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y) }
private func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint { CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y) }
private func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint { CGPoint(x: lhs.x * rhs, y: lhs.y * rhs) }