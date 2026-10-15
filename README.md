# DoctorApp

**Tiếng Việt** · [English](README.en.md)

DoctorApp là ứng dụng đặt lịch khám và mua thuốc, kết nối **bệnh nhân**, **bác sĩ** và **nhà thuốc**. Bệnh nhân có thể:
- Tìm bác sĩ theo chuyên khoa, gửi yêu cầu đặt lịch, nhắn tin với bác sĩ.
- Tra cứu thuốc và đặt mua thuốc không kê đơn (trả tiền khi nhận hàng).
- Hỏi trợ lý AI các câu hỏi sức khỏe chung và về thuốc.

Bác sĩ duyệt lịch hẹn. Nhà thuốc xử lý đơn hàng và quản lý kho. Giao diện có hai ngôn ngữ Anh và Việt.

- Bản web: https://doctor-app-df8ca.web.app. Có thể build cho Android và iOS (xem [Chạy trên Android và iOS](#chạy-trên-android-và-ios)).
- Trợ lý AI chỉ hoạt động khi máy chủ AI đang bật (xem [Trợ lý AI](#trợ-lý-ai)).
- Dữ liệu thuốc là **dữ liệu minh họa**. Hãy đọc kỹ hướng dẫn sử dụng và hỏi dược sĩ trước khi dùng thuốc.

## Hướng dẫn sử dụng

### Chung

- **Đổi ngôn ngữ:** bấm nút **EN / VI** ở góc màn hình.
- **Chế độ tối:** app tự theo cài đặt sáng/tối của thiết bị hoặc trình duyệt.
- **Đăng ký:** chọn vai trò *Bệnh nhân* hoặc *Bác sĩ*, rồi nhập họ tên, email, mật khẩu (tối thiểu 6 ký tự), số điện thoại và thành phố. Có thể bấm **Dùng vị trí hiện tại** để lưu tọa độ. Bác sĩ phải nhập thêm chuyên khoa, bằng cấp và số năm kinh nghiệm.
- Tài khoản **nhà thuốc** không tự đăng ký được, do quản trị viên cấp (xem [Cấp tài khoản nhà thuốc](#cấp-tài-khoản-nhà-thuốc)).
- **Đăng nhập / đăng xuất:** đăng nhập bằng email và mật khẩu, app tự chuyển đến giao diện theo vai trò. Nút **Đăng xuất** nằm ở tab *Tài khoản*.

### Bệnh nhân

| Tab | Chức năng |
|---|---|
| **Tìm bác sĩ** | Lọc bác sĩ theo chuyên khoa (Nha khoa, Tim mạch, Ung bướu, Ngoại khoa) và bấm vào một bác sĩ để xem hồ sơ. |
| **Nhà thuốc** | Tìm thuốc, xem chi tiết, thêm vào giỏ và đặt hàng. |
| **Tin nhắn** | Danh sách các cuộc trò chuyện với bác sĩ. |
| **Trợ lý AI** | Hỏi đáp sức khỏe chung với AI. |
| **Tài khoản** | Xem lịch hẹn và **đơn thuốc** kèm trạng thái, hủy đơn, đăng xuất. |

**Đặt lịch khám:** vào *Tìm bác sĩ*, chọn bác sĩ, chọn ngày, giờ, ghi lý do khám rồi bấm **Gửi yêu cầu đặt lịch**. Lịch hẹn có trạng thái *Chờ xác nhận* cho đến khi bác sĩ xử lý. Theo dõi trạng thái ở *Tài khoản*.

Trong hồ sơ bác sĩ còn có các nút:
- **Gọi điện:** mở ứng dụng gọi điện.
- **Chỉ đường:** mở Google Maps.
- **Tin nhắn:** mở cuộc trò chuyện với bác sĩ.

**Mua thuốc:**
1. Vào tab *Nhà thuốc*. Gõ tên thuốc hoặc hoạt chất vào ô tìm kiếm, hoặc lọc theo nhóm (Giảm đau, hạ sốt; Ho, cảm; Tiêu hóa; Vitamin, khoáng chất; Dị ứng; Da liễu; Mắt, tai, mũi; Kháng sinh; Tim mạch, huyết áp; Đái tháo đường).
2. Bấm vào một thuốc để xem **hoạt chất, dạng bào chế, công dụng, cách dùng, chống chỉ định, tác dụng phụ** và giá.
3. Bấm **Thêm vào giỏ**. Thuốc có nhãn *Hết hàng* thì không mua được.
   - Thuốc có nhãn **Thuốc kê đơn** chỉ cho xem thông tin. Thay cho nút mua là nút **Đặt lịch khám**.
4. Bấm biểu tượng giỏ hàng ở góc trên để sửa số lượng (không vượt quá số còn trong kho). Điền họ tên, số điện thoại (điền sẵn từ hồ sơ), địa chỉ giao hàng, ghi chú, rồi bấm **Đặt hàng (trả khi nhận hàng)**.
5. Theo dõi đơn ở *Tài khoản → Đơn thuốc của bạn*. Các trạng thái lần lượt là *Chờ xác nhận → Đang giao → Đã giao*, hoặc *Đã hủy*. Bấm **Hủy đơn** được khi đơn còn *Chờ xác nhận*.

**Trợ lý AI:**
- Nhập câu hỏi (tối đa 2.000 ký tự) rồi bấm gửi. Mỗi câu trả lời mất khoảng 10–60 giây.
- Mỗi tài khoản được hỏi **tối đa 20 câu mỗi giờ**.
- **Hỏi về một thuốc:** trong trang chi tiết thuốc, bấm **Hỏi AI về thuốc này**. AI trả lời dựa trên thông tin của thuốc đó trong danh mục. Nhãn *Đang hỏi về: …* hiện phía trên ô nhập. Bấm dấu × trên nhãn để quay lại hỏi chung.
- Cuộc trò chuyện **không được lưu**: đăng xuất hoặc tải lại trang là mất.
- Ngôn ngữ của câu trả lời theo nút EN/VI.
- AI có thể trả lời sai. AI không chẩn đoán, không kê đơn, và không đưa liều dùng cho thuốc kê đơn. Khi gặp tình huống khẩn cấp, hãy gọi cấp cứu.

### Bác sĩ

| Tab | Chức năng |
|---|---|
| **Lịch hẹn** | Xem yêu cầu đặt lịch của bệnh nhân. Bấm vào một yêu cầu để chuyển trạng thái sang *Đã chấp nhận*, *Đã từ chối* hoặc *Đã hoàn tất*, rồi bấm **Lưu trạng thái**. |
| **Tin nhắn** | Trả lời tin nhắn của bệnh nhân. |
| **Tài khoản** | Xem hồ sơ (email, điện thoại, thành phố, bằng cấp, kinh nghiệm), trạng thái xác minh, đăng xuất. |

Tài khoản bác sĩ mới đăng ký sẽ hiện *Đang chờ xác minh: bệnh nhân chưa tìm thấy bạn*. Bác sĩ chỉ xuất hiện trong *Tìm bác sĩ*, nhận được lịch hẹn và xem được hồ sơ bệnh nhân sau khi quản trị viên xác minh (xem [Xác minh bác sĩ](#xác-minh-bác-sĩ)). Khi đó trạng thái đổi thành *Đã xác minh*.

### Nhà thuốc

| Tab | Chức năng |
|---|---|
| **Đơn hàng** | Lọc đơn theo trạng thái. Mỗi đơn hiển thị thuốc, tổng tiền, tên, số điện thoại, địa chỉ và ghi chú của khách. |
| **Kho** | Danh sách thuốc kèm số tồn, sắp xếp theo số tồn tăng dần. Tìm kiếm, lọc **Sắp hết** (tồn ≤ 10), nhập kho, chỉnh tồn, thêm và sửa thuốc. |
| **Tài khoản** | Email tài khoản, đăng xuất. |

**Xử lý đơn:**
- **Xác nhận và giao hàng:** app trừ kho từng thuốc trong đơn, rồi chuyển đơn sang *Đang giao*. Nếu một thuốc không đủ hàng, app báo *Không đủ hàng cho …*, giữ nguyên kho và đơn vẫn ở trạng thái *Chờ xác nhận*.
- **Đã giao xong:** chuyển đơn sang *Đã giao*.
- **Hủy đơn:** chuyển đơn sang *Đã hủy*. Nếu đơn đã được xác nhận thì số thuốc được **trả lại kho**.

**Kho:**
- Bấm ⋮ ở một thuốc để chọn:
  - **Nhập kho:** cộng thêm số lượng vừa nhận.
  - **Chỉnh tồn kho:** đặt lại đúng số tồn thực tế.
- Bấm vào một thuốc để sửa thông tin. Số tồn không sửa ở đây.
- Nút **Thêm thuốc** để thêm thuốc mới, nhập tồn kho ban đầu và đánh dấu *Thuốc kê đơn* nếu cần.

## Dành cho dev

### Công nghệ

| Lớp | Công nghệ |
|---|---|
| App | Flutter 3.38 / Dart ≥3.4, Material 3 (theme sáng + tối), font Lexend + Noto Sans (có tiếng Việt, đóng gói sẵn), `flutter_localizations` + `intl` |
| Backend | Firebase project `doctor-app-df8ca`: Authentication, Realtime Database (rules trong [database.rules.json](database.rules.json)), Hosting |
| Thiết bị | `location`, `url_launcher` |
| Di động | Android: AGP 8.11, Kotlin 2.2, Gradle 8.14, Java 17+, Android SDK 36. iOS 13+. Mã app `vn.doctorapp.app` |
| Trợ lý AI | n8n 2.42.7 (webhook) → Ollama `qwen3:1.7b`, mở ra internet bằng Tailscale Funnel |
| Test rules | Firebase Database Emulator (cần Java) + `@firebase/rules-unit-testing` |

Web, Android và iOS đều đã được cấu hình trong [lib/firebase_options.dart](lib/firebase_options.dart), không cần file `google-services.json` hay `GoogleService-Info.plist`.

### Cấu trúc thư mục

```
lib/
  main.dart            Khởi tạo Firebase, theme, ngôn ngữ
  splash_screen.dart   Kiểm tra đăng nhập, chuyển đến màn hình chính theo vai trò
  auth/                Đăng nhập, đăng ký, role_home.dart (Doctors → Pharmacists → Patients)
  patient/             Màn hình chính và danh sách chat của bệnh nhân
  doctor/              Danh sách và hồ sơ bác sĩ, lịch hẹn, model (Doctor, Patient, Booking)
  pharmacy/            Nhà thuốc cho bệnh nhân: danh mục, chi tiết, giỏ hàng, đơn của tôi,
                       PharmacyStore (đọc/ghi Firebase), model Drug và DrugOrder
  pharmacist/          Vai trò nhà thuốc: đơn hàng, kho, form thêm/sửa thuốc
  ai/                  Trợ lý AI: AiChatSession (gọi webhook, kèm drugId), AiChatPage
  chat_screen.dart     Màn hình chat 1-1
  l10n/app_strings.dart  Bảng dịch Anh → Việt, context.tr(), nút EN/VI
  ui/                  Theme, widget dùng chung, home shell responsive
assets/fonts/          Lexend, Noto Sans (TTF) và giấy phép OFL
data/drugs.json        41 thuốc minh họa
database.rules.json    Security rules của Realtime Database
n8n/                   Workflow AI, test workflow, hướng dẫn chi tiết
scripts/               start-n8n.ps1, register-autostart.ps1, seed-drugs.ps1, add-pharmacist.ps1,
                       migrate-chat.ps1, verify-doctor.ps1
test/                  Test widget và unit; test/rules/ là test security rules
```

Các nhánh dữ liệu trong Realtime Database:

| Nhánh | Nội dung | Quyền |
|---|---|---|
| `Doctors` | Hồ sơ bác sĩ, `verified` | Đã đăng nhập thì đọc được. Chỉ chủ hồ sơ được ghi, nhưng không tự sửa được `verified` |
| `Patients/<uid>` | Hồ sơ bệnh nhân | Chủ hồ sơ và bác sĩ đã xác minh đọc được, chỉ chủ hồ sơ được ghi |
| `Requests` | Lịch hẹn | Bệnh nhân tạo, chỉ gửi được cho bác sĩ đã xác minh. Bác sĩ đổi trạng thái (`Accepted`, `Rejected`, `Completed`) |
| `Chat/<uidA_uidB>` | Tin nhắn của một cuộc hội thoại (hai uid xếp theo thứ tự) | Chỉ hai người trong cuộc đọc được, người gửi tạo tin nhắn |
| `ChatList/<uid>` | Danh sách người đã nhắn tin | Chỉ chủ danh sách đọc được |
| `Pharmacists/<uid>` | Đánh dấu tài khoản nhà thuốc | Không ai ghi được từ app |
| `Drugs/<id>` | Thông tin thuốc, `price`, `stock`, `prescription` | Đã đăng nhập thì đọc được, chỉ nhà thuốc được ghi |
| `Carts/<uid>` | `{drugId: số lượng}` | Chỉ chủ giỏ. Không cho thêm thuốc kê đơn |
| `Orders/<id>` | Đơn hàng | Bệnh nhân tạo và xem đơn của mình, chỉ hủy được khi đơn còn `pending`. Nhà thuốc xem tất cả và đổi `status`, `stockDeducted` |

Rules kiểm tra giá và tên thuốc trong đơn phải khớp với `Drugs`, nên client không sửa giá được. Kho bị trừ khi nhà thuốc xác nhận đơn, bằng transaction trên `Drugs/<id>/stock`.

### Cài đặt

Cần có: Flutter SDK 3.38+, Chrome, Firebase CLI (`npm i -g firebase-tools`). Muốn chạy test rules thì cần thêm Node.js 22+ và Java 11+.

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

### Chạy trên Android và iOS

**Android** (Windows, macOS hoặc Linux): cần Java 17+ và Android SDK 36 (cài bằng Android Studio → SDK Manager), rồi chạy `flutter doctor --android-licenses`. Cắm điện thoại (bật *USB debugging*) hoặc mở emulator:

```powershell
flutter devices
flutter run -d <device-id> --dart-define=AI_CHAT_URL=https://doctorapp-ai.tail6390aa.ts.net/webhook/doctorapp-ai
flutter build apk --release --dart-define=AI_CHAT_URL=https://doctorapp-ai.tail6390aa.ts.net/webhook/doctorapp-ai   # file: build/app/outputs/flutter-apk/app-release.apk
```

**iOS**: chỉ build được trên **macOS** có Xcode (iOS 13+). Lần đầu chạy `cd ios; pod install`. Muốn cài lên iPhone thật thì mở `ios/Runner.xcworkspace` trong Xcode, chọn Team ở *Signing & Capabilities*, rồi:

```bash
flutter run -d <device-id> --dart-define=AI_CHAT_URL=https://doctorapp-ai.tail6390aa.ts.net/webhook/doctorapp-ai
```

Trên điện thoại, `AI_CHAT_URL` phải là địa chỉ `https` công khai: app chỉ chấp nhận `http` khi trỏ tới `localhost`, mà `localhost` trên điện thoại không phải máy tính của bạn. Bản release Android hiện ký bằng debug key, nên chỉ dùng để cài thử. Muốn đưa lên Google Play thì phải tạo keystore riêng.

### Dữ liệu thuốc

```powershell
powershell -ExecutionPolicy Bypass -File scripts/seed-drugs.ps1
```

Lệnh này nạp [data/drugs.json](data/drugs.json) vào `Drugs`. Thuốc trùng `id` sẽ bị **ghi đè cả số tồn**, các thuốc khác giữ nguyên. Nội dung thuốc là dữ liệu minh họa, cần người có chuyên môn rà lại trước khi dùng thật.

### Cấp tài khoản nhà thuốc

1. Firebase Console → Authentication → **Add user**: nhập email và mật khẩu, rồi copy **User UID**.
2. Chạy lệnh:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/add-pharmacist.ps1 -Uid <USER_UID> -Email <email>
# Thu hồi quyền: thêm -Remove
```

### Xác minh bác sĩ

Bác sĩ tự đăng ký trong app, nhưng chỉ hiện với bệnh nhân sau khi được xác minh. Kiểm tra bằng cấp của bác sĩ, copy **User UID** của họ trong Firebase Console → Authentication, rồi chạy:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/verify-doctor.ps1 -Uid <USER_UID>
# Bỏ xác minh: thêm -Remove
```

Sau khi deploy rules này lần đầu, các bác sĩ đã đăng ký từ trước cũng cần được xác minh như trên.

### Test

```powershell
flutter analyze
flutter test
node n8n/test-workflow.cjs

# Security rules (chạy emulator, cần Java)
cd test/rules; npm install; npm test
```

### Trợ lý AI

Luồng xử lý:

```
App ──POST + Firebase ID token (+ drugId)──▶ Tailscale Funnel ──▶ n8n webhook
     ──▶ xác minh token với Firebase ──▶ giới hạn 20 câu/giờ/uid
     ──▶ có drugId? đọc Drugs/<id> bằng token của bệnh nhân, đưa vào prompt
     ──▶ Ollama ──▶ App
```

Máy chủ AI là máy Windows của chủ dự án:
- n8n tự chạy khi đăng nhập Windows (Task Scheduler).
- Ollama tự chạy khi đăng nhập.
- Tailscale Funnel chỉ public đúng đường dẫn `/webhook/doctorapp-ai`. Editor n8n vẫn chỉ mở ở `127.0.0.1:5678`.
- Khi máy tắt hoặc ngủ, AI báo lỗi kết nối. Các chức năng khác vẫn chạy bình thường.

Hướng dẫn cài đặt, cấu hình và xử lý sự cố: [n8n/README.md](n8n/README.md).

### Deploy

```powershell
firebase deploy --only database --project doctor-app-df8ca   # rules, chạy test rules trước
flutter build web --release --dart-define=AI_CHAT_URL=https://doctorapp-ai.tail6390aa.ts.net/webhook/doctorapp-ai
firebase deploy --only hosting --project doctor-app-df8ca
```

Lệnh deploy database sẽ **ghi đè** rules đang có trên Firebase Console bằng nội dung file `database.rules.json`.

Nếu database còn tin nhắn kiểu cũ (nằm thẳng dưới `Chat`), chạy script sau **trước** khi deploy rules. Script chuyển tin nhắn sang `Chat/<uidA_uidB>` và lưu bản sao vào `.local/`. Chạy lại nhiều lần vẫn an toàn.

```powershell
powershell -ExecutionPolicy Bypass -File scripts/migrate-chat.ps1
```

### Đóng góp

Khi thêm hoặc đổi chức năng, cập nhật **cả** `README.md` và `README.en.md` trong cùng commit (xem [CLAUDE.md](CLAUDE.md)).
