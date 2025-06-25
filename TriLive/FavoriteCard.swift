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
        HStack(alignment: .center, spacing: 16) {
            // Route badge
            Text(route.isMAX ? "MAX" : "\(route.id)")
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .font(.headline)
                .foregroundColor(.white)
                .padding(10)
                .background(route.isMAX ? Color.blue : Color.green)
                .clipShape(Circle())
                .scaledToFill()
                .frame(width: 54, height: 54)
            
            // Route name
            VStack(alignment: .leading, spacing: 4) {
                Text(route.name)
                    .font(.headline)
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.leading)
                
                Text(route.direction)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.95)
                    .multilineTextAlignment(.leading)
            }
            .layoutPriority(1)
            
            Spacer()
            
            // Stop info
            VStack(alignment: .trailing, spacing: 12){
                Text("Stop \(parentStop.id)")
                    .font(.subheadline)
                    .lineLimit(1)
                    .foregroundColor(.white)
                    .frame(width: 65)
                    
                
                // Remove favorite button
                Button(action: onRemove) {
                    Image(systemName: "star.fill")
                        .font(.title2)
                        .foregroundColor(.yellow)
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.primary.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white, lineWidth: 2)
        )
        .cornerRadius(12)
        
    }
}

#Preview {
    FavoriteCard(
        parentStop: stops[0],
        route: stops[0].routeList[0],
        onRemove: {}
    )
    .preferredColorScheme(.dark)
}
