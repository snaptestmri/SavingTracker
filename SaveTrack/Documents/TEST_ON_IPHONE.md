# Testing SaveTrack on Your iPhone

## Prerequisites

1. **Mac with Xcode** installed
2. **iPhone** (iOS 15.0 or later)
3. **USB cable** to connect iPhone to Mac
4. **Apple ID** (free account works for development)

## Step-by-Step Instructions

### 1. Connect Your iPhone

1. **Connect your iPhone** to your Mac using a USB cable
2. **Unlock your iPhone** and tap "Trust This Computer" if prompted
3. **Enter your iPhone passcode** if asked

### 2. Configure Code Signing in Xcode

1. **Open your project** in Xcode:
   ```
   SaveTrack/SaveTrack/SaveTrack/SaveTrack.xcodeproj
   ```

2. **Select the project** in the Project Navigator (top-left):
   - Click on `SaveTrack` (the blue project icon at the top)

3. **Select the SaveTrack target:**
   - In the main editor, click on the `SaveTrack` target (under TARGETS)
   - Click on the **"Signing & Capabilities"** tab

4. **Enable Automatic Signing:**
   - ✅ Check **"Automatically manage signing"**
   - Select your **Team** from the dropdown:
     - If you don't see your team, click "Add Account..."
     - Sign in with your Apple ID
     - Your team will appear (it will be your name or "Personal Team")

5. **Verify Bundle Identifier:**
   - The Bundle Identifier should be: `org.mann.SaveTrack`
   - If there's a conflict, change it to something unique like: `com.yourname.SaveTrack`

### 3. Select Your iPhone as the Build Target

1. **Click the device selector** at the top of Xcode (next to the Play/Stop buttons)
2. **Select your iPhone** from the list:
   - It should appear as "Your Name's iPhone" or similar
   - Make sure it shows "iOS 15.0+" or your iOS version

### 4. Build and Run

1. **Click the Play button** (▶️) or press `⌘ + R`
2. **Wait for the build** to complete (this may take a minute the first time)
3. **Xcode will install the app** on your iPhone automatically

### 5. Trust the Developer Certificate on iPhone

**Important:** After the app is installed, you need to trust the developer certificate:

1. **On your iPhone**, go to: **Settings → General → VPN & Device Management**
   - (On older iOS versions: Settings → General → Device Management or Profiles & Device Management)

2. **Tap on your Apple ID** under "Developer App"

3. **Tap "Trust [Your Apple ID]"**

4. **Confirm** by tapping "Trust" in the popup

5. **Go back to the home screen** and tap the SaveTrack app icon
   - The app should now launch!

## Troubleshooting

### "No devices found" or iPhone doesn't appear

**Solutions:**
- Make sure iPhone is unlocked
- Try a different USB cable
- Try a different USB port
- Restart Xcode
- On iPhone: Settings → General → Reset → Reset Location & Privacy (then reconnect)

### "Signing for SaveTrack requires a development team"

**Solution:**
- Go to Signing & Capabilities tab
- Click "Add Account..." and sign in with your Apple ID
- Select your team from the dropdown

### "Failed to code sign" or "Provisioning profile" errors

**Solutions:**
- Make sure "Automatically manage signing" is checked
- Change the Bundle Identifier to something unique (e.g., `com.yourname.SaveTrack`)
- Clean build folder: Product → Clean Build Folder (⇧⌘K)
- Delete derived data and rebuild

### App installs but crashes immediately

**Solutions:**
- Check Xcode console for error messages
- Make sure you trusted the developer certificate (Step 5 above)
- Try deleting the app and reinstalling
- Check that your iPhone's iOS version is 15.0 or later

### "Untrusted Enterprise Developer" error

**Solution:**
- This means you haven't trusted the certificate yet
- Follow Step 5 above to trust the developer certificate

### App won't install / "Unable to install SaveTrack"

**Solutions:**
- Make sure iPhone has enough storage space
- Restart your iPhone
- Delete any previous version of the app
- Try building again in Xcode

## Testing Tips

### View Console Logs

To see debug output while testing:

1. In Xcode, open the **Console** (View → Debug Area → Activate Console, or `⇧⌘C`)
2. Run the app on your iPhone
3. All `print()` statements and errors will appear in the console

### Test Different Features

Once the app is running on your iPhone:

1. **Add entries** - Test the entry form
2. **Create goals** - Test goal creation and tracking
3. **View history** - Check that entries are saved
4. **Check charts** - Verify data visualization
5. **Test settings** - Change currency, enable reminders

### Disconnect and Use Wirelessly (Optional)

After the first successful connection, you can enable wireless debugging:

1. **Keep iPhone connected via USB**
2. In Xcode: **Window → Devices and Simulators**
3. Select your iPhone
4. Check **"Connect via network"**
5. **Disconnect USB** - You can now build and run wirelessly!

## Requirements Checklist

- [ ] iPhone connected via USB
- [ ] iPhone unlocked and trusted computer
- [ ] Xcode project open
- [ ] Code signing configured with your Apple ID
- [ ] iPhone selected as build target
- [ ] App built and installed successfully
- [ ] Developer certificate trusted on iPhone
- [ ] App launches and runs correctly

## Free vs Paid Apple Developer Account

**Free Account (Personal Team):**
- ✅ Works for testing on your own devices
- ✅ No cost
- ⚠️ Apps expire after 7 days (need to reinstall)
- ⚠️ Limited to 3 apps at a time
- ❌ Cannot distribute to App Store

**Paid Account ($99/year):**
- ✅ Apps don't expire
- ✅ Can distribute to App Store
- ✅ TestFlight beta testing
- ✅ More devices and capabilities

For testing purposes, the **free account is sufficient**.

## Next Steps

Once you've successfully tested the app:

1. **Test all features** thoroughly
2. **Report any bugs** you find
3. **Test on different iOS versions** if possible**
4. **Consider **TestFlight** for beta testing** (requires paid developer account)

## Quick Reference

| Action | Shortcut |
|--------|----------|
| Build and Run | `⌘ + R` |
| Stop Running | `⌘ + .` |
| Clean Build | `⇧⌘K` |
| Show Console | `⇧⌘C` |
| Devices Window | `⇧⌘2` |

---

**Need Help?** Check the Xcode console for specific error messages, or refer to Apple's documentation on code signing and device deployment.
