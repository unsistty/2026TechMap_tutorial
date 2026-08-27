xcodebuild docbuild \
  -project WindGarden.xcodeproj \
  -scheme WindGarden \
  -destination 'generic/platform=iOS' \
  -derivedDataPath .build/DerivedData \
  CODE_SIGNING_ALLOWED=NO

ARCHIVE_PATH="$(find .build/DerivedData/Build/Products -name 'WindGarden.doccarchive' -type d -print -quit)"
test -n "$ARCHIVE_PATH"

xcrun docc process-archive transform-for-static-hosting \
  "$ARCHIVE_PATH" \
  --output-path .build/site/WindGarden \
  --hosting-base-path WindGarden

printf '{}\n' > .build/site/WindGarden/theme-settings.json

python3 -m http.server 8000 --directory .build/site
