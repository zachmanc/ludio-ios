import UIKit
import AVFoundation

public class LudioPlayer: NSObject {
    var view: UIView
    var player: AVQueuePlayer
    var configuration: LudioPlayerConfiguration;
    var playerLooper: AVPlayerLooper?;
    var timeObserverToken: Any?;
    private var listeners: [LudioPlayerDelegate] = []

    // Key-value observing context
    private var playerItemContext = 0
    private var playerContext = 1

    let requiredAssetKeys = [
        "playable",
        "hasProtectedContent",
        "duration"
    ]
    
    
    public init(view: UIView, configuration: LudioPlayerConfiguration){
        self.configuration = configuration;
        self.view = view
        self.player = AVQueuePlayer();
        super.init()
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.rate), options: [.old, .new],
                            context: &playerContext)
    }
    
    public func load(videoUrl: String) {
        guard let url = URL(string: videoUrl) else {
            return
        }
        
        let asset = AVAsset(url: url);
        
        let playerItem = AVPlayerItem(asset: asset);
                
        // Register as an observer of the player item's status property
        playerItem.addObserver(self,
                               forKeyPath: #keyPath(AVPlayerItem.status),
                               options: [.old, .new],
                               context: &playerItemContext)
        
        playerItem.addObserver(self,
                               forKeyPath: #keyPath(AVPlayerItem.isPlaybackBufferFull),
                               options: [.old, .new],
                               context: &playerItemContext)
        
        playerItem.addObserver(self,
                               forKeyPath: #keyPath(AVPlayerItem.isPlaybackBufferEmpty),
                               options: [.old, .new],
                               context: &playerItemContext)
        
        playerItem.addObserver(self,
                               forKeyPath: #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp),
                               options: [.old, .new],
                               context: &playerItemContext)
        
        // Register as an observer of the player item's status property
        playerItem.addObserver(self,
                               forKeyPath: #keyPath(AVPlayerItem.duration),
                               options: [.old, .new],
                               context: &playerItemContext)
        // Register as an observer of the player item's status property
        playerItem.addObserver(self,
                               forKeyPath: #keyPath(AVPlayerItem.error),
                               options: [.old, .new],
                               context: &playerItemContext)
        
        player.replaceCurrentItem(with: playerItem)
        

        
        if (self.configuration.loopVideo) {
            self.playerLooper = AVPlayerLooper(player: player, templateItem: playerItem)
        }
        
        addPeriodicTimeObserver()
        
        let playerLayer = AVPlayerLayer(player: player);
        
        playerLayer.frame = self.view.bounds
        
        playerLayer.videoGravity = .resizeAspectFill
        
        self.view.layer.addSublayer(playerLayer)
    }
    
    public func load(videoUrls: [String]) {
        
    }
    
    public func play() {
        player.play()
    }
    
    public func pause() {
        self.player.pause()
    }
    
    
    public func add(listener: LudioPlayerDelegate) {
        listeners.append(listener);
    }

    public func remove(listener: LudioPlayerDelegate) {
        if let idx = listeners.firstIndex(where: { $0 === listener }) {
            listeners.remove(at: idx)
        }
    }
    
    func addPeriodicTimeObserver() {
        // Notify every half second
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.1, preferredTimescale: timeScale)

        
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: time, queue: .main, using: {
            [weak self] (playerTime) in
            guard let listeners = self?.listeners else {
                return
            }
            for listener in listeners {
                listener.timeChanged(time: CMTimeGetSeconds(playerTime));
            }
        })

    }

    func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    public func rate() -> Float {
        return self.player.rate
    }
    
    public func seek(time: Double){
        self.player.seek(to: CMTimeMakeWithSeconds(time, 1000))
    }
            
    public override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {

        // Only handle observations for the playerItemContext
        guard (context == &playerItemContext || context == &playerContext) else {
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
            return
        }

        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItemStatus
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItemStatus(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }

            // Switch over status value
            switch status {
            case .readyToPlay:
                // Player item is ready to play.
                print("Status: readyToPlay")
                if(self.configuration.autoplay) {
                    self.play()
                }
                break
            case .failed:
                // Player item failed. See error.
                print("Status: failed")
                break
            case .unknown:
                // Player item is not yet ready.
                print("Status: unknown")
                break
            }
        } else if keyPath == #keyPath(AVPlayerItem.duration) {
            guard let duration:Double = change?[.newKey] as? Double else {
                return
            }
            print("Duration: \(duration)")
        } else if keyPath == #keyPath(AVPlayer.rate) {
            guard let rate:Double = change?[.newKey] as? Double, let oldRate:Double = change?[.oldKey] as? Double else {
                return
            }
            for listener in listeners {
                listener.rateChanged(rate: rate);
            }
            
            if (rate == 1.0 && oldRate == 0.0) {
                for listener in listeners {
                    listener.onPlay();
                }
            }else if (rate == 0.0 && oldRate == 1.0) {
                for listener in listeners {
                    listener.onPause();
                }
            }
        }else if keyPath == #keyPath(AVPlayerItem.isPlaybackBufferEmpty) {
            guard let value:Bool = change?[.newKey] as? Bool else {
                return
            }
            print("isPlaybackBufferEmpty \(value)")
        }
        else if keyPath == #keyPath(AVPlayerItem.isPlaybackBufferFull) {
            guard let value:Bool = change?[.newKey] as? Bool else {
                return
            }
            print("isPlaybackBufferFull \(value)")
        }
        else if keyPath == #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp) {
            guard let value:Bool = change?[.newKey] as? Bool else {
                return
            }
            print("isPlaybackLikelyToKeepUp: \(value)")
        }
    }
    
}
