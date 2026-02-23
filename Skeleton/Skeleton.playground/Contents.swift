//
//  CKSkeleton.swift
//  ChronoPackages
//
//  Created by Pascale Beaulac on 2026-02-21.
//

import SwiftUI
import Foundation
import PlaygroundSupport

// MARK: - CKShimmer modifier

/// A shimmer effect: a bright highlight that sweeps left-to-right over the view.
/// - Parameters:
///   - tint: Base color of the shimmer highlight. Defaults to white.
///   - bandWidth: Width of the bright band as a fraction of the view width (0…1). Defaults to 0.4.
///   - angle: Angle of the gradient band. Defaults to 70°.
///   - duration: Duration of one sweep. Defaults to 1.4s.
@available(macOS 12.0, *)
public struct CKShimmer: ViewModifier {

    @State private var phase: CGFloat = -1

    private let tint: Color
    private let bandWidth: CGFloat
    private let angle: Angle
    private let duration: Double

    public init(
        tint: Color = .white,
        bandWidth: CGFloat = 0.4,
        angle: Angle = .degrees(70),
        duration: Double = 1.4
    ) {
        self.tint = tint
        self.bandWidth = bandWidth
        self.angle = angle
        self.duration = duration
    }

    public func body(content: Content) -> some View {
        content.overlay {
            GeometryReader { geo in
                let gradient = LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0),
                        .init(color: tint.opacity(0.6), location: 0.5 - bandWidth / 2),
                        .init(color: tint.opacity(0.9), location: 0.5),
                        .init(color: tint.opacity(0.6), location: 0.5 + bandWidth / 2),
                        .init(color: .clear, location: 1),
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )

                Rectangle()
                    .fill(gradient)
                    .rotationEffect(angle, anchor: .center)
                    .scaleEffect(x: 2.5)
                    .offset(x: phase * geo.size.width)
                    .blendMode(.screen)
            }
            .clipped()
        }
        .onAppear {
            withAnimation(
                .linear(duration: duration)
                .repeatForever(autoreverses: false)
            ) {
                phase = 1
            }
        }
    }
}

@available(macOS 12.0, *)
public extension View {
    func shimmer(
        tint: Color = .white,
        bandWidth: CGFloat = 0.4,
        angle: Angle = .degrees(70),
        duration: Double = 1.4
    ) -> some View {
        modifier(CKShimmer(tint: tint, bandWidth: bandWidth, angle: angle, duration: duration))
    }
}

// MARK: - CKSkeleton modifier

@available(macOS 12.0, *)
public struct CKSkeleton: ViewModifier {

    @State private var isAnimating = false

    private let color: Color
    private let highOpacity: Double
    private let lowOpacity: Double
    private let animationDuration: Double

    public init(
        color: Color = .secondary,
        highOpacity: Double = 0.95,
        lowOpacity: Double = 0.5,
        animationDuration: Double = 1.1
    ) {
        self.color = color
        self.highOpacity = highOpacity
        self.lowOpacity = lowOpacity
        self.animationDuration = animationDuration
    }

    public func body(content: Content) -> some View {
        content
            .overlay {
                color.opacity(isAnimating ? lowOpacity : highOpacity)
            }
            .mask { content }
            .environment(\.skeletonColor, color)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: animationDuration)
                    .repeatForever(autoreverses: true)
                ) {
                    isAnimating = true
                }
            }
    }
}

@available(macOS 12.0, *)
public extension View {
    func skeleton(
        color: Color = .white,
        highOpacity: Double = 0.95,
        lowOpacity: Double = 0.5,
        animationDuration: Double = 1.1
    ) -> some View {
        modifier(CKSkeleton(
            color: color,
            highOpacity: highOpacity,
            lowOpacity: lowOpacity,
            animationDuration: animationDuration
        ))
    }
}

// MARK: - Skeleton environment keys

private struct CKSkeletonRowHeightKey: EnvironmentKey {
    static let defaultValue: CGFloat = 20
}

private struct CKSkeletonColorKey: EnvironmentKey {
    static let defaultValue: Color = .secondary
}

@available(macOS 12.0, *)
public extension EnvironmentValues {
    /// The height allocated to each skeleton row, computed from the card's available height.
    var skeletonRowHeight: CGFloat {
        get { self[CKSkeletonRowHeightKey.self] }
        set { self[CKSkeletonRowHeightKey.self] = newValue }
    }

    /// The base color used by skeleton shapes in this card.
    var skeletonColor: Color {
        get { self[CKSkeletonColorKey.self] }
        set { self[CKSkeletonColorKey.self] = newValue }
    }
}

