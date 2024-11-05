import SwiftUI
import ComposableArchitecture

@main
struct LabeloApp: App {
    var body: some Scene {
        WindowGroup {
            AppView(
                store: Store(
                    initialState: AppFeature.State(),
                    reducer: {
                        AppFeature()
#if DEBUG
                            ._printChanges()
#endif
                    })
            )
        }
    }
}




