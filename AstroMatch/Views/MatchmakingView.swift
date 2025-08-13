import SwiftUI

struct MatchmakingView: View {
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var astrologyService: AstrologyService
    
    @State private var searchQuery = ""
    @State private var selectedFilters = UserFilters()
    @State private var compatiblePartners: [CompatiblePartner] = []
    @State private var isLoading = false
    @State private var showingFilters = false
    @State private var selectedPartner: CompatiblePartner?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Поисковая строка
                searchBar
                
                // Фильтры
                filterBar
                
                // Список совместимых партнеров
                if isLoading {
                    loadingView
                } else if compatiblePartners.isEmpty {
                    emptyStateView
                } else {
                    partnersList
                }
            }
            .navigationTitle("Поиск пары")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingFilters = true }) {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(.purple)
                    }
                }
            }
            .sheet(isPresented: $showingFilters) {
                FilterView(filters: $selectedFilters)
            }
            .sheet(item: $selectedPartner) { partner in
                PartnerDetailView(partner: partner)
            }
            .onAppear {
                loadCompatiblePartners()
            }
            .onChange(of: selectedFilters) { _ in
                loadCompatiblePartners()
            }
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Поиск по имени...", text: $searchQuery)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !searchQuery.isEmpty {
                Button(action: { searchQuery = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
        .padding(.horizontal)
        .onChange(of: searchQuery) { _ in
            loadCompatiblePartners()
        }
    }
    
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                FilterChip(
                    title: "Возраст",
                    isActive: selectedFilters.ageRange != nil,
                    action: { showingFilters = true }
                )
                
                FilterChip(
                    title: "Знак зодиака",
                    isActive: selectedFilters.zodiacSign != nil,
                    action: { showingFilters = true }
                )
                
                FilterChip(
                    title: "Стихия",
                    isActive: selectedFilters.element != nil,
                    action: { showingFilters = true }
                )
                
                FilterChip(
                    title: "Качество",
                    isActive: selectedFilters.quality != nil,
                    action: { showingFilters = true }
                )
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 10)
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                .scaleEffect(1.5)
            
            Text("Ищем вашу идеальную пару...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Совместимых партнеров не найдено")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Попробуйте изменить фильтры или расширить поиск")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Обновить поиск") {
                loadCompatiblePartners()
            }
            .foregroundColor(.purple)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.purple, lineWidth: 1)
            )
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var partnersList: some View {
        ScrollView {
            LazyVStack(spacing: 15) {
                ForEach(compatiblePartners) { partner in
                    PartnerCard(partner: partner) {
                        selectedPartner = partner
                    }
                }
            }
            .padding()
        }
    }
    
    private func loadCompatiblePartners() {
        guard let currentUser = userManager.currentUser else { return }
        
        isLoading = true
        
        Task {
            do {
                let users = try await userManager.searchUsers(query: searchQuery, filters: selectedFilters)
                let partners = try await astrologyService.findCompatiblePartners(for: currentUser, from: users)
                
                await MainActor.run {
                    compatiblePartners = partners
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                }
                print("Ошибка загрузки партнеров: \(error)")
            }
        }
    }
}

// MARK: - Supporting Views

struct FilterChip: View {
    let title: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .foregroundColor(isActive ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(isActive ? Color.purple : Color(.systemGray5))
                )
        }
    }
}

struct PartnerCard: View {
    let partner: CompatiblePartner
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 15) {
                // Заголовок карточки
                HStack {
                    // Аватар
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [.purple, .blue]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 60, height: 60)
                        
                        Text(String(partner.user.name.prefix(1)))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text(partner.user.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("\(partner.user.age) лет • \(partner.user.zodiacSign.rawValue)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Балл совместимости
                    VStack(spacing: 5) {
                        Text("\(Int(partner.matchScore))%")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.purple)
                        
                        Text("Совместимость")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Описание
                if !partner.user.bio.isEmpty {
                    Text(partner.user.bio)
                        .font(.body)
                        .foregroundColor(.primary)
                        .lineLimit(3)
                }
                
                // Интересы
                if !partner.user.interests.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(partner.user.interests.prefix(5), id: \.self) { interest in
                                Text(interest)
                                    .font(.caption)
                                    .foregroundColor(.purple)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.purple.opacity(0.1))
                                    )
                            }
                        }
                    }
                }
                
                // Астрологические детали
                HStack(spacing: 15) {
                    AstroDetail(
                        icon: "sun.max.fill",
                        title: "Солнце",
                        value: partner.user.zodiacSign.rawValue
                    )
                    
                    if let moonSign = partner.user.moonSign {
                        AstroDetail(
                            icon: "moon.fill",
                            title: "Луна",
                            value: moonSign.rawValue
                        )
                    }
                    
                    if let risingSign = partner.user.risingSign {
                        AstroDetail(
                            icon: "arrow.up.circle.fill",
                            title: "Восход",
                            value: risingSign.rawValue
                        )
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AstroDetail: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .foregroundColor(.purple)
                .font(.caption)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.caption)
                .foregroundColor(.primary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }
}

