# ludio

## Installation

ludio is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ludio'
```

```swift 
import ludio
```

### Video Playback 

```swift
//Create a ludio configuration
let configuration = LudioPlayerConfiguration(loopVideo: true, autoplay: false)

// Create the player
self.ludioPlayer = LudioPlayer(view:self.playerView!, configuration: configuration);

// Add yourself as a listener for events
self.ludioPlayer?.add(listener: self)

// Load a video to playback
self.ludioPlayer?.load(videoUrl: "https://mkplayer.z13.web.core.windows.net/squat.mp4")

// Call play
self.ludioPlayer?.play()

// Call pause when needed 
self.ludioPlayer?.pause()
```

Listen to events through the LudioPlayerDelegate

```swift
public protocol LudioPlayerDelegate: class {
    func timeChanged(time: Double);
    func rateChanged(rate: Double);
    func stallStarted();
    func stallEnded();
    func onError(code: Number)
    func onPlay();
    func onPause();
}

self.ludioPlayer?.add(listener: self)
```

### Video Capture

Creating a capture object and previewing the content into a view

```swift
// Create a Ludio Cpature object
self.ludioCapture = LudioCapture(view: self.camPreview!)

// Call start recording when you are ready
self.ludioCapture?.startRecording()

// Call stopRecording when you are done
ludioCapture?.stopRecording()

```

Listen to events through the LudioCpatureDelegate

```swift
func onCaptureStarted()
func onCaptureCompleted()
func onError()
```

