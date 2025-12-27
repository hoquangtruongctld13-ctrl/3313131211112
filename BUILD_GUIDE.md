# 🔧 Hướng Dẫn Build EXE với VieNeu-TTS (CPU)

Tài liệu này hướng dẫn chi tiết cách build file .exe từ mã nguồn, bao gồm việc tự động lấy tất cả thư viện cần thiết, đặc biệt là VieNeu-TTS - một thư viện Text-to-Speech tiếng Việt.

## Mục Lục

1. [Tổng Quan](#1-tổng-quan)
2. [Chuẩn Bị Môi Trường](#2-chuẩn-bị-môi-trường)
3. [Cài Đặt llama-cpp-python cho CPU](#3-cài-đặt-llama-cpp-python-cho-cpu)
4. [Cài Đặt VieNeu-TTS](#4-cài-đặt-vieneu-tts)
5. [Build EXE với PyInstaller](#5-build-exe-với-pyinstaller)
6. [Build EXE với Nuitka](#6-build-exe-với-nuitka)
7. [Cấu Trúc Thư Mục Output](#7-cấu-trúc-thư-mục-output)
8. [Khắc Phục Sự Cố](#8-khắc-phục-sự-cố)

---

## 1. Tổng Quan

### Các thư viện chính cần thiết:

| Thư viện | Mô tả | Yêu cầu |
|----------|-------|---------|
| `VieNeu-TTS` | TTS tiếng Việt với voice cloning | Python 3.12 |
| `llama-cpp-python` | Chạy model GGUF trên CPU | Build từ source |
| `phonemizer` | Chuyển text thành phoneme | eSpeak NG |
| `neucodec` | Codec audio neural | PyTorch |
| `customtkinter` | Giao diện đồ họa | - |

### Lưu ý quan trọng:

- **Python phải là phiên bản 3.12.x** (VieNeu-TTS yêu cầu)
- **llama-cpp-python cần được build từ source** để chạy model GGUF
- **eSpeak NG là bắt buộc** để phonemizer hoạt động

---

## 2. Chuẩn Bị Môi Trường

### 2.1 Cài Đặt Python 3.12

#### Windows:

```bash
# Tải từ https://www.python.org/downloads/
# Chọn phiên bản Python 3.12.x (bất kỳ phiên bản 3.12 nào)
# QUAN TRỌNG: Tick "Add Python to PATH" khi cài đặt

# Kiểm tra phiên bản
python --version
# Output: Python 3.12.x
```

#### Linux (Ubuntu/Debian):

```bash
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update
sudo apt install python3.12 python3.12-venv python3.12-dev -y
```

### 2.2 Cài Đặt eSpeak NG (BẮT BUỘC)

#### Windows:

1. Tải từ: https://github.com/espeak-ng/espeak-ng/releases
2. Tải file `espeak-ng-X.Y.Z-x64.msi`
3. Cài đặt vào: `C:\Program Files\eSpeak NG\`
4. Thêm vào PATH:
   ```
   C:\Program Files\eSpeak NG
   ```
5. Kiểm tra:
   ```bash
   espeak-ng --version
   ```

#### Linux:

```bash
sudo apt install espeak-ng -y
espeak-ng --version
```

### 2.3 Cài Đặt Build Tools (cho llama-cpp-python)

#### Windows - Visual Studio Build Tools (BẮT BUỘC):

1. Tải từ: https://visualstudio.microsoft.com/visual-cpp-build-tools/
2. Chạy installer và chọn:
   - **"Desktop development with C++"** workload
   - Đảm bảo các thành phần sau được chọn:
     - MSVC v143 - VS 2022 C++ x64/x86 build tools
     - Windows 10/11 SDK
     - C++ CMake tools for Windows
3. Khởi động lại máy sau khi cài đặt

#### Linux:

```bash
sudo apt update
sudo apt install build-essential cmake python3-dev -y
```

---

## 3. Cài Đặt llama-cpp-python cho CPU

### Tại sao cần build llama-cpp-python?

VieNeu-TTS sử dụng model GGUF (Q4/Q8) để inference trên CPU. Thư viện `llama-cpp-python` là wrapper Python cho `llama.cpp` - engine inference hiệu suất cao.

### 3.1 Cách 1: Cài từ Pre-built Wheel (Khuyến nghị)

**Windows:**

```bash
# Gỡ cài đặt phiên bản cũ (nếu có)
pip uninstall llama-cpp-python -y

# Cài đặt từ wheel pre-built cho CPU
pip install llama-cpp-python --extra-index-url https://abetlen.github.io/llama-cpp-python/whl/cpu
```

**Linux:**

```bash
pip uninstall llama-cpp-python -y
pip install llama-cpp-python --extra-index-url https://abetlen.github.io/llama-cpp-python/whl/cpu
```

### 3.2 Cách 2: Build từ Source (Nếu cách 1 lỗi)

#### Windows (với Visual Studio Build Tools):

```bash
# Mở "Developer Command Prompt for VS 2022" hoặc "x64 Native Tools Command Prompt"

# Set environment variables
set CMAKE_ARGS=-DLLAMA_BLAS=OFF -DLLAMA_CUBLAS=OFF -DLLAMA_AVX2=OFF
set FORCE_CMAKE=1

# Cài đặt
pip uninstall llama-cpp-python -y
pip install llama-cpp-python --no-cache-dir --force-reinstall
```

#### Windows (với AVX2 support - nhanh hơn cho CPU hiện đại):

```bash
# Nếu CPU hỗ trợ AVX2 (hầu hết CPU từ 2013 trở lên)
set CMAKE_ARGS=-DLLAMA_AVX2=ON
pip install llama-cpp-python --no-cache-dir --force-reinstall
```

#### Linux:

```bash
# Install cmake và build-essential
sudo apt install cmake build-essential -y

# Build cho CPU
CMAKE_ARGS="-DLLAMA_BLAS=OFF -DLLAMA_CUBLAS=OFF" pip install llama-cpp-python --no-cache-dir --force-reinstall
```

### 3.3 Kiểm Tra Cài Đặt Thành Công

```python
# Chạy Python shell
python -c "from llama_cpp import Llama; print('llama-cpp-python installed successfully!')"
```

### 3.4 Các Lỗi Thường Gặp Khi Build llama-cpp-python

| Lỗi | Nguyên nhân | Giải pháp |
|-----|-------------|-----------|
| `error: Microsoft Visual C++ 14.0 is required` | Thiếu Build Tools | Cài Visual Studio Build Tools với C++ workload |
| `CMake Error` | Thiếu CMake | `pip install cmake` |
| `fatal error: 'stdlib.h' file not found` (macOS) | Thiếu Xcode tools | `xcode-select --install` |
| `Building wheel failed` | Thiếu compiler | Xem hướng dẫn cài Build Tools ở trên |
| `No matching distribution found` | Python version sai | Sử dụng Python 3.12.x |

---

## 4. Cài Đặt VieNeu-TTS

### 4.1 Clone Repository

```bash
# Clone VieNeu-TTS vào thư mục project
cd /path/to/spp
git clone https://github.com/pnnbao97/VieNeu-TTS.git
```

### 4.2 Cài Đặt Dependencies cho CPU

**Bước 1: Chuyển sang config CPU**

```bash
cd VieNeu-TTS

# Windows (Command Prompt)
del pyproject.toml
ren pyproject.toml.cpu pyproject.toml

# Linux/macOS
rm pyproject.toml
mv pyproject.toml.cpu pyproject.toml
```

**Bước 2: Cài đặt với pip (thay thế UV)**

```bash
# Tạo và kích hoạt virtual environment
python -m venv venv

# Windows
venv\Scripts\activate

# Linux/macOS
source venv/bin/activate

# Cài đặt dependencies
pip install phonemizer>=3.3.0
pip install torch>=2.5.1 torchaudio>=2.5.1 --index-url https://download.pytorch.org/whl/cpu
pip install neucodec>=0.0.4
pip install librosa>=0.11.0
pip install gradio>=5.49.1
pip install onnxruntime>=1.23.2
pip install datasets>=3.2.0

# Cài llama-cpp-python (như đã hướng dẫn ở Bước 3)
pip install llama-cpp-python --extra-index-url https://abetlen.github.io/llama-cpp-python/whl/cpu
```

### 4.3 Cài Đặt Dependencies cho Main App (spp)

```bash
# Quay lại thư mục gốc
cd ..

# Cài đặt thêm dependencies cho main.py
pip install customtkinter
pip install python-docx
pip install google-genai
pip install requests

# PyAudio (tùy chọn - cho chức năng phát audio)
# Windows:
pip install pyaudio

# Linux:
sudo apt install portaudio19-dev python3-pyaudio -y
pip install pyaudio
```

### 4.4 Kiểm Tra VieNeu-TTS

```python
# Test import VieNeu-TTS
python -c "
import sys
sys.path.insert(0, 'VieNeu-TTS')
from vieneu_tts import VieNeuTTS
print('VieNeu-TTS imported successfully!')
"
```

---

## 5. Build EXE với PyInstaller

### 5.1 Cài Đặt PyInstaller

```bash
pip install pyinstaller
```

### 5.2 File Spec cho Build

Tạo file `main.spec`:

```python
# -*- mode: python ; coding: utf-8 -*-

import sys
from pathlib import Path

# Add VieNeu-TTS to path
vieneu_path = Path('.') / 'VieNeu-TTS'

a = Analysis(
    ['main.py'],
    pathex=[str(vieneu_path)],
    binaries=[],
    datas=[
        # VieNeu-TTS files
        ('VieNeu-TTS/sample', 'VieNeu-TTS/sample'),
        ('VieNeu-TTS/utils', 'VieNeu-TTS/utils'),
        ('VieNeu-TTS/vieneu_tts', 'VieNeu-TTS/vieneu_tts'),
        ('VieNeu-TTS/config.yaml', 'VieNeu-TTS'),
        # Edge TTS module
        ('edge', 'edge'),
        # App icon
        ('icon.ico', '.'),
    ],
    hiddenimports=[
        # VieNeu-TTS
        'vieneu_tts',
        'vieneu_tts.vieneu_tts',
        'utils',
        'utils.core_utils',
        'utils.normalize_text',
        'utils.phonemize_text',
        # llama.cpp
        'llama_cpp',
        # Phonemizer
        'phonemizer',
        'phonemizer.backend',
        'phonemizer.backend.espeak',
        # Audio processing
        'librosa',
        'soundfile',
        'neucodec',
        # PyTorch
        'torch',
        'torchaudio',
        # Other
        'customtkinter',
        'google.genai',
        'docx',
    ],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[
        # Exclude GPU-specific packages for CPU build
        'lmdeploy',
        'triton',
        'triton_windows',
        'cuda',
    ],
    noarchive=False,
    optimize=0,
)

pyz = PYZ(a.pure)

exe = EXE(
    pyz,
    a.scripts,
    [],
    exclude_binaries=True,
    name='FathTTS',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    console=False,  # Set True để debug
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon='icon.ico',
)

coll = COLLECT(
    exe,
    a.binaries,
    a.datas,
    strip=False,
    upx=True,
    upx_exclude=[],
    name='FathTTS',
)
```

### 5.3 Build Command

```bash
# Build với spec file
pyinstaller main.spec --clean

# Output sẽ nằm trong thư mục: dist/FathTTS/
```

### 5.4 Cấu Trúc Output (PyInstaller)

```
dist/
└── FathTTS/
    ├── FathTTS.exe              # File exe chính
    ├── VieNeu-TTS/              # Thư mục VieNeu-TTS
    │   ├── sample/              # Voice samples
    │   │   ├── Vĩnh (nam miền Nam).wav
    │   │   ├── Vĩnh (nam miền Nam).txt
    │   │   ├── Vĩnh (nam miền Nam).pt
    │   │   └── ...
    │   ├── utils/               # Utility modules
    │   ├── vieneu_tts/          # Core TTS module
    │   └── config.yaml          # Config file
    ├── edge/                    # Edge TTS module
    ├── _internal/               # PyInstaller runtime
    │   ├── llama_cpp/           # llama.cpp library
    │   ├── torch/               # PyTorch
    │   └── ...
    ├── ffmpeg.exe               # Cần copy thủ công
    └── icon.ico
```

---

## 6. Build EXE với Nuitka

Nuitka tạo exe tối ưu hơn PyInstaller nhưng build lâu hơn.

### 6.1 Cài Đặt Nuitka

```bash
pip install nuitka
pip install ordered-set zstandard  # Dependencies
```

### 6.2 Build Command

```bash
python -m nuitka ^
    --standalone ^
    --onefile ^
    --enable-plugin=tk-inter ^
    --enable-plugin=numpy ^
    --include-package=vieneu_tts ^
    --include-package=utils ^
    --include-package=edge ^
    --include-package=llama_cpp ^
    --include-package=phonemizer ^
    --include-package=neucodec ^
    --include-package=torch ^
    --include-package=torchaudio ^
    --include-package=customtkinter ^
    --include-data-dir=VieNeu-TTS=VieNeu-TTS ^
    --include-data-dir=edge=edge ^
    --include-data-files=icon.ico=icon.ico ^
    --windows-disable-console ^
    --windows-icon-from-ico=icon.ico ^
    --output-dir=dist ^
    --output-filename=FathTTS.exe ^
    main.py
```

### 6.3 Nuitka Multi-file Build (Khuyến nghị)

```bash
python -m nuitka ^
    --standalone ^
    --enable-plugin=tk-inter ^
    --enable-plugin=numpy ^
    --include-package=vieneu_tts ^
    --include-package=utils ^
    --include-package=llama_cpp ^
    --include-data-dir=VieNeu-TTS/sample=VieNeu-TTS/sample ^
    --include-data-dir=VieNeu-TTS/utils=VieNeu-TTS/utils ^
    --include-data-files=VieNeu-TTS/config.yaml=VieNeu-TTS/config.yaml ^
    --windows-disable-console ^
    --windows-icon-from-ico=icon.ico ^
    --output-dir=dist ^
    main.py
```

---

## 7. Cấu Trúc Thư Mục Output

### 7.1 Cấu Trúc Thư Mục Hoàn Chỉnh

Sau khi build, cấu trúc thư mục cần như sau để app hoạt động:

```
FathTTS/
├── FathTTS.exe                  # File exe chính
├── VieNeu-TTS/                  # Thư viện VieNeu-TTS (QUAN TRỌNG)
│   ├── sample/                  # Voice samples
│   │   ├── Vĩnh (nam miền Nam).wav
│   │   ├── Vĩnh (nam miền Nam).txt
│   │   ├── Vĩnh (nam miền Nam).pt
│   │   ├── Bình (nam miền Bắc).wav
│   │   ├── Bình (nam miền Bắc).txt
│   │   ├── Bình (nam miền Bắc).pt
│   │   ├── Ngọc (nữ miền Bắc).wav
│   │   ├── Ngọc (nữ miền Bắc).txt
│   │   ├── Ngọc (nữ miền Bắc).pt
│   │   ├── Dung (nữ miền Nam).wav
│   │   ├── Dung (nữ miền Nam).txt
│   │   ├── Dung (nữ miền Nam).pt
│   │   └── ... (các voice khác)
│   ├── utils/                   # Utility modules
│   │   ├── __init__.py
│   │   ├── core_utils.py
│   │   ├── normalize_text.py
│   │   ├── phonemize_text.py
│   │   └── phoneme_dict.json
│   ├── vieneu_tts/              # Core TTS module
│   │   ├── __init__.py
│   │   └── vieneu_tts.py
│   └── config.yaml
├── edge/                        # Edge TTS module
│   ├── __init__.py
│   └── communicate.py
├── capcutvoice/                 # CapCut voice data (nếu có)
├── tts_output/                  # Thư mục output (tự tạo)
├── ffmpeg.exe                   # FFmpeg binary
├── settings.json                # Settings file (tự tạo khi chạy)
└── _internal/                   # PyInstaller runtime (auto-generated)
    ├── llama_cpp/
    │   └── lib/
    │       └── llama.dll        # llama.cpp library
    ├── torch/
    ├── phonemizer/
    └── ...
```

### 7.2 Files Cần Copy Thủ Công

Một số files cần copy thủ công sau khi build:

1. **ffmpeg.exe** - Tải từ https://www.gyan.dev/ffmpeg/builds/
2. **VieNeu-TTS/sample/** - Voice sample files (nếu chưa include trong build)
3. **Models GGUF** - Sẽ tự động download lần đầu chạy từ HuggingFace

---

## 8. Khắc Phục Sự Cố

### 8.1 Lỗi "DLL load failed" với llama-cpp-python

**Nguyên nhân:** Thiếu Visual C++ Redistributable

**Giải pháp:**
1. Tải từ: https://aka.ms/vs/17/release/vc_redist.x64.exe
2. Cài đặt và restart

### 8.2 Lỗi "Failed to import phonemizer"

**Nguyên nhân:** eSpeak NG chưa được cài hoặc không trong PATH

**Giải pháp:**
```bash
# Kiểm tra eSpeak
espeak-ng --version

# Nếu không tìm thấy, thêm vào PATH:
# Windows: C:\Program Files\eSpeak NG
```

### 8.3 Lỗi "No module named 'llama_cpp'"

**Giải pháp:**
```bash
# Kiểm tra cài đặt
pip show llama-cpp-python

# Nếu không có, cài lại
pip install llama-cpp-python --extra-index-url https://abetlen.github.io/llama-cpp-python/whl/cpu
```

### 8.4 Lỗi "CUDA not found" khi chạy trên CPU

**Nguyên nhân:** App đang tìm CUDA nhưng không có GPU

**Giải pháp:**
- Đảm bảo chọn model GGUF (Q4 hoặc Q8) thay vì model GPU
- Chọn Device = "CPU" trong settings

### 8.5 Lỗi khi build: "hidden import not found"

**Giải pháp:** Thêm module vào `hiddenimports` trong file spec:
```python
hiddenimports=[
    'module_name',
    'another_module',
]
```

### 8.6 App không tìm thấy VieNeu-TTS sau khi build

**Nguyên nhân:** Đường dẫn không đúng

**Giải pháp:** Kiểm tra code trong `main.py`:
```python
# Đường dẫn VieNeu-TTS
VIENEU_TTS_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "VieNeu-TTS")

# Nếu chạy từ exe
if getattr(sys, 'frozen', False):
    VIENEU_TTS_DIR = os.path.join(os.path.dirname(sys.executable), "VieNeu-TTS")
```

---

## 9. Script Build Tự Động

### 9.1 Build Script (Windows)

Tạo file `build.bat`:

```batch
@echo off
echo ====================================
echo Building FathTTS with VieNeu-TTS
echo ====================================

:: Check Python version
python --version 2>&1 | findstr "3.12" >nul
if errorlevel 1 (
    echo ERROR: Python 3.12 is required!
    exit /b 1
)

:: Check eSpeak
espeak-ng --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: eSpeak NG is not installed!
    exit /b 1
)

:: Install dependencies
echo Installing dependencies...
pip install pyinstaller
pip install llama-cpp-python --extra-index-url https://abetlen.github.io/llama-cpp-python/whl/cpu

:: Build with PyInstaller
echo Building executable...
pyinstaller main.spec --clean --noconfirm

:: Copy additional files
echo Copying additional files...
xcopy /E /I "VieNeu-TTS\sample" "dist\FathTTS\VieNeu-TTS\sample"
copy "ffmpeg.exe" "dist\FathTTS\" 2>nul

echo ====================================
echo Build completed! Output: dist\FathTTS\
echo ====================================
pause
```

### 9.2 Build Script (Linux/macOS)

Tạo file `build.sh`:

```bash
#!/bin/bash
set -e

echo "===================================="
echo "Building FathTTS with VieNeu-TTS"
echo "===================================="

# Check Python version
if ! python3.12 --version &> /dev/null; then
    echo "ERROR: Python 3.12 is required!"
    exit 1
fi

# Check eSpeak
if ! espeak-ng --version &> /dev/null; then
    echo "ERROR: eSpeak NG is not installed!"
    exit 1
fi

# Install dependencies
echo "Installing dependencies..."
pip install pyinstaller
pip install llama-cpp-python --extra-index-url https://abetlen.github.io/llama-cpp-python/whl/cpu

# Build with PyInstaller
echo "Building executable..."
pyinstaller main.spec --clean --noconfirm

# Copy additional files
echo "Copying additional files..."
cp -r VieNeu-TTS/sample dist/FathTTS/VieNeu-TTS/

echo "===================================="
echo "Build completed! Output: dist/FathTTS/"
echo "===================================="
```

---

## 10. Tham Khảo

### Links hữu ích:

- **VieNeu-TTS GitHub:** https://github.com/pnnbao97/VieNeu-TTS
- **llama.cpp:** https://github.com/ggerganov/llama.cpp
- **llama-cpp-python:** https://github.com/abetlen/llama-cpp-python
- **llama-cpp-python Wheels:** https://abetlen.github.io/llama-cpp-python/whl/cpu
- **eSpeak NG:** https://github.com/espeak-ng/espeak-ng
- **PyInstaller:** https://pyinstaller.org/
- **Nuitka:** https://nuitka.net/

### Hugging Face Models:

- **VieNeu-TTS (GPU):** https://huggingface.co/pnnbao-ump/VieNeu-TTS
- **VieNeu-TTS Q8 GGUF:** https://huggingface.co/pnnbao-ump/VieNeu-TTS-q8-gguf
- **VieNeu-TTS Q4 GGUF:** https://huggingface.co/pnnbao-ump/VieNeu-TTS-q4-gguf

---

**Được tạo bởi:** Fath TTS Team  
**Ngày cập nhật:** Tháng 12, 2025  
**Phiên bản:** 1.0
