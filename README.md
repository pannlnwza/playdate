# PlayDate

A SwiftUI iOS app for parents to find playmates for their kids. Swipe, match, chat, and join family events nearby.

## Features

- Email/password auth, persisted across launches
- Tinder-style swipe with filters (age, hobbies, same-event)
- Real reciprocity matching, with auto-match for seeded demo parents
- Real-time chat with unread badges
- Browse, join, and create events with cover photos and map-search location
- Live notifications with read tracking
- Profile with photo gallery, location, and child management

## Tech Stack

| Area | Choice |
|---|---|
| UI | SwiftUI (iOS 17+) |
| Architecture | MVVM with `@Observable` view models |
| Auth | Firebase Authentication |
| Database | Cloud Firestore (real-time listeners) |
| Image Storage | Base64 in Firestore documents (no Firebase Storage required) |
| Location | CoreLocation + MapKit |

## Getting Started

1. Open `PlayDate.xcodeproj` in Xcode 16+ (iOS 17+ deployment target).
2. Set up a Firebase project and drop your `GoogleService-Info.plist` into `PlayDate/`. Follow the [official Firebase iOS guide](https://firebase.google.com/docs/ios/setup). The plist is gitignored.
3. In Firebase Console, enable **Authentication → Email/Password** and create a **Firestore Database**.
4. In the Xcode target's **Info** tab, add:
   - `Privacy - Location When In Use Usage Description`
   - `Privacy - Photo Library Usage Description`
5. Build and run. On first launch, demo parents, kids, and events seed into Firestore automatically.
