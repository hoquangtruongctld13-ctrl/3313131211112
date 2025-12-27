# 🚀 Hướng Dẫn Build Nhanh VieNeu-TTS với Nuitka

Tài liệu này hướng dẫn cách build VieNeu-TTS bằng Nuitka - **chỉ compile code Python thành C**, không bundle các thư viện nặng vào exe.

## Mục Tiêu

- ✅ **Build nhanh** (2-10 phút thay vì 30-60 phút)
- ✅ **File exe nhỏ gọn** (chỉ chứa code đã compile)
- ✅ **Thư viện nặng nằm ngoài exe** (dễ dàng update/thay thế)
- ✅ **Chỉ compile code UI** (customtkinter, tkinter)

## Mục Lục

1. [Yêu Cầu Hệ Thống](#1-yêu-cầu-hệ-thống)
2. [Cài Đặt Môi Trường](#2-cài-đặt-môi-trường)
3. [Phương Pháp Build](#3-phương-pháp-build)
4. [Cấu Trúc Thư Mục Output](#4-cấu-trúc-thư-mục-output)
5. [Chạy Ứng Dụng](#5-chạy-ứng-dụng)
6. [Khắc Phục Sự Cố](#6-khắc-phục-sự-cố)

---

## 1. Yêu Cầu Hệ Thống

### Máy Build (Compile)

| Yêu cầu | Chi tiết |
|---------|----------|
| OS | Windows 10/11 64-bit |
| Python | 3.12.x (bắt buộc) |
| RAM | Tối thiểu 8GB |
| Disk | Tối thiểu 5GB trống |
| Compiler | Visual Studio Build Tools (C++) |

### Máy Chạy (Runtime)

| Yêu cầu | Chi tiết |
|---------|----------|
| OS | Windows 10/11 64-bit |
| Python | 3.12.x (để chạy thư viện) |
| eSpeak NG | Bắt buộc cho VN TTS |
| RAM | Tối thiểu 4GB |

---

## 2. Cài Đặt Môi Trường

### 2.1 Cài Python 3.12

```bash
# Tải từ https://www.python.org/downloads/
# QUAN TRỌNG: Tick "Add Python to PATH"

# Kiểm tra
python --version
# Output: Python 3.12.x
```

### 2.2 Cài eSpeak NG

1. Tải từ: https://github.com/espeak-ng/espeak-ng/releases
2. Cài đặt vào: `C:\Program Files\eSpeak NG\`
3. Thêm vào PATH: `C:\Program Files\eSpeak NG`
4. Kiểm tra: `espeak-ng --version`

### 2.3 Cài Visual Studio Build Tools

1. Tải từ: https://visualstudio.microsoft.com/visual-cpp-build-tools/
2. Chọn workload: **"Desktop development with C++"**
3. Restart máy sau khi cài

### 2.4 Cài Nuitka

```bash
pip install nuitka ordered-set zstandard
```

---

## 3. Phương Pháp Build

### 3.1 Build Nhanh (Khuyến nghị)

**Dùng cho:** Khi máy đích đã có Python và các thư viện

```bash
# Chạy script build nhanh
build_nuitka_fast.bat
```

**Đặc điểm:**
- Thời gian build: 2-10 phút
- Kích thước output: ~50-100MB
- Yêu cầu: Máy đích phải có Python + thư viện đã cài

### 3.2 Build Portable

**Dùng cho:** Khi muốn copy thư viện vào cùng thư mục exe

```bash
# Chạy script build portable
build_nuitka_portable.bat
```

**Đặc điểm:**
- Thời gian build: 5-20 phút
- Kích thước output: ~500MB-2GB (tùy thư viện)
- Copy được sang máy khác dễ dàng

### 3.3 Build Thủ Công

**Command build cơ bản:**

```bash
python -m nuitka ^
    --standalone ^
    --enable-plugin=tk-inter ^
    --follow-imports ^
    --nofollow-import-to=torch ^
    --nofollow-import-to=torchaudio ^
    --nofollow-import-to=neucodec ^
    --nofollow-import-to=llama_cpp ^
    --nofollow-import-to=phonemizer ^
    --nofollow-import-to=librosa ^
    --nofollow-import-to=scipy ^
    --nofollow-import-to=numpy ^
    --nofollow-import-to=soundfile ^
    --nofollow-import-to=onnxruntime ^
    --nofollow-import-to=transformers ^
    --nofollow-import-to=huggingface_hub ^
    --nofollow-import-to=google ^
    --include-package=edge ^
    --include-data-dir=edge=edge ^
    --windows-icon-from-ico=icon.ico ^
    --windows-console-mode=disable ^
    --output-dir=dist_nuitka ^
    main.py
```

**Giải thích options:**

| Option | Mô tả |
|--------|-------|
| `--standalone` | Tạo thư mục độc lập |
| `--enable-plugin=tk-inter` | Hỗ trợ tkinter/customtkinter |
| `--nofollow-import-to=xxx` | KHÔNG bundle thư viện xxx vào exe |
| `--include-package=edge` | Bundle module edge vào exe |
| `--include-data-dir=edge=edge` | Copy thư mục edge |

---

## 4. Cấu Trúc Thư Mục Output

### 4.1 Build Nhanh (Fast)

```
dist_nuitka/
└── main.dist/
    ├── VieNeuTTS.exe         # File exe chính (compiled C)
    ├── VieNeu-TTS/           # Module VN TTS
    │   ├── sample/           # Voice samples (.wav, .txt, .pt)
    │   ├── utils/            # Utilities
    │   └── vieneu_tts/       # Core TTS
    ├── edge/                 # Edge TTS module
    ├── config.yaml           # Config file
    ├── ffmpeg.exe            # FFmpeg binary
    └── install_libs.bat      # Script cài thư viện
```

### 4.2 Build Portable

```
dist_portable/
└── main.dist/
    ├── VieNeuTTS.exe         # File exe chính
    ├── libs/                 # THƯ VIỆN NẶNG
    │   ├── torch/            # PyTorch
    │   ├── torchaudio/       # TorchAudio
    │   ├── neucodec/         # NeuCodec
    │   ├── llama_cpp/        # llama.cpp Python
    │   ├── phonemizer/       # Phonemizer
    │   ├── librosa/          # Librosa
    │   ├── scipy/            # SciPy
    │   ├── numpy/            # NumPy
    │   └── ...               # Các thư viện khác
    ├── VieNeu-TTS/           # Module VN TTS
    ├── edge/                 # Edge TTS
    └── ffmpeg.exe            # FFmpeg
```

---

## 5. Chạy Ứng Dụng

### 5.1 Trường Hợp Build Nhanh

**Bước 1:** Copy thư mục `dist_nuitka/main.dist` đến máy đích

**Bước 2:** Trên máy đích, cài thư viện:
```bash
# Chạy script đã tạo sẵn
install_libs.bat

# Hoặc cài thủ công:
pip install torch torchaudio --index-url https://download.pytorch.org/whl/cpu
pip install numpy scipy librosa soundfile
pip install phonemizer neucodec onnxruntime
pip install llama-cpp-python --extra-index-url https://abetlen.github.io/llama-cpp-python/whl/cpu
pip install transformers huggingface_hub safetensors
pip install google-genai python-docx requests
pip install customtkinter pyaudio pillow
```

**Bước 3:** Chạy `VieNeuTTS.exe`

### 5.2 Trường Hợp Build Portable

**Bước 1:** Copy toàn bộ thư mục `dist_portable/main.dist` đến máy đích

**Bước 2:** Đảm bảo eSpeak NG đã cài trên máy đích

**Bước 3:** Chạy `VieNeuTTS.exe`

---

## 6. Khắc Phục Sự Cố

### 6.1 Lỗi: "No module named 'torch'"

**Nguyên nhân:** Thư viện chưa được cài/copy

**Giải pháp (Build Nhanh):**
```bash
pip install torch torchaudio --index-url https://download.pytorch.org/whl/cpu
```

**Giải pháp (Build Portable):**
- Kiểm tra thư mục `libs/torch` có tồn tại không
- Copy thư mục torch từ `site-packages` vào `libs/`

### 6.2 Lỗi: "Failed to import phonemizer"

**Nguyên nhân:** eSpeak NG chưa cài hoặc không trong PATH

**Giải pháp:**
```bash
# Kiểm tra
espeak-ng --version

# Nếu không tìm thấy, thêm vào PATH:
# C:\Program Files\eSpeak NG
```

### 6.3 Lỗi: "DLL load failed"

**Nguyên nhân:** Thiếu Visual C++ Redistributable

**Giải pháp:**
1. Tải: https://aka.ms/vs/17/release/vc_redist.x64.exe
2. Cài đặt
3. Restart máy

### 6.4 Build chậm/treo

**Giải pháp:**
- Đảm bảo đủ RAM (tối thiểu 8GB)
- Tắt các chương trình khác
- Chạy với quyền Administrator

### 6.5 Lỗi: "Module not found in libs"

**Nguyên nhân:** Thư viện trong libs/ không đầy đủ

**Giải pháp:**
```bash
# Tìm site-packages của Python
python -c "import site; print(site.getsitepackages()[0])"

# Copy thư viện thiếu từ site-packages vào libs/
```

---

## 7. So Sánh Các Phương Pháp Build

| Đặc điểm | Build Nhanh | Build Portable | PyInstaller |
|----------|-------------|----------------|-------------|
| Thời gian build | 2-10 phút | 5-20 phút | 15-60 phút |
| Kích thước output | 50-100MB | 500MB-2GB | 1-3GB |
| Yêu cầu Python trên máy đích | ✅ Có | ❌ Không | ❌ Không |
| Dễ update thư viện | ✅ Dễ | ⚠️ Vừa | ❌ Khó |
| Tốc độ chạy | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |

---

## 8. Tips & Best Practices

### 8.1 Giảm Kích Thước Output

```bash
# Chỉ bundle thư viện UI cần thiết
--nofollow-import-to=torch
--nofollow-import-to=torchaudio
# ... (các thư viện nặng khác)
```

### 8.2 Tối Ưu Tốc Độ Build

```bash
# Sử dụng ccache (Windows)
pip install ccache
# Nuitka sẽ tự động detect và sử dụng
```

### 8.3 Debug Build

```bash
# Bật console để xem log
--windows-console-mode=attach

# Hoặc
--windows-console-mode=force
```

### 8.4 Cập Nhật Thư Viện

**Build Nhanh:** Cập nhật qua pip trên máy đích
```bash
pip install --upgrade torch
```

**Build Portable:** Copy thư viện mới vào `libs/`

---

## 9. Tham Khảo

- [Nuitka Documentation](https://nuitka.net/doc/user-manual.html)
- [VieNeu-TTS GitHub](https://github.com/pnnbao97/VieNeu-TTS)
- [llama-cpp-python Wheels](https://abetlen.github.io/llama-cpp-python/whl/cpu)
- [eSpeak NG Releases](https://github.com/espeak-ng/espeak-ng/releases)

---

**Phiên bản:** 2.0  
**Cập nhật:** Tháng 12, 2025
