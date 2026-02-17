# YearBar
<details>
  <summary><h2>just why?</h2></summary>
  <p>I wanted a simple app which could show me how much of the year is left (it helps me realise how quickly time is passing since i still feel like its 2022 and college is about to start. PS - im about to graduate in a few months 😔). 
  
  All existing apps like this are paid, so I decided to vibecode my own app.</p>
</details>
 

## what is it
A macOS menu bar app that shows how much of the year has passed.

Displays a live progress percentage with a circular ring icon in the menu bar. Click it to see year, month, and week progress at a glance.

## what it can do

- Year progress percentage in the menu bar, updates every 60 seconds
- Dropdown with circular progress bars for year, month, and week
- No Dock icon, no window bs: lives entirely in the menu bar

## installation

1. Download `YearBar.zip` from [Releases](https://github.com/sahiwl/YearBar/releases)
2. Unzip and drag `YearBar.app` to `/Applications`
3. First launch: right click the app → Open → Open (macOS blocks unsigned apps by default)

Requires macOS 13+.

## build from source

```bash
xcodebuild -project YearBar.xcodeproj -scheme YearBar -configuration Release -derivedDataPath build clean build
```

The `.app` will be at `build/Build/Products/Release/YearBar.app`.

