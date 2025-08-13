import SwiftUI

enum Destination: Hashable {
    case people
    case profile
}

struct RootView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            InterstellarHeroView(
                onCalculate: { path.append(Destination.profile) },
                onCheckCompatibility: { path.append(Destination.people) }
            )
            .navigationDestination(for: Destination.self) { dest in
                switch dest {
                case .people:
                    PeopleSelectionView(people: samplePeople)
                        .navigationTitle("Выбор человека")
                        .navigationBarTitleDisplayMode(.inline)
                case .profile:
                    ProfileView()
                        .navigationTitle("Профиль")
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }

    private var samplePeople: [Person] {
        [
            Person(name: "Аня", age: 27, city: "Москва", compatibilityScore: 18),
            Person(name: "Марина", age: 31, city: "Санкт‑Петербург", compatibilityScore: 43),
            Person(name: "Ника", age: 26, city: "Казань", compatibilityScore: 67),
            Person(name: "Вера", age: 29, city: "Новосибирск", compatibilityScore: 86)
        ]
    }
}