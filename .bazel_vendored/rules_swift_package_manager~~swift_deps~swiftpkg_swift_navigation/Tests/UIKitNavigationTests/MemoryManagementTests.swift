#if canImport(UIKit) && !os(watchOS)
  import UIKitNavigation
  import XCTest

  @available(iOS 14, tvOS 14, *)
  final class MemoryManagementTests: XCTestCase {
    @MainActor
    func testPresentIsPresented_ObservationDoesNotRetainModel() {
      weak var weakModel: Model?
      do {
        @UIBindable var model = Model()
        weakModel = model
        let vc = UIViewController()
        vc.present(isPresented: $model.isPresented) { UIViewController() }
      }
      XCTAssertNil(weakModel)
    }

    @MainActor
    func testPresentItem_ObservationDoesNotRetainModel() {
      weak var weakModel: Model?
      do {
        @UIBindable var model = Model()
        weakModel = model
        let vc = UIViewController()
        vc.present(item: $model.child) { _ in UIViewController() }
      }
      XCTAssertNil(weakModel)
    }

    @MainActor
    func testBinding_ObservationDoesNotRetainModel() {
      weak var weakModel: Model?
      do {
        @UIBindable var model = Model()
        weakModel = model
        let textField = UITextField(text: $model.text)
        observe {
          _ = textField
        }
      }
      XCTAssertNil(weakModel)
    }

    @MainActor
    func testNavigationStackController_ObservationDoesNotRetainModel() {
      #if swift(>=5.10)
        weak nonisolated(unsafe) var weakModel: Model?
      #else
        weak var weakModel: Model?
      #endif
      do {
        @UIBindable var model = Model()
        weakModel = model
        let vc = NavigationStackController(path: $model.path) { UIViewController() }
        _ = vc.view!
      }
      XCTAssertNil(weakModel)
    }
  }

  @Perceptible
  private final class Model: Identifiable {
    var isPresented = false
    var child: Model? = nil
    var path = UINavigationPath()
    var text = ""
  }
#endif
