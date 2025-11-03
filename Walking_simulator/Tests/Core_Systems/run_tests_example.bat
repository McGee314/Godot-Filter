@echo off
REM Test Execution Examples for Windows
REM This batch file demonstrates how to run different types of tests

echo === Test Execution Examples ===
echo.

REM Configuration
set GODOT_PATH=D:\Portable\Programming\Godot_v4.3-stable_win64.exe\Godot_v4.3-stable_win64.exe
set PROJECT_PATH=D:\Projects\game-issat\Walking Simulator

echo Godot Path: %GODOT_PATH%
echo Project Path: %PROJECT_PATH%
echo.

:menu
echo Choose an option:
echo 1. Run Headless Tests
echo 2. List Editor Tests
echo 3. Show CI/CD Example
echo 4. Show Results Parsing
echo 5. Run All Examples
echo 6. Exit
echo.
set /p choice="Enter your choice (1-6): "

if "%choice%"=="1" goto run_headless
if "%choice%"=="2" goto list_editor
if "%choice%"=="3" goto show_cicd
if "%choice%"=="4" goto show_parsing
if "%choice%"=="5" goto run_all
if "%choice%"=="6" goto exit
echo Invalid choice. Please try again.
echo.
goto menu

:run_headless
echo 🖥️  Running Headless Tests...
echo ----------------------------------------
echo.
echo 1. Running Core System Tests...
"%GODOT_PATH%" --headless --script "%PROJECT_PATH%\Tests\Core_Systems\run_tests_cli.gd"
echo.
echo 2. Running Python Validation...
python "%PROJECT_PATH%\Tests\Validation_Scripts\validate_phase1.py"
echo.
echo ✅ Headless tests completed!
echo.
pause
goto menu

:list_editor
echo 🎮 Editor Tests (Manual Execution Required)
echo ----------------------------------------
echo.
echo These tests must be run in Godot Editor:
echo.
echo 🏔️  Terrain3D Tests:
echo    %PROJECT_PATH%\Tests\Terrain3D\test_terrain3d_editor.tscn
echo.
echo 🎨 PSX Asset Tests:
echo    %PROJECT_PATH%\Tests\PSX_Assets\test_psx_placement_editor.tscn
echo.
echo 🔗 Phase 1 Integration Tests:
echo    %PROJECT_PATH%\Tests\Phase1_Integration\test_phase1_integration_editor.tscn
echo.
echo ⌨️  Input System Tests:
echo    %PROJECT_PATH%\Tests\Input_Systems\test_input_handling.tscn
echo.
echo 👥 NPC Interaction Tests:
echo    %PROJECT_PATH%\Tests\NPC_Interaction\test_npc_interaction.tscn
echo.
echo 🖥️  UI Component Tests:
echo    %PROJECT_PATH%\Tests\UI_Components\test_radar.tscn
echo.
echo 📋 Instructions for Editor Tests:
echo    1. Open Godot Editor
echo    2. Open the test scene file
echo    3. Press F5 to run
echo    4. Check Output panel for results
echo    5. Use UI controls for interactive testing
echo.
pause
goto menu

:show_cicd
echo 🚀 CI/CD Integration Example
echo ----------------------------------------
echo.
echo # GitHub Actions Workflow Example:
echo.
echo name: Test Game
echo on: [push, pull_request]
echo.
echo jobs:
echo   test:
echo     runs-on: ubuntu-latest
echo     steps:
echo       - uses: actions/checkout@v3
echo       - name: Setup Godot
echo         uses: haukex/godot-setup@v1
echo         with:
echo           version: 4.3-stable
echo       - name: Run Headless Tests
echo         run: ^|
echo           godot --headless --script Tests/Core_Systems/run_tests_cli.gd
echo       - name: Run Validation Scripts
echo         run: ^|
echo           python Tests/Validation_Scripts/validate_phase1.py
echo.
echo Note: Editor tests are not included in CI/CD
echo       as they require visual environment.
echo.
pause
goto menu

:show_parsing
echo 📊 Test Results Parsing
echo ----------------------------------------
echo.
echo # Example: Parse test output for CI/CD
echo.
echo @echo off
echo.
echo REM Run tests and capture output
echo for /f "tokens=*" %%i in ('"%GODOT_PATH%" --headless --script "%PROJECT_PATH%\Tests\Core_Systems\run_tests_cli.gd" 2^>^&1') do set TEST_OUTPUT=%%i
echo.
echo REM Check for test failures
echo echo %%TEST_OUTPUT%% ^| findstr /i "FAILED" ^>nul
echo if %%errorlevel%% equ 0 (
echo     echo ❌ Tests failed!
echo     echo %%TEST_OUTPUT%%
echo     exit /b 1
echo ) else (
echo     echo ✅ All tests passed!
echo     echo %%TEST_OUTPUT%%
echo )
echo.
pause
goto menu

:run_all
call :run_headless
call :list_editor
call :show_cicd
call :show_parsing
goto menu

:exit
echo Goodbye!
exit /b 0
