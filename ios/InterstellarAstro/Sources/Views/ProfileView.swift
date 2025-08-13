import SwiftUI
import PhotosUI
import UIKit

struct ProustAnswer: Identifiable, Hashable {
    let id = UUID()
    var question: String
    var answer: String
}

struct UserProfile: Identifiable {
    let id = UUID()
    var name: String
    var age: Int
    var city: String
    var zodiac: String
    var bio: String
    var hobbies: Set<String>
    var proust: [ProustAnswer]
    var photos: [UIImage]
}

let popularHobbies: [String] = [
    "Путешествия","Кино","Музыка","Чтение","Кофе","Йога","Фитнес","Фотография","Танцы","Искусство",
    "Настолки","Природа","Медитация","Астрология","Готовка","Театр","Волонтёрство","Игры"
]

let proustQuestions: [String] = [
    "Главная черта вашего характера?",
    "Каким вы хотите быть на самом деле?",
    "Ваше любимое занятие?",
    "Качество, которое вы больше всего цените в друзьях?",
    "Ваш главный порок?",
    "Ваша мечта о счастье?",
    "Чего вы больше всего боитесь?",
    "Ваш девиз?"
]

struct ProfileView: View {
    @State private var profile: UserProfile = .mock
    @State private var isEditing: Bool = false

    var body: some View {
        ZStack {
            SkyStarfieldBackground()
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    header

                    ForEach(interleavedItems(), id: \._id) { item in
                        switch item.content {
                        case .photo(let image):
                            PhotoCard(image: image)
                        case .bio(let text):
                            BioCard(text: text)
                        case .hobbies(let hobbies):
                            HobbiesCard(hobbies: Array(hobbies))
                        case .proust(let qa):
                            ProustCard(answers: qa)
                        }
                    }
                    bottomSpacer
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
            }
        }
        .sheet(isPresented: $isEditing) {
            EditProfileSheet(profile: $profile)
        }
        .preferredColorScheme(.light)
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text("\(profile.name), \(profile.age)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color.black.opacity(0.9))
                    ZodiacBadge(sign: profile.zodiac)
                }
                Text(profile.city)
                    .font(.system(size: 14))
                    .foregroundColor(Color.black.opacity(0.6))
            }
            Spacer()
            Button {
                isEditing = true
            } label: {
                Text("Редактировать")
                    .font(.system(size: 14, weight: .semibold))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(.white.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.5), lineWidth: 1))
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white.opacity(0.25))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.35), lineWidth: 1))
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 8)
        )
    }

    private var bottomSpacer: some View {
        Text("18+. Профиль и ответы — по желанию. Данные используются для подбора совместимости.")
            .font(.footnote)
            .foregroundColor(Color.black.opacity(0.5))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 4)
            .padding(.horizontal, 8)
    }

    enum Piece {
        case photo(UIImage)
        case bio(String)
        case hobbies(Set<String>)
        case proust([ProustAnswer])
    }

    struct FeedItem {
        let _id = UUID()
        let content: Piece
    }

    private func interleavedItems() -> [FeedItem] {
        var photos = profile.photos
        var texts: [Piece] = []
        if !profile.bio.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            texts.append(.bio(profile.bio))
        }
        if !profile.hobbies.isEmpty {
            texts.append(.hobbies(profile.hobbies))
        }
        if !profile.proust.allSatisfy({ $0.answer.isEmpty }) {
            texts.append(.proust(profile.proust.filter { !$0.answer.isEmpty }))
        }

        var result: [FeedItem] = []
        var i = 0, j = 0
        while i < photos.count || j < texts.count {
            if i < photos.count {
                result.append(FeedItem(content: .photo(photos[i])))
                i += 1
            }
            if j < texts.count {
                result.append(FeedItem(content: texts[j]))
                j += 1
            }
        }
        return result
    }
}

struct PhotoCard: View {
    let image: UIImage
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(height: 320)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18).stroke(.white.opacity(0.35), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: 10)
            .accessibilityLabel("Фото из профиля")
    }
}

