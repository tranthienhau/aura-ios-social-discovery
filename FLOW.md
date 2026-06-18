# Demo & Screenshot Capture

How the committed `screenshots/*.png` and `screenshots/demo.gif` were produced
from the running app (not mockups).

## Prereqs
- Xcode 26+, `xcodegen`, `ffmpeg`.
- Generate the project: `xcodegen generate`.

## 1. Boot the simulator
```bash
xcrun simctl boot "iPhone 17 Pro"
open -a Simulator
```

## 2. Build & install
```bash
xcodebuild -project Aura.xcodeproj -scheme Aura \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -derivedDataPath build build
xcrun simctl install booted "$(find build/Build/Products -name Aura.app -type d | head -1)"
```

## 3. Screenshots (deep-link launch args)
`AppFlow` reads `-screen <name>` and jumps straight to a screen, so each shot is
deterministic:
```bash
BID=com.aura.app
for s in onboarding discover map chat profile; do
  xcrun simctl terminate booted $BID 2>/dev/null
  xcrun simctl launch booted $BID -screen $s         # add -openChat for the chat thread
  sleep 4
  xcrun simctl io booted screenshot screenshots/$s.png
done
```

## 4. Demo GIF (real UI test drives the app while recording)
`AuraUITests/DemoFlow` navigates onboarding -> discover (swipe) -> map (join
meetup) -> chat -> profile (credit store). Record the simulator around it:
```bash
xcrun simctl io booted recordVideo --codec h264 /tmp/aura_demo.mp4 &
REC=$!
xcodebuild -project Aura.xcodeproj -scheme Aura \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -derivedDataPath build \
  -only-testing:AuraUITests/DemoFlow/testWalkthrough test
kill -INT $REC

ffmpeg -y -ss 1.5 -i /tmp/aura_demo.mp4 \
  -vf "fps=12,scale=300:-1:flags=lanczos,palettegen=stats_mode=diff" /tmp/pal.png
ffmpeg -y -ss 1.5 -i /tmp/aura_demo.mp4 -i /tmp/pal.png \
  -lavfi "fps=12,scale=300:-1:flags=lanczos[x];[x][1:v]paletteuse=dither=bayer:bayer_scale=3" \
  screenshots/demo.gif
```
