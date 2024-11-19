//
// Bitmovin Player iOS SDK
// Copyright (C) 2024, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import SwiftUI

internal struct FillWidth: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .frame(minWidth: 0, maxWidth: .infinity)
    }
}

internal struct FillHeight: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .frame(minHeight: 0, maxHeight: .infinity)
    }
}

internal extension View {
    func fillWidth() -> some View {
        return self.modifier(FillWidth())
    }

    func fillHeight() -> some View {
        return self.modifier(FillHeight())
    }

    func fillSpace() -> some View {
        return self
            .modifier(FillWidth())
            .modifier(FillHeight())
    }
}