struct BioCard: View {
    let text: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("О себе")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black.opacity(0.7))
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.black.opacity(0.88))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.5))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.6), lineWidth: 1))
        )
    }
}

struct HobbiesCard: View {
    let hobbies: [String]
    private let columns = [GridItem(.adaptive(minimum: 96), spacing: 8)]
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Увлечения и хобби")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black.opacity(0.7))
            LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                ForEach(hobbies, id: \.self) { hobby in
                    Text(hobby)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            Capsule().fill(LinearGradient(colors: [Color.purple.opacity(0.8), Color.pink.opacity(0.8)],
                                                          startPoint: .leading, endPoint: .trailing))
                        )
                        .overlay(Capsule().stroke(.white.opacity(0.25), lineWidth: 1))
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.5))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.6), lineWidth: 1))
        )
    }
}

struct ProustCard: View {
    let answers: [ProustAnswer]
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Опросник Пруста")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black.opacity(0.7))
            ForEach(answers) { qa in
                VStack(alignment: .leading, spacing: 4) {
                    Text(qa.question)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.black.opacity(0.6))
                    Text(qa.answer)
                        .font(.system(size: 15))
                        .foregroundColor(.black.opacity(0.9))
                }
                .padding(10)
                .background(.white.opacity(0.45))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.5))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.6), lineWidth: 1))
        )
    }
}

struct ZodiacBadge: View {
    let sign: String
    var body: some View {
        Text(sign)
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(.white)
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(
                Capsule().fill(LinearGradient(colors: [Color.blue, Color.purple], startPoint: .leading, endPoint: .trailing))
            )
            .overlay(Capsule().stroke(.white.opacity(0.4), lineWidth: 1))
    }
}

struct EditProfileSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var profile: UserProfile

    @State private var tempBio: String = ""
    @State private var tempHobbies: Set<String> = []
    @State private var tempProust: [ProustAnswer] = []
    @State private var selectedPickerItems: [PhotosPickerItem] = []
    @State private var tempPhotos: [UIImage] = []

    private let maxPhotos = 15

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    photosSection
                    bioSection
                    hobbiesSection
                    proustSection
                }
                .padding(16)
            }
            .navigationTitle("Редактировать профиль")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        profile.bio = tempBio
                        profile.hobbies = tempHobbies
                        profile.proust = tempProust
                        profile.photos = Array(tempPhotos.prefix(maxPhotos))
                        dismiss()
                    }.disabled(tempPhotos.isEmpty && profile.photos.isEmpty)
                }
            }
            .onAppear {
                tempBio = profile.bio
                tempHobbies = profile.hobbies
                tempProust = profile.proust.isEmpty
                    ? proustQuestions.map { ProustAnswer(question: $0, answer: "") }
                    : profile.proust
                tempPhotos = profile.photos
            }
        }
    }

    private var photosSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Фотографии • \(tempPhotos.count)/\(maxPhotos)")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                PhotosPicker(selection: $selectedPickerItems, maxSelectionCount: maxPhotos - tempPhotos.count, matching: .images) {
                    Label("Добавить", systemImage: "plus.circle.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
                        .clipShape(Capsule())
                }
            }

            let columns = [GridItem(.adaptive(minimum: 100), spacing: 8)]
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(Array(tempPhotos.enumerated()), id: \.offset) { index, ui in
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: ui)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 120)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.4), lineWidth: 1))

                        Button {
                            tempPhotos.remove(at: index)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white)
                                .background(Circle().fill(Color.black.opacity(0.4)))
                        }
                        .offset(x: -6, y: 6)
                    }
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.5))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.6), lineWidth: 1))
        )
        .onChange(of: selectedPickerItems) { _, newItems in
            Task {
                for item in newItems {
                    if tempPhotos.count >= maxPhotos { break }
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let img = UIImage(data: data) {
                        tempPhotos.append(img)
                    }
                }
                selectedPickerItems = []
            }
        }
    }

    private var bioSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("О себе")
                .font(.system(size: 16, weight: .semibold))
            TextEditor(text: $tempBio)
                .frame(minHeight: 120)
                .padding(10)
                .background(.white.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.5))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.6), lineWidth: 1))
        )
    }

    private var hobbiesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Увлечения и хобби (выберите)")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Text("\(tempHobbies.count) выбрано")
                    .font(.system(size: 13))
                    .foregroundColor(.black.opacity(0.6))
            }
            let columns = [GridItem(.adaptive(minimum: 110), spacing: 8)]
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(popularHobbies, id: \.self) { hobby in
                    let isOn = tempHobbies.contains(hobby)
                    Button {
                        if isOn { tempHobbies.remove(hobby) } else { tempHobbies.insert(hobby) }
                    } label: {
                        Text(hobby)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(isOn ? .white : .black.opacity(0.75))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(
                                Capsule().fill(
                                    isOn
                                    ? LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing)
                                    : Color.white.opacity(0.7)
                                )
                            )
                            .overlay(Capsule().stroke(.white.opacity(0.5), lineWidth: 1))
                    }
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.5))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.6), lineWidth: 1))
        )
    }

    private var proustSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Опросник Пруста")
                .font(.system(size: 16, weight: .semibold))
            ForEach($tempProust) { $qa in
                VStack(alignment: .leading, spacing: 6) {
                    Text(qa.question)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.black.opacity(0.65))
                    TextField("Ваш ответ", text: $qa.answer, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(1...3)
                }
                .padding(10)
                .background(.white.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.5))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.6), lineWidth: 1))
        )
    }
}

