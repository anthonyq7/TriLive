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
    let isFavorited: Bool
    let onTap: () -> Void
    let onFavoriteTapped: () -> Void
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            //route badge
            Text("\(line.routeId)")
                .font(.headline)
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding(10)
                .background(Color(colorFromHex(line.routeColor)))
                .clipShape(Circle())
                .scaledToFill()
                .frame(width: 54, height: 54)
            
            //route name & stop info
            VStack(alignment: .leading, spacing: 2) {
                Text(line.routeName)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("Stop: \(parentStop.name)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            .layoutPriority(1)
            
            Spacer()
            
            //ETA & favorite button
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(line.eta) min")
                    .font(.headline)
                    .foregroundColor(.green)
                    .lineLimit(1)
                    .frame(width: 80)
                
                /*
                Button(action: onFavoriteTapped) {
                    Image(systemName: isFavorited ? "star.fill" : "star")
                        .foregroundColor(isFavorited ? .yellow : .white)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 12)*/
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .frame(minWidth: 80, alignment: .topTrailing)
        .background(isSelected
                    ? Color.accentColor.opacity(0.3)
                    : Color.black.opacity(0.8)
        )
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.5), radius: isSelected ? 6 : 2)
        .onTapGesture(perform: onTap)
    }
}

func colorFromHex(_ hex: String) -> Color {
    let sanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int: UInt64 = 0
    Scanner(string: sanitized).scanHexInt64(&int)
    
    let a, r, g, b: Double
    switch sanitized.count {
        
    case 6:
        a = 1.0
        r = Double((int >> 16) & 0xFF) / 255.0
        g = Double((int >> 8) & 0xFF)  / 255.0
        b = Double(int & 0xFF)         / 255.0
        
    default:
        
        return Color.gray
    }
    
    return Color(.sRGB, red: r, green: g, blue: b, opacity: a)
}



/*
 struct RouteCard_Previews: PreviewProvider {
 static var previews: some View {
 let sampleStop = Stop(
 stopId:      1001,
 name:        "Main St & 1st Ave",
 dir:         "Northbound",
 lon:         -122.662345,
 lat:         45.512789,
 dist:        0,
 description: nil
 )
 let sampleRoute = Route(
 stopId:     sampleStop.stopId,
 routeId:    77,
 routeName:  "77 – Broadway",
 status:     "IN_SERVICE",
 eta:        "5",
 routeColor: "green",
 eta_unix:   1_673_324_320
 )
 
 RouteCard(
 parentStop:      sampleStop,
 line:            sampleRoute,
 isSelected:      false,
 isFavorited:     false,
 onTap:           { /* highlight or navigate */ },
 onFavoriteTapped: { /* toggle favorite & switch tab */ }
 )
 .padding()
 .previewLayout(.sizeThatFits)
 }
 }*/
