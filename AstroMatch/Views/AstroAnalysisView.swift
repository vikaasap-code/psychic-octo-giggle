import SwiftUI

struct AstroAnalysisView: View {
    @EnvironmentObject var viewModel: AstroMatchViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack {
                if let currentUser = viewModel.currentUser {
                    // Заголовок
                    headerSection(user: currentUser)
                    
                    // Табы для разных типов анализа
                    tabSection
                    
                    // Содержимое выбранного таба
                    TabView(selection: $selectedTab) {
                        natalChartTab(user: currentUser)
                            .tag(0)
                        
                        personalityAnalysisTab(user: currentUser)
                            .tag(1)
                        
                        compatibilityGuideTab(user: currentUser)
                            .tag(2)
                        
                        dailyHoroscopeTab(user: currentUser)
                            .tag(3)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                } else {
                    loadingView
                }
            }
            .navigationTitle("Астрологический анализ")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Header Section
    
    private func headerSection(user: UserProfile) -> some View {
        VStack(spacing: 16) {
            HStack {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [.purple.opacity(0.3), .blue.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 80, height: 80)
                    
                    Text(user.natalChart.sunSign.emoji)
                        .font(.system(size: 40))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Натальная карта")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(user.name)
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("\(user.natalChart.sunSign.rawValue) • \(user.natalChart.sunSign.element.rawValue)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Tab Section
    
    private var tabSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(AnalysisTab.allCases, id: \.self) { tab in
                    TabButton(
                        title: tab.title,
                        isSelected: selectedTab == tab.rawValue,
                        action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedTab = tab.rawValue
                            }
                        }
                    )
                }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Natal Chart Tab
    
    private func natalChartTab(user: UserProfile) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Основные планеты
                planetsSection(user: user)
                
                // Дома гороскопа
                housesSection(user: user)
                
                // Аспекты
                aspectsSection(user: user)
            }
            .padding()
        }
    }
    
    // MARK: - Personality Analysis Tab
    
    private func personalityAnalysisTab(user: UserProfile) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Характер по Солнцу
                sunPersonalitySection(user: user)
                
                // Эмоции по Луне
                moonPersonalitySection(user: user)
                
                // Коммуникация по Меркурию
                mercuryPersonalitySection(user: user)
                
                // Любовь по Венере
                venusPersonalitySection(user: user)
                