// MARK: - CKSkeletonAccentBar

/// Describes a decorative accent bar shown on a side of a `CKSkeletonCard`.
@available(macOS 12.0, *)
public struct CKSkeletonAccentBar {
    public enum Side { case leading, trailing }

    public let side: Side
    public let width: CGFloat
    /// If `nil`, the bar uses the same color as the skeleton elements.
    public let color: Color?

    public init(side: Side = .leading, width: CGFloat = 8, color: Color? = nil) {
        self.side = side
        self.width = width
        self.color = color
    }
}

// MARK: - PartiallyRoundedRectangle

/// A rectangle with independently controlled per-corner radii, compatible with all OS versions.
private struct PartiallyRoundedRectangle: Shape {
    var topLeading: CGFloat = 0
    var topTrailing: CGFloat = 0
    var bottomLeading: CGFloat = 0
    var bottomTrailing: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let tl = min(topLeading,     rect.width / 2, rect.height / 2)
        let tr = min(topTrailing,    rect.width / 2, rect.height / 2)
        let bl = min(bottomLeading,  rect.width / 2, rect.height / 2)
        let br = min(bottomTrailing, rect.width / 2, rect.height / 2)

        path.move(to: CGPoint(x: rect.minX + tl, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - tr, y: rect.minY))
        path.addArc(center: CGPoint(x: rect.maxX - tr, y: rect.minY + tr),
                    radius: tr, startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - br))
        path.addArc(center: CGPoint(x: rect.maxX - br, y: rect.maxY - br),
                    radius: br, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX + bl, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.minX + bl, y: rect.maxY - bl),
                    radius: bl, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + tl))
        path.addArc(center: CGPoint(x: rect.minX + tl, y: rect.minY + tl),
                    radius: tl, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        path.closeSubpath()
        return path
    }
}

// MARK: - CKSkeletonCard

/// A skeleton card whose rows are fully customisable via a `@ViewBuilder` closure.
///
/// Each row receives the row index and should return a horizontal arrangement of shapes.
/// The height of each row is distributed evenly across the card's available height,
/// accounting for padding (16pt) and inter-row spacing (8pt).
/// Read `@Environment(\.skeletonRowHeight)` inside the closure to size your shapes.
///
/// Example:
/// ```swift
/// CKSkeletonCard(rows: 3) { _ in
///     Circle().frame(width: 40, height: 40).skeleton()
///     RoundedRectangle(cornerRadius: 6).frame(width: 120, height: 14).skeleton()
///     Spacer()
///     RoundedRectangle(cornerRadius: 6).frame(width: 50, height: 14).skeleton()
/// }
/// ```
@available(macOS 12.0, *)
public struct CKSkeletonCard<Row: View>: View {

    static var rowSpacing: CGFloat { 8 }
    static var padding: CGFloat { 16 }

    @Environment(\.skeletonColor) private var skeletonColor

    private let rows: Int
    private let cardBackground: Color
    private let accentBar: CKSkeletonAccentBar?
    private let rowBuilder: (Int) -> Row

    /// - Parameters:
    ///   - rows: Number of rows inside the card.
    ///   - cardBackground: Background color of the card.
    ///   - accentBar: Optional decorative bar on a side of the card. Pass `nil` for none.
    ///   - rowContent: A `@ViewBuilder` closure called once per row index.
    public init(
        rows: Int = 3,
        cardBackground: Color = .white,
        accentBar: CKSkeletonAccentBar? = nil,
        @ViewBuilder rowContent: @escaping (Int) -> Row
    ) {
        self.rows = max(rows, 1)
        self.cardBackground = cardBackground
        self.accentBar = accentBar
        self.rowBuilder = rowContent
    }

    public var body: some View {
        GeometryReader { geo in
            let n = CGFloat(rows)
            let rowHeight = (geo.size.height - Self.padding * 2 - Self.rowSpacing * (n - 1)) / n

            ZStack(alignment: .leading) {
                // Card content
                VStack(alignment: .leading, spacing: Self.rowSpacing) {
                    ForEach(0..<rows, id: \.self) { i in
                        HStack(alignment: .center, spacing: 8) {
                            rowBuilder(i)
                        }
                        .frame(height: rowHeight)
                    }
                }
                .padding(Self.padding)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Accent bar — reads skeletonColor from environment set by .skeleton() modifiers
                if let bar = accentBar {
                    let barColor = bar.color ?? skeletonColor
                    Rectangle()
                        .fill(barColor)
                        .frame(width: bar.width)
                        .frame(maxHeight: .infinity)
                        .frame(
                            maxWidth: .infinity,
                            alignment: bar.side == .leading ? .leading : .trailing
                        )
                        .clipShape(
                            bar.side == .leading
                            ? PartiallyRoundedRectangle(topLeading: 12, bottomLeading: 12)
                            : PartiallyRoundedRectangle(topTrailing: 12, bottomTrailing: 12)
                        )
                }
            }
        }
        .background(cardBackground)
        .cornerRadius(12)
        .skeleton()
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
    }

}

