## **Scan Guarantee**

ScanGuarantee is an iOS app that helps you store and manage warranty certificates in one place. The app allows users to scan or manually add warranties, automatically extract important data using OCR, and receive notifications before warranties expire.

**Note:** All data is stored locally on the device using SwiftData. The app uses on-device OCR (Vision framework) — no external servers are involved.

## **Tech Stack**
- **Language:** Swift  
- **Framework:** SwiftUI
- **Architecture**: MVVM
- **Data Storage:** SwiftData, UserDefaults
- **OCR:** Vision Framework(on-device text recognition)
- **Notifications:** UserNotifications
- **Platform:** iOS (minimum version — 17)
- **Devices:** any, starting from iPhone 11

---

## **Features**

### 1. Home Screen

- Displays a list of all saved warranty certificates.
- Filtering (All / Active / Expiring soon(within 7 days / Expired)
- Search by product name.
- Clean and minimal UI

### 2. Custom TabBar 

A fully custom-built tab bar designed for filtering and searching warranties in a compact and interactive way.

- Horizontally scrollable filter chips (All | Active | Expiring soon | Expired)
- Smooth animated transitions between states.
- Integrated expandable search bar:
    * Expands inline within the tab bar.
    * Automatically shifts content using custom layout logic.
    * Activates keyboard with smooth animation.
- Dynamic UI behavior:
    * Filters are disabled while search is active.
    * Search resets selected filter to default.
    * “Close” button appears when typing.
- Built with:
    * ScrollView + custom layout logic (no TabView)
    * @FocusState for keyboard handling
    * VisualEffect for dynamic offset animation

### 3. Add Certificate

- Add warranty manually or via image.
- Import image from gallery.
- OCR automatically extracts (Product name / Purchase date / Warranty period / Expiration date)
- Ability to edit extracted data before saving.
- Image of the certificate is stored locally.

### 4. Detail Screen

- Full information about the warranty (Product name / Expiration date / Serial number (if available) / Seller info (optional))
- Displays remaining days or overdue status.
- Shows attached certificate image.
- Edit and delete functionality.

### 5. Notifications
- Automatic reminder before warranty expiration.
- Default: notification 7 days before.
- Smart fallback

If less than 7 days remain → notify next day (or today if before 10:00).
Ability to disable notifications per certificate.
Handles permission state and guides user to Settings if needed.

### 6. OCR Processing
- Uses Apple's Vision framework.
- Works with both printed and handwritten text (basic support).
- Smart parsing:
- Handles different formats like: “Warranty for 12 months” or “Valid until DD.MM.YYYY”
- Extracted raw text can be logged for debugging and improving parsing accuracy.

### 7. Adaptive Interface
- Supports all devices from iPhone 8 and newer.
- Minimum iOS version — 17.
- Smooth animations and custom UI (no NavigationStack usage).

### 8. Clean Architecture
- MVVM architecture.
- Clear separation of UI (SwiftUI Views), Business logic (ViewModels), Services (OCR, Notifications)
- Local-first approach (no backend required).

---
https://github.com/user-attachments/assets/b70161d9-679e-4f33-997f-d85869e52342
