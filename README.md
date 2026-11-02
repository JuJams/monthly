# Monthly

**See how much you have left to spend this month without opening an app.**

Budget apps show what you spent, but you have to open them and work out what's left yourself. Monthly puts one number on your lock screen: what's left of your monthly spending budget. It updates the moment you pay.

> Budget: **$1,000** for Nov 1–30 (not counting rent).
> Spent **$20** by Nov 2 → lock screen shows **$980 · $33/day**.

---

## How it works

```
Tap to pay with Apple Pay
   → iPhone Shortcuts "Transaction" automation fires instantly
   → passes the amount + merchant to Monthly in the background
   → Monthly subtracts it from the budget
   → lock screen widget updates: "$980 · $33/day"
```

- **iPhone only.**
- **Apple Pay purchases are logged automatically** through a Shortcuts automation (iOS 17+). You don't need to connect a bank.
- **Everything else is entered by hand**, such as online purchases that don't use Apple Pay, cash, and refunds. A lock screen "+" button makes that two taps.
- **Rent and bills stay out** automatically if you pay them by bank transfer instead of Apple Pay.
- **The budget resets every month** on a day you choose (the 1st, or your payday).
- **Daily pace:** besides what's left, it shows how much you can spend per day for the rest of the month. That number tells you whether you're on track.

## Screens

### 1. Lock screen widget (the main product)
- **Under the clock:** a large **$980**, with **$33/day · 29d left** below it and a thin progress bar.
- **Above the clock (one line):** `$980 left · $33/day`
- **Small ring option:** a circle that empties as you spend, with the amount in the middle.
- Tapping the widget opens the app.
- Turns red when you're over budget.

### 2. Quick add button
- Replaces the flashlight or camera button in a lock screen corner, or goes in Control Center.
- Opens straight to a number pad. Type the amount, tap Save.

### 3. Home screen (in the app)
- A big "left this month" number, "left of $1,000," a progress bar, and the per-day amount.
- Below that, this month's purchases, newest first. Each one shows an icon for Apple Pay or manual entry, the merchant, the time and the amount.
- Swipe to delete, tap to edit.
- **+** in the top right adds a purchase, and the gear icon in the top left opens Settings.

### 4. Add / edit purchase
- Switch between Purchase and Refund.
- Amount field with the number pad already open.
- Optional note or merchant.
- Date and time (defaults to now).

### 5. Settings
- Monthly budget amount.
- Reset day (1–28).
- Instructions for setting up the Apple Pay automation in the Shortcuts app.

## Version 1 scope

| In | Out (for now) |
|---|---|
| Lock screen widget + daily pace | Bank connections |
| Apple Pay auto-logging | Categories |
| Manual add / edit / refund | Rollover of unspent money |
| Budget + reset day settings | Shared budgets with a partner |
| Lock screen "+" button | Android |

## Open questions to test

- Does the Shortcuts trigger also fire for **online / in-app Apple Pay**? If it does, manual entries could count those purchases twice.
- Do **refunds** fire the trigger? (Probably not, so they get entered by hand.)
- How fast does the lock screen widget update after a tap?

## Build notes

- Swift and SwiftUI; the widget uses Apple's widget framework (WidgetKit).
- The Shortcuts action is a "Log Expense" App Intent that runs in the background.
- The app and widget share data through an App Group, which likely requires the paid Apple Developer Program ($99/yr).
