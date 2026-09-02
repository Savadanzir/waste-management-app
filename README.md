♻️ What is the Project?

The Waste Management System is a digital platform designed to improve the way waste is reported, collected, monitored, and managed.

The system allows users to report waste-related issues such as garbage accumulation or uncollected waste through a mobile application. The information can then be managed by the responsible authorities or waste-management staff through the system.

The project can help connect citizens, waste collectors, and administrators in a single platform. It provides a more organized way to track waste-collection activities and address waste-related problems.


# ♻️ Waste Management System

A Waste Management System designed to manage waste-related activities through a web/backend application and Flutter mobile application.

## 📋 Project Overview

The project consists of two main parts:

* **Backend / Web Application** — Node.js-based application and API
* **Mobile Application** — Flutter-based Android application

The Flutter application communicates with the backend through APIs.

---
Main functions

📱 Report waste or garbage-related issues
📍 Provide the location of the reported waste
🗑️ Track waste-collection requests
👨‍💼 Allow administrators to manage reports
🚛 Help waste-management staff identify collection requirements
📊 Monitor waste-management activities
🔄 Update the status of reported complaints
📱 Provide access through a Flutter mobile application


🎯 What is the Need for the Project?

Traditional waste management often depends on manual complaints, phone calls, or physical inspections. This can make it difficult for authorities to know where waste has accumulated, how long it has been there, and whether it has been collected.

The Waste Management System is needed to solve these problems by providing a centralized digital platform.

Major needs of the project

1. Improves waste reporting

Citizens can report garbage problems easily instead of having to visit an office or make repeated phone calls.

2. Faster response

When a waste issue is reported digitally, the responsible staff can identify the problem and take appropriate action more quickly.

3. Location-based reporting

The location of the waste can help collection teams find the exact area that requires attention.

4. Better monitoring

Administrators can monitor reported complaints and check whether they are pending, assigned, in progress, or completed.

5. Reduces manual work

Digital records reduce dependence on paper-based complaints and manual record keeping.

6. Improves cleanliness

Faster identification and collection of accumulated waste can contribute to cleaner public spaces and better environmental conditions.

7. Creates accountability

The status of each complaint can be tracked, making it easier to determine whether reported waste has actually been addressed.
# 🚀 How to Run the Project

## 1. Pre requisites

Install the following software before running the project:

### Backend

* Node.js 18 or later
* npm
* Git
* Visual Studio Code

Check the installation:

```bash
node --version
npm --version
git --version
```

### Flutter

* Flutter SDK
* Android Studio
* Android SDK
* Android Emulator or physical Android phone
* Visual Studio Code or Android Studio

Check Flutter:

```bash
flutter --version
flutter doctor
```

Make sure `flutter doctor` does not show any critical configuration errors.

---

# 🖥️ Backend Setup

## 2. Clone the Repository

Clone the GitHub repository:

```bash
git clone https://github.com/your-username/waste-management-system.git
```

Move into the project:

```bash
cd waste-management-system
```

---

## 3. Install Backend Dependencies

Navigate to the backend folder:

```bash
cd backend
```

Install the required Node.js packages:

```bash
npm install
```

This installs the dependencies listed in `package.json`.

---

## 4. Configure Environment Variables

If the project contains a `.env.example` file, create a `.env` file.

Example:

```env
PORT=5000
DATABASE_URL=your_database_connection
```

Configure the values according to your local environment.

> Never upload passwords, API keys, database credentials, or other secrets to GitHub.

---

## 5. Start the Backend

Start the development server:

```bash
npm run dev
```

If the project uses the standard start script:

```bash
npm start
```

The terminal should display the address/port on which the backend is running.

For example:

```text
Server running on port 5000
```

Keep this terminal running.

---

# 📱 Flutter Mobile Application

## 6. Navigate to the Flutter Project

Open a **new terminal** and navigate to the Flutter application folder:

```bash
cd flutter_app
```

Make sure this folder contains:

```text
pubspec.yaml
```

---

## 7. Install Flutter Dependencies

Run:

```bash
flutter pub get
```

This downloads all Flutter/Dart packages required by the application.

---

## 8. Check Flutter Configuration

Run:

```bash
flutter doctor
```

If there are Android configuration issues, follow the instructions provided by Flutter Doctor.

You can also check available devices:

```bash
flutter devices
```

---

# 🤖 Run Using Android Emulator

## 9. Start Android Emulator

Open **Android Studio**.

Go to:

**Tools → Device Manager**

Create an Android Virtual Device if necessary.

