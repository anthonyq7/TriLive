//
//  FavoriteCard.swift
//  TriLive
//
//  Created by Anthony Qin on 6/17/25.
//

import SwiftUI

struct FavoriteCard: View {
    let parentStop: Stop
    let route: Route
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            //the route badge
            Text(route.isMAX ? "MAX" : "\(route.id)")
                .font(.headline)
                .foregroundColor(.white)
                .padding(10)
                .background(route.isMAX ? Color.blue : Color.green)
                .clipShape(Circle())

            //the route name
            Text(route.name)
                .font(.body)
                .foregroundColor(.white)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()

            //stop info
            Text("Stop \(parentStop.id)")
                .font(.subheadline)
                .foregroundColor(.white)

            Spacer()

            //remove favorite button
            Button(action: onRemove) {
                Image(systemName: "star.fill")
                    .font(.title2)
                    .foregroundColor(.yellow)
            }
        }
        .padding()
        .background(Color.black)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white, lineWidth: 2)
        )
        .cornerRadius(12)
    }
}


#Preview {
    FavoriteCard(
        parentStop: dummyStop1,
        route: dummyRoutes1[0],
        onRemove: { }
    )
}