                // Энергия по Марсу
                marsPersonalitySection(user: user)
            }
            .padding()
        }
    }
    
    // MARK: - Compatibility Guide Tab
    
    private func compatibilityGuideTab(user: UserProfile) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Совместимость по стихиям
                elementCompatibilitySection(user: user)
                
                // Совместимость по качествам
                qualityCompatibilitySection(user: user)
                
                // Рекомендации по совместимости
                compatibilityRecommendationsSection(user: user)
            }
            .padding()
        }
    }
    
    // MARK: - Daily Horoscope Tab
    
    private func dailyHoroscopeTab(user: UserProfile) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Сегодняшний гороскоп
                todayHoroscopeSection(user: user)
                
                // Недельный прогноз
                weeklyForecastSection(user: user)
                
                // Лунный календарь
                lunarCalendarSection(user: user)
            }
            .padding()
        }
    }
    
    // MARK: - Supporting Sections
    
    private func planetsSection(user: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Планеты в натальной карте")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                PlanetRow(
                    planet: .sun,
                    sign: user.natalChart.sunSign,
                    description: "Основная личность, эго, жизненная сила"
                )
                
                PlanetRow(
                    planet: .moon,
                    sign: user.natalChart.moonSign,
                    description: "Эмоции, подсознание, внутренний мир"
                )
                
                PlanetRow(
                    planet: .mercury,
                    sign: user.natalChart.sunSign, // Упрощенно
                    description: "Коммуникация, мышление, обучение"
                )
                
                PlanetRow(
                    planet: .venus,
                    sign: user.natalChart.sunSign, // Упрощенно
                    description: "Любовь, красота, гармония"
                )
                
                PlanetRow(
                    planet: .mars,
                    sign: user.natalChart.sunSign, // Упрощенно
                    description: "Энергия, действие, страсть"
                )
            }
        }
    }
    
    private func housesSection(user: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Дома гороскопа")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(House.allCases, id: \.self) { house in
                    HouseCard(house: house)
                }
            }
        }
    }
    
    private func aspectsSection(user: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ключевые аспекты")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                AspectRow(
                    title: "☀️🌙 Солнце-Луна",
                    aspect: "Соединение",
                    description: "Гармония между личностью и эмоциями"
                )
                
                AspectRow(
                    title: "☀️♂️ Солнце-Марс",
                    aspect: "Трин",
                    description: "Сильная воля и энергия"
                )
                
                AspectRow(
                    title: "♀️♂️ Венера-Марс",
                    aspect: "Секстиль",
                    description: "Гармония в любовных отношениях"
                )
            }
        }
    }
    
    private func sunPersonalitySection(user: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Характер по Солнцу")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(getSunPersonalityDescription(for: user.natalChart.sunSign))
                .font(.body)
                .lineSpacing(4)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.opacity(0.05))
                )
        }
    }
    
    private func moonPersonalitySection(user: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Эмоции по Луне")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(getMoonPersonalityDescription(for: user.natalChart.moonSign))
                .font(.body)
                .lineSpacing(4)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.05))
                )
        }
    }
    
    private func mercuryPersonalitySection(user: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Коммуникация по Меркурию")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Ваш стиль общения и мышления определяется положением Меркурия в знаке \(user.natalChart.sunSign.rawValue). Это влияет на то, как вы выражаете мысли и воспринимаете информацию.")
                .font(.body)
                .lineSpacing(4)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.green.opacity(0.05))
                )
        }
    }
    
    private func venusPersonalitySection(user: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Любовь по Венере")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Положение Венеры показывает ваш стиль любви и то, что вас привлекает в партнере. В знаке \(user.natalChart.sunSign.rawValue) это дает особый подход к отношениям.")
                .font(.body)
                .lineSpacing(4)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.pink.opacity(0.05))
                )
        }
    }
    
    private func marsPersonalitySection(user: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Энергия по Марсу")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Марс определяет вашу активность, страсть и способ действия. В знаке \(user.natalChart.sunSign.rawValue) это проявляется в особом стиле достижения целей.")
                .font(.body)
                .lineSpacing(4)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.red.opacity(0.05))
                )
        }
    }
    
    private func elementCompatibilitySection(user: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Совместимость по стихиям")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ElementCompatibilityRow(
                    element: user.natalChart.sunSign.element,
                    compatibleElements: getCompatibleElements(for: user.natalChart.sunSign.element),
                    description: getElementCompatibilityDescription(for: user.natalChart.sunSign.element)
                )
            }
        }
    }
    
    private func qualityCompatibilitySection(user: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Совместимость по качествам")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Ваш знак \(user.natalChart.sunSign.rawValue) имеет качество \(user.natalChart.sunSign.quality.rawValue). Это влияет на то, как вы подходите к жизни и отношениям.")
                .font(.body)
                .lineSpacing(4)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.purple.opacity(0.05))
                )
        }
    }
    
    private func compatibilityRecommendationsSection(user: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Рекомендации по совместимости")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(getCompatibilityRecommendations(for: user.natalChart.sunSign), id: \.self) { recommendation in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        
                        Text(recommendation)
                            .font(.body)
                            .lineSpacing(2)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.yellow.opacity(0.05))
            )
        }
    }
    
    private func todayHoroscopeSection(user: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Сегодняшний гороскоп")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Сегодня для знака \(user.natalChart.sunSign.rawValue) благоприятное время для новых знакомств. Луна в гармоничном аспекте с Венерой способствует романтическим встречам.")
                .font(.body)
                .lineSpacing(4)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.green.opacity(0.05))
                )
        }
    }
    
    private func weeklyForecastSection(user: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Недельный прогноз")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 12) {
                WeeklyForecastDay(day: "Понедельник", forecast: "Отличный день для активного поиска")
                WeeklyForecastDay(day: "Вторник", forecast: "Фокус на качественном общении")
                WeeklyForecastDay(day: "Среда", forecast: "Возможны неожиданные встречи")
                WeeklyForecastDay(day: "Четверг", forecast: "Время для глубоких разговоров")
                WeeklyForecastDay(day: "Пятница", forecast: "Романтическое настроение")
                WeeklyForecastDay(day: "Суббота", forecast: "Социальная активность")
                WeeklyForecastDay(day: "Воскресенье", forecast: "Отдых и размышления")
            }
        }
    }
    
    private func lunarCalendarSection(user: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Лунный календарь")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Фаза Луны")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("Растущая Луна")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("🌓")
                    .font(.title)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.05))
            )
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Загрузка астрологического анализа...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Helper Methods
    
    private func getSunPersonalityDescription(for sign: ZodiacSign) -> String {
        switch sign {
        case .aries: return "Вы энергичный лидер с сильной волей. Ваша прямолинейность и смелость привлекают людей. Вы любите быть первым и не боитесь вызовов."
        case .taurus: return "Вы надежный и практичный человек. Цените стабильность и комфорт. Ваша преданность и терпение делают вас отличным партнером."
        case .gemini: return "Вы любознательный и общительный человек. Ваш ум всегда в поиске новой информации. Вы легко адаптируетесь к изменениям."
        case .cancer: return "Вы эмоциональный и заботливый человек. Ваша интуиция и эмпатия помогают понимать других. Вы цените семью и близкие отношения."
        case .leo: return "Вы харизматичный и творческий человек. Ваша уверенность и щедрость привлекают внимание. Вы любите быть в центре событий."
        case .virgo: return "Вы аналитичный и организованный человек. Ваше внимание к деталям и стремление к совершенству помогают в достижении целей."
        case .libra: return "Вы дипломатичный и справедливый человек. Ваше чувство баланса и гармонии помогает в отношениях. Вы цените красоту и мир."
        case .scorpio: return "Вы страстный и проницательный человек. Ваша интуиция и глубина чувств делают вас загадочным. Вы ищете истину во всем."
        case .sagittarius: return "Вы оптимистичный и авантюрный человек. Ваша любовь к свободе и путешествиям расширяет горизонты. Вы философ по натуре."
        case .capricorn: return "Вы амбициозный и дисциплинированный человек. Ваша ответственность и целеустремленность помогают достигать успеха."
        case .aquarius: return "Вы оригинальный и гуманистичный человек. Ваша независимость и инновационность выделяют вас. Вы думаете о будущем человечества."
        case .pisces: return "Вы мечтательный и сострадательный человек. Ваша творческая природа и духовность помогают понимать глубину жизни."
        }
    }
    
    private func getMoonPersonalityDescription(for sign: ZodiacSign) -> String {
        switch sign {
        case .aries: return "Ваши эмоции вспыхивают быстро и ярко. Вы импульсивны в чувствах и нуждаетесь в действии для выражения эмоций."
        case .taurus: return "Ваши эмоции стабильны и глубоки. Вы цените комфорт и безопасность в эмоциональной сфере."
        case .gemini: return "Ваши эмоции изменчивы и разнообразны. Вы нуждаетесь в интеллектуальной стимуляции для эмоционального удовлетворения."
        case .cancer: return "Ваши эмоции очень глубоки и связаны с семьей. Вы интуитивны и чувствительны к настроению других."
        case .leo: return "Ваши эмоции ярки и драматичны. Вы нуждаетесь в признании и восхищении для эмоционального комфорта."
        case .virgo: return "Ваши эмоции аналитичны и практичны. Вы стремитесь к совершенству в эмоциональных отношениях."
        case .libra: return "Ваши эмоции гармоничны и сбалансированы. Вы ищете мир и красоту в эмоциональных связях."
        case .scorpio: return "Ваши эмоции интенсивны и трансформативны. Вы испытываете чувства очень глубоко и страстно."
        case .sagittarius: return "Ваши эмоции оптимистичны и свободолюбивы. Вы нуждаетесь в пространстве для эмоционального роста."
        case .capricorn: return "Ваши эмоции сдержанны и ответственны. Вы контролируете чувства и цените стабильность."
        case .aquarius: return "Ваши эмоции оригинальны и независимы. Вы мыслите нестандартно в эмоциональной сфере."
        case .pisces: return "Ваши эмоции мистичны и сострадательны. Вы чувствуете связь с вселенной и другими людьми."
        }
    }
    
    private func getCompatibleElements(for element: Element) -> [Element] {
        switch element {
        case .fire: return [.fire, .air]
        case .earth: return [.earth, .water]
        case .air: return [.air, .fire]
        case .water: return [.water, .earth]
        }
    }
    
    private func getElementCompatibilityDescription(for element: Element) -> String {
        switch element {
        case .fire: return "Огонь лучше всего сочетается с Воздухом (стимулирует) и Огнем (усиливает). Избегайте Воды, которая может потушить ваш энтузиазм."
        case .earth: return "Земля гармонирует с Водой (питает) и Землей (стабилизирует). Воздух может быть слишком нестабильным для вас."
        case .air: return "Воздух отлично сочетается с Огнем (раздувает) и Воздухом (расширяет). Земля может ограничивать вашу свободу."
        case .water: return "Вода хорошо сочетается с Землей (находит форму) и Водой (углубляет). Огонь может испарять ваши чувства."
        }
    }
    
    private func getCompatibilityRecommendations(for sign: ZodiacSign) -> [String] {
        switch sign {
        case .aries: return [
            "Ищите партнеров с огненными или воздушными знаками",
            "Избегайте слишком эмоциональных и чувствительных людей",
            "Цените независимость и активность в партнере"
        ]
        case .taurus: return [
            "Лучше всего подходят земные и водные знаки",
            "Ищите стабильность и надежность",
            "Цените практичность и материальную обеспеченность"
        ]
        case .gemini: return [
            "Гармонируйте с воздушными и огненными знаками",
            "Нуждаетесь в интеллектуальной стимуляции",
            "Цените разнообразие и общение"
        ]
        case .cancer: return [
            "Идеальны водные и земные знаки",
            "Ищите эмоциональную глубину и заботу",
            "Цените семейные ценности и стабильность"
        ]
        case .leo: return [
            "Лучше всего с огненными и воздушными знаками",
            "Нуждаетесь в восхищении и внимании",
            "Цените щедрость и творчество"
        ]
        case .virgo: return [
            "Гармонируйте с земными и водными знаками",
            "Ищите интеллектуальную совместимость",
            "Цените порядок и совершенство"
        ]
        case .libra: return [
            "Идеальны воздушные и огненные знаки",
            "Нуждаетесь в гармонии и балансе",
            "Цените красоту и справедливость"
        ]
        case .scorpio: return [
            "Лучше всего с водными и земными знаками",
            "Ищите глубину и страсть",
            "Цените честность и преданность"
        ]
        case .sagittarius: return [
            "Гармонируйте с огненными и воздушными знаками",
            "Нуждаетесь в свободе и приключениях",
            "Цените оптимизм и философию"
        ]
        case .capricorn: return [
            "Идеальны земные и водные знаки",
            "Ищите амбиции и ответственность",
            "Цените стабильность и достижения"
        ]
        case .aquarius: return [
            "Лучше всего с воздушными и огненными знаками",
            "Нуждаетесь в независимости и инновациях",
            "Цените оригинальность и гуманизм"
        ]
        case .pisces: return [
            "Гармонируйте с водными и земными знаками",
            "Ищите духовную связь и сострадание",
            "Цените творчество и интуицию"
        ]
        }
    }
}

