# Media Upload Testing Guide - PlayDate

This guide explains how to test the new Firestore-based media storage system. We have moved away from local Docker/MinIO storage to a cloud-based solution using Firestore Base64 encoding.

## 1. Prerequisites
- Ensure the app is running on an iOS Simulator or a physical device.
- Ensure the device has an internet connection to reach Firebase.
- The `GoogleService-Info.plist` must be correctly added to the Xcode project.

## 2. Testing Steps
1. **Launch the App**: The app will open directly to the **Upload Test** screen.
2. **Select a Photo**: Tap the **"Select Photo"** button. This will open the standard iOS photo picker.
3. **Choose an Image**: Select any image from the gallery.
   - *Tip: Choose a small image or a screenshot to ensure it stays under the 1MB limit.*
4. **Upload**: Tap the **"Upload to Firestore"** button.
   - You will see a loading spinner while the image is being encoded and sent to the cloud.

## 3. Expected Results
If the connection is successful:
- [ ] **Success Message**: You should see "Upload Success!" in green.
- [ ] **Data URI**: A long string starting with `data:image/jpeg;base64,...` will appear. This is the "URL" stored in the database.
- [ ] **Preview**: The image you just uploaded will be displayed again below the URL, fetched directly from the Firestore data.

## 4. Verifying in Firebase Console
To confirm the data is actually in the database:
1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Navigate to **Firestore Database**.
3. Look for a collection named `media_storage`.
4. You should see a document with a field named `data` containing the Base64 string.

## 5. Known Limitations
- **File Size**: Firestore has a **1MB limit** per document. If an upload fails with a "413" error, the image is too large.
- **Cost**: This method uses Firestore write operations. For a high volume of large images, Firebase Storage is the better long-term (but potentially paid) alternative.
