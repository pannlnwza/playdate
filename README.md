# PlayDate iOS App

PlayDate is a dedicated iOS mobile application designed to bridge the gap between digital interaction and physical play. Parents swipe to find playmates for their kids, chat to coordinate, and join family-friendly events nearby.

## Tech Stack

| Area | Choice |
|---|---|
| UI | SwiftUI (iOS 17+) |
| Architecture | MVVM with `@Observable` view models |
| Auth | Firebase Authentication (email/password) |
| Database | Cloud Firestore (real-time listeners for chat and notifications) |
| Image Storage | Base64-encoded images stored in Firestore documents (no Firebase Storage required, works on the Spark free plan) |
| Location | CoreLocation + MapKit's `MKLocalSearchCompleter` |

## Getting Started

### 1. Prerequisites
- Xcode 16 or later
- iOS 17+ deployment target
- A Firebase project (free Spark plan is fine)

### 2. Clone the repo
```bash
git clone https://github.com/pannlnwza/playdate.git
cd playdate
```

### 3. Set up Firebase

Create a Firebase project and register an iOS app, then drop the generated `GoogleService-Info.plist` into the `PlayDate/` folder. The file is **gitignored** (it identifies your project and shouldn't live in source control).

Follow the official Firebase iOS setup guide: <https://firebase.google.com/docs/ios/setup>

You'll also need to enable in your Firebase Console:
- **Authentication** → **Sign-in method** → **Email/Password**
- **Firestore Database** → create one (start in test mode is fine for development)

### 4. Add the Info.plist privacy keys

In Xcode → select the PlayDate target → **Info** tab → add:
- `Privacy - Location When In Use Usage Description` → `"PlayDate uses your location to show nearby families."`
- `Privacy - Photo Library Usage Description` → `"PlayDate needs access to your photos to add profile and child photos."`

### 5. Build and run
- Open `PlayDate.xcodeproj` in Xcode
- Select an iPhone simulator (or your connected device)
- ⌘R to build and run

On first launch, the app seeds three demo parent profiles (Sarah, Mike, Aisha) and their children + sample events into your Firestore so you can immediately swipe and join events.

## Features

- **Auth**: Email/password sign in/up via FirebaseAuth, persisted across launches
- **Discover**: Tinder-style swipeable child cards with filters (age, hobbies, going to same event)
- **Matching**: Real reciprocity check (both sides must swipe right, with auto-match for seed parents)
- **Chat**: Real-time messaging with Firestore snapshot listeners, unread badge on tab
- **Events**: Browse, filter by category, join/leave, create your own with cover photo and `MKLocalSearch` location picker
- **Notifications**: Live updates on matches, mark-as-read, unread badge on bell icon
- **Profile**: Edit name/bio/location with reverse-geocoded coordinates, manage children with photo galleries