// MARK: - Supporting Views

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.purple : Color.gray.opacity(0.1))
                )
                .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PlanetRow: View {
    let planet: Planet
    let sign: ZodiacSign
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Text(planet.emoji)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(planet.rawValue)
                    .font(.body)
                    .fontWeight(.semibold)
                
                Text("в знаке \(sign.rawValue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.05))
        )
    }
}

struct HouseCard: View {
    let house: House
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(house.rawValue)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.purple)
            
            Text(house.name)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.purple.opacity(0.05))
        )
    }
}

struct AspectRow: View {
    let title: String
    let aspect: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Text(title)
                .font(.body)
                .fontWeight(.medium)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(aspect)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.purple)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.05))
        )
    }
}

struct ElementCompatibilityRow: View {
    let element: Element
    let compatibleElements: [Element]
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(element.emoji)
                    .font(.title2)
                
                Text(element.rawValue)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            Text("Совместимые стихии:")
                .font(.subheadline)
                .fontWeight(.medium)
            
            HStack {
                ForEach(compatibleElements, id: \.self) { compatibleElement in
                    HStack(spacing: 4) {
                        Text(compatibleElement.emoji)
                        Text(compatibleElement.rawValue)
                            .font(.caption)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(3)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.05))
        )
    }
}

struct WeeklyForecastDay: View {
    let day: String
    let forecast: String
    
    var body: some View {
        HStack {
            Text(day)
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(width: 100, alignment: .leading)
            
            Text(forecast)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            Spacer()
        }
    }
}

// MARK: - Enums

enum AnalysisTab: Int, CaseIterable {
    case natalChart = 0
    case personality = 1
    case compatibility = 2
    case horoscope = 3
    
    var title: String {
        switch self {
        case .natalChart: return "Натальная карта"
        case .personality: return "Личность"
        case .compatibility: return "Совместимость"
        case .horoscope: return "Гороскоп"
        }
    }
}

#Preview {
    AstroAnalysisView()
        .environmentObject(AstroMatchViewModel())
}