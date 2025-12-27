@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

echo ====================================================
echo   VieNeu-TTS Build Nhanh với Nuitka
echo   Chỉ compile code Python - Không bundle thư viện nặng
echo ====================================================
echo.

:: ===========================
:: 1. Kiểm tra Python version
:: ===========================
echo [1/6] Kiểm tra Python version...
python --version 2>&1 | findstr "Python 3\.12" >nul
if errorlevel 1 (
    echo [ERROR] Python 3.12 là bắt buộc!
    echo        Vui lòng cài Python 3.12.x từ https://www.python.org/downloads/
    pause
    exit /b 1
)
echo       ✓ Python 3.12 đã được cài đặt
echo.

:: ===========================
:: 2. Cài đặt Nuitka
:: ===========================
echo [2/6] Cài đặt Nuitka và dependencies...
pip install nuitka ordered-set zstandard >nul 2>&1
pip install customtkinter >nul 2>&1
echo       ✓ Nuitka đã được cài đặt
echo.

:: ===========================
:: 3. Tạo thư mục output
:: ===========================
echo [3/6] Tạo thư mục output...
if exist "dist_nuitka" rmdir /s /q "dist_nuitka"
mkdir "dist_nuitka"
echo       ✓ Thư mục dist_nuitka đã được tạo
echo.

:: ===========================
:: 4. Build với Nuitka (FAST MODE)
:: ===========================
echo [4/6] Build với Nuitka (chế độ nhanh)...
echo       Đang compile code Python thành C...
echo       (Thời gian: 2-10 phút tùy cấu hình máy)
echo.

:: Kiểm tra config.yaml có tồn tại không để quyết định include hay không
set "CONFIG_OPTION="
if exist "config.yaml" (
    set "CONFIG_OPTION=--include-data-files=config.yaml=config.yaml"
)

python -m nuitka ^
    --standalone ^
    --enable-plugin=tk-inter ^
    --follow-imports ^
    --nofollow-import-to=torch ^
    --nofollow-import-to=torchaudio ^
    --nofollow-import-to=torchvision ^
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
    --nofollow-import-to=safetensors ^
    --nofollow-import-to=datasets ^
    --nofollow-import-to=google ^
    --nofollow-import-to=google.genai ^
    --nofollow-import-to=docx ^
    --nofollow-import-to=PIL ^
    --nofollow-import-to=pyaudio ^
    --include-package=edge ^
    --include-package=auth_module ^
    --include-data-dir=edge=edge ^
    --include-data-files=icon.ico=icon.ico ^
    %CONFIG_OPTION% ^
    --windows-icon-from-ico=icon.ico ^
    --windows-console-mode=disable ^
    --output-dir=dist_nuitka ^
    --output-filename=VieNeuTTS.exe ^
    --assume-yes-for-downloads ^
    main.py

if errorlevel 1 (
    echo [ERROR] Build thất bại!
    pause
    exit /b 1
)
echo       ✓ Build thành công
echo.

:: ===========================
:: 5. Copy thư mục cần thiết
:: ===========================
echo [5/6] Copy thư mục và file cần thiết...

:: Tìm thư mục output
set "OUTPUT_DIR=dist_nuitka\main.dist"
if not exist "%OUTPUT_DIR%" (
    for /d %%i in (dist_nuitka\*.dist) do set "OUTPUT_DIR=%%i"
)

:: Copy VieNeu-TTS
if exist "VieNeu-TTS" (
    xcopy /E /I /Y "VieNeu-TTS\sample" "%OUTPUT_DIR%\VieNeu-TTS\sample" >nul 2>&1
    xcopy /E /I /Y "VieNeu-TTS\utils" "%OUTPUT_DIR%\VieNeu-TTS\utils" >nul 2>&1
    xcopy /E /I /Y "VieNeu-TTS\vieneu_tts" "%OUTPUT_DIR%\VieNeu-TTS\vieneu_tts" >nul 2>&1
    copy "VieNeu-TTS\config.yaml" "%OUTPUT_DIR%\VieNeu-TTS\" >nul 2>&1
    echo       ✓ Đã copy VieNeu-TTS
)

:: Copy edge module
if exist "edge" (
    xcopy /E /I /Y "edge" "%OUTPUT_DIR%\edge" >nul 2>&1
    echo       ✓ Đã copy Edge TTS module
)

:: Copy ffmpeg nếu có
if exist "ffmpeg.exe" (
    copy "ffmpeg.exe" "%OUTPUT_DIR%\" >nul 2>&1
    echo       ✓ Đã copy ffmpeg.exe
)

:: Copy config
if exist "config.yaml" (
    copy "config.yaml" "%OUTPUT_DIR%\" >nul 2>&1
    echo       ✓ Đã copy config.yaml
)

:: Copy icon
if exist "icon.ico" (
    copy "icon.ico" "%OUTPUT_DIR%\" >nul 2>&1
    echo       ✓ Đã copy icon.ico
)

echo.

:: ===========================
:: 6. Tạo script cài thư viện
:: ===========================
echo [6/6] Tạo script cài thư viện runtime...

:: Tạo file install_libs.bat
(
echo @echo off
echo chcp 65001 ^>nul
echo echo ====================================================
echo echo   Cài đặt thư viện runtime cho VieNeu-TTS
echo echo ====================================================
echo echo.
echo echo Đang cài đặt các thư viện cần thiết...
echo echo.
echo.
echo :: Cài đặt thư viện chính
echo pip install torch torchaudio --index-url https://download.pytorch.org/whl/cpu
echo pip install numpy scipy librosa soundfile
echo pip install phonemizer neucodec onnxruntime
echo pip install llama-cpp-python --extra-index-url https://abetlen.github.io/llama-cpp-python/whl/cpu
echo pip install transformers huggingface_hub safetensors
echo pip install google-genai python-docx requests
echo pip install customtkinter pyaudio pillow
echo.
echo echo.
echo echo ====================================================
echo echo   Cài đặt hoàn tất!
echo echo   Bạn có thể chạy VieNeuTTS.exe
echo echo ====================================================
echo pause
) > "%OUTPUT_DIR%\install_libs.bat"

echo       ✓ Đã tạo install_libs.bat
echo.

echo ====================================================
echo   BUILD HOÀN TẤT!
echo ====================================================
echo.
echo   Output: %OUTPUT_DIR%\VieNeuTTS.exe
echo.
echo   HƯỚNG DẪN SỬ DỤNG:
echo   1. Copy toàn bộ thư mục %OUTPUT_DIR% đến máy đích
echo   2. Chạy install_libs.bat để cài thư viện runtime
echo   3. Chạy VieNeuTTS.exe
echo.
echo   LƯU Ý QUAN TRỌNG:
echo   - Máy đích cần Python 3.12 đã cài sẵn
echo   - Máy đích cần eSpeak NG (cho phonemizer)
echo   - Các thư viện nặng sẽ dùng từ Python environment
echo   - File exe đã được compile từ C - chạy nhanh hơn
echo.
echo ====================================================

pause
