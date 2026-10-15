# DoctorApp

[Tiếng Việt](README.md) · **English**

DoctorApp is an appointment booking and medicine ordering app that connects **patients**, **doctors** and a **pharmacy**. Patients can:
- Find doctors by specialty, request appointments and message doctors.
- Look up medicines and order over-the-counter ones (cash on delivery).
- Ask an AI assistant general health and medicine questions.

Doctors review appointments. The pharmacy processes orders and manages inventory. The interface is available in English and Vietnamese.

- Web app: https://doctor-app-df8ca.web.app
- The AI assistant only works while the AI server is on (see [AI assistant](#ai-assistant)).
- Medicine data is **demo data** (written in Vietnamese). Read the package leaflet and ask a pharmacist before taking any medicine.

## User guide

### General

- **Language:** use the **EN / VI** switch at the corner of the screen.
- **Dark mode:** the app follows the light/dark setting of your device or browser.
- **Sign up:** choose *Patient* or *Doctor*, then enter your name, email, password (at least 6 characters), phone number and city. You can tap **Use current location** to save your coordinates. Doctors also enter their specialty, qualification and years of experience.
- **Pharmacist** accounts cannot sign up themselves; an administrator grants them (see [Granting a pharmacist account](#granting-a-pharmacist-account)).
- **Sign in / out:** sign in with email and password; the app opens the screens for your role. **Sign out** is in the *My account* tab.

### Patients

| Tab | What it does |
|---|---|
| **Find care** | Filter doctors by specialty (Dentist, Cardiology, Oncology, Surgeon) and tap a doctor to open their profile. |
| **Pharmacy** | Search medicines, view details, add to cart and order. |
| **Messages** | Your conversations with doctors. |
| **AI assistant** | General health Q&A with AI. |
| **My account** | Your appointments and **medicine orders** with their status, order cancellation, sign out. |

**Book an appointment:** go to *Find care*, pick a doctor, choose a date and time, describe the reason for your visit, then tap **Request appointment**. The appointment stays *pending* until the doctor responds. Track its status in *My account*.

A doctor's profile also has these buttons:
- **Call:** opens your phone dialer.
- **Directions:** opens Google Maps.
- **Message:** opens a conversation with the doctor.

**Buying medicine:**
1. Open the *Pharmacy* tab. Type a medicine name or active ingredient in the search box, or filter by category (Pain & fever, Cough & cold, Digestive, Vitamins & minerals, Allergy, Skin care, Eye, ear & nose, Antibiotics, Heart & blood pressure, Diabetes).
2. Tap a medicine to see its **active ingredient, dosage form, uses, how to use, contraindications, side effects** and price.
3. Tap **Add to cart**. Medicines tagged *Out of stock* cannot be bought.
   - Medicines tagged **Prescription** are view-only. Instead of a buy button they show **Book an appointment**.
4. Tap the cart icon at the top to change quantities (up to the number left in stock). Fill in your full name, phone number (prefilled from your profile), delivery address and note, then tap **Place order (cash on delivery)**.
5. Track the order in *My account → Your medicine orders*. The statuses go *Awaiting confirmation → Shipping → Delivered*, or *Cancelled*. You can tap **Cancel order** while it is still *Awaiting confirmation*.

**AI assistant:**
- Type a question (up to 2,000 characters) and send it. Each reply takes about 10–60 seconds.
- Each account can ask **at most 20 questions per hour**.
- **Asking about a medicine:** on a medicine's detail page, tap **Ask AI about this medicine**. The AI answers using that medicine's catalog information. An *About: …* chip appears above the input; tap its × to go back to general questions.
- The conversation is **not saved**: signing out or reloading the page clears it.
- Replies use the language selected with the EN/VI switch.
- The AI can be wrong. It does not diagnose, prescribe, or suggest doses for prescription medicines. In an emergency, call emergency services.

### Doctors

| Tab | What it does |
|---|---|
| **Appointments** | View patients' appointment requests. Tap a request to set it to *Accepted*, *Rejected* or *Completed*, then tap **Save status**. |
| **Messages** | Reply to patients. |
| **My account** | View your profile (email, phone, city, qualification, experience) and verification status; sign out. |

A newly registered doctor sees *Awaiting verification: patients cannot find you yet*. Doctors appear in *Find care*, receive appointments and can read patient profiles only after an administrator verifies them (see [Verifying a doctor](#verifying-a-doctor)). The status then changes to *Verified*.

### Pharmacists

| Tab | What it does |
|---|---|
| **Orders** | Filter orders by status. Each order shows its medicines, total, and the customer's name, phone, address and note. |
| **Inventory** | Medicines with their stock, sorted lowest stock first. Search, filter **Low stock** (≤ 10), restock, set stock, add and edit medicines. |
| **My account** | Account email; sign out. |

**Processing orders:**
- **Confirm and ship:** the app takes each item from stock, then moves the order to *Shipping*. If an item is short, the app shows *Not enough stock for …*, leaves stock unchanged and keeps the order *Awaiting confirmation*.
- **Mark delivered:** moves the order to *Delivered*.
- **Cancel order:** moves the order to *Cancelled*. If the order was already confirmed, its items **go back into stock**.

**Inventory:**
- Tap ⋮ on a medicine and choose:
  - **Restock:** adds the quantity received.
  - **Set stock:** sets the exact count.
- Tap a medicine to edit its details. Stock is not edited there.
- Tap **Add medicine** to create a new one with its initial stock, and mark *Prescription only* if needed.

## For developers

### Tech stack

| Layer | Technology |
|---|---|
| App | Flutter 3.38 / Dart ≥3.4, Material 3 (light + dark theme), Lexend + Noto Sans fonts (Vietnamese glyphs, bundled), `flutter_localizations` + `intl` |
| Backend | Firebase project `doctor-app-df8ca`: Authentication, Realtime Database (rules in [database.rules.json](database.rules.json)), Storage, Hosting |
| Device | `location`, `url_launcher`, `image_picker`, `google_maps_flutter` |
| AI assistant | n8n 2.42.7 (webhook) → Ollama `qwen3:1.7b`, exposed to the internet with Tailscale Funnel |
| Rules tests | Firebase Database Emulator (needs Java) + `@firebase/rules-unit-testing` |

Only **web** is configured in [lib/firebase_options.dart](lib/firebase_options.dart). To run on Android or iOS, run `flutterfire configure` first.

### Project layout

```
lib/
  main.dart            Firebase init, theme, locale
  splash_screen.dart   Auth check, routes to the home screen for the user's role
  auth/                Sign in, sign up, role_home.dart (Doctors → Pharmacists → Patients)
  patient/             Patient home and chat list
  doctor/              Doctor list and profile, appointments, models (Doctor, Patient, Booking)
  pharmacy/            Patient pharmacy: catalog, details, cart, my orders,
                       PharmacyStore (Firebase reads/writes), Drug and DrugOrder models
  pharmacist/          Pharmacist role: orders, inventory, add/edit medicine form
  ai/                  AI assistant: AiChatSession (calls the webhook, sends drugId), AiChatPage
  chat_screen.dart     One-to-one chat
  l10n/app_strings.dart  English → Vietnamese strings, context.tr(), EN/VI switch
  ui/                  Theme, shared widgets, responsive home shell
assets/fonts/          Lexend, Noto Sans (TTF) and their OFL licences
data/drugs.json        41 demo medicines
database.rules.json    Realtime Database security rules
n8n/                   AI workflow, workflow test, detailed guide
scripts/               start-n8n.ps1, register-autostart.ps1, seed-drugs.ps1, add-pharmacist.ps1,
                       migrate-chat.ps1, verify-doctor.ps1
test/                  Widget and unit tests; test/rules/ tests the security rules
```

Realtime Database nodes:

| Node | Contents | Access |
|---|---|---|
| `Doctors` | Doctor profiles, `verified` | Readable when signed in. Only the owner writes, and cannot change `verified` |
| `Patients/<uid>` | Patient profiles | The owner and verified doctors read; only the owner writes |
| `Requests` | Appointments | Patient creates, only for verified doctors. Doctor updates status (`Accepted`, `Rejected`, `Completed`) |
| `Chat/<uidA_uidB>` | One conversation's messages (the two uids in sorted order) | Only the two participants read it; the sender creates messages |
| `ChatList/<uid>` | Who each user has chatted with | Only the owner reads |
| `Pharmacists/<uid>` | Pharmacist role marker | Nobody can write from the app |
| `Drugs/<id>` | Medicine info, `price`, `stock`, `prescription` | Readable when signed in; only pharmacists write |
| `Carts/<uid>` | `{drugId: quantity}` | Owner only; prescription medicines rejected |
| `Orders/<id>` | Orders | Patient creates and reads own orders, can only cancel while `pending`. Pharmacists read all and change `status`, `stockDeducted` |

The rules check that each order item's price and name match `Drugs`, so clients cannot change prices. Stock is taken when a pharmacist confirms an order, with a transaction on `Drugs/<id>/stock`.

### Setup

Requirements: Flutter SDK 3.38+, Chrome, Firebase CLI (`npm i -g firebase-tools`). To run the rules tests you also need Node.js 22+ and Java 11+.

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

### Medicine data

```powershell
powershell -ExecutionPolicy Bypass -File scripts/seed-drugs.ps1
```

This loads [data/drugs.json](data/drugs.json) into `Drugs`. Medicines with the same `id` are **overwritten, including stock**; others are kept. The content is demo data and needs review by a qualified person before real use.

### Granting a pharmacist account

1. Firebase Console → Authentication → **Add user**: enter an email and password, then copy the **User UID**.
2. Run:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/add-pharmacist.ps1 -Uid <USER_UID> -Email <email>
# Revoke: add -Remove
```

### Verifying a doctor

Doctors register in the app, but patients only see them once they are verified. Check the doctor's credentials, copy their **User UID** from Firebase Console → Authentication, then run:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/verify-doctor.ps1 -Uid <USER_UID>
# Un-verify: add -Remove
```

After deploying these rules for the first time, doctors who registered earlier must be verified the same way.

### Tests

```powershell
flutter analyze
flutter test
node n8n/test-workflow.cjs

# Security rules (starts the emulator, needs Java)
cd test/rules; npm install; npm test
```

### AI assistant

Request flow:

```
App ──POST + Firebase ID token (+ drugId)──▶ Tailscale Funnel ──▶ n8n webhook
     ──▶ verify token with Firebase ──▶ 20 questions/hour/uid limit
     ──▶ drugId? read Drugs/<id> with the patient's token and add it to the prompt
     ──▶ Ollama ──▶ App
```

The AI server is the project owner's Windows machine:
- n8n starts at Windows logon (Task Scheduler).
- Ollama starts at logon.
- Tailscale Funnel exposes only the `/webhook/doctorapp-ai` path. The n8n editor stays on `127.0.0.1:5678`.
- While the machine is off or asleep, the AI returns a connection error. Everything else keeps working.

Setup, configuration and troubleshooting (in Vietnamese): [n8n/README.md](n8n/README.md).

### Deploy

```powershell
firebase deploy --only database --project doctor-app-df8ca   # rules; run the rules tests first
flutter build web --release --dart-define=AI_CHAT_URL=https://doctorapp-ai.tail6390aa.ts.net/webhook/doctorapp-ai
firebase deploy --only hosting --project doctor-app-df8ca
```

Deploying the database **replaces** the rules in Firebase Console with `database.rules.json`.

If the database still has old-style messages (directly under `Chat`), run this **before** deploying the rules. It moves them to `Chat/<uidA_uidB>` and saves a backup in `.local/`. It is safe to run more than once.

```powershell
powershell -ExecutionPolicy Bypass -File scripts/migrate-chat.ps1
```

### Contributing

When you add or change a feature, update **both** `README.md` and `README.en.md` in the same commit (see [CLAUDE.md](CLAUDE.md)).
