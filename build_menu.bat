@echo off
chcp 65001 >nul
echo.
echo ====================================================
echo   VieNeu-TTS - CHỌN CHẾ ĐỘ BUILD
echo ====================================================
echo.
echo   [1] Build NHANH (2-10 phút)
echo       - Chỉ compile code Python
echo       - Thư viện nặng dùng từ Python system
echo       - Máy đích cần cài Python + thư viện
echo.
echo   [2] Build PORTABLE (5-20 phút)
echo       - Compile code + copy thư viện vào cùng thư mục
echo       - Copy được sang máy khác dễ dàng
echo       - Kích thước lớn hơn (~500MB-2GB)
echo.
echo   [3] Build với PyInstaller (truyền thống)
echo       - Sử dụng PyInstaller thay vì Nuitka
echo       - Thời gian build lâu hơn
echo.
echo   [4] Thoát
echo.
echo ====================================================
echo.

set /p choice="Chọn chế độ build (1-4): "

if "%choice%"=="1" (
    echo.
    echo Đang chạy Build NHANH...
    call build_nuitka_fast.bat
    goto :end
)

if "%choice%"=="2" (
    echo.
    echo Đang chạy Build PORTABLE...
    call build_nuitka_portable.bat
    goto :end
)

if "%choice%"=="3" (
    echo.
    echo Đang chạy Build PyInstaller...
    if exist "main_fath.spec" (
        pyinstaller main_fath.spec --clean --noconfirm
    ) else (
        echo [ERROR] File main_fath.spec không tồn tại!
    )
    goto :end
)

if "%choice%"=="4" (
    echo.
    echo Thoát...
    goto :end
)

echo.
echo [ERROR] Lựa chọn không hợp lệ!
echo.
pause

:end
