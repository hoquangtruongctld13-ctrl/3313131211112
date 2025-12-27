@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

echo ====================================================
echo   VieNeu-TTS Build Portable với Nuitka
echo   Compile code + copy libs vào cùng thư mục exe
echo ====================================================
echo.

:: ===========================
:: Cấu hình
:: ===========================
set "OUTPUT_NAME=VieNeuTTS"
set "OUTPUT_DIR=dist_portable"

:: ===========================
:: 1. Kiểm tra Python version
:: ===========================
echo [1/7] Kiểm tra Python version...
python --version 2>&1 | findstr "Python 3\.12" >nul
if errorlevel 1 (
    echo [ERROR] Python 3.12 là bắt buộc!
    pause
    exit /b 1
)
echo       ✓ Python 3.12
echo.

:: ===========================
:: 2. Kiểm tra eSpeak NG
:: ===========================
echo [2/7] Kiểm tra eSpeak NG...
espeak-ng --version >nul 2>&1
if errorlevel 1 (
    echo [WARNING] eSpeak NG không tìm thấy - VN TTS sẽ không hoạt động
) else (
    echo       ✓ eSpeak NG đã cài đặt
)
echo.

:: ===========================
:: 3. Cài đặt dependencies
:: ===========================
echo [3/7] Cài đặt Nuitka và build dependencies...
pip install nuitka ordered-set zstandard >nul 2>&1
echo       ✓ Nuitka đã được cài đặt
echo.

:: ===========================
:: 4. Xóa build cũ
:: ===========================
echo [4/7] Dọn dẹp build cũ...
if exist "%OUTPUT_DIR%" rmdir /s /q "%OUTPUT_DIR%"
mkdir "%OUTPUT_DIR%"
echo       ✓ Đã dọn dẹp
echo.

:: ===========================
:: 5. Build với Nuitka
:: ===========================
echo [5/7] Build với Nuitka...
echo       Đây là build PORTABLE - bao gồm tất cả thư viện
echo       Thời gian: 5-20 phút tùy cấu hình máy
echo.

python -m nuitka ^
    --standalone ^
    --enable-plugin=tk-inter ^
    --enable-plugin=numpy ^
    --follow-imports ^
    --include-package=customtkinter ^
    --include-package=edge ^
    --include-package=requests ^
    --include-package=PIL ^
    --nofollow-import-to=torch ^
    --nofollow-import-to=torchaudio ^
    --nofollow-import-to=torchvision ^
    --nofollow-import-to=neucodec ^
    --nofollow-import-to=llama_cpp ^
    --nofollow-import-to=phonemizer ^
    --nofollow-import-to=librosa ^
    --nofollow-import-to=soundfile ^
    --nofollow-import-to=onnxruntime ^
    --nofollow-import-to=transformers ^
    --nofollow-import-to=huggingface_hub ^
    --nofollow-import-to=safetensors ^
    --nofollow-import-to=datasets ^
    --nofollow-import-to=google ^
    --nofollow-import-to=google.genai ^
    --nofollow-import-to=docx ^
    --nofollow-import-to=pyaudio ^
    --nofollow-import-to=scipy ^
    --include-data-dir=edge=edge ^
    --include-data-files=icon.ico=icon.ico ^
    --windows-icon-from-ico=icon.ico ^
    --windows-console-mode=disable ^
    --output-dir=%OUTPUT_DIR% ^
    --output-filename=%OUTPUT_NAME%.exe ^
    --assume-yes-for-downloads ^
    main.py

if errorlevel 1 (
    echo [ERROR] Nuitka build thất bại!
    pause
    exit /b 1
)
echo       ✓ Nuitka build thành công
echo.

:: ===========================
:: 6. Copy thư viện và data
:: ===========================
echo [6/7] Copy thư viện runtime và data files...

:: Tìm thư mục output của Nuitka
set "DIST_DIR=%OUTPUT_DIR%\main.dist"
if not exist "%DIST_DIR%" (
    for /d %%i in (%OUTPUT_DIR%\*.dist) do set "DIST_DIR=%%i"
)

