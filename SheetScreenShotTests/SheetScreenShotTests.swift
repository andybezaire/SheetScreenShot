import XCTest
import SwiftUI

class SheetScreenShotTests: XCTestCase {
    func test_() {
        let view = NavigationView {
            Text("Hello, World!")
                .navigationTitle("Welcome")
                .sheet(isPresented: .constant(true)) {
                    Text("I should be on top")
                }
        }
            .preferredColorScheme(.light)

        recordSnapshot(for: view, named: "PresentingSheet", using: .iPhone8(style: .light))

        let viewDark = NavigationView {
            Text("Hello, World!")
                .navigationTitle("Welcome")
                .sheet(isPresented: .constant(true)) {
                    Text("I should be on top")
                }
        }
            .preferredColorScheme(.dark)

    recordSnapshot(for: viewDark, named: "PresentingSheetDark", using: .iPhone8(style: .light))

    }

    func test_moreComplex() {
        let view = MainContentView(isShowingSheet: .constant(true)) {
            Text("Hello, World")
        } sheet: {
            Text("I should be on top")
        }
            .preferredColorScheme(.light)

        let viewDark = MainContentView(isShowingSheet: .constant(true)) {
            Text("Hello, World")
        } sheet: {
            Text("I should be on top")
        }
            .preferredColorScheme(.dark)

        recordSnapshot(for: view, named: "MoreComplexLight", using: .iPhone8(style: .light))
        recordSnapshot(for: viewDark, named: "MoreComplexDark", using: .iPhone8(style: .light))

    }
}

struct MainContentView<Content, Sheet>: View where Content: View, Sheet: View {
    @Binding var isShowingSheet: Bool
    let content: () -> Content
    let sheet: () -> Sheet

    var body: some View {
        content()
        .sheet(isPresented: $isShowingSheet) {
            sheet()
        }
    }
}
