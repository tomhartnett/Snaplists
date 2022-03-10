//
//  OpenURLState.swift
//  Simplists
//
//  Created by Tom Hartnett on 3/9/22.
//

import Combine
import Foundation

public final class OpenURLState: ObservableObject {
    @Published var selectedListID: UUID? = nil
}
