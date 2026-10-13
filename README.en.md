# DoctorApp

[Tiếng Việt](README.md) · **English**

DoctorApp is an appointment booking app that connects **patients** with **doctors**. Patients find doctors by specialty, request appointments, message doctors and ask an AI assistant general health questions. Doctors review appointments and reply to messages. The interface is available in English and Vietnamese.

- Web app: https://doctor-app-df8ca.web.app
- The AI assistant only works while the AI server is on (see [AI assistant](#ai-assistant)).

## User guide

### General

- **Language:** use the **EN / VI** switch at the corner of the screen.
- **Sign up:** choose *Patient* or *Doctor*, then enter your name, email, password (at least 6 characters), phone number and city. You can tap **Use current location** to save your coordinates. Doctors also enter their specialty, qualification and years of experience.
- **Sign in / out:** sign in with email and password. **Sign out** is in the *My account* tab.

### Patients

| Tab | What it does |
|---|---|
| **Find care** | Filter doctors by specialty (Dentist, Cardiology, Oncology, Surgeon) and tap a doctor to open their profile. |
| **Messages** | Your conversations with doctors. |
| **AI assistant** | General health Q&A with AI. |
| **My account** | Your appointments and their status; sign out. |

**Book an appointment:** go to *Find care*, pick a doctor, choose a date and time, describe the reason for your visit, then tap **Request appointment**. The appointment stays *pending* until the doctor responds. Track its status in *My account*.

A doctor's profile also has these buttons:
- **Call:** opens your phone dialer.
- **Directions:** opens Google Maps.
- **Message:** opens a conversation with the doctor.

**AI assistant:**
- Type a question (up to 2,000 characters) and send it. Each reply takes about 10–60 seconds.
- Each account can ask **at most 20 questions per hour**.
- The conversation is **not saved**: signing out or reloading the page clears it.
- Replies use the language selected with the EN/VI switch.
- The AI can be wrong. It does not diagnose or prescribe. In an emergency, call emergency services.

### Doctors

| Tab | What it does |
|---|---|
| **Appointments** | View patients' appointment requests. Tap a request to set it to *Accepted*, *Rejected* or *Completed*, then tap **Save status**. |
| **Messages** | Reply to patients. |
| **My account** | View your profile (email, phone, city, qualification, experience); sign out. |

## For developers

### Tech stack

| Layer | Technology |
|---|---|
| App | Flutter 3.38 / Dart ≥3.4, Material, `google_fonts`, `flutter_localizations` + `intl` |
| Backend | Firebase project `doctor-app-df8ca`: Authentication, Realtime Database, Storage, Hosting |
| Device | `location`, `url_launcher`, `image_picker`, `google_maps_flutter` |
| AI assistant | n8n 2.42.7 (webhook) → Ollama `qwen3:1.7b`, exposed to the internet with Tailscale Funnel |

Only **web** is configured in [lib/firebase_options.dart](lib/firebase_options.dart). To run on Android or iOS, run `flutterfire configure` first.

### Project layout

```
lib/
  main.dart            Firebase init, theme, locale
  splash_screen.dart   Auth check, routes to the home screen for the user's role
  auth/                Sign in, sign up
  patient/             Patient home and chat list
  doctor/              Doctor list and profile, appointments, models (Doctor, Patient, Booking)
  ai/                  AI assistant: AiChatSession (calls the webhook), AiChatPage
  chat_screen.dart     One-to-one chat
  l10n/app_strings.dart  English → Vietnamese strings, context.tr(), EN/VI switch
  ui/                  Theme, shared widgets, responsive home shell
n8n/                   AI workflow, workflow test, detailed guide
scripts/               start-n8n.ps1, register-autostart.ps1
test/                  Widget and unit tests
```

Realtime Database nodes: `Doctors`, `Patients`, `Requests` (appointments), `Chat`, `ChatList`.

### Setup

Requirements: Flutter SDK 3.38+, Chrome, Firebase CLI (`npm i -g firebase-tools`).

```powershell
git clone https://github.com/tun12348573/Flutter_doctor_app_master.git
cd Flutter_doctor_app_master
flutter pub get
```

### Run

```powershell
# Without AI
flutter run -d chrome --web-port 8080

# With AI, using n8n on this machine
flutter run -d chrome --web-port 8080 --dart-define=AI_CHAT_URL=http://localhost:5678/webhook/doctorapp-ai
```

Use port `8080`, because the webhook's CORS settings only allow `localhost:8080`. If `AI_CHAT_URL` is not set, the AI assistant tab shows *not configured*.

### Tests

```powershell
flutter analyze
flutter test
node n8n/test-workflow.cjs
```

### AI assistant

Request flow:

```
App ──POST + Firebase ID token──▶ Tailscale Funnel ──▶ n8n webhook
     ──▶ verify token with Firebase ──▶ 20 questions/hour/uid limit ──▶ Ollama ──▶ App
```

The AI server is the project owner's Windows machine:
- n8n starts at Windows logon (Task Scheduler).
- Ollama starts at logon.
- Tailscale Funnel exposes only the `/webhook/doctorapp-ai` path. The n8n editor stays on `127.0.0.1:5678`.
- While the machine is off or asleep, the AI returns a connection error. Everything else keeps working.

Setup, configuration and troubleshooting (in Vietnamese): [n8n/README.md](n8n/README.md).

### Deploy web

```powershell
flutter build web --release --dart-define=AI_CHAT_URL=https://doctorapp-ai.tail6390aa.ts.net/webhook/doctorapp-ai
firebase deploy --only hosting --project doctor-app-df8ca
```

### Contributing

When you add or change a feature, update **both** `README.md` and `README.en.md` in the same commit (see [CLAUDE.md](CLAUDE.md)).
