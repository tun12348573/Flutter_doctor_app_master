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
  'AI assistant': 'Trợ lý AI',
  'New conversation': 'Cuộc trò chuyện mới',
  'Clear this conversation?': 'Xóa cuộc trò chuyện này?',
  'Clear': 'Xóa',
  'You': 'Bạn',
  'Your question': 'Câu hỏi của bạn',
  'AI can make mistakes. For general information, not diagnosis or prescriptions. For emergencies, contact local emergency services.':
      'AI có thể trả lời sai. Chỉ cung cấp thông tin chung, không chẩn đoán hay kê đơn. Khi khẩn cấp, hãy liên hệ cấp cứu địa phương.',
  'AI assistant is not configured yet.': 'Trợ lý AI chưa được cấu hình.',
  'Please contact the app administrator.':
      'Vui lòng liên hệ quản trị viên ứng dụng.',
  'How can I help?': 'Tôi có thể giúp gì cho bạn?',
  'Ask about general health or preparing for a visit. Avoid sharing identifying information.':
      'Hỏi về sức khỏe chung hoặc chuẩn bị đi khám. Tránh chia sẻ thông tin định danh cá nhân.',
  'AI is preparing a reply...': 'AI đang chuẩn bị câu trả lời...',
  'Enter a question of up to 2,000 characters.':
      'Nhập câu hỏi tối đa 2.000 ký tự.',
  'Please sign in again to use the AI assistant.':
      'Vui lòng đăng nhập lại để sử dụng trợ lý AI.',
  'The AI took too long. Please try again.':
      'AI phản hồi quá lâu. Vui lòng thử lại.',
  'Too many questions. Please try again later.':
      'Bạn đã hỏi quá nhiều. Vui lòng thử lại sau.',
  'Unable to reach the AI assistant. Please try again.':
      'Không thể kết nối trợ lý AI. Vui lòng thử lại.',
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
  "Verified": "Đã xác minh",
  "Awaiting verification": "Đang chờ xác minh",
  "Verify": "Xác minh",
  "Remove verification": "Bỏ xác minh",
  "Verify doctors": "Xác minh bác sĩ",
  "Verify {name}?": "Xác minh {name}?",
  "Patients will be able to find and book this doctor, and the doctor will be able to read patient profiles. Check their qualification first.":
      "Bệnh nhân sẽ tìm thấy và đặt lịch được với bác sĩ này, và bác sĩ sẽ xem được hồ sơ bệnh nhân. Hãy kiểm tra bằng cấp trước.",
  "No doctors yet": "Chưa có bác sĩ",
  "Doctors who sign up will appear here for review.":
      "Bác sĩ đăng ký sẽ hiện ở đây để duyệt.",
  "Doctors": "Bác sĩ",
  "Administrator account": "Tài khoản quản trị viên",
  "Awaiting verification: patients cannot find you yet":
      "Đang chờ xác minh: bệnh nhân chưa tìm thấy bạn",
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
  // Pharmacy
  "Pharmacy": "Nhà thuốc",
  "Cart": "Giỏ hàng",
  "Refresh medicines": "Tải lại danh sách thuốc",
  "Unable to load medicines": "Không thể tải danh sách thuốc",
  "Search by name or ingredient": "Tìm theo tên thuốc hoặc hoạt chất",
  "No medicines found": "Không tìm thấy thuốc",
  "Try another name or category.": "Thử tên hoặc nhóm thuốc khác.",
  "Demo data. Read the package leaflet and ask a pharmacist before use.":
      "Dữ liệu minh họa. Đọc kỹ hướng dẫn sử dụng và hỏi dược sĩ trước khi dùng.",
  "Pain & fever": "Giảm đau, hạ sốt",
  "Cough & cold": "Ho, cảm",
  "Digestive": "Tiêu hóa",
  "Vitamins & minerals": "Vitamin, khoáng chất",
  "Allergy": "Dị ứng",
  "Skin care": "Da liễu",
  "Eye, ear & nose": "Mắt, tai, mũi",
  "Antibiotics": "Kháng sinh",
  "Heart & blood pressure": "Tim mạch, huyết áp",
  "Diabetes": "Đái tháo đường",
  "Prescription": "Thuốc kê đơn",
  "Out of stock": "Hết hàng",
  "Low stock": "Sắp hết",
  "Medicine details": "Chi tiết thuốc",
  "Prescription required": "Cần đơn của bác sĩ",
  "This medicine is sold only with a doctor's prescription. Book a visit to get advice.":
      "Thuốc này chỉ bán theo đơn của bác sĩ. Hãy đặt lịch khám để được tư vấn.",
  "Book an appointment": "Đặt lịch khám",
  "Add to cart": "Thêm vào giỏ",
  "Ask AI about this medicine": "Hỏi AI về thuốc này",
  "What should I know about {name}?": "Tôi cần biết gì về {name}?",
  "Active ingredient": "Hoạt chất",
  "Dosage form": "Dạng bào chế",
  "Uses": "Công dụng",
  "How to use": "Cách dùng",
  "Contraindications": "Chống chỉ định",
  "Side effects": "Tác dụng phụ",
  "In your cart: {qty}": "Trong giỏ: {qty}",
  "View cart": "Xem giỏ",
  "Unable to update your cart. Please try again.":
      "Không thể cập nhật giỏ hàng. Vui lòng thử lại.",
  "Unable to load your cart": "Không thể tải giỏ hàng",
  "Your cart is empty.": "Giỏ hàng trống.",
  "Find medicines in the Pharmacy tab.": "Tìm thuốc ở tab Nhà thuốc.",
  "Total (cash on delivery)": "Tổng tiền (trả khi nhận hàng)",
  "Delivery details": "Thông tin giao hàng",
  "Full name": "Họ và tên",
  "Enter a valid phone number.": "Nhập số điện thoại hợp lệ.",
  "Delivery address": "Địa chỉ giao hàng",
  "Note (optional)": "Ghi chú (không bắt buộc)",
  "Placing order...": "Đang đặt hàng...",
  "Place order (cash on delivery)": "Đặt hàng (trả khi nhận hàng)",
  "Order placed. Track it in My account.":
      "Đã đặt hàng. Theo dõi đơn ở tab Tài khoản.",
  "Unable to place your order. Please try again.":
      "Không thể đặt hàng. Vui lòng thử lại.",
  "Some items are unavailable. Update your cart and try again.":
      "Một số thuốc không còn đủ hàng. Hãy cập nhật giỏ hàng rồi thử lại.",
  "Unavailable medicine": "Thuốc không còn bán",
  "No longer available. Remove it to continue.":
      "Không còn bán. Xóa khỏi giỏ để tiếp tục.",
  "Remove": "Xóa",
  "Only {count} left.": "Chỉ còn {count}.",
  "Decrease quantity": "Giảm số lượng",
  "Increase quantity": "Tăng số lượng",
  "Your medicine orders": "Đơn thuốc của bạn",
  "Refresh orders": "Tải lại đơn hàng",
  "Unable to load orders": "Không thể tải đơn hàng",
  "No orders yet": "Chưa có đơn hàng",
  "Order #{id}": "Đơn #{id}",
  "Note: {value}": "Ghi chú: {value}",
  "Awaiting confirmation": "Chờ xác nhận",
  "Shipping": "Đang giao",
  "Delivered": "Đã giao",
  "Cancelled": "Đã hủy",
  "Cancel this order?": "Hủy đơn hàng này?",
  "Keep order": "Giữ đơn",
  "Cancel order": "Hủy đơn",
  "Cancelling...": "Đang hủy...",
  "Unable to cancel. The pharmacy may have already confirmed it.":
      "Không thể hủy. Có thể nhà thuốc đã xác nhận đơn.",
  "About: {name}": "Đang hỏi về: {name}",
  "Stop asking about this medicine": "Không hỏi về thuốc này nữa",
  // Pharmacist
  "Orders": "Đơn hàng",
  "Inventory": "Kho",
  "Pharmacist account": "Tài khoản nhà thuốc",
  "No orders here": "Không có đơn hàng",
  "New orders from patients will appear here.":
      "Đơn hàng mới của bệnh nhân sẽ hiển thị tại đây.",
  "Confirm and ship": "Xác nhận và giao hàng",
  "Mark delivered": "Đã giao xong",
  "Its stock will be returned to inventory.": "Số thuốc của đơn sẽ được trả lại kho.",
  "Not enough stock for {name}. Restock or cancel the order.":
      "Không đủ hàng cho {name}. Hãy nhập thêm hoặc hủy đơn.",
  "Add medicine": "Thêm thuốc",
  "Edit medicine": "Sửa thông tin thuốc",
  "Medicine name": "Tên thuốc",
  "Strength": "Hàm lượng",
  "Category": "Nhóm thuốc",
  "Pack size": "Quy cách đóng gói",
  "Price (VND)": "Giá (VND)",
  "Initial stock": "Tồn kho ban đầu",
  "Prescription only": "Thuốc kê đơn",
  "Save": "Lưu",
  "Stock actions": "Thao tác kho",
  "Restock": "Nhập kho",
  "Set stock": "Chỉnh tồn kho",
  "In stock: {count}": "Tồn kho: {count}",
  "Quantity received": "Số lượng nhập",
  "Exact stock": "Số tồn chính xác",
  "Low stock ({count})": "Sắp hết ({count})",
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
