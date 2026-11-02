# Monthly

A lock screen number showing how much of your monthly budget is left, plus a daily pace.
Apple Pay purchases are logged automatically through a Shortcuts automation, and anything else you add by hand.

```
Apple Pay tap → Shortcuts "Transaction" automation → Monthly "Log Expense" action
             → saved to shared storage → lock screen widget redraws: "$980 · $33/day"
```

## One-time setup on your Mac

1. **Install XcodeGen**, which generates the Xcode project from `project.yml`:
   ```sh
   brew install xcodegen
   ```
   (No Homebrew? Install it first from https://brew.sh.)

2. **Pick a unique ID.** Open `project.yml` and change `BUNDLE_PREFIX: com.example` to something like `com.yourname`.

3. **Generate and open the project:**
   ```sh
   cd monthly
   xcodegen
   open Monthly.xcodeproj
   ```

4. **Signing.** In Xcode, click the blue *Monthly* project in the left sidebar. For **each** target (*Monthly* and *MonthlyWidget*), go to *Signing & Capabilities* and pick your Team.
   - The widget reads the app's data through an **App Group**. Free Apple accounts usually can't use App Groups, so you'll likely need the $99/year Apple Developer Program. If Xcode shows an App Groups error, that's the reason.

5. **Run it on your iPhone.** Plug in the phone, select it at the top of Xcode, and press ▶. The first time, approve the developer on the phone under *Settings → General → VPN & Device Management*, and turn on *Developer Mode* if asked.

## Set up on your iPhone

**Budget:** open Monthly, tap ⚙️, and set your budget and the day it resets.

**Apple Pay auto-logging:**
1. Open the Shortcuts app, go to **Automation**, tap **+**, and choose **Transaction**.
2. Pick the cards you pay with and select **Run Immediately**.
3. Add the action **Log Expense** (from Monthly).
4. Tap **Amount** and pick *Shortcut Input → Amount*. Tap **Merchant** and pick *Shortcut Input → Merchant*.

**Lock screen widget:** long-press the lock screen, tap **Customize → Lock Screen**, tap the widget area under the clock, and add **Monthly → Money Left**.

**Quick add button:** in the same lock screen editor, tap a bottom corner button (flashlight or camera), remove it, and pick **Add Expense**. You can also add it to Control Center.

## Things to test in week one

- [ ] An in-store Apple Pay tap logs the right amount within seconds.
- [ ] **Online / in-app Apple Pay purchases:** does the automation fire? If it does, don't also enter them by hand, or they'll count twice.
- [ ] A refund. It probably doesn't fire the automation; add it manually as a *Refund*.
- [ ] The lock screen number updates right after a tap, without opening the app.
- [ ] The per-day number changes after midnight.

## Code map

| File | What it does |
|---|---|
| `Shared/Storage.swift` | Expense data model, shared storage, settings |
| `Shared/Budget.swift` | Budget period math, "left" and "per day", amount parsing |
| `Shared/QuickAddIntent.swift` | Lock screen "+" button action |
| `Monthly/LogExpenseIntent.swift` | The "Log Expense" Shortcuts action |
| `Monthly/ContentView.swift` | Main screen |
| `Monthly/ExpenseFormView.swift` | Add/edit a purchase |
| `Monthly/SettingsView.swift` | Budget and reset day |
| `MonthlyWidget/BudgetWidget.swift` | Lock screen and home screen widget |
| `MonthlyWidget/QuickAddControl.swift` | Lock screen / Control Center button |