struct FilterView: View {
    @Binding var filters: UserFilters
    @Environment(\.dismiss) private var dismiss
    
    @State private var ageRange: ClosedRange<Double> = 18...50
    @State private var selectedZodiacSign: ZodiacSign?
    @State private var selectedElement: Element?
    @State private var selectedQuality: Quality?
    
    var body: some View {
        NavigationView {
            Form {
                Section("Возраст") {
                    VStack {
                        HStack {
                            Text("От: \(Int(ageRange.lowerBound))")
                            Spacer()
                            Text("До: \(Int(ageRange.upperBound))")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        
                        RangeSlider(value: $ageRange, bounds: 18...80)
                    }
                }
                
                Section("Знак зодиака") {
                    Picker("Знак зодиака", selection: $selectedZodiacSign) {
                        Text("Любой").tag(nil as ZodiacSign?)
                        ForEach(ZodiacSign.allCases, id: \.self) { sign in
                            Text(sign.rawValue).tag(sign as ZodiacSign?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section("Стихия") {
                    Picker("Стихия", selection: $selectedElement) {
                        Text("Любая").tag(nil as Element?)
                        ForEach(Element.allCases, id: \.self) { element in
                            Text(element.rawValue).tag(element as Element?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section("Качество") {
                    Picker("Качество", selection: $selectedQuality) {
                        Text("Любое").tag(nil as Quality?)
                        ForEach(Quality.allCases, id: \.self) { quality in
                            Text(quality.rawValue).tag(quality as Quality?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
            }
            .navigationTitle("Фильтры")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Применить") {
                        applyFilters()
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadCurrentFilters()
        }
    }
    
    private func loadCurrentFilters() {
        if let ageRange = filters.ageRange {
            self.ageRange = Double(ageRange.lowerBound)...Double(ageRange.upperBound)
        }
        selectedZodiacSign = filters.zodiacSign
        selectedElement = filters.element
        selectedQuality = filters.quality
    }
    
    private func applyFilters() {
        filters = UserFilters(
            ageRange: Int(ageRange.lowerBound)...Int(ageRange.upperBound),
            zodiacSign: selectedZodiacSign,
            element: selectedElement,
            quality: selectedQuality
        )
    }
}

struct RangeSlider: View {
    @Binding var value: ClosedRange<Double>
    let bounds: ClosedRange<Double>
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 4)
                
                Rectangle()
                    .fill(Color.purple)
                    .frame(width: width(for: value, in: geometry), height: 4)
                    .offset(x: position(for: value.lowerBound, in: geometry))
                
                HStack(spacing: 0) {
                    Circle()
                        .fill(Color.purple)
                        .frame(width: 20, height: 20)
                        .position(x: position(for: value.lowerBound, in: geometry), y: 10)
                        .gesture(dragGesture(for: \.lowerBound, in: geometry))
                    
                    Circle()
                        .fill(Color.purple)
                        .frame(width: 20, height: 20)
                        .position(x: position(for: value.upperBound, in: geometry), y: 10)
                        .gesture(dragGesture(for: \.upperBound, in: geometry))
                }
            }
        }
        .frame(height: 20)
    }
    
    private func position(for value: Double, in geometry: GeometryProxy) -> CGFloat {
        let range = bounds.upperBound - bounds.lowerBound
        let percentage = (value - bounds.lowerBound) / range
        return percentage * geometry.size.width
    }
    
    private func width(for range: ClosedRange<Double>, in geometry: GeometryProxy) -> CGFloat {
        position(for: range.upperBound, in: geometry) - position(for: range.lowerBound, in: geometry)
    }
    
    private func dragGesture(for bound: WritableKeyPath<ClosedRange<Double>, Double>, in geometry: GeometryProxy) -> some Gesture {
        DragGesture()
            .onChanged { gesture in
                let range = bounds.upperBound - bounds.lowerBound
                let percentage = gesture.location.x / geometry.size.width
                let newValue = bounds.lowerBound + (range * percentage)
                
                if bound == \ClosedRange<Double>.lowerBound {
                    value = Swift.max(bounds.lowerBound, Swift.min(newValue, value.upperBound - 1))...value.upperBound
                } else {
                    value = value.lowerBound...Swift.min(bounds.upperBound, Swift.max(newValue, value.lowerBound + 1))
                }
            }
    }
}

#Preview {
    MatchmakingView()
        .environmentObject(UserManager())
        .environmentObject(AstrologyService())
}