import SwiftUI
import MapKit

struct MapDiscoveryView: View {
    @Environment(MockBackend.self) private var backend
    @State private var camera: MapCameraPosition = .region(
        MKCoordinateRegion(center: .init(latitude: 39.4690, longitude: -0.3700),
                           span: .init(latitudeDelta: 0.03, longitudeDelta: 0.03))
    )

    var body: some View {
        ZStack(alignment: .top) {
            map
            VStack(spacing: 12) {
                searchBar
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            VStack {
                Spacer()
                if let meetup = backend.selectedMeetup ?? backend.meetups.first {
                    MeetupCard(meetup: meetup)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 96)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .onAppear {
            if backend.selectedMeetupID == nil { backend.selectedMeetupID = backend.meetups.first?.id }
        }
    }

    private var map: some View {
        Map(position: $camera) {
            ForEach(backend.meetups) { m in
                Annotation(m.title, coordinate: m.coordinate) {
                    MeetupPin(meetup: m, selected: m.id == backend.selectedMeetupID) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            backend.selectMeetup(m.id)
                        }
                    }
                }
            }
        }
        .mapStyle(.standard(pointsOfInterest: .excludingAll))
        .ignoresSafeArea()
        .tint(AuraColor.primary)
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass").foregroundStyle(AuraColor.onSurfaceVariant)
                Text("Find gatherings near you...")
                    .font(AuraFont.bodyMd()).foregroundStyle(AuraColor.onSurfaceVariant)
                Spacer()
            }
            .padding(.horizontal, 16).padding(.vertical, 14)
            .background(AuraColor.containerLowest, in: Capsule())
            .auraCardShadow()

            Image(systemName: "slider.horizontal.3")
                .foregroundStyle(AuraColor.primary)
                .padding(12)
                .background(AuraColor.containerLowest, in: Circle())
                .auraCardShadow()
        }
    }
}

/// Map pin: circular avatar with a category label callout for the selected one.
struct MeetupPin: View {
    let meetup: Meetup
    let selected: Bool
    var onTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            if selected {
                Label(meetup.title, systemImage: icon)
                    .font(AuraFont.labelMd()).foregroundStyle(.white)
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .background(AuraColor.primaryDeep, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .auraCardShadow()
                Triangle().fill(AuraColor.primaryDeep)
                    .frame(width: 14, height: 8)
                Image(systemName: "photo")
                    .font(.system(size: 22)).foregroundStyle(AuraColor.primary.opacity(0.6))
                    .frame(width: 56, height: 56)
                    .background(AuraColor.surfaceContainer, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AuraColor.primary, lineWidth: 2))
            } else {
                AvatarView(asset: meetup.attendeePhotos.first ?? "a1", name: meetup.title, size: 44)
                    .overlay(Circle().stroke(.white, lineWidth: 3))
                    .auraCardShadow()
            }
        }
        .onTapGesture(perform: onTap)
    }

    private var icon: String {
        switch meetup.category {
        case "CREATIVE": "paintbrush.fill"
        case "WELLNESS": "figure.run"
        default: "cup.and.saucer.fill"
        }
    }
}

struct MeetupCard: View {
    @Environment(MockBackend.self) private var backend
    let meetup: Meetup
    @State private var showToast = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(meetup.category)
                    .font(AuraFont.labelSm()).foregroundStyle(AuraColor.secondaryDeep)
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(AuraColor.secondary.opacity(0.14), in: Capsule())
                Spacer()
                Label("\(meetup.distanceMi, specifier: "%.1f") mi away", systemImage: "location.fill")
                    .font(AuraFont.labelMd()).foregroundStyle(AuraColor.onSurfaceVariant)
                Image(systemName: "square.and.arrow.up")
                    .foregroundStyle(AuraColor.onSurfaceVariant)
                    .frame(width: 36, height: 36)
                    .background(AuraColor.surfaceContainerHigh, in: Circle())
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(meetup.title).font(AuraFont.headlineMd()).foregroundStyle(AuraColor.onSurface)
                Text("\(meetup.venue) · \(meetup.time)")
                    .font(AuraFont.bodyMd()).foregroundStyle(AuraColor.onSurfaceVariant)
            }

            HStack(spacing: 10) {
                HStack(spacing: -10) {
                    ForEach(meetup.attendeePhotos, id: \.self) { a in
                        AvatarView(asset: a, name: a, size: 34)
                            .overlay(Circle().stroke(AuraColor.containerLowest, lineWidth: 2))
                    }
                    Text("+\(max(meetup.attendeeCount - meetup.attendeePhotos.count, 0))")
                        .font(AuraFont.labelSm()).foregroundStyle(AuraColor.onSurfaceVariant)
                        .frame(width: 34, height: 34)
                        .background(AuraColor.surfaceContainerHighest, in: Circle())
                        .overlay(Circle().stroke(AuraColor.containerLowest, lineWidth: 2))
                }
                Text("\(meetup.attendeeCount) people attending")
                    .font(AuraFont.labelMd()).foregroundStyle(AuraColor.onSurface)
                Spacer()
            }

            PrimaryButton(title: meetup.joined ? "Reserved ✓" : "Join Meetup  ·  \(meetup.creditCost) credits",
                          icon: meetup.joined ? "checkmark.seal.fill" : "calendar.badge.plus") {
                if backend.joinSelectedMeetup() {
                    withAnimation(.spring) { showToast = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                        withAnimation { showToast = false }
                    }
                }
            }
            .accessibilityIdentifier("joinMeetup")
        }
        .padding(20)
        .background(AuraColor.containerLowest, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .auraOverlayShadow()
        .overlay(alignment: .top) {
            if showToast {
                Text("Spot reserved · \(meetup.creditCost) credits spent")
                    .font(AuraFont.labelMd()).foregroundStyle(.white)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .background(AuraColor.primaryDeep, in: Capsule())
                    .offset(y: -56)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
}

struct Triangle: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: r.midX, y: r.maxY))
        p.addLine(to: CGPoint(x: r.minX, y: r.minY))
        p.addLine(to: CGPoint(x: r.maxX, y: r.minY))
        p.closeSubpath()
        return p
    }
}
