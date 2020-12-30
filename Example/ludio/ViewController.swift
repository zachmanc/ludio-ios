//
//  ViewController.swift
//  ludio
//
//  Created by Cory Zachman on 12/18/2020.
//  Copyright (c) 2020 Cory Zachman. All rights reserved.
//

import UIKit
import ludio
import AVFoundation
import Photos

class ViewController: UIViewController {
    @IBOutlet weak var playerView: UIView?
    @IBOutlet weak var camPreview: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!

    let cameraButton = UIView()

    var ludioPlayer: LudioPlayer?
    var ludioCapture: LudioCapture?
    var isRecording: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        let configuration = LudioPlayerConfiguration(loopVideo: true, autoplay: true)

        self.ludioPlayer = LudioPlayer(view: self.playerView!, configuration: configuration)
        self.ludioCapture = LudioCapture(view: self.camPreview!)

        cameraButton.isUserInteractionEnabled = true

        let cameraButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.startCapture))

        cameraButton.addGestureRecognizer(cameraButtonRecognizer)

        cameraButton.frame = CGRect(x: 5, y: 5, width: 30, height: 30)

        cameraButton.backgroundColor = UIColor.red

        camPreview.addSubview(cameraButton)
        self.ludioPlayer?.add(listener: self)
        self.ludioCapture?.add(listener: self)
        self.ludioPlayer?.load(videoUrl: "https://mkplayer.z13.web.core.windows.net/squat.mp4")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func startCapture() {
        if self.isRecording {
            ludioCapture?.stopRecording()
        } else {
            ludioCapture?.startRecording()
        }
    }

    @IBAction func playButtonPressed(_ sender: UIButton, forEvent event: UIEvent) {
        guard let player = self.ludioPlayer else {
            return
        }
        if player.rate().isEqual(to: 0.0) {
            player.play()
        } else {
            player.pause()
        }
    }

    @IBAction func seekButtonPressed(_ sender: UIButton, forEvent event: UIEvent) {
        guard let player = self.ludioPlayer else {
            return
        }
        player.seek(time: 10)
    }
}

extension ViewController: LudioPlayerDelegate {
    func onError(code: Int) {
        print("On Error")
    }

    func stallStarted() {
        print("Stall Started")
    }

    func stallEnded() {
        print("Stall Ended")
    }
    func rateChanged(rate: Double) {
        print("On Rate Changed: \(rate)")
        if rate != 0 {
            self.playButton.setTitle("Pause", for: .normal)
        } else {
            self.playButton.setTitle("Play", for: .normal)
        }
    }

    func timeChanged(time: Double) {
        self.timeLabel.text = String(format: "%.1f", time)
    }

    func onPause() {
        print("On Pause")

    }

    func onPlay() {
        print("On Play")

    }
}

extension ViewController: LudioCaptureDelegate {
    func onCaptureStarted() {
        print("On Capture Started")
        cameraButton.backgroundColor = UIColor.white
        isRecording = true
    }

    func onCaptureCompleted() {
        print("On Capture Completed")
        cameraButton.backgroundColor = UIColor.red
        isRecording = false
    }

    func onError() {
        print("On Capture rror")
    }

}
