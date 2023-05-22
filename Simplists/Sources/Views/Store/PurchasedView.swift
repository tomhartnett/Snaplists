//
//  PurchasedView.swift
//  Simplists
//
//  Created by Tom Hartnett on 2/6/21.
//

import SwiftUI

struct PurchasedView: View {
    var body: some View {
        VStack {
            Text("Purchased")
                .foregroundColor(Color.red)
                .font(.title)
                .padding(.top, 10)
            Text("Thank you!")
                .foregroundColor(.primary)
                .padding([.bottom, .leading, .trailing], 10)
        }
        .frame(width: 250)
        .background(Color(UIColor.systemBackground))
        .border(.red, width: 5)
        .rotationEffect(.degrees(-20))
    }
}

struct PurchasedView_Previews: PreviewProvider {
    static var previews: some View {
        PurchasedView()
    }
}