:: Tạo thư mục libs cho thư viện nặng
mkdir "%DIST_DIR%\libs" 2>nul

:: Copy VieNeu-TTS
echo       - Copying VieNeu-TTS...
if exist "VieNeu-TTS" (
    xcopy /E /I /Y "VieNeu-TTS\sample" "%DIST_DIR%\VieNeu-TTS\sample" >nul 2>&1
    xcopy /E /I /Y "VieNeu-TTS\utils" "%DIST_DIR%\VieNeu-TTS\utils" >nul 2>&1
    xcopy /E /I /Y "VieNeu-TTS\vieneu_tts" "%DIST_DIR%\VieNeu-TTS\vieneu_tts" >nul 2>&1
    copy "VieNeu-TTS\config.yaml" "%DIST_DIR%\VieNeu-TTS\" >nul 2>&1
    echo       ✓ VieNeu-TTS
)

:: Copy edge module (nếu chưa được include)
echo       - Copying edge module...
if not exist "%DIST_DIR%\edge" (
    xcopy /E /I /Y "edge" "%DIST_DIR%\edge" >nul 2>&1
)
echo       ✓ edge module

:: Copy ffmpeg
echo       - Copying ffmpeg...
if exist "ffmpeg.exe" (
    copy "ffmpeg.exe" "%DIST_DIR%\" >nul 2>&1
    echo       ✓ ffmpeg.exe
) else (
    echo       [NOTE] ffmpeg.exe không tìm thấy - cần tải về sau
)

:: Copy config files
echo       - Copying config files...
if exist "config.yaml" copy "config.yaml" "%DIST_DIR%\" >nul 2>&1
if exist "icon.ico" copy "icon.ico" "%DIST_DIR%\" >nul 2>&1
echo       ✓ config files

:: Lấy thông tin về site-packages
for /f "tokens=*" %%i in ('python -c "import site; print(site.getsitepackages()[0])"') do set "SITE_PACKAGES=%%i"

:: Copy các thư viện nặng từ site-packages
echo       - Copying heavy libraries from Python environment...
echo         (Đây là bước quan trọng - copy thư viện vào thư mục exe)

:: Copy torch (nếu có) - Sử dụng robocopy cho tốc độ nhanh hơn
:: robocopy return codes: 0-7 = success/warnings, 8+ = errors
if exist "%SITE_PACKAGES%\torch" (
    echo         Copying torch... (có thể mất vài phút)
    :: Thử dùng robocopy (nhanh hơn với multi-thread)
    robocopy "%SITE_PACKAGES%\torch" "%DIST_DIR%\libs\torch" /E /MT:8 /NFL /NDL /NJH /NJS >nul 2>&1
    :: Kiểm tra nếu robocopy không tồn tại hoặc lỗi nghiêm trọng (errorlevel >= 8)
    if %ERRORLEVEL% GEQ 8 (
        echo         [NOTE] Fallback to xcopy...
        xcopy /E /I /Y "%SITE_PACKAGES%\torch" "%DIST_DIR%\libs\torch" >nul 2>&1
    )
    echo       ✓ torch
)

:: Copy torchaudio (nếu có)
if exist "%SITE_PACKAGES%\torchaudio" (
    robocopy "%SITE_PACKAGES%\torchaudio" "%DIST_DIR%\libs\torchaudio" /E /MT:8 /NFL /NDL /NJH /NJS >nul 2>&1
    if %ERRORLEVEL% GEQ 8 (
        xcopy /E /I /Y "%SITE_PACKAGES%\torchaudio" "%DIST_DIR%\libs\torchaudio" >nul 2>&1
    )
    echo       ✓ torchaudio
)

:: Copy các thư viện nhẹ hơn
for %%L in (neucodec llama_cpp phonemizer librosa soundfile scipy numpy onnxruntime) do (
    if exist "%SITE_PACKAGES%\%%L" (
        xcopy /E /I /Y "%SITE_PACKAGES%\%%L" "%DIST_DIR%\libs\%%L" >nul 2>&1
        echo       ✓ %%L
    )
)

