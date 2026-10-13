import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A null locale follows the device language until the user makes a choice.
final appLocale = ValueNotifier<Locale?>(null);

extension AppTranslation on BuildContext {
  String appointmentDate(String value) {
    final parsed = DateFormat('MM/dd/yyyy', 'en').tryParseStrict(value);
    return parsed == null
        ? value
        : DateFormat.yMMMd(Localizations.localeOf(this).languageCode)
            .format(parsed);
  }

  String appointmentTime(String value) {
    final parsed = DateFormat('h:mm a', 'en').tryParseStrict(value) ??
        DateFormat('HH:mm', 'en').tryParseStrict(value);
    return parsed == null
        ? value
        : MaterialLocalizations.of(this)
            .formatTimeOfDay(TimeOfDay.fromDateTime(parsed));
  }

  String tr(String key, [Map<String, String> values = const {}]) {
    var text = Localizations.localeOf(this).languageCode == 'vi'
        ? vietnamese[key] ?? key
        : key;
    for (final entry in values.entries) {
      text = text.replaceAll('{${entry.key}}', entry.value);
    }
    return text;
  }
}

const vietnamese = <String, String>{
  "Welcome back": "Chào mừng trở lại",
  "Your next step to better care starts here.":
      "Bắt đầu hành trình chăm sóc sức khỏe của bạn.",
  "Sign in to your account": "Đăng nhập tài khoản",
  "Email": "Email",
  "Password": "Mật khẩu",
  "Show password": "Hiện mật khẩu",
  "Hide password": "Ẩn mật khẩu",
  "Sign in": "Đăng nhập",
  "Signing in...": "Đang đăng nhập...",
  "New here? Create an account": "Chưa có tài khoản? Đăng ký",
  "Enter a valid email address.": "Vui lòng nhập địa chỉ email hợp lệ.",
  "Enter your password.": "Vui lòng nhập mật khẩu.",
  "Your profile could not be found. Please contact the demo administrator.":
      "Không tìm thấy hồ sơ. Vui lòng liên hệ quản trị viên bản demo.",
  "Unable to sign in. Check your email, password and connection.":
      "Không thể đăng nhập. Hãy kiểm tra email, mật khẩu và kết nối.",
  "Unable to load your profile. Please try again.":
      "Không thể tải hồ sơ. Vui lòng thử lại.",
  "Create account": "Tạo tài khoản",
  "Creating account...": "Đang tạo tài khoản...",
  "Better care, together": "Cùng chăm sóc sức khỏe",
  "Join as a patient or doctor. It only takes a few details.":
      "Đăng ký với vai trò bệnh nhân hoặc bác sĩ bằng vài thông tin cơ bản.",
  "I am a": "Tôi là",
  "Patient": "Bệnh nhân",
  "Doctor": "Bác sĩ",
  "Account details": "Thông tin tài khoản",
  "Use at least 6 characters.": "Sử dụng ít nhất 6 ký tự.",
  "Personal information": "Thông tin cá nhân",
  "First name": "Tên",
  "Last name": "Họ",
  "Phone number": "Số điện thoại",
  "City": "Thành phố",
  "Professional information": "Thông tin chuyên môn",
  "Qualification": "Bằng cấp",
  "Specialty": "Chuyên khoa",
  "Years of experience": "Số năm kinh nghiệm",
  "Enter a valid number of years.": "Vui lòng nhập số năm hợp lệ.",
  "Location (optional)": "Vị trí (không bắt buộc)",
  "Share your current location to help with directions.":
      "Chia sẻ vị trí hiện tại để hỗ trợ chỉ đường.",
  "Getting location...": "Đang lấy vị trí...",
  "Location added": "Đã thêm vị trí",
  "Use current location": "Dùng vị trí hiện tại",
  "Already have an account? Sign in": "Đã có tài khoản? Đăng nhập",
  "This field is required.": "Vui lòng điền thông tin này.",
  "Location unavailable. Allow location access or continue without it.":
      "Không lấy được vị trí. Hãy cấp quyền truy cập hoặc tiếp tục mà không chia sẻ vị trí.",
  "This email already has an account. Please sign in.":
      "Email này đã được đăng ký. Vui lòng đăng nhập.",
  "Unable to create your account. Check your details and connection.":
      "Không thể tạo tài khoản. Hãy kiểm tra thông tin và kết nối.",
  "Unable to save your profile. Your entries are kept; please try again.":
      "Không thể lưu hồ sơ. Thông tin đã nhập vẫn được giữ lại; vui lòng thử lại.",
  "Find care": "Tìm bác sĩ",
  "Messages": "Tin nhắn",
  "My account": "Tài khoản",
  "Appointments": "Lịch hẹn",
  "Refresh doctors": "Tải lại danh sách bác sĩ",
  "Unable to load doctors": "Không thể tải danh sách bác sĩ",
  "Check your connection and try again.": "Hãy kiểm tra kết nối và thử lại.",
  "Find the right care for you": "Tìm bác sĩ phù hợp với bạn",
  "Explore specialists and request an appointment that suits you.":
      "Tìm chuyên gia và đặt lịch khám vào thời gian phù hợp.",
  "All": "Tất cả",
  "Dentist": "Nha khoa",
  "Cardiology": "Tim mạch",
  "Oncology": "Ung bướu",
  "Surgeon": "Ngoại khoa",
  "{count} doctors available": "Có {count} bác sĩ",
  "No doctors here yet": "Chưa có bác sĩ",
  "Try another specialty or check back later.":
      "Hãy chọn chuyên khoa khác hoặc quay lại sau.",
  "{years} years of experience": "{years} năm kinh nghiệm",
  "View profile": "Xem hồ sơ",
  "Doctor profile": "Hồ sơ bác sĩ",
  "About your doctor": "Thông tin bác sĩ",
  "Qualification: {value}": "Bằng cấp: {value}",
  "Phone: {value}": "Điện thoại: {value}",
  "Message": "Tin nhắn",
  "Call": "Gọi điện",
  "Directions": "Chỉ đường",
  "This doctor has not shared a location.": "Bác sĩ chưa chia sẻ vị trí.",
  "Request an appointment": "Đặt lịch khám",
  "Choose a preferred time. Your doctor will confirm the request.":
      "Chọn thời gian mong muốn. Bác sĩ sẽ xác nhận yêu cầu của bạn.",
  "Choose date": "Chọn ngày",
  "Choose time": "Chọn giờ",
  "Reason for your visit": "Lý do khám",
  "Tell the doctor how they can help.": "Vui lòng mô tả nhu cầu khám của bạn.",
  "Sending request...": "Đang gửi yêu cầu...",
  "Request appointment": "Gửi yêu cầu đặt lịch",
  "Choose both a date and a time.": "Vui lòng chọn cả ngày và giờ.",
  "Appointment requested. Check My account for updates.":
      "Đã gửi yêu cầu đặt lịch. Xem cập nhật trong mục Tài khoản.",
  "Unable to request this appointment. Your details are kept; try again.":
      "Không thể gửi yêu cầu. Thông tin vẫn được giữ lại; vui lòng thử lại.",
  "Unable to open this link on your device.":
      "Không thể mở liên kết trên thiết bị của bạn.",
  "Refresh appointments": "Tải lại lịch hẹn",
  "Unable to load appointments": "Không thể tải lịch hẹn",
  "Your schedule is clear": "Chưa có lịch hẹn",
  "New appointment requests will appear here.":
      "Các yêu cầu đặt lịch mới sẽ xuất hiện tại đây.",
  "Review appointment": "Xem yêu cầu đặt lịch",
  "Cancel": "Hủy",
  "Saving...": "Đang lưu...",
  "Save status": "Lưu trạng thái",
  "Unable to save. Please try again.": "Không thể lưu. Vui lòng thử lại.",
  "Accepted": "Đã chấp nhận",
  "Rejected": "Đã từ chối",
  "Completed": "Đã hoàn tất",
  "pending": "Chờ xác nhận",
  "Status: {status}": "Trạng thái: {status}",
  "Sign out": "Đăng xuất",
  "Unable to sign out. Try again.": "Không thể đăng xuất. Vui lòng thử lại.",
  "Patient account": "Tài khoản bệnh nhân",
  "Your appointments": "Lịch hẹn của bạn",
  "No appointments yet": "Chưa có lịch hẹn",
  "Find a doctor and request your first appointment.":
      "Tìm bác sĩ và gửi yêu cầu đặt lịch khám đầu tiên.",
  "Unable to load profile": "Không thể tải hồ sơ",
  "Please check your connection.": "Vui lòng kiểm tra kết nối.",
  "Email: {value}": "Email: {value}",
  "City: {value}": "Thành phố: {value}",
  "Experience: {years} years": "Kinh nghiệm: {years} năm",
  "Refresh conversations": "Tải lại cuộc trò chuyện",
  "Unable to load messages": "Không thể tải tin nhắn",
  "No conversations yet": "Chưa có cuộc trò chuyện",
  "Messages from your patients will appear here.":
      "Tin nhắn từ bệnh nhân sẽ xuất hiện tại đây.",
  "Open a doctor profile to start a conversation.":
      "Mở hồ sơ bác sĩ để bắt đầu trò chuyện.",
  "Open conversation": "Mở cuộc trò chuyện",
  "Conversation": "Cuộc trò chuyện",
  "Start a conversation": "Bắt đầu trò chuyện",
  "Send a message to introduce yourself.": "Gửi tin nhắn để giới thiệu về bạn.",
  "Message not sent. Please try again.":
      "Chưa gửi được tin nhắn. Vui lòng thử lại.",
  "Write your message...": "Nhập tin nhắn...",
  "Sending message": "Đang gửi tin nhắn",
  "Send message": "Gửi tin nhắn",
  "Unable to connect": "Không thể kết nối",
  "Check your connection to continue to DoctorApp.":
      "Kiểm tra kết nối để tiếp tục sử dụng DoctorApp.",
  "Care that fits your life.": "Chăm sóc sức khỏe theo cách của bạn.",
  "Loading your account": "Đang tải tài khoản",
  "Try again": "Thử lại",
};

class LanguageButton extends StatelessWidget {
  const LanguageButton({super.key});
  @override
  Widget build(BuildContext context) => PopupMenuButton<String>(
        tooltip: 'Language / Ngôn ngữ',
        initialValue: Localizations.localeOf(context).languageCode,
        onSelected: (code) => appLocale.value = Locale(code),
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'en', child: Text('English')),
          PopupMenuItem(value: 'vi', child: Text('Tiếng Việt')),
        ],
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.language, size: 22),
              const SizedBox(width: 6),
              Text(Localizations.localeOf(context).languageCode == 'vi'
                  ? 'VI'
                  : 'EN'),
              const Icon(Icons.arrow_drop_down, size: 18),
            ])),
      );
}
