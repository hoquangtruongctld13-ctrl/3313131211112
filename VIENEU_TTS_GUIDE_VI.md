# 🎤 Hướng Dẫn Cài Đặt VieNeu-TTS Chi Tiết (Tiếng Việt)

## Mục Lục

1. [Giới Thiệu](#1-giới-thiệu)
2. [Yêu Cầu Hệ Thống](#2-yêu-cầu-hệ-thống)
3. [Cài Đặt Từ A-Z](#3-cài-đặt-từ-a-z)
   - [Bước 1: Cài Đặt Python](#bước-1-cài-đặt-python)
   - [Bước 2: Cài Đặt eSpeak NG](#bước-2-cài-đặt-espeak-ng)
   - [Bước 3: Clone Repository](#bước-3-clone-repository)
   - [Bước 4: Cài Đặt Thư Viện](#bước-4-cài-đặt-thư-viện)
   - [Bước 5: Cài Đặt FFmpeg (Tùy chọn)](#bước-5-cài-đặt-ffmpeg-tùy-chọn)
4. [Danh Sách Thư Viện Cần Cài](#4-danh-sách-thư-viện-cần-cài)
5. [Cách Chạy Ứng Dụng](#5-cách-chạy-ứng-dụng)
6. [Hướng Dẫn Sử Dụng Tab VieNeu-TTS](#6-hướng-dẫn-sử-dụng-tab-vieneu-tts)
7. [Giải Thích Cấu Hình Model](#7-giải-thích-cấu-hình-model)
8. [Khắc Phục Sự Cố Thường Gặp](#8-khắc-phục-sự-cố-thường-gặp)
9. [Tham Khảo Thêm](#9-tham-khảo-thêm)

---

## 1. Giới Thiệu

**VieNeu-TTS** là một ứng dụng chuyển văn bản thành giọng nói (Text-to-Speech) tiếng Việt chất lượng cao với khả năng **nhân bản giọng nói tức thì** (instant voice cloning).

### Đặc điểm nổi bật:
- ✅ **Phát âm chuẩn**: Tiếng Việt rõ ràng, tự nhiên
- ✅ **Chuyển đổi ngôn ngữ**: Hỗ trợ chuyển đổi mượt mà giữa tiếng Việt và tiếng Anh
- ✅ **Nhân bản giọng nói**: Có thể sao chép giọng nói từ file audio mẫu
- ✅ **Tổng hợp real-time**: Tạo âm thanh 24 kHz trên CPU hoặc GPU
- ✅ **Nhiều định dạng model**: PyTorch, GGUF Q4/Q8 (tối ưu cho CPU), ONNX

### Các Model Có Sẵn:

| Model | Định dạng | Thiết bị | Chất lượng | Tốc độ | Streaming |
|-------|-----------|----------|------------|--------|-----------|
| VieNeu-TTS (GPU) | PyTorch | GPU/CPU | ⭐⭐⭐⭐⭐ | Rất nhanh với lmdeploy | ❌ |
| VieNeu-TTS-q8-gguf | GGUF Q8 | CPU/GPU | ⭐⭐⭐⭐ | Nhanh | ✅ |
| VieNeu-TTS-q4-gguf | GGUF Q4 | CPU/GPU | ⭐⭐⭐ | Rất nhanh | ✅ |

**Khuyến nghị:**
- **Người dùng GPU**: Sử dụng `VieNeu-TTS (GPU)` để có chất lượng tốt nhất
- **Người dùng CPU**: Sử dụng `VieNeu-TTS-q4-gguf` để inference nhanh nhất

---

## 2. Yêu Cầu Hệ Thống

### Yêu cầu tối thiểu:

| Thành phần | Yêu cầu tối thiểu | Khuyến nghị |
|------------|-------------------|-------------|
| **Hệ điều hành** | Windows 10/11, Linux, macOS | Windows 11 hoặc Ubuntu 22.04 |
| **Python** | 3.12.x (yêu cầu bởi VieNeu-TTS) | Python 3.12.x |
| **RAM** | 8GB | 16GB+ |
| **Ổ cứng** | 10GB trống | 20GB+ SSD |
| **GPU (tùy chọn)** | NVIDIA GTX 1060 6GB+ | NVIDIA RTX 3060+ |
| **CUDA (nếu dùng GPU)** | CUDA 12.8+ | CUDA 12.8+ |

### Yêu cầu cho từng chế độ:

**Chế độ CPU:**
- RAM: 8GB+
- Không cần GPU
- Sử dụng model GGUF (Q4/Q8)

**Chế độ GPU:**
- VRAM: 6GB+ (8GB+ khuyến nghị)
- NVIDIA Driver mới nhất
- CUDA Toolkit 12.8+

---

## 3. Cài Đặt Từ A-Z

### Bước 1: Cài Đặt Python

#### Windows:

1. **Tải Python 3.12:**
   - Truy cập: https://www.python.org/downloads/
   - Tải phiên bản **Python 3.12.x** (KHÔNG phải 3.13 hay 3.11)
   
2. **Cài đặt Python:**
   - Chạy file cài đặt đã tải
   - ⚠️ **QUAN TRỌNG**: Tick vào ô **"Add Python to PATH"** ở màn hình đầu tiên
   - Click "Install Now"
   - Chờ cài đặt hoàn tất

3. **Kiểm tra cài đặt:**
   - Mở **Command Prompt** (nhấn `Win + R`, gõ `cmd`, Enter)
   - Gõ lệnh:
   ```bash
   python --version
   ```
   - Kết quả phải hiện: `Python 3.12.x`

#### Linux (Ubuntu/Debian):

```bash
# Cập nhật hệ thống
sudo apt update
sudo apt upgrade -y

# Cài đặt Python 3.12
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update
sudo apt install python3.12 python3.12-venv python3.12-dev -y

# Kiểm tra
python3.12 --version
```

#### macOS:

```bash
# Sử dụng Homebrew
brew install python@3.12

# Kiểm tra
python3.12 --version
```

---

### Bước 2: Cài Đặt eSpeak NG

eSpeak NG là thành phần bắt buộc để chuyển đổi văn bản thành phoneme (âm vị).

#### Windows:

1. **Tải eSpeak NG:**
   - Truy cập: https://github.com/espeak-ng/espeak-ng/releases
   - Tải file `espeak-ng-X.Y.Z-x64.msi` (phiên bản mới nhất)

2. **Cài đặt:**
   - Chạy file `.msi` đã tải
   - Chọn cài đặt vào thư mục mặc định: `C:\Program Files\eSpeak NG\`
   - Click "Install"

3. **Thêm vào PATH (nếu chưa tự động):**
   - Nhấn `Win + R`, gõ `sysdm.cpl`, Enter
   - Tab "Advanced" → "Environment Variables"
   - Trong "System Variables", tìm "Path" → "Edit"
   - Click "New" → Thêm: `C:\Program Files\eSpeak NG`
   - OK → OK → OK

4. **Kiểm tra:**
   - Mở Command Prompt mới
   - Gõ:
   ```bash
   espeak-ng --version
   ```

#### Linux (Ubuntu/Debian):

```bash
sudo apt install espeak-ng -y

# Kiểm tra
espeak-ng --version
```

#### macOS:

```bash
brew install espeak

# Kiểm tra
espeak-ng --version
```

---

### Bước 3: Clone Repository

#### Cách 1: Sử dụng Git (Khuyến nghị)

1. **Cài Git (nếu chưa có):**
   
   **Windows:**
   - Tải từ: https://git-scm.com/download/win
   - Cài đặt với các tùy chọn mặc định

   **Linux:**
   ```bash
   sudo apt install git -y
   ```

   **macOS:**
   ```bash
   brew install git
   ```

2. **Clone repository:**
   
   Mở Terminal/Command Prompt và chạy:
   ```bash
   # Clone VieNeu-TTS
   git clone https://github.com/pnnbao97/VieNeu-TTS.git
   cd VieNeu-TTS
   ```

#### Cách 2: Tải trực tiếp (Không cần Git)

1. Truy cập: https://github.com/pnnbao97/VieNeu-TTS
2. Click nút xanh "Code" → "Download ZIP"
3. Giải nén file ZIP vào thư mục mong muốn
4. Mở Terminal/Command Prompt và `cd` vào thư mục đã giải nén

---

### Bước 4: Cài Đặt Thư Viện

#### Cài đặt UV Package Manager (Khuyến nghị)

UV là công cụ quản lý package Python nhanh và hiện đại. VieNeu-TTS sử dụng UV làm package manager chính.

**Windows:**
```bash
# Sử dụng PowerShell (chạy với quyền Administrator)
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

**Linux/macOS:**
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

---

#### Tùy chọn A: Cài Đặt cho Người Dùng GPU (NVIDIA)

> ⚠️ **QUAN TRỌNG**: Bạn cần cài đặt **NVIDIA GPU Computing Toolkit (CUDA Toolkit)** trước!
> Tải từ: https://developer.nvidia.com/cuda-downloads

1. **Kiểm tra CUDA:**
   ```bash
   nvidia-smi
   ```
   Đảm bảo Driver Version >= 535 và CUDA Version >= 12.8

2. **Cài đặt dependencies:**
   ```bash
   cd VieNeu-TTS
   uv sync
   ```

3. **Đợi quá trình cài đặt hoàn tất** (có thể mất 5-15 phút tùy tốc độ mạng)

---

#### Tùy chọn B: Cài Đặt cho Người Dùng CPU

1. **Đổi sang cấu hình CPU:**
   
   **Windows (Command Prompt):**
   ```cmd
   cd VieNeu-TTS
   del pyproject.toml
   ren pyproject.toml.cpu pyproject.toml
   ```

   **Linux/macOS:**
   ```bash
   cd VieNeu-TTS
   rm pyproject.toml
   mv pyproject.toml.cpu pyproject.toml
   ```

2. **Cài đặt dependencies:**
   ```bash
   uv sync
   ```

---

#### Cách cài đặt thay thế (Không dùng UV - sử dụng pip)

Nếu bạn không muốn dùng UV, có thể sử dụng pip truyền thống:

```bash
# Tạo môi trường ảo
python -m venv venv

# Kích hoạt môi trường ảo
# Windows:
venv\Scripts\activate
# Linux/macOS:
source venv/bin/activate

# Cài đặt thư viện
pip install -r requirements.txt
```

---

### Bước 5: Cài Đặt FFmpeg (Tùy chọn)

FFmpeg cần thiết để ghép các file audio thành một file duy nhất.

#### Windows:

1. Tải FFmpeg từ: https://www.gyan.dev/ffmpeg/builds/
2. Chọn "ffmpeg-release-essentials.zip"
3. Giải nén và copy file `ffmpeg.exe` vào thư mục VieNeu-TTS hoặc thêm vào PATH

#### Linux:

```bash
sudo apt install ffmpeg -y
```

#### macOS:

```bash
brew install ffmpeg
```

---

## 4. Danh Sách Thư Viện Cần Cài

### Thư viện core (bắt buộc):

| Thư viện | Phiên bản | Mô tả |
|----------|-----------|-------|
| `phonemizer` | >=3.3.0 | Chuyển văn bản thành phoneme |
| `torch` | >=2.5.1 | PyTorch deep learning framework |
| `torchaudio` | >=2.5.1 | Xử lý audio với PyTorch |
| `neucodec` | >=0.0.4 | Codec neural cho audio |
| `librosa` | >=0.11.0 | Phân tích audio |
| `gradio` | >=5.49.1 | Giao diện web |
| `onnxruntime` | >=1.23.2 | Runtime ONNX |
| `datasets` | >=3.2.0 | Xử lý datasets |

### Thư viện cho GPU (tùy chọn):

| Thư viện | Phiên bản | Mô tả |
|----------|-----------|-------|
| `lmdeploy` | >=0.11.0 | Tối ưu inference trên GPU |
| `triton` | >=3.0.0 | Compiler cho GPU kernels |
| `triton-windows` | >=3.5.1 | Triton cho Windows |

### Thư viện cho CPU (GGUF models):

| Thư viện | Phiên bản | Mô tả |
|----------|-----------|-------|
| `llama-cpp-python` | >=0.3.2 | Chạy model GGUF trên CPU |

### Thư viện bổ sung (cho main.py với tab VieNeu-TTS):

| Thư viện | Mô tả |
|----------|-------|
| `customtkinter` | Giao diện đồ họa hiện đại |
| `requests` | HTTP requests |
| `python-docx` | Đọc file .docx |
| `pyaudio` | Phát audio (tùy chọn) |
| `google-genai` | Google Gemini API (cho các tab khác) |

---

## 5. Cách Chạy Ứng Dụng

### Chạy Gradio Web Interface (Khuyến nghị cho người mới)

Đây là cách dễ nhất để sử dụng VieNeu-TTS với giao diện web đẹp mắt.

```bash
cd VieNeu-TTS

# Nếu dùng UV
uv run gradio_app.py

# Nếu dùng pip/venv
python gradio_app.py
```

Sau đó mở trình duyệt và truy cập: **http://127.0.0.1:7860**

### Chạy Main.py (Batch inference)

```bash
cd VieNeu-TTS

# Nếu dùng UV
uv run main.py

# Nếu dùng pip/venv
python main.py
```

### Chạy với tích hợp Tab VieNeu-TTS trong Fath TTS (Repository spp)

Repository hiện tại (`spp`) đã tích hợp VieNeu-TTS như một tab trong ứng dụng desktop. Để chạy:

1. **Đảm bảo thư mục VieNeu-TTS tồn tại:**
   - Clone VieNeu-TTS vào thư mục gốc của spp:
   ```bash
   cd /path/to/spp
   git clone https://github.com/pnnbao97/VieNeu-TTS.git
   ```

2. **Cài đặt thêm dependencies cho main.py:**
   ```bash
   pip install customtkinter pyaudio python-docx google-genai
   ```

3. **Chạy ứng dụng:**
   ```bash
   python main.py
   ```

---

## 6. Hướng Dẫn Sử Dụng Tab VieNeu-TTS

### Trong Gradio Web Interface:

1. **Chọn Backbone Model:**
   - `VieNeu-TTS (GPU)`: Chất lượng cao nhất, cần GPU
   - `VieNeu-TTS-q8-gguf`: Cân bằng chất lượng/tốc độ
   - `VieNeu-TTS-q4-gguf`: Nhẹ nhất, phù hợp CPU

2. **Chọn Codec:**
   - `NeuCodec (Standard)`: Codec chuẩn
   - `NeuCodec ONNX (Fast CPU)`: Tối ưu cho CPU

3. **Chọn Device:**
   - `Auto`: Tự động phát hiện
   - `CPU`: Chạy trên CPU
   - `CUDA`: Chạy trên GPU NVIDIA

4. **Click "🔄 Tải Model"** và đợi model được tải

5. **Nhập văn bản** vào ô text

6. **Chọn giọng mẫu:**
   - Tab "👤 Preset": Chọn từ các giọng có sẵn
   - Tab "🎙️ Custom": Upload file audio mẫu của bạn

7. **Click "🎵 Bắt đầu"** để tạo audio

### Các giọng mẫu có sẵn:

| Tên | Giới tính | Vùng miền |
|-----|-----------|-----------|
| Vĩnh | Nam | Miền Nam |
| Bình | Nam | Miền Bắc |
| Ngọc | Nữ | Miền Bắc |
| Dung | Nữ | Miền Nam |
| Tuyên | Nam | Miền Bắc |
| Nguyên | Nam | Miền Nam |
| Sơn | Nam | Miền Nam |
| Đoan | Nữ | Miền Nam |
| Ly | Nữ | Miền Bắc |

---

## 7. Giải Thích Cấu Hình Model

### File `config.yaml`:

```yaml
# Cài đặt văn bản
text_settings:
  max_chars_per_chunk: 256     # Số ký tự tối đa mỗi đoạn
  max_total_chars_streaming: 3000  # Tổng ký tự tối đa cho streaming

# Cấu hình backbone
backbone_configs:
  "VieNeu-TTS (GPU)":
    repo: pnnbao-ump/VieNeu-TTS
    supports_streaming: false
    description: Chất lượng cao nhất, yêu cầu GPU
    
  "VieNeu-TTS-q8-gguf":
    repo: pnnbao-ump/VieNeu-TTS-q8-gguf
    supports_streaming: true
    description: Cân bằng giữa chất lượng và tốc độ
    
  "VieNeu-TTS-q4-gguf":
    repo: pnnbao-ump/VieNeu-TTS-q4-gguf
    supports_streaming: true
    description: Nhẹ nhất, phù hợp CPU

# Cấu hình codec
codec_configs:
  "NeuCodec (Standard)":
    repo: neuphonic/neucodec
    use_preencoded: false
    
  "NeuCodec ONNX (Fast CPU)":
    repo: neuphonic/neucodec-onnx-decoder
    use_preencoded: true  # Cần file .pt pre-encoded
```

### Giải thích các tham số:

- **repo**: Repository Hugging Face chứa model
- **supports_streaming**: Model có hỗ trợ streaming không
- **use_preencoded**: Codec có cần file .pt pre-encoded không

---

## 8. Khắc Phục Sự Cố Thường Gặp

### Lỗi 1: "No module named 'phonemizer'"

**Nguyên nhân:** Chưa cài eSpeak NG

**Giải pháp:**
- Cài eSpeak NG theo hướng dẫn Bước 2
- Khởi động lại Terminal/Command Prompt

---

### Lỗi 2: "CUDA out of memory"

**Nguyên nhân:** GPU không đủ VRAM

**Giải pháp:**
1. Giảm Max Batch Size (nếu có slider)
2. Giảm độ dài văn bản
3. Đóng các ứng dụng khác đang dùng GPU
4. Chuyển sang model GGUF (Q4/Q8) chạy trên CPU

---

### Lỗi 3: "Failed to import llama_cpp"

**Nguyên nhân:** Chưa cài llama-cpp-python hoặc cài sai version. Thư viện này cần được build từ source hoặc cài từ wheel phù hợp với hệ thống.

**Giải pháp chi tiết theo hệ điều hành:**

#### 🔹 Windows:

**Bước 1: Cài Visual Studio Build Tools (BẮT BUỘC)**
1. Tải từ: https://visualstudio.microsoft.com/visual-cpp-build-tools/
2. Chạy file cài đặt
3. Chọn "Desktop development with C++" workload
4. Click Install và chờ cài đặt hoàn tất
5. Khởi động lại máy tính

**Bước 2: Cài llama-cpp-python**
```bash
# Gỡ cài đặt phiên bản cũ (nếu có)
pip uninstall llama-cpp-python -y

# Cài đặt mới
pip install llama-cpp-python --force-reinstall
```

**Nếu vẫn lỗi - Cài từ wheel có sẵn (khuyến nghị):**
```bash
pip install llama-cpp-python --extra-index-url https://abetlen.github.io/llama-cpp-python/whl/cpu
```

**Với UV Package Manager:**
```bash
uv pip install llama-cpp-python --extra-index-url https://abetlen.github.io/llama-cpp-python/whl/cpu
```

#### 🔹 Linux (Ubuntu/Debian):

```bash
# Cài đặt các dependencies cần thiết
sudo apt update
sudo apt install build-essential cmake python3-dev -y

# Gỡ cài đặt phiên bản cũ (nếu có)
pip uninstall llama-cpp-python -y

# Cài đặt mới
pip install llama-cpp-python --force-reinstall
```

**Nếu vẫn lỗi:**
```bash
# Cài từ wheel có sẵn
pip install llama-cpp-python --extra-index-url https://abetlen.github.io/llama-cpp-python/whl/cpu
```

#### 🔹 macOS:

```bash
# Cài đặt Xcode Command Line Tools
xcode-select --install

# Cài đặt cmake (nếu chưa có)
brew install cmake

# Gỡ cài đặt phiên bản cũ (nếu có)
pip uninstall llama-cpp-python -y

# Cài đặt mới
pip install llama-cpp-python --force-reinstall
```

#### 🔹 Các lỗi thường gặp khi cài llama-cpp-python:

| Lỗi | Nguyên nhân | Giải pháp |
|-----|-------------|-----------|
| `error: Microsoft Visual C++ 14.0 is required` | Thiếu Visual Studio Build Tools | Cài Visual Studio Build Tools với C++ workload |
| `CMake Error` | Thiếu CMake | `pip install cmake` hoặc cài từ website |
| `No matching distribution found` | Phiên bản Python không tương thích | Sử dụng Python 3.12.x |
| `Building wheel failed` | Thiếu compiler | Xem hướng dẫn cài Build Tools ở trên |

#### 🔹 Kiểm tra cài đặt thành công:

```python
# Mở Python shell và chạy:
python -c "from llama_cpp import Llama; print('llama_cpp installed successfully!')"
```

Nếu không có lỗi, llama-cpp-python đã được cài đặt thành công.

---

### Lỗi 4: "$env:CUDA_PATH not found"

**Nguyên nhân:** Chưa cài CUDA Toolkit

**Giải pháp:**
1. Tải và cài CUDA Toolkit từ: https://developer.nvidia.com/cuda-downloads
2. Khởi động lại máy tính
3. Kiểm tra: `nvidia-smi`

---

### Lỗi 5: "No valid speech tokens found"

**Nguyên nhân:** Model không sinh ra token hợp lệ

**Giải pháp:**
1. Kiểm tra văn bản đầu vào (không để trống, không có ký tự đặc biệt lạ)
2. Thử văn bản ngắn hơn
3. Thử model khác

---

### Lỗi 6: Tốc độ chậm trên GPU

**Nguyên nhân:** Không sử dụng LMDeploy hoặc Triton

**Giải pháp:**
1. Đảm bảo đã tick "⚡ Enable Triton Compilation"
2. Kiểm tra đã cài đúng phiên bản lmdeploy
3. Cài triton: `pip install triton` (Linux) hoặc `pip install triton-windows` (Windows)

---

### Lỗi 7: "espeak: command not found" (macOS)

**Giải pháp:**
```bash
export PHONEMIZER_ESPEAK_LIBRARY=/opt/homebrew/lib/libespeak-ng.dylib
```

Thêm dòng này vào `~/.zshrc` hoặc `~/.bashrc` để lưu vĩnh viễn.

---

## 9. Tham Khảo Thêm

### Links hữu ích:

- **GitHub Repository:** https://github.com/pnnbao97/VieNeu-TTS
- **Hugging Face Models:**
  - VieNeu-TTS: https://huggingface.co/pnnbao-ump/VieNeu-TTS
  - VieNeu-TTS-q4-gguf: https://huggingface.co/pnnbao-ump/VieNeu-TTS-q4-gguf
  - VieNeu-TTS-q8-gguf: https://huggingface.co/pnnbao-ump/VieNeu-TTS-q8-gguf
- **Dataset:** https://huggingface.co/datasets/pnnbao-ump/VieNeu-TTS-1000h
- **CUDA Toolkit:** https://developer.nvidia.com/cuda-downloads
- **eSpeak NG:** https://github.com/espeak-ng/espeak-ng

### Liên hệ hỗ trợ:

- **GitHub Issues:** https://github.com/pnnbao97/VieNeu-TTS/issues
- **Tác giả:** Phạm Nguyễn Ngọc Bảo
- **Facebook:** https://www.facebook.com/bao.phamnguyenngoc.5

---

## Tóm Tắt Nhanh (Quick Start)

### Cho người dùng CPU:

```bash
# 1. Clone repo
git clone https://github.com/pnnbao97/VieNeu-TTS.git
cd VieNeu-TTS

# 2. Cài eSpeak NG (xem Bước 2)

# 3. Đổi sang config CPU (chạy từng lệnh)
rm pyproject.toml
mv pyproject.toml.cpu pyproject.toml

# 4. Cài dependencies
pip install uv
uv sync

# 5. Chạy
uv run gradio_app.py
```

### Cho người dùng GPU:

```bash
# 1. Cài CUDA Toolkit (https://developer.nvidia.com/cuda-downloads)

# 2. Clone repo
git clone https://github.com/pnnbao97/VieNeu-TTS.git
cd VieNeu-TTS

# 3. Cài eSpeak NG (xem Bước 2)

# 4. Cài dependencies
pip install uv
uv sync

# 5. Chạy
uv run gradio_app.py
```

---

## 10. Build EXE với PyInstaller/Nuitka

Nếu bạn muốn đóng gói ứng dụng thành file .exe để phân phối, vui lòng tham khảo tài liệu **[BUILD_GUIDE.md](BUILD_GUIDE.md)** để biết hướng dẫn chi tiết về:

- Cách build llama-cpp-python cho CPU
- Cấu hình PyInstaller spec file
- Cấu trúc thư mục output
- Script build tự động
- Khắc phục sự cố khi build

### Quick Start Build:

```bash
# Windows - Chạy script build tự động
build.bat

# Hoặc build thủ công
pyinstaller main_fath.spec --clean
```

---

**Được tạo bởi:** Fath TTS Team  
**Ngày cập nhật:** Tháng 12, 2025  
**Phiên bản:** 1.1
