#!/bin/bash

# Enhanced script for Android emulator control from container
# Uses HTTP requests to communicate with PowerShell server on host

echo "=================================="
echo "Android Emulator Control Script"
echo "=================================="
echo ""

HOST_SERVER="host.docker.internal:8888"

case "$1" in
    "list")
        echo "Requesting AVD list from host..."
        if curl -s -m 5 "http://$HOST_SERVER/list" 2>/dev/null; then
            echo ""
        else
            echo "Could not connect to emulator server on host."
            echo "Please start the PowerShell server on your Windows host:"
            echo "1. Copy /workspace/.devcontainer/emulator-server.ps1 to your Windows machine"
            echo "2. Open PowerShell as Administrator"
            echo "3. Run: .\\emulator-server.ps1 -Action server"
            echo ""
            echo "Alternative: Use manual method with 'start-manual' command"
        fi
        ;;
        
    "start")
        local avd_name="$2"
        if [ -z "$avd_name" ]; then
            echo "Usage: $0 start <avd_name>"
            echo "First, list available AVDs:"
            $0 list
            return 1
        fi
        
        echo "Requesting to start AVD: $avd_name"
        if curl -s -m 10 "http://$HOST_SERVER/start?avd=$avd_name" 2>/dev/null; then
            echo ""
            echo "Start command sent. Waiting for emulator to boot..."
            sleep 5
            $0 connect
        else
            echo "Could not connect to emulator server on host."
            echo "Please ensure the PowerShell server is running."
        fi
        ;;
        
    "stop")
        echo "Requesting to stop all emulators..."
        if curl -s -m 5 "http://$HOST_SERVER/stop" 2>/dev/null; then
            echo ""
            $0 disconnect
        else
            echo "Could not connect to emulator server on host."
        fi
        ;;

    "connect")
        echo "Attempting to connect to running emulator on host..."
        
        # Make sure ADB is available
        if ! command -v adb >/dev/null 2>&1; then
            echo "ERROR: ADB not found. Adding Android SDK to PATH..."
            export PATH=$PATH:/home/brett/Android/Sdk/platform-tools
        fi
        
        echo "Trying different connection methods..."
        
        # Method 1: Standard emulator port
        echo "1. Connecting to host.docker.internal:5555..."
        adb connect host.docker.internal:5555
        
        # Method 2: Alternative ports
        echo "2. Connecting to host.docker.internal:5554..."
        adb connect host.docker.internal:5554
        
        # Method 3: Localhost (if network=host works)
        echo "3. Connecting to localhost:5555..."
        adb connect localhost:5555
        
        # Show connected devices
        echo ""
        echo "Connected devices:"
        adb devices -l
        ;;
        
    "status")
        echo "Checking emulator connection status..."
        if command -v adb >/dev/null 2>&1; then
            adb devices -l
        else
            echo "ADB not available. Adding to PATH..."
            export PATH=$PATH:/home/brett/Android/Sdk/platform-tools
            adb devices -l
        fi
        ;;
        
    "disconnect")
        echo "Disconnecting from all emulators..."
        adb disconnect
        adb kill-server
        echo "Disconnected."
        ;;
        
    "start-manual")
        echo "To start an emulator on your host Windows machine:"
        echo ""
        echo "Method 1 - Using Android Studio:"
        echo "  1. Open Android Studio"
        echo "  2. Go to Tools > AVD Manager"
        echo "  3. Click 'Play' button next to an AVD"
        echo ""
        echo "Method 2 - Using Command Line:"
        echo "  1. Open Command Prompt or PowerShell"
        echo "  2. Navigate to: C:\\Users\\Brett\\AppData\\Local\\Android\\Sdk\\emulator"
        echo "  3. Run: emulator.exe -list-avds    (to see available AVDs)"
        echo "  4. Run: emulator.exe -avd <AVD_NAME>"
        echo ""
        echo "Method 3 - Using Windows Run Dialog:"
        echo "  1. Press Win+R"
        echo "  2. Type: C:\\Users\\Brett\\AppData\\Local\\Android\\Sdk\\emulator\\emulator.exe -avd Pixel_7_API_34"
        echo "  3. Press Enter"
        echo ""
        echo "After starting, run: $0 connect"
        ;;
        
    "install-tasks")
        echo "Installing VS Code tasks for emulator control..."
        # This would be handled by the tasks.json we already created
        echo "Tasks have been added to .vscode/tasks.json"
        echo "Use Ctrl+Shift+P > 'Tasks: Run Task' to access them"
        ;;
        
    *)
        echo "Usage: $0 {connect|status|disconnect|start-manual|install-tasks}"
        echo ""
        echo "Commands:"
        echo "  connect       - Connect to running emulator on host"
        echo "  status        - Show connected devices"
        echo "  disconnect    - Disconnect from all emulators"
        echo "  start-manual  - Show instructions to start emulator manually"
        echo "  install-tasks - Info about VS Code tasks"
        echo ""
        echo "Workflow:"
        echo "  1. Run: $0 start-manual    (follow instructions to start emulator on host)"
        echo "  2. Run: $0 connect         (connect container to host emulator)"
        echo "  3. Run: flutter run        (deploy your app to the emulator)"
        ;;
esac