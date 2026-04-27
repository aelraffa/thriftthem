# ThriftThem

A Flutter app for tracking thrift store finds. Spot something you like? Log it with a photo and your GPS location, watch it, then mark it as bought when you pull the trigger.

## Features

### Firebase Authentication
- Email & password register / login via Firebase Auth
- Auth state persisted across app restarts

### Watchlist (CRUD — Firestore)
- **Add** an item with name, price, photo, tags, and current location
- **View** all watching items in real-time (Firestore stream)
- **Edit** name, price, or tags at any time
- **Delete** an item (removes Firestore doc + local photo file)
- **Mark as Bought** — moves item to the archive with a `bought_at` timestamp

### Archive
- Browsable history of all purchased items

### GPS Location (Smartphone Resource)
- Tap "Use My Location" when adding an item to auto-fill coordinates
- Reverse-geocoded to a human-readable address label
- Map preview on the item detail screen (flutter_map + OpenStreetMap)
- Tapping the map opens Google Maps for navigation

### Notifications
- Local push notification triggered for any watchlist item sitting unwatched for **7+ days**
- Notification includes item name, days elapsed, and store location

### Photo Storage
- Camera or gallery picker via `image_picker`
- Photos saved locally to app documents directory

## Tech Stack

| Layer | Package |
|---|---|
| Auth | `firebase_auth` |
| Database | `cloud_firestore` |
| Local storage | `path_provider` |
| Camera | `image_picker` |
| GPS | `geolocator`, `geocoding` |
| Map | `flutter_map`, `latlong2` |
| Notifications | `flutter_local_notifications` |
| State management | `provider` |

## Getting Started

1. Clone the repo and run `flutter pub get`
2. Add your `google-services.json` (Android) to `android/app/`
3. Run on a physical device or emulator: `flutter run`

> Location and notification features require a physical device or an emulator with location mocking enabled.
