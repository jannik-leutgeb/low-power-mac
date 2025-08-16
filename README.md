# low-power-mac
automatically switch low power mode on MacOS based on battery state

## Build

### Option 1: Using Xcode (GUI)

Open the project in Xcode and build it as Release (⇧⌘R).

> Make sure to select the correct scheme `low-power-mac`.

### Option 2: Using the Command Line

Use the following command:

```bash
xcodebuild -scheme low-power-mac -configuration Release
```

## Deploy
To deploy the project, use the following command:

```bash
sudo ./deploy.sh
```
