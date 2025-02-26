import ComposableArchitecture
import SwiftUI

@Reducer
struct Preferences {
    @CasePathable
    enum Action: BindableAction {
        case dummy
        case binding(BindingAction<State>)
    }

    @ObservableState
    struct State {}

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { _, _ in
            .none
        }
    }
}
