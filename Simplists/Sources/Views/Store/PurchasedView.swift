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
                .font(.title)
                .padding(.top, 10)
            Text("Thank you!")
                .foregroundColor(.primary)
                .padding([.bottom, .leading, .trailing], 10)
        }
        .frame(minWidth: 250)
        .background(Color(UIColor.systemBackground))
        .foregroundColor(Color.red)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.red, lineWidth: 5)
        )
        .rotationEffect(.degrees(-15))
    }
}

struct PurchasedView_Previews: PreviewProvider {
    static var previews: some View {
        PurchasedView()
    }
}
