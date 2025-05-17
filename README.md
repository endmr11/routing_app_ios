# 📱 Route Optimization iOS App

**Route Optimization iOS App** is the official iOS client for the Route Optimization Platform. Built with SwiftUI and Combine, this app enables users to visualize, plan, and manage optimized delivery routes with a modern, map-based interface.

## 🌐 Related Projects

- [routing_backend](https://github.com/endmr11/routing_app/tree/main/routing_backend)

## 🚀 Features

- **Interactive Map Visualization:** View optimized delivery and return routes on a dynamic map using MapKit.
- **Vehicle & Dispatch Management:** Select vehicles, assign dispatches, and create route plans with ease.
- **Real-Time API Integration:** Fetch branches, vehicles, dispatches, and routes from the backend instantly.
- **Geospatial Insights:** Visualize delivery zones, customer locations, and branch boundaries for smarter logistics.
- **Modern iOS Architecture:** Clean separation of Models, Managers, and Views for scalability and maintainability.

## 🛠️ Tech Stack

- **Swift 5**
- **SwiftUI**
- **Combine**
- **MapKit**


## ⚙️ Getting Started

### Prerequisites

- Xcode 15 or later
- iOS 16.0+
- A running instance of the [routing_backend](https://github.com/endmr11/routing_app/tree/main/routing_backend) (see backend README for setup)

### Installation

1. **Clone the repository:**
   ```sh
   git clone https://github.com/endmr11/routing_app.git
   cd routing_ios
   ```

2. **Open the project in Xcode:**
   ```
   open routing_ios.xcodeproj
   ```

3. **Configure Backend URL:**
   - By default, the app connects to `http://localhost:8070`.  
   - To use a remote backend, update the `baseURL` in `APIManager.swift`.

4. **Build & Run:**
   - Select a simulator or your device and hit **Run**.

## 🧩 Project Structure

```
routing_ios/
├── App/                # App entry point and configuration
├── Models/             # Data models (Branch, Vehicle, Dispatch, etc.)
├── Managers/           # API and business logic managers
├── Views/              # SwiftUI views and UI components
├── Assets.xcassets/    # App assets and icons
```

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!  
Feel free to check the [issues page](https://github.com/yourusername/routing_ios/issues).

## 📄 License

This project is [MIT](LICENSE) licensed.
