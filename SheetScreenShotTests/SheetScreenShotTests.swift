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

        recordSnapshot(for: view, named: "PresentingSheet", using: .iPhone8(style: .light))
    }
}
