@echo off
echo Nettoyage du cache Flutter...
flutter clean
echo.
echo Suppression du dossier build...
if exist build rmdir /s /q build
echo.
echo Suppression du dossier .dart_tool...
if exist .dart_tool rmdir /s /q .dart_tool
echo.
echo Suppression du dossier pub-cache.lock...
if exist pub-cache.lock del pub-cache.lock
echo.
echo Nettoyage terminé!
echo.
echo Installation des dépendances...
flutter pub get
echo.
echo Terminé! Vous pouvez maintenant lancer: flutter run
