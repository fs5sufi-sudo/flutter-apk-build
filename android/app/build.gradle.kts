name: Build Android APK

on:
  push:
    branches: [ "main", "master" ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v4

    - uses: actions/setup-java@v4
      with:
        distribution: 'zulu'
        java-version: '17'

    - uses: subosito/flutter-action@v2
      with:
        channel: 'stable'
        flutter-version: '3.19.0'

    - name: Clean Project
      run: flutter clean

    - name: Get Dependencies
      run: flutter pub get

    # تغییر استراتژی: ساخت نسخه Debug (بدون دردسر ساین و گریدل)
    - name: Build APK (Debug Mode)
      run: flutter build apk --debug --verbose

    - name: Upload APK
      if: always()
      uses: actions/upload-artifact@v4
      with:
        name: debug-apk
        path: build/app/outputs/flutter-apk/app-debug.apk
