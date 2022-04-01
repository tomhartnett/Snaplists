//
//  OpenURLContext.swift
//  Simplists
//
//  Created by Tom Hartnett on 3/9/22.
//

import Combine
import Foundation

public final class OpenURLContext: ObservableObject {
    @Published var selectedListID: UUID?
}
