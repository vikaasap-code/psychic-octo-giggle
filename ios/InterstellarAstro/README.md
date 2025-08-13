# InterstellarAstro (iOS, SwiftUI)

Готовый каркас приложения знакомств «по звёздам» для российских пользователей:
- Кинематографичная главная сцена в стиле «Интерстеллар» (анимации, орбиты, «линзирование»).
- Экран выбора человека с визуальной шкалой совместимости (от «лучше даже не пробовать» до «возможно, это ваша судьба»).
- Профиль: до 15 фото, чередование фото и текста, популярные хобби-чипсы, мини-опросник Пруста, небесно-голубой мерцающий фон.

## Требования
- macOS с Xcode 15+
- iOS 16+

## Запуск
1) Откройте проект: `ios/InterstellarAstro/InterstellarAstro.xcodeproj`.
2) В Scheme выберите симулятор iPhone (iOS 16+) и нажмите Run (⌘R).
3) Для запуска на реальном устройстве укажите свой Team в настройках Target (Signing & Capabilities).

## Навигация
- Root: `InterstellarHeroView` (главная кинематографичная сцена) с кнопками:
  - «Рассчитать мою карту» → `ProfileView`.
  - «Проверить совместимость» → `PeopleSelectionView`.

## Структура
- `Sources/App/InterstellarAstroApp.swift` — @main App и корневой `RootView`.
- `Sources/App/RootView.swift` — `NavigationStack`, маршруты и мок-данные.
- `Sources/Views/InterstellarHeroView.swift` — главная сцена (анимации «Интерстеллар»).
- `Sources/Views/PeopleSelectionView.swift` — выбор человека и шкала совместимости.
- `Sources/Views/ProfileView.swift` — профиль (до 15 фото, хобби и Пруст).
- `Info.plist` — ключи, включая `NSPhotoLibraryUsageDescription` (RU).
- `Resources/Assets.xcassets` — ассеты (AppIcon placeholder).

## Примечания
- Визуал построен на Canvas/градиентах/шейпах — без внешних ассетов.
- Для релизной сборки замените `PRODUCT_BUNDLE_IDENTIFIER` и добавьте иконки в `AppIcon.appiconset`.
- Поддержка РФ: русский язык, 24‑часовое время, тексты и дисклеймер 18+.