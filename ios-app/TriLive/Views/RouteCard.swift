//
//  RouteCard.swift
//  TriLive
//
//  Created by Anthony Qin on 6/16/25.
//

import SwiftUI

struct RouteCard: View {
    let parentStop: Stop
    let line: Route
    let isSelected: Bool
    let onTap: () -> Void
    let isFavorited: Bool
    let toggleFavorite: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            // route badge
            Text(line.isMAX ? "MAX" : "\(line.id)")
                .font(.headline)
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding(10)
                .background(line.isMAX ? Color.blue : Color.green)
                .clipShape(Circle())
                .scaledToFill()
                .frame(width: 54, height: 54)

            // route ID and stop info
            VStack(alignment: .leading, spacing: 2) {
                // big route number
                Text("\(line.id)")
                    .font(.headline)
                    .foregroundColor(.white)

                // stop name as subtitle
                Text("Stop: \(parentStop.name)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            .layoutPriority(1)

            Spacer()

            // arrival time & favorite button
            VStack(alignment: .trailing, spacing: 4) {
                Text(line.formattedMinutesRemaining)
                    .font(.headline)
                    .foregroundColor(.green)
                    .lineLimit(1)
                    .frame(width: 80)

                Button(action: toggleFavorite) {
                    Image(systemName: isFavorited ? "star.fill" : "star")
                        .foregroundColor(isFavorited ? .yellow : .white)
                }
                .buttonStyle(.plain)
            }
            .frame(minWidth: 80, alignment: .topTrailing)
        }
        .padding()
        .background(isSelected
            ? Color.accentColor.opacity(0.3)
            : Color.black.opacity(0.8)
        )
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.5), radius: isSelected ? 6 : 2)
        .onTapGesture(perform: onTap)
    }
}

struct RouteCard_Previews: PreviewProvider {
    static var previews: some View {
        let sampleStop = Stop(
            id:          1,
            name:        "NE Broadway & 21st",
            latitude:    45.5120,
            longitude:   -122.6587,
            description: "Near Broadway",
            trimetID:    123456
        )
        let sampleRoute = Route(
            id:           77,
            name:         "",
            arrivalTime:  Int(Date().timeIntervalSince1970) + 300,
            direction:    "",
            realTime:     Int(Date().timeIntervalSince1970) + 300,
            isMAX:        false
        )

        RouteCard(
            parentStop:   sampleStop,
            line:         sampleRoute,
            isSelected:   false,
            onTap:        {},
            isFavorited:  false,
            toggleFavorite: {}
        )
        .padding()
        .previewLayout(.sizeThatFits)
        // dark card in both light/dark previews
    }
}
