# Cài bảng xếp hạng cho Xù Bay (Supabase)

Tên menu của Supabase có thể thay đổi theo thời gian. Nếu không thấy đúng tên, hãy tìm mục có ý nghĩa tương tự.

## 1. Tạo dự án
1. Vào supabase.com, đăng ký (có thể dùng tài khoản GitHub).
2. Bấm **New project**, đặt tên (ví dụ `xu-bay`), tạo mật khẩu cơ sở dữ liệu và **lưu lại ở nơi an toàn**. Chọn vùng gần Việt Nam (ví dụ Singapore). Chờ vài phút để dự án khởi tạo.

## 2. Tạo bảng và hàm kiểm tra điểm
1. Mở **SQL Editor**, tạo truy vấn mới.
2. Dán toàn bộ nội dung file `leaderboard/setup.sql` rồi bấm **Run**. Kết quả mong đợi là thông báo thành công, không có lỗi.
3. Có thể chạy lại file này nhiều lần mà không hỏng gì.

## 3. Lấy địa chỉ và khoá công khai
1. Vào phần cài đặt dự án, mục **API** (hoặc **Data API**, **API Keys**).
2. Sao chép **Project URL** (dạng `https://xxxx.supabase.co`) và khoá **anon public** hoặc **publishable** (dạng `eyJ...` hoặc `sb_publishable_...`).
3. Tuyệt đối **không** dùng khoá `service_role` hoặc `secret`, và không gửi mật khẩu cơ sở dữ liệu cho ai.

## 4. Dán vào game
Mở file `xu-bay-app/config.js` và điền:

```js
window.CHIMBAY_LEADERBOARD = { url: "https://xxxx.supabase.co", key: "khoá công khai ở bước 3" };
```

## 5. Đưa game lên mạng
- GitHub Pages: đổi repo sang công khai, vào Settings, Pages, chọn nhánh `master`, thư mục gốc. Game ở `.../xu-bay-app/`.
- Hoặc Netlify / Cloudflare Pages: tải thư mục `xu-bay-app` lên.

## 6. Kiểm tra
Mở link game, chơi một lượt, nhập biệt danh khi game hỏi, rồi bấm biểu tượng cúp. Trong Supabase, mục **Table Editor**, bảng `scores` sẽ có dòng điểm của bạn.

## Ghi chú
- Game gửi điểm thẳng lên bảng, không kiểm tra gian lận. Máy chủ chỉ kiểm tra tên dài 2 đến 12 ký tự và điểm từ 0 đến 9999, và chỉ thay điểm của một biệt danh khi điểm mới cao hơn.
- Nếu trước đó bạn đã chạy bản `setup.sql` cũ (có kiểm tra thời gian), chạy lại file mới này sẽ tự gỡ phần cũ.
- Xoá dòng không phù hợp: vào **Table Editor**, bảng `scores`, xoá dòng đó.
- Sau khi sửa `config.js`, có thể cần mở lại game hai lần mới thấy thay đổi, vì trình duyệt lưu bản cũ để chạy ngoại tuyến.
