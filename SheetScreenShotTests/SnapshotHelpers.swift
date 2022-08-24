import XCTest
import SwiftUI
import UIKit

extension XCTestCase {
    func recordSnapshot<V: View>(
        for view: V,
        named name: String,
        using configuration: SnapshotConfiguration,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let snapshotURL = makeSnapshotURL(file: file, name: name)
        let snapshot = view.snapshotFromKeyWindow(for: configuration)
        let snapshotData = makeSnapshotData(from: snapshot, file: file, line: line)
        do {
            try FileManager.default.createDirectory(
                at: snapshotURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try snapshotData?.write(to: snapshotURL)
        } catch {
            XCTFail("Failed to save snapshot with error \(error)", file: file, line: line)
        }
    }

    func assertSnapshot<V: View>(
        for view: V,
        named name: String,
        using configuration: SnapshotConfiguration,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let snapshotURL = makeSnapshotURL(file: file, name: name)
        let snapshot = view.snapshot(for: configuration)
        let snapshotData = makeSnapshotData(from: snapshot, file: file, line: line)

        guard let storedSnapshotData = try? Data(contentsOf: snapshotURL) else {
            XCTFail(
                "Unable to read PNG data from the snapshot url \(snapshotURL), use the record method before asserting.",
                file: file,
                line: line
            )
            return
        }

        if snapshotData != storedSnapshotData {
            let temporarySnapshotURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                .appendingPathComponent(snapshotURL.lastPathComponent)

            try? snapshotData?.write(to: temporarySnapshotURL)
            XCTFail(
                "Snapshots do not match. New snapshot URL: \(temporarySnapshotURL) Stored snapshot URL: \(snapshotURL)",
                file: file,
                line: line
            )
        }
    }
}

struct SnapshotConfiguration {
    let size: CGSize
    let safeAreaInsets: UIEdgeInsets
    let layoutMargins: UIEdgeInsets
    let traitCollection: UITraitCollection

    static func iPhone8(style: UIUserInterfaceStyle) -> SnapshotConfiguration {
        .init(
            size: .init(width: 375, height: 667),
            safeAreaInsets: .init(top: 20, left: 0, bottom: 0, right: 0),
            layoutMargins: .init(top: 20, left: 16, bottom: 0, right: 16),
            traitCollection: .init(
                traitsFrom: [
                    .init(forceTouchCapability: .available),
                    .init(layoutDirection: .leftToRight),
                    .init(preferredContentSizeCategory: .medium),
                    .init(userInterfaceIdiom: .phone),
                    .init(horizontalSizeClass: .compact),
                    .init(verticalSizeClass: .regular),
                    .init(displayScale: 2),
                    .init(displayGamut: .P3),
                    .init(userInterfaceStyle: style)
                ]
            )
        )
    }
}

// MARK: - helpers

private final class SnapshotWindow: UIWindow {
    private var configuration: SnapshotConfiguration = .iPhone8(style: .light)

    convenience init(configuration: SnapshotConfiguration, root: UIViewController) {
        self.init(frame: .init(origin: .zero, size: configuration.size))
        self.configuration = configuration
        self.layoutMargins = configuration.layoutMargins
        self.rootViewController = root
        self.isHidden = false
        root.view.layoutMargins = configuration.layoutMargins
        makeKeyAndVisible()
    }

    override var safeAreaInsets: UIEdgeInsets { configuration.safeAreaInsets }

    override var traitCollection: UITraitCollection {
        .init(traitsFrom: [super.traitCollection, configuration.traitCollection])
    }

    func snapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds, format: .init(for: traitCollection))
        return renderer.image { action in
            layer.render(in: action.cgContext)
        }
    }
}

private extension View {
    func snapshot(for configuration: SnapshotConfiguration) -> UIImage {
        let root = UIHostingController(rootView: self)
        root.loadView()
        root.viewWillLayoutSubviews()
        root.becomeFirstResponder()
        return SnapshotWindow(configuration: configuration, root: root).snapshot()
    }
}

private extension XCTestCase {
    private func makeSnapshotData(from snapshot: UIImage, file: StaticString, line: UInt) -> Data? {
        guard let snapshotData = snapshot.pngData() else {
            XCTFail("Unable to generate PNG data from the snapshot", file: file, line: line)
            return nil
        }
        return snapshotData
    }

    private func makeSnapshotURL(file: StaticString, name: String) -> URL {
        URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(name).png")
    }
}

private extension View {
    func snapshotFromKeyWindow(for configuration: SnapshotConfiguration) -> UIImage {
        let root = UIHostingController(rootView: self)
        let keyWindow = (UIApplication.shared.connectedScenes.first as! UIWindowScene).keyWindow!
        keyWindow.rootViewController = root

        RunLoop.current.run(until: Date())

        let renderer = UIGraphicsImageRenderer(bounds: keyWindow.bounds, format: .init(for: keyWindow.traitCollection))
        return renderer.image { action in
            keyWindow.layer.render(in: action.cgContext)
        }
    }
}
