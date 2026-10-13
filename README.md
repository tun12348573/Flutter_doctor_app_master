# DoctorApp

**Tiếng Việt** · [English](README.en.md)

DoctorApp là ứng dụng đặt lịch khám, kết nối **bệnh nhân** với **bác sĩ**. Bệnh nhân tìm bác sĩ theo chuyên khoa, gửi yêu cầu đặt lịch, nhắn tin với bác sĩ và hỏi trợ lý AI các câu hỏi sức khỏe chung. Bác sĩ duyệt lịch hẹn và trả lời tin nhắn. Giao diện có hai ngôn ngữ Anh và Việt.

- Bản web: https://doctor-app-df8ca.web.app
- Trợ lý AI chỉ hoạt động khi máy chủ AI đang bật (xem [Trợ lý AI](#trợ-lý-ai)).

## Hướng dẫn sử dụng

### Chung

- **Đổi ngôn ngữ:** bấm nút **EN / VI** ở góc màn hình.
- **Đăng ký:** chọn vai trò *Bệnh nhân* hoặc *Bác sĩ*, rồi nhập họ tên, email, mật khẩu (tối thiểu 6 ký tự), số điện thoại và thành phố. Có thể bấm **Dùng vị trí hiện tại** để lưu tọa độ. Bác sĩ phải nhập thêm chuyên khoa, bằng cấp và số năm kinh nghiệm.
- **Đăng nhập / đăng xuất:** đăng nhập bằng email và mật khẩu. Nút **Đăng xuất** nằm ở tab *Tài khoản*.

### Bệnh nhân

| Tab | Chức năng |
|---|---|
| **Tìm bác sĩ** | Lọc bác sĩ theo chuyên khoa (Nha khoa, Tim mạch, Ung bướu, Ngoại khoa) và bấm vào một bác sĩ để xem hồ sơ. |
| **Tin nhắn** | Danh sách các cuộc trò chuyện với bác sĩ. |
| **Trợ lý AI** | Hỏi đáp sức khỏe chung với AI. |
| **Tài khoản** | Xem các lịch hẹn và trạng thái của chúng, đăng xuất. |

**Đặt lịch khám:** vào *Tìm bác sĩ*, chọn bác sĩ, chọn ngày, giờ, ghi lý do khám rồi bấm **Gửi yêu cầu đặt lịch**. Lịch hẹn có trạng thái *Chờ xác nhận* cho đến khi bác sĩ xử lý. Theo dõi trạng thái ở *Tài khoản*.

Trong hồ sơ bác sĩ còn có các nút:
- **Gọi điện:** mở ứng dụng gọi điện.
- **Chỉ đường:** mở Google Maps.
- **Tin nhắn:** mở cuộc trò chuyện với bác sĩ.

**Trợ lý AI:**
- Nhập câu hỏi (tối đa 2.000 ký tự) rồi bấm gửi. Mỗi câu trả lời mất khoảng 10–60 giây.
- Mỗi tài khoản được hỏi **tối đa 20 câu mỗi giờ**.
- Cuộc trò chuyện **không được lưu**: đăng xuất hoặc tải lại trang là mất.
- Ngôn ngữ của câu trả lời theo nút EN/VI.
- AI có thể trả lời sai. AI không chẩn đoán, không kê đơn. Khi gặp tình huống khẩn cấp, hãy gọi cấp cứu.

### Bác sĩ

| Tab | Chức năng |
|---|---|
| **Lịch hẹn** | Xem yêu cầu đặt lịch của bệnh nhân. Bấm vào một yêu cầu để chuyển trạng thái sang *Đã chấp nhận*, *Đã từ chối* hoặc *Đã hoàn tất*, rồi bấm **Lưu trạng thái**. |
| **Tin nhắn** | Trả lời tin nhắn của bệnh nhân. |
| **Tài khoản** | Xem hồ sơ (email, điện thoại, thành phố, bằng cấp, kinh nghiệm), đăng xuất. |

## Dành cho dev

### Công nghệ

| Lớp | Công nghệ |
|---|---|
| App | Flutter 3.38 / Dart ≥3.4, Material, `google_fonts`, `flutter_localizations` + `intl` |
| Backend | Firebase project `doctor-app-df8ca`: Authentication, Realtime Database, Storage, Hosting |
| Thiết bị | `location`, `url_launcher`, `image_picker`, `google_maps_flutter` |
| Trợ lý AI | n8n 2.42.7 (webhook) → Ollama `qwen3:1.7b`, mở ra internet bằng Tailscale Funnel |

Hiện chỉ **web** được cấu hình trong [lib/firebase_options.dart](lib/firebase_options.dart). Muốn chạy Android/iOS thì phải chạy `flutterfire configure` trước.

### Cấu trúc thư mục

```
lib/
  main.dart            Khởi tạo Firebase, theme, ngôn ngữ
  splash_screen.dart   Kiểm tra đăng nhập, chuyển đến màn hình chính theo vai trò
  auth/                Đăng nhập, đăng ký
  patient/             Màn hình chính và danh sách chat của bệnh nhân
  doctor/              Danh sách và hồ sơ bác sĩ, lịch hẹn, model (Doctor, Patient, Booking)
  ai/                  Trợ lý AI: AiChatSession (gọi webhook), AiChatPage
  chat_screen.dart     Màn hình chat 1-1
  l10n/app_strings.dart  Bảng dịch Anh → Việt, context.tr(), nút EN/VI
  ui/                  Theme, widget dùng chung, home shell responsive
n8n/                   Workflow AI, test workflow, hướng dẫn chi tiết
scripts/               start-n8n.ps1, register-autostart.ps1
test/                  Test widget và unit
```

Các nhánh dữ liệu trong Realtime Database: `Doctors`, `Patients`, `Requests` (lịch hẹn), `Chat`, `ChatList`.

### Cài đặt

Cần có: Flutter SDK 3.38+, Chrome, Firebase CLI (`npm i -g firebase-tools`).

```powershell
git clone https://github.com/tun12348573/Flutter_doctor_app_master.git
cd Flutter_doctor_app_master
flutter pub get
```

### Chạy

```powershell
# Không có AI
flutter run -d chrome --web-port 8080

# Có AI, dùng n8n trên chính máy này
flutter run -d chrome --web-port 8080 --dart-define=AI_CHAT_URL=http://localhost:5678/webhook/doctorapp-ai
```

Phải dùng cổng `8080` vì CORS của webhook chỉ cho phép `localhost:8080`. Nếu không truyền `AI_CHAT_URL`, tab Trợ lý AI sẽ báo *chưa cấu hình*.

### Test

```powershell
flutter analyze
flutter test
node n8n/test-workflow.cjs
```

### Trợ lý AI

Luồng xử lý:

```
App ──POST + Firebase ID token──▶ Tailscale Funnel ──▶ n8n webhook
     ──▶ xác minh token với Firebase ──▶ giới hạn 20 câu/giờ/uid ──▶ Ollama ──▶ App
```

Máy chủ AI là máy Windows của chủ dự án:
- n8n tự chạy khi đăng nhập Windows (Task Scheduler).
- Ollama tự chạy khi đăng nhập.
- Tailscale Funnel chỉ public đúng đường dẫn `/webhook/doctorapp-ai`. Editor n8n vẫn chỉ mở ở `127.0.0.1:5678`.
- Khi máy tắt hoặc ngủ, AI báo lỗi kết nối. Các chức năng khác vẫn chạy bình thường.

Hướng dẫn cài đặt, cấu hình và xử lý sự cố: [n8n/README.md](n8n/README.md).

### Deploy web

```powershell
flutter build web --release --dart-define=AI_CHAT_URL=https://doctorapp-ai.tail6390aa.ts.net/webhook/doctorapp-ai
firebase deploy --only hosting --project doctor-app-df8ca
```

### Đóng góp

Khi thêm hoặc đổi chức năng, cập nhật **cả** `README.md` và `README.en.md` trong cùng commit (xem [CLAUDE.md](CLAUDE.md)).
