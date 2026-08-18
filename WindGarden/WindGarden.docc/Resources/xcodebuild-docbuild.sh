xcodebuild docbuild \
  -project WindGarden.xcodeproj \
  -scheme WindGarden \
  -destination 'generic/platform=iOS' \
  -derivedDataPath .build/DerivedData \
  CODE_SIGNING_ALLOWED=NO

