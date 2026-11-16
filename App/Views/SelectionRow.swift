import FamilyControls
import ManagedSettings
import SwiftUI

/// A button that opens Apple's app picker, plus icons of what's selected.
struct SelectionRow: View {
    let title: String
    @Binding var selection: FamilyActivitySelection
    @State private var isPickerPresented = false

    var body: some View {
        Button {
            isPickerPresented = true
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(title).foregroundStyle(.primary)
                    Spacer()
                    Text(selection.summary).foregroundStyle(.secondary)
                    Image(systemName: "chevron.right").font(.caption).foregroundStyle(.tertiary)
                }
                if !selection.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(Array(selection.applicationTokens), id: \.self) { token in
                                Label(token).labelStyle(.iconOnly)
                            }
                            ForEach(Array(selection.categoryTokens), id: \.self) { token in
                                Label(token).labelStyle(.iconOnly)
                            }
                            ForEach(Array(selection.webDomainTokens), id: \.self) { token in
                                Label(token).labelStyle(.iconOnly)
                            }
                        }
                    }
                }
            }
        }
        .familyActivityPicker(isPresented: $isPickerPresented, selection: $selection)
    }
}