:: Copy các thư viện khác
for %%L in (google transformers huggingface_hub safetensors docx PIL) do (
    if exist "%SITE_PACKAGES%\%%L" (
        xcopy /E /I /Y "%SITE_PACKAGES%\%%L" "%DIST_DIR%\libs\%%L" >nul 2>&1
        echo       ✓ %%L
    )
)

echo.

:: ===========================
:: 7. Tạo launcher script
:: ===========================
echo [7/7] Tạo launcher và readme...

:: Tạo file README
(
echo # VieNeu-TTS Portable
echo.
echo ## Cấu trúc thư mục:
echo ```
echo VieNeuTTS/
echo ├── VieNeuTTS.exe        # File chạy chính
echo ├── libs/                # Thư viện Python runtime
echo │   ├── torch/
echo │   ├── torchaudio/
echo │   ├── neucodec/
echo │   ├── llama_cpp/
echo │   └── ...
echo ├── VieNeu-TTS/          # Module VieNeu-TTS
echo │   ├── sample/          # Voice samples
echo │   ├── utils/           # Utilities
echo │   └── vieneu_tts/      # Core module
echo ├── edge/                # Edge TTS module
echo ├── ffmpeg.exe           # FFmpeg binary
echo └── config.yaml          # Config file
echo ```
echo.
echo ## Yêu cầu:
echo - Windows 10/11 64-bit
echo - eSpeak NG phải được cài đặt (cho VN TTS)
echo.
echo ## Cài đặt eSpeak NG:
echo 1. Tải từ: https://github.com/espeak-ng/espeak-ng/releases
echo 2. Cài đặt vào: C:\Program Files\eSpeak NG\
echo 3. Thêm vào PATH nếu chưa có
echo.
echo ## Chạy ứng dụng:
echo - Double-click vào VieNeuTTS.exe
echo.
echo ## Lưu ý:
echo - Nếu thiếu thư viện trong libs/, chạy install_missing_libs.bat
echo - Model GGUF sẽ tự động tải về lần đầu sử dụng VN TTS
) > "%DIST_DIR%\README.md"

:: Tạo script cài thư viện thiếu
(
echo @echo off
echo chcp 65001 ^>nul
echo echo Cài đặt thư viện thiếu vào thư mục libs...
echo.
echo set "LIBS_DIR=%%~dp0libs"
echo.
echo :: Kiểm tra và tải thư viện
echo pip download torch torchaudio --index-url https://download.pytorch.org/whl/cpu -d "%%LIBS_DIR%%\downloads"
echo pip download neucodec phonemizer librosa soundfile scipy numpy -d "%%LIBS_DIR%%\downloads"
echo pip download llama-cpp-python --extra-index-url https://abetlen.github.io/llama-cpp-python/whl/cpu -d "%%LIBS_DIR%%\downloads"
echo.
echo echo.
echo echo Các file đã được tải về thư mục libs/downloads
echo echo Vui lòng giải nén và copy vào libs/
echo pause
) > "%DIST_DIR%\install_missing_libs.bat"

echo       ✓ README và scripts đã được tạo
echo.

echo ====================================================
echo   BUILD PORTABLE HOÀN TẤT!
echo ====================================================
echo.
echo   Output: %DIST_DIR%
echo   Size: (đợi tính toán...)
for /f "tokens=3" %%a in ('dir /s "%DIST_DIR%" ^| find "File(s)"') do echo   Size: %%a bytes
echo.
echo   CẤU TRÚC THƯ MỤC:
echo   %DIST_DIR%\
echo   ├── %OUTPUT_NAME%.exe
echo   ├── libs\                (thư viện Python)
echo   ├── VieNeu-TTS\          (TTS module)
echo   ├── edge\                (Edge TTS)
echo   └── ffmpeg.exe
echo.
echo   CÁCH SỬ DỤNG:
echo   1. Copy thư mục %DIST_DIR% đến máy đích
echo   2. Đảm bảo eSpeak NG đã cài trên máy đích
echo   3. Chạy %OUTPUT_NAME%.exe
echo.
echo ====================================================

pause
