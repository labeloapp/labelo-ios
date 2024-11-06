import ComposableArchitecture
import Testing
@testable import Labelo
// This import is needed so the test target pick ups the tests
// without it bazel doesn't seem to see the tests annotated with @Tests
// TODO: Research
import XCTest


@Suite("AppFeature")
@MainActor
struct AppFeatureTests {
    @Test
    func testTabBar() async throws {
        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        }

        await store.send(.selectTab(.settings)) {
            $0.selectedTab = .settings
        }

        await store.send(.selectTab(.list)) {
            $0.selectedTab = .list
        }
    }
}
