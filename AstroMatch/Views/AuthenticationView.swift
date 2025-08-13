import SwiftUI

struct AuthenticationView: View {
    @State private var isSignUp = false
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var age = 25
    @State private var bio = ""
    @State private var birthDate = Date()
    @State private var birthTime = Date()
    @State private var selectedZodiacSign = ZodiacSign.libra
    @State private var selectedInterests: Set<String> = []
    
    @EnvironmentObject var userManager: UserManager
    
    private let availableInterests = [
        "Астрология", "Путешествия", "Музыка", "Книги", "Спорт", "Искусство",
        "Природа", "Йога", "Наука", "Философия", "Танцы", "Приключения",
        "Кулинария", "Фотография", "Технологии", "Медитация"
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Градиентный фон
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.purple.opacity(0.8),
                        Color.blue.opacity(0.6),
                        Color.pink.opacity(0.4)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Логотип и заголовок
                        VStack(spacing: 20) {
                            Image(systemName: "moon.stars.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.white)
                                .shadow(radius: 10)
                            
                            Text("AstroMatch")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Найдите свою астрологическую пару")
                                .font(.title3)
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 50)
                        
                        // Форма
                        VStack(spacing: 20) {
                            if isSignUp {
                                signUpForm
                            } else {
                                signInForm
                            }
                        }
                        .padding(.horizontal, 30)
                        
                        // Переключение между входом и регистрацией
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isSignUp.toggle()
                            }
                        }) {
                            Text(isSignUp ? "Уже есть аккаунт? Войти" : "Нет аккаунта? Зарегистрироваться")
                                .foregroundColor(.white)
                                .underline()
                        }
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private var signInForm: some View {
        VStack(spacing: 20) {
            Text("Вход в аккаунт")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            VStack(spacing: 15) {
                CustomTextField(
                    text: $email,
                    placeholder: "Email",
                    icon: "envelope.fill"
                )
                
                CustomSecureField(
                    text: $password,
                    placeholder: "Пароль",
                    icon: "lock.fill"
                )
            }
            
            Button(action: signIn) {
                if userManager.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2)
                } else {
                    Text("Войти")
                        .font(.headline)
                        .foregroundColor(.purple)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.white)
            .cornerRadius(25)
            .disabled(userManager.isLoading)
            
            if let errorMessage = userManager.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 30)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private var signUpForm: some View {
        VStack(spacing: 20) {
            Text("Регистрация")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            VStack(spacing: 15) {
                CustomTextField(
                    text: $name,
                    placeholder: "Имя",
                    icon: "person.fill"
                )
                
                HStack {
                    Text("Возраст: \(age)")
                        .foregroundColor(.white)
                    Spacer()
                    Slider(value: Binding(
                        get: { Double(age) },
                        set: { age = Int($0) }
                    ), in: 18...80, step: 1)
                    .accentColor(.white)
                }
                
                CustomTextField(
                    text: $bio,
                    placeholder: "О себе",
                    icon: "text.quote"
                )
                
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.white)
                    DatePicker("Дата рождения", selection: $birthDate, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                        .colorScheme(.dark)
                }
                
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.white)
                    DatePicker("Время рождения", selection: $birthTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(CompactDatePickerStyle())
                        .colorScheme(.dark)
                }
                
                HStack {
                    Image(systemName: "moon.stars")
                        .foregroundColor(.white)
                    Picker("Знак зодиака", selection: $selectedZodiacSign) {
                        ForEach(ZodiacSign.allCases, id: \.self) { sign in
                            Text(sign.rawValue).tag(sign)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .accentColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Интересы")
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                        ForEach(availableInterests, id: \.self) { interest in
                            InterestButton(
                                title: interest,
                                isSelected: selectedInterests.contains(interest),
                                action: {
                                    if selectedInterests.contains(interest) {
                                        selectedInterests.remove(interest)
                                    } else {
                                        selectedInterests.insert(interest)
                                    }
                                }
                            )
                        }
                    }
                }
            }
            
            Button(action: signUp) {
                if userManager.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                        .scaleEffect(1.2)
                } else {
                    Text("Зарегистрироваться")
                        .font(.headline)
                        .foregroundColor(.purple)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.white)
            .cornerRadius(25)
            .disabled(userManager.isLoading)
            
            if let errorMessage = userManager.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 30)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private func signIn() {
        Task {
            await userManager.signIn(email: email, password: password)
        }
    }
    
    private func signUp() {
        let userData = UserRegistrationData(
            name: name,
            age: age,
            bio: bio,
            birthDate: birthDate,
            birthTime: birthTime,
            birthLocation: Location(
                city: "Москва",
                country: "Россия",
                latitude: 55.7558,
                longitude: 37.6176
            ),
            zodiacSign: selectedZodiacSign,
            interests: Array(selectedInterests)
        )
        
        Task {
            await userManager.signUp(userData: userData)
        }
    }
}

// MARK: - Supporting Views

struct CustomTextField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white)
                .frame(width: 20)
            
            TextField(placeholder, text: $text)
                .foregroundColor(.white)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.2))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
    }
}

struct CustomSecureField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white)
                .frame(width: 20)
            
            SecureField(placeholder, text: $text)
                .foregroundColor(.white)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.2))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
    }
}

struct InterestButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .foregroundColor(isSelected ? .purple : .white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(isSelected ? Color.white : Color.white.opacity(0.2))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

#Preview {
    AuthenticationView()
        .environmentObject(UserManager())
}