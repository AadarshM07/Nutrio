# 🥗 Nutrio

**Nutrio** is an AI-powered nutrition and health assistant application that helps users track their food intake, analyze nutritional content, and get personalized dietary recommendations based on their health profile.

---

## 📋 Table of Contents

- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Architecture](#-architecture)
- [Folder Structure](#-folder-structure)
- [Prerequisites](#-prerequisites)
- [Setup & Installation](#-setup--installation)
  - [Backend Setup](#backend-setup)
  - [Frontend Setup](#frontend-setup)
- [Running the Application](#-running-the-application)
- [API Endpoints](#-api-endpoints)
- [License](#-license)

---

## ✨ Features

- 🔐 **User Authentication** - Secure signup/login with JWT tokens
- 📊 **Health Profile** - Track health issues, dietary preferences, goals, weight, and height
- 📷 **Barcode Scanner** - Scan food products to get nutritional information
- 🤖 **AI Chat Assistant** - Get personalized nutrition advice powered by Google Gemini AI
- 📦 **Inventory Management** - Track scanned products with AI-generated feedback
- 📈 **Dashboard** - View nutrition insights and health analytics
- 🔍 **Product Search** - Search and analyze food products via OpenFoodFacts API
- 📚 **RAG-based Recommendations** - Context-aware responses using ChromaDB vector database

---

## 🛠 Tech Stack

### Backend
| Technology | Purpose |
|------------|---------|
| **FastAPI** | Modern, high-performance Python web framework |
| **PostgreSQL** | Primary relational database |
| **SQLModel** | SQL database ORM (SQLAlchemy + Pydantic) |
| **Alembic** | Database migrations |
| **ChromaDB** | Vector database for RAG (Retrieval Augmented Generation) |
| **Google Gemini AI** | AI/LLM for chat and nutrition analysis |
| **Uvicorn** | ASGI server |
| **asyncpg** | Async PostgreSQL driver |
| **Pydantic** | Data validation and settings management |
| **python-jose** | JWT token handling |
| **bcrypt/passlib** | Password hashing |

### Frontend
| Technology | Purpose |
|------------|---------|
| **Flutter** | Cross-platform mobile/web UI framework |
| **Dart** | Programming language |
| **shared_preferences** | Local storage for auth tokens |
| **http** | HTTP client for API calls |
| **mobile_scanner** | Barcode scanning functionality |
| **openfoodfacts** | OpenFoodFacts API integration |
| **fl_chart** | Charts and data visualization |
| **permission_handler** | Device permissions management |


---

## 📁 Folder Structure

```
Nutrio/
├── README.md
├── LICENSE
│
├── backend/                    # FastAPI Backend
│   ├── alembic.ini            # Alembic configuration
│   ├── requirements.txt       # Python dependencies
│   ├── sample.env             # Environment variables template
│   │
│   ├── alembic/               # Database migrations
│   │   ├── README
│   │   └── script.py.mako
│   │
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py            # FastAPI app entry point
│   │   ├── config.py          # Settings & configuration
│   │   ├── database.py        # Database connection
│   │   ├── models.py          # SQLModel database models
│   │   │
│   │   ├── schemas/           # Pydantic request/response schemas
│   │   │   ├── auth.py
│   │   │   ├── dashboard.py
│   │   │   ├── internal.py
│   │   │   └── inventory.py
│   │   │
│   │   ├── services/          # API route handlers
│   │   │   ├── auth.py        # Authentication endpoints
│   │   │   ├── chat.py        # AI chat endpoints
│   │   │   ├── dashboard.py   # Dashboard endpoints
│   │   │   ├── internal.py    # Internal/v1 endpoints
│   │   │   └── invertory.py   # Inventory management
│   │   │
│   │   └── integrations/      # External service integrations
│   │       ├── app.py         # Nutrition analyzer
│   │       ├── embedding.py   # Embedding functions
│   │       ├── memory.py      # Chat memory management
│   │       ├── rag_utils.py   # RAG utilities
│   │       ├── chroma-db/     # ChromaDB vector store
│   │       └── data/          # Training/reference data
│   │
│   └── chroma-db/             # ChromaDB persistence
│
└── frontend/                   # Flutter Frontend
    ├── pubspec.yaml           # Flutter dependencies
    ├── analysis_options.yaml  # Dart linting rules
    │
    ├── lib/
    │   ├── main.dart          # App entry point
    │   └── pages/
    │       ├── auth/          # Login/Signup screens
    │       ├── survey/        # Health profile survey
    │       ├── constants/     # App constants
    │       └── dashboard/     # Main app screens
    │           ├── dashboard.dart
    │           ├── home/      # Home tab
    │           ├── search/    # Product search
    │           ├── inventory/ # Saved products
    │           ├── chat/      # AI chat interface
    │           └── profile/   # User profile
    │
    ├── assets/                # Images, fonts, etc.
    ├── android/               # Android-specific config
    ├── ios/                   # iOS-specific config
    ├── linux/                 # Linux desktop config
    ├── macos/                 # macOS desktop config
    ├── windows/               # Windows desktop config
    ├── web/                   # Web build config
    └── test/                  # Widget tests
```

---

## 📦 Prerequisites

Before setting up the project, ensure you have the following installed:

- **Python 3.10+** - [Download](https://www.python.org/downloads/)
- **PostgreSQL 14+** - [Download](https://www.postgresql.org/download/)
- **Flutter SDK 3.10+** - [Install Guide](https://docs.flutter.dev/get-started/install)
- **Dart SDK** (included with Flutter)
- **Git** - [Download](https://git-scm.com/)

---

## 🚀 Setup & Installation

### Backend Setup

1. **Navigate to the backend directory:**
   ```bash
   cd backend
   ```

2. **Create a virtual environment:**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

4. **Create the environment file:**
   ```bash
   cp sample.env .env
   ```

5. **Configure environment variables in `.env`:**
   ```env
   DATABASE_URL=postgresql+asyncpg://username:password@localhost:5432/nutrio
   GEMINI_API=your_google_gemini_api_key
   ```
   
   > 📝 **Getting a Gemini API Key:**
   > 1. Go to [Google AI Studio](https://aistudio.google.com/)
   > 2. Sign in with your Google account
   > 3. Navigate to "Get API Key" and create a new key

6. **Set up PostgreSQL database:**
   ```bash
   # Connect to PostgreSQL
   psql -U postgres
   
   # Create the database
   CREATE DATABASE nutrio;
   
   # Exit
   \q
   ```

7. **Run database migrations (optional, tables auto-create on startup):**
   ```bash
   alembic upgrade head
   ```

---

### Frontend Setup

1. **Navigate to the frontend directory:**
   ```bash
   cd frontend
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoint:**
   
   Update the API base URL in your service files to point to your backend:
   - For local development: `http://localhost:8000` or `http://10.0.2.2:8000` (Android emulator)
   - For physical device: Use your machine's IP address

4. **Verify Flutter setup:**
   ```bash
   flutter doctor
   ```

---

## ▶️ Running the Application

### Start the Backend

```bash
cd backend
source venv/bin/activate  # Activate virtual environment
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

The API will be available at:
- **API:** http://localhost:8000
- **Swagger Docs:** http://localhost:8000/docs
- **ReDoc:** http://localhost:8000/redoc

### Start the Frontend

```bash
cd frontend

# Run on connected device/emulator
flutter run

# Run on specific platform
flutter run -d chrome      # Web
flutter run -d linux       # Linux desktop
flutter run -d android     # Android device/emulator
flutter run -d ios         # iOS device/simulator
```

---

## 🔌 API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/auth/signup` | POST | Register new user |
| `/auth/login` | POST | User login |
| `/auth/validate` | GET | Validate JWT token |
| `/v1/...` | - | Internal endpoints |
| `/chat/` | POST | Send message to AI assistant |
| `/inv/` | GET/POST | Manage inventory items |
| `/dashboard/` | GET | Get dashboard analytics |

> 📖 For complete API documentation, visit `http://localhost:8000/docs` when the backend is running.

---

## 🔧 Development Tips

- **Hot Reload:** Both Flutter (`r` key) and FastAPI (`--reload` flag) support hot reloading
- **Database Changes:** Use Alembic for migrations: `alembic revision --autogenerate -m "description"`
- **Testing:** Run Flutter tests with `flutter test`
- **Linting:** Run `flutter analyze` to check for issues

---

## 📄 License

This project is licensed under the terms specified in the [LICENSE](LICENSE) file.

---

---

<p align="center">
  Made with ❤️ for healthier eating habits
</p>
