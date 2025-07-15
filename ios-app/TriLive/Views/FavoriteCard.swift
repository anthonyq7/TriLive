import SwiftUI

// A card showing a favorited route at a given stop, with a remove button.
struct FavoriteCard: View {
    let parentStop: Stop
    let route: Route
    let onRemove: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Text("\(route.routeId)")
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .font(.headline)
                .foregroundColor(.white)
                .padding(10)
                .background(Color(route.routeColor))
                .clipShape(Circle())
                .frame(width: 54, height: 54)


            VStack(alignment: .leading, spacing: 4) {
                Text(route.routeName)
                    .font(.headline)
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.leading)

                Text(route.status)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.95)
                    .multilineTextAlignment(.leading)
            }
            .layoutPriority(1)

            Spacer()

            VStack(alignment: .trailing, spacing: 12) {
                // show stop’s name
                Text(parentStop.name)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .frame(width: 100, alignment: .trailing)

                Button(action: onRemove) {
                    Image(systemName: "star.fill")
                        .font(.title2)
                        .foregroundColor(.yellow)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Remove favorite \(route.routeName) from \(parentStop.name)")
                .accessibilityAddTraits(.isButton)
            }
            .padding()
        }
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

    let sampleStop = Stop(
        id:   1,
        name: "Main St & 3rd Ave",
        lon:  -122.6587,
        lat:   45.5120
    )
    // sample Route
    let sampleRoute = Route(
        stopId: 2,
        routeId:    10,
        routeName: "10 – Downtown",
        status:     "IN_SERVICE",
        eta:        "5",
        routeColor: "green"
    )

    FavoriteCard(
        parentStop: sampleStop,
        route:      sampleRoute,
        onRemove:   { print("Removed!") }
    )
    .preferredColorScheme(.dark)
}
