# Trợ lý AI cho bệnh nhân

Luồng: Flutter → webhook n8n → xác minh Firebase ID token → Ollama `qwen3:1.7b` → Flutter.
Giao diện có trong tab **Trợ lý AI** sau khi đăng nhập bệnh nhân. Nội dung hội thoại chỉ nằm trong bộ nhớ phiên đăng nhập, không được ghi vào Firebase. Workflow tắt lưu execution (cả thành công và lỗi) để tránh lưu token và nội dung sức khỏe.

## Chạy trên Windows

Máy hiện tại dùng Node 24 và n8n 2.42.7 riêng trong `.local/` (đã được gitignore). Không đổi Node toàn máy. Ollama cần chạy và có model `qwen3:1.7b`.

Mở PowerShell tại thư mục project:

```powershell
# Lần đầu hoặc sau khi sửa workflow: chạy khi n8n đang tắt.
powershell -ExecutionPolicy Bypass -File scripts/start-n8n.ps1 -ImportWorkflow

# Giữ cửa sổ này chạy; Ctrl+C để dừng. (Không cần nếu đã đăng ký tự khởi động, xem bên dưới.)
powershell -ExecutionPolicy Bypass -File scripts/start-n8n.ps1
```

Editor: http://localhost:5678. Nếu n8n yêu cầu tạo tài khoản quản trị, tự đặt email và mật khẩu tại trang đó; đây là tài khoản n8n, không phải tài khoản bệnh nhân.

Ở cửa sổ PowerShell khác:

```powershell
flutter run -d chrome --web-port 8080 --dart-define=AI_CHAT_URL=http://localhost:5678/webhook/doctorapp-ai
```

Đăng nhập bệnh nhân bằng tài khoản Firebase hiện có, chọn **Trợ lý AI**, nhập câu hỏi và bấm gửi. Chọn EN/VI để đổi ngôn ngữ câu trả lời tiếp theo. Tối đa 2.000 ký tự/câu hỏi; gửi tối đa 10 tin nhắn gần nhất làm ngữ cảnh. Lỗi hoặc timeout giữ lại câu hỏi để gửi lại. Nút cuộc trò chuyện mới xóa lịch sử sau xác nhận.

## Cài lại trên máy khác

1. Cài Ollama, chạy `ollama pull qwen3:1.7b`.
2. Tải bản ZIP **Node 24 Windows x64** từ https://nodejs.org/dist/ và đối chiếu SHA256 với `SHASUMS256.txt`. Giải nén vào `.local/` để có `.local/node-v24.<phiên-bản>-win-x64/node.exe`.
3. Cài n8n bằng npm đi kèm Node đó:

```powershell
$nodeFolder = (Get-ChildItem .local -Directory -Filter 'node-v24.*-win-x64' | Select-Object -First 1).FullName
$env:PATH = "$nodeFolder;$env:PATH"
& "$nodeFolder/node.exe" "$nodeFolder/node_modules/npm/bin/npm-cli.js" install --prefix .local/n8n n8n@2.42.7 --no-audit --no-fund
```

Sau đó import và chạy như trên. Không commit `.local/` vì chứa cơ sở dữ liệu và khóa mã hóa n8n.

## Cấu hình workflow

`patient-ai.workflow.json` có thể import từ giao diện n8n. Sửa model trong node **Prepare AI request**, và URL Ollama trong **Ask Ollama** nếu chạy khác máy. Model đang cấu hình tắt thinking và dùng câu trả lời JSON không streaming. Firebase Web API key trong workflow là cấu hình công khai của project, không phải khóa quản trị. Không đặt API key quản trị hoặc service-account key trong Flutter.

Webhook nhận JSON `{message, language, history}` và header `Authorization: Bearer <Firebase ID token>`. Token phải thuộc `doctor-app-df8ca`, được Firebase xác minh trước khi gọi AI. Trả `{reply, model}` hoặc HTTP 400/401/429/502. Giới hạn một workflow production chạy cùng lúc để tránh quá tải model cục bộ.

Giới hạn **20 câu/giờ cho mỗi uid**, trả HTTP 429 khi vượt. Bộ đếm nằm trong workflow static data của n8n (node **Prepare AI request**; sửa số `20` ở đó).

## Public bằng Tailscale Funnel

Bản Firebase Hosting gọi `https://doctorapp-ai.tail6390aa.ts.net/webhook/doctorapp-ai`. Funnel chỉ chuyển tiếp đúng đường dẫn này tới `127.0.0.1:5678`. Editor n8n và Ollama không mở ra internet.

Thiết lập một lần (PowerShell tại thư mục project):

```powershell
# 1. Cài Tailscale, đăng nhập (mở trình duyệt)
winget install --id Tailscale.Tailscale -e
& 'C:\Program Files\Tailscale\tailscale.exe' up
& 'C:\Program Files\Tailscale\tailscale.exe' set --hostname=doctorapp-ai

# 2. Bật Funnel cho đường dẫn webhook. Lần đầu lệnh in link để bật HTTPS + Funnel cho tailnet; mở link, bật, chạy lại.
& 'C:\Program Files\Tailscale\tailscale.exe' funnel --bg --set-path=/webhook/doctorapp-ai http://127.0.0.1:5678/webhook/doctorapp-ai

# 3. Tự chạy n8n khi đăng nhập Windows
powershell -ExecutionPolicy Bypass -File scripts/register-autostart.ps1
Start-ScheduledTask -TaskName 'DoctorApp n8n'
```

`--bg` lưu cấu hình Funnel trong dịch vụ Tailscale, tự bật lại sau khởi động máy. Ollama tự chạy khi đăng nhập. Nên tắt chế độ ngủ khi cắm sạc (Settings → System → Power).

Lệnh hữu ích:

```powershell
& 'C:\Program Files\Tailscale\tailscale.exe' funnel status   # xem đang public gì
& 'C:\Program Files\Tailscale\tailscale.exe' funnel reset    # tắt Funnel
Stop-ScheduledTask -TaskName 'DoctorApp n8n'                 # dừng n8n (trước khi -ImportWorkflow)
powershell -ExecutionPolicy Bypass -File scripts/register-autostart.ps1 -Remove   # bỏ tự khởi động
```

Sau khi sửa workflow: dừng task, chạy `start-n8n.ps1 -ImportWorkflow`, rồi `Start-ScheduledTask -TaskName 'DoctorApp n8n'`.

Nếu domain thay đổi (đổi tên máy hoặc tailnet), build lại bằng URL mới rồi deploy Hosting:

```powershell
flutter build web --release --dart-define=AI_CHAT_URL=https://doctorapp-ai.tail6390aa.ts.net/webhook/doctorapp-ai
firebase deploy --only hosting --project doctor-app-df8ca
```

Nếu không truyền `AI_CHAT_URL`, app hiển thị trạng thái chưa cấu hình và khóa gửi tin nhắn. CORS của webhook chỉ cho phép `localhost:8080` và hai domain Firebase Hosting (node **Patient question**).

## Kiểm tra

```powershell
node n8n/test-workflow.cjs
flutter analyze
flutter test
```

Model nhỏ có thể đưa thông tin sai. Chatbot dành cho thông tin chung và chuẩn bị đi khám, không dùng để chẩn đoán, kê đơn hoặc xử trí cấp cứu. Prompt và thông báo giao diện không bảo đảm độ chính xác y khoa.

Tài liệu: [n8n CLI](https://docs.n8n.io/hosting/cli-commands/), [Ollama Chat API](https://docs.ollama.com/api/chat), [Firebase Auth REST](https://firebase.google.com/docs/reference/rest/auth).