Start the emulator and wait until Android has completely loaded.

Then run:

```bash
flutter devices
```

The emulator should appear in the device list.

---

## 10. Run the Flutter Application

Run:

```bash
flutter run
```

Flutter will launch the application on the selected Android device.

If multiple devices are available, specify the device:

```bash
flutter run -d emulator-5554
```

Replace `emulator-5554` with the device ID shown by:

```bash
flutter devices
```

---

# 📲 Run Using a Physical Android Phone

## 11. Enable Developer Options

On your Android phone:

**Settings → About Phone → Build Number**

Tap **Build Number** several times until Developer Options are enabled.

Then open:

**Settings → Developer Options**

Enable:

**USB Debugging**

Connect your phone to the computer using a USB cable.

When Android displays:

```text
Allow USB debugging?
```

select:

**Allow**

Check the device:

```bash
flutter devices
```

If your phone appears, run:

```bash
flutter run
```

The application will be installed and launched on your phone.

---

# 🔗 Backend + Flutter Configuration

## 12. Run Both Applications

If the Flutter application communicates with the Node.js backend, both applications must be running.

### Terminal 1 — Backend

```bash
cd backend
npm install
npm run dev
```

Keep this terminal open.

### Terminal 2 — Flutter

```bash
cd flutter_app
flutter pub get
flutter run
```

The communication flow is:

```text
             API Requests
┌─────────────────────────────┐
│      Flutter Mobile App     │
│                             │
│       Android Device        │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│       Node.js Backend       │
│                             │
│          REST API            │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│          Database           │
└─────────────────────────────┘
```

---

# 🌐 API / Backend URL

## 13. Configure the API Address

If the Flutter application connects to the Node.js backend running on your computer, make sure the API URL is configured correctly.

For example, the backend might run at:

```text
http://localhost:5000
```

However, when using an **Android Emulator**, `localhost` normally refers to the emulator itself.

For the standard Android Emulator, the computer's localhost can commonly be accessed using:

```text
http://10.0.2.2:5000
```

For a physical Android phone, use your computer's local network IP address:

```text
http://192.168.1.10:5000
```

Your phone and computer should normally be connected to the same Wi-Fi network.

> Use the API URL already configured in this project if one exists.

---

# 🔥 Flutter Hot Reload

While the Flutter application is running, changes can be updated using hot reload.

Press:

```text
r
```

in the Flutter terminal.

For a full restart:

```text
R
```

This makes Flutter development faster because you do not need to completely restart the application after every code change.

---

# 🛑 Stop the Applications

## Stop Flutter

Press:

```text
q
```

or:

```text
Ctrl + C
```

## Stop Node.js Backend

Press:

```text
Ctrl + C
```

in the backend terminal.

---

# 🧹 Clean Flutter Project

If you encounter Flutter build or dependency problems:

```bash
flutter clean
```

Then:

```bash
flutter pub get
```

Finally:

```bash
flutter run
```

Complete command:

```bash
flutter clean
flutter pub get
flutter run
```

---

# 🔧 Troubleshooting

## Flutter command not found

Check:

```bash
flutter doctor
```

If Flutter is not recognized, add the Flutter SDK's `bin` directory to your system PATH.

---

## No Android Device Found

Run:

```bash
flutter devices
```

If no device appears:

* Start the Android Emulator.
* Check that USB Debugging is enabled.
* Reconnect the Android phone.
* Make sure Android SDK is installed.
* Run `flutter doctor`.

---

## Android License Error

Run:

```bash
flutter doctor --android-licenses
```

Accept the required licenses.

Then run:

```bash
flutter doctor
```

again.

---

## Flutter Dependency Error

Try:

```bash
flutter clean
flutter pub get
flutter run
```

---

## Backend Connection Error

Make sure the backend is running:

```bash
npm run dev
```

Then check the API URL configured in the Flutter application.

For an Android Emulator, remember:

```text
localhost
```

is different from:

```text
10.0.2.2
```

---

# 📦 Build Android APK

To generate a release APK:

```bash
flutter build apk --release
```

The APK will normally be generated inside:

```text
build/app/outputs/flutter-apk/
```

You can install the generated APK on a compatible Android device.

---

# 🔄 Quick Start

For future development, the complete process is:

### Backend

```bash
cd backend
npm install
npm run dev
```

### Flutter

Open another terminal:

```bash
cd flutter_app
flutter pub get
flutter devices
flutter run
```

That's it! The Node.js backend and Flutter mobile application should now be running together.

