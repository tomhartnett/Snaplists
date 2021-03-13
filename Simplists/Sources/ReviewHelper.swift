//
//  ReviewHelper.swift
//  Simplists
//
//  Created by Tom Hartnett on 3/12/21.
//

import Foundation
import StoreKit

class ReviewHelper {
    static func requestReview(event: ReviewEvent) {
        var count = UserDefaults.standard.integer(forKey: event.userDefaultsKey)
        count += 1
        UserDefaults.standard.set(count, forKey: event.userDefaultsKey)

        if count >= event.promptThreshold {
            UserDefaults.standard.set(0, forKey: event.userDefaultsKey)

            DispatchQueue.main.async {
                if let scene = UIApplication.shared.connectedScenes.first(where: {
                    $0.activationState == .foregroundActive
                }) as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                }
            }
        }
    }
}

extension ReviewHelper {
    enum ReviewEvent {
        case itemMarkedComplete

        var userDefaultsKey: String {
            switch self {
            case .itemMarkedComplete:
                return "ReviewEvent-ItemMarkedComplete"
            }
        }

        var promptThreshold: Int {
            switch self {
            case .itemMarkedComplete:
                return 10
            }
        }
    }
}
