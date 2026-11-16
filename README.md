# Screen Time — a free, open-source screen time manager for iOS

A personal screen time app built on Apple's own Screen Time frameworks
(`FamilyControls`, `ManagedSettings`, `DeviceActivity`). It has no account, no
server and no subscription, and nothing leaves your phone.

## Features

| Tab | What it does |
| --- | --- |
| **Today** | Today's total screen time, pickups and most-used apps. |
| **Limits** | Daily time limits for apps, categories (Social, Games…) or websites. When you've used up the time, they're blocked until midnight. |
| **Focus** | Block chosen apps right now for 15 min – 4 hr, with a live countdown. |
| **Downtime** | A nightly schedule (e.g. 22:00–07:00) that blocks everything except an allow-list. |
| **Settings** | Optionally stop apps from being deleted, so you can't uninstall your way out of a limit. |

Blocks keep working when the app is closed. iOS enforces them in the background.

## How it's built

```
App/              Main SwiftUI app (UI + registers schedules with iOS)
Shared/           Models, App Group storage and blocking logic shared by all targets
ActivityMonitor/  Background extension: iOS wakes it when a limit is hit or a schedule starts/ends
ShieldConfig/     Extension that draws the "This app is blocked" screen
UsageReport/      Extension that reads usage data and draws the Today report
project.yml       XcodeGen spec → generates ScreenTime.xcodeproj
```

## Installing it on your iPhone

You need a **Mac with Xcode 16+** and an iPhone on **iOS 16+**.

1. **Install XcodeGen and generate the project**
   ```sh
   brew install xcodegen
   cd Screen_time
   xcodegen generate
   open ScreenTime.xcodeproj
   ```
2. **Make the bundle ID yours.** In `project.yml`, change
   `APP_BUNDLE_ID: com.yourname.screentime` to something unique, e.g.
   `com.janedoe.screentime`. Then run `xcodegen generate` again.
3. **Pick your team.** Either set `DEVELOPMENT_TEAM` in `project.yml`, or in Xcode
   select each of the 4 targets → *Signing & Capabilities* → *Team*.
4. Plug in your iPhone, select it as the run destination, and press **⌘R**.
   On the phone, enable *Settings ▸ Privacy & Security ▸ Developer Mode* if asked.
5. Open the app, tap **Allow Screen Time Access**, and confirm.

### About the Apple developer account

The *Family Controls* capability this app relies on is restricted by Apple:

- If Xcode reports that your team doesn't support Family Controls, you need an
  Apple Developer Program membership ($99/year). A free Apple ID may not be enough.
- Apps installed with a free Apple ID expire after 7 days; re-run from Xcode to
  refresh. With a paid account it's a year.
- You don't need App Store distribution approval to run it on your own phone.

## Tips

- **Pick categories**, not just apps, so new apps in that category are caught too.
- **Make it stricter.** Have a friend set a Screen Time passcode
  (*Settings ▸ Screen Time ▸ Lock Screen Time Settings*). Removing this app's
  access then needs that passcode.
- Phone, Settings and this app can never be blocked; iOS doesn't allow it.

## Troubleshooting

- **The Today tab is blank:** usage data can take a few minutes to appear after
  you first grant access. Tap ↻ to refresh.
- **A limit didn't trigger:** iOS needs the app's usage to cross the threshold
  while the limit is active. Limits created mid-day count usage from earlier
  that day only on iOS 17.4+.