// MARK: - CKSkeletonList

/// A list of identical skeleton cards built from the same row closure.
/// - Parameters:
///   - cards: Number of cards to display.
///   - rows: Number of rows inside each card.
///   - cardBackground: Background color of each card.
///   - rowContent: A `@ViewBuilder` closure called once per row index.
@available(macOS 12.0, *)
public struct CKSkeletonList<Row: View>: View {

    private let cards: Int
    private let rows: Int
    private let cardHeight: CGFloat
    private let cardBackground: Color
    private let rowBuilder: (Int) -> Row

    /// - Parameters:
    ///   - cards: Number of cards to display.
    ///   - rows: Number of rows inside each card.
    ///   - cardHeight: Fixed height for each card. Row heights are derived from this value.
    ///   - cardBackground: Background color of each card.
    ///   - rowContent: A `@ViewBuilder` closure called once per row index.
    public init(
        cards: Int = 3,
        rows: Int = 3,
        cardHeight: CGFloat = 100,
        cardBackground: Color = .white,
        @ViewBuilder rowContent: @escaping (Int) -> Row
    ) {
        self.cards = cards
        self.rows = rows
        self.cardHeight = cardHeight
        self.cardBackground = cardBackground
        self.rowBuilder = rowContent
    }

    public var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<cards, id: \.self) { _ in
                CKSkeletonCard(rows: rows, cardBackground: cardBackground, rowContent: rowBuilder)
                    .frame(height: cardHeight)
            }
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Playground Live View

@available(macOS 12.0, *)
struct PreviewView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Text("CKSkeletonCard").font(.headline)
                CKSkeletonCard(
                    rows: 3,
                    cardBackground: Color(nsColor: .white),
                    accentBar: CKSkeletonAccentBar(side: .leading, width: 8, color: .accentColor)
                ) { rowIndex in
                    switch rowIndex {
                    case 0:
                        Circle()
                            .frame(width: 14, height: 14)
                            .skeleton(color: Color(nsColor: .systemGray))
                        RoundedRectangle(cornerRadius: 6)
                            .frame(width: 180)
                            .skeleton(color: Color(nsColor: .systemGray))
                        Spacer()
                    case 1:
                        RoundedRectangle(cornerRadius: 6)
                            .frame(width: 140)
                            .skeleton(color: Color(nsColor: .systemGray))
                        Spacer()
                    default:
                        Spacer()
                        RoundedRectangle(cornerRadius: 6)
                            .frame(width: 80)
                            .skeleton(color: Color(nsColor: .systemGray))
                    }
                }
                .frame(height: 100)
                .padding(.horizontal)

                Text("CKSkeletonList").font(.headline)
                CKSkeletonList(
                    cards: 3,
                    rows: 3,
                    cardHeight: 100,
                    cardBackground: Color(nsColor: .white)
                ) { rowIndex in
                    switch rowIndex {
                    case 0:
                        Circle()
                            .frame(width: 14, height: 14)
                            .skeleton(color: Color(nsColor: .systemGray))
                        RoundedRectangle(cornerRadius: 6)
                            .frame(width: 180)
                            .skeleton(color: Color(nsColor: .systemGray))
                        Spacer()
                    case 1:
                        RoundedRectangle(cornerRadius: 6)
                            .frame(width: 140)
                            .skeleton(color: Color(nsColor: .systemGray))
                        Spacer()
                    default:
                        Spacer()
                        RoundedRectangle(cornerRadius: 6)
                            .frame(width: 80)
                            .skeleton(color: Color(nsColor: .systemGray))
                    }
                }
                .shadow(radius: 0.3)
                .padding(.vertical)
            }
            .padding()
        }
        .frame(width: 375, height: 700)
        .background(Color(nsColor: .controlBackgroundColor))
    }
}

if #available(macOS 12.0, *) {
    PlaygroundPage.current.setLiveView(PreviewView())
}