struct SkyStarfieldBackground: View {
    @State private var start = Date()
    private let stars: [Star] = SkyStarfieldBackground.generateStars(count: 280, seed: 77)

    struct Star {
        let uv: SIMD2<Double>
        let depth: Double
        let phase: Double
    }

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSince(start)

            ZStack {
                LinearGradient(colors: [
                    Color(red: 0.82, green: 0.93, blue: 1.0),
                    Color(red: 0.70, green: 0.86, blue: 1.0)
                ], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

                Canvas { context, size in
                    let time = CGFloat(t)
                    for s in stars {
                        let x = CGFloat(s.uv.x) * size.width
                        let y = CGFloat(s.uv.y) * size.height
                        let twinkle = 0.7 + 0.3 * sin(CGFloat(s.phase) + time * (0.8 + 0.6 * s.depth))
                        let opacity = 0.35 + 0.65 * twinkle
                        let r: CGFloat = CGFloat(0.8 + 1.8 * (1 - s.depth)) * (0.9 + 0.2 * twinkle)

                        var path = Path()
                        path.addEllipse(in: CGRect(x: x, y: y, width: r, height: r))
                        context.fill(path, with: .color(Color.white.opacity(opacity)))
                    }
                }
                .blendMode(.plusLighter)
                .opacity(0.9)

                LinearGradient(colors: [Color.white.opacity(0.0), Color.white.opacity(0.18)],
                               startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            }
        }
    }

    static func generateStars(count: Int, seed: UInt64) -> [Star] {
        var rng = SeededGenerator(seed: seed)
        return (0..<count).map { _ in
            Star(
                uv: SIMD2(Double.random(in: 0...1, using: &rng), Double.random(in: 0...1, using: &rng)),
                depth: Double.random(in: 0...1, using: &rng),
                phase: Double.random(in: 0...(Double.pi * 2), using: &rng)
            )
        }
    }
}

fileprivate struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { self.state = seed == 0 ? 0x123456789ABCDEF : seed }
    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}

extension UserProfile {
    static var mock: UserProfile {
        UserProfile(
            name: "Алиса",
            age: 27,
            city: "Москва",
            zodiac: "♒︎ Водолей",
            bio: "Люблю ранние рассветы, книги о космосе и длинные прогулки. Увлекаюсь астрологией и фотографией.",
            hobbies: ["Чтение","Фотография","Астрология","Путешествия"],
            proust: proustQuestions.map { ProustAnswer(question: $0, answer: "") },
            photos: []
        )
    }
}