# Employee Management System

A full-stack employee management and authentication system featuring a cross-platform mobile application built with Flutter, backed by a RESTful Node.js/Express API, and powered by MongoDB.

---

## Features

* **Unified Authentication**: Seamless login and registration workflows supporting authentication via Email Address or numerical Employee ID.
* **Complete CRUD Operations**: Add, browse, search, update, and remove employee records with real-time UI synchronisation.
* **Flexible Image Handling**: Supports device camera photo capture, gallery image selection (encoded to Base64), direct web image URLs, and automatic fallback avatars.
* **Instant Dynamic Search**: Query employee directory records across name, role, and department.
* **Clean Modern UI**: Built with a responsive card-based layout, subtle elevation shadows, and custom form validation.

---

## Tech Stack

| Layer | Technology |
| --- | --- |
| **Mobile Client** | Flutter (Dart), `image_picker`, `http` |
| **Backend API** | Node.js, Express.js |
| **Database** | MongoDB, Mongoose ODM |
| **Authentication** | Unified Mongoose Employee Schema |

---

## Project Structure

```text
├── employee-backend/
│   ├── controllers/
│   │   ├── auth.controller.js       # Register and login handling
│   │   └── employee.controller.js   # Employee CRUD logic & queries
│   ├── models/
│   │   └── employee.model.js        # Mongoose Employee schema
│   ├── routes/                      # Express route endpoints
│   ├── index.js                     # Server entry point & body parser config
│   └── package.json
│
└── login_app/                       # Flutter Application
    ├── lib/
    │   ├── models/
    │   │   └── employee_model.dart  # Data model & JSON serialization
    │   ├── screens/
    │   │   ├── login_screen.dart    # Login & registration toggle view
    │   │   ├── employee_list_screen.dart # Directory list & search view
    │   │   └── add_edit_screen.dart # Employee creation & edit form
    │   ├── services/
    │   │   └── api_service.dart     # HTTP client service
    │   └── main.dart
    └── pubspec.yaml

```

---

## Getting Started

### 1. Prerequisites

* [Node.js](https://nodejs.org/) (v16+ recommended)
* [MongoDB](https://www.mongodb.com/) (local instance running on `localhost:27017` or MongoDB Atlas URI)
* [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.0+)
* Android Studio / VS Code with Flutter and Dart plugins

---

### 2. Backend Setup

1. Navigate to the backend directory:
```bash
cd employee-backend

```


2. Install dependencies:
```bash
npm install

```


3. Verify your MongoDB connection string in your database configuration/`.env` file:
```env
PORT=5000
MONGO_URI=mongodb://localhost:27017/employee_db

```


4. Start the server:
```bash
npm run serve
# or
npm start

```



---

### 3. Flutter App Setup

1. Navigate to the Flutter application directory:
```bash
cd login_app

```


2. Fetch dependencies:
```bash
flutter pub get

```


3. Set your backend base URL in `lib/services/api_service.dart`:
* **Android Emulator**: `[http://10.0.2.2:5000/api](http://10.0.2.2:5000/api)`
* **Physical Device**: `http://<YOUR_LOCAL_IP>:5000/api`


4. Launch the application:
```bash
flutter run

```



---

## API Endpoints

### Authentication

* `POST /api/auth/register` - Create a new employee account with login credentials.
* `POST /api/auth/login` - Authenticate using Email or Employee ID and password.

### Employee Management

* `GET /api/employee` - Fetch all employee records (supports `?search=keyword`).
* `GET /api/employee/:id` - Fetch single employee details by ID.
* `POST /api/employee` - Create a new employee profile.
* `PUT /api/employee/:id` - Update employee details and optional password changes.
* `DELETE /api/employee/:id` - Delete an employee record.
