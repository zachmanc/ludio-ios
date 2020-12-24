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

class ViewController: UIViewController, LudioPlayerDelegate {
    func stallStarted() {
        print("Stall Started")
    }
    
    func stallEnded() {
        print("Stall Ended")
    }
    func rateChanged(rate: Double) {
        print("Rate Changed: \(rate)")
        if (rate != 0) {
            self.playButton.setTitle("Pause", for: .normal)
        }else {
            self.playButton.setTitle("Play", for: .normal)
        }
    }
    
    func timeChanged(time: Double) {
        self.timeLabel.text = String(format: "%.1f", time)
    }
    
    
    @IBAction func playButtonPressed(_ sender: UIButton, forEvent event: UIEvent){
        guard let player = self.ludioPlayer else {
            return
        }
        if (player.rate().isEqual(to: 0.0)) {
            player.play()
        }else {
            player.pause()
        }
    }
    
    @IBOutlet weak var playerView: UIView?
    @IBOutlet weak var camPreview: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!

    let cameraButton = UIView()

    var ludioPlayer:LudioPlayer?;
    var ludioCapture:LudioCapture?;
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let configuration = LudioPlayerConfiguration(loopVideo: true, autoplay: false)
        
        self.ludioPlayer = LudioPlayer(view:self.playerView!, configuration: configuration);
        self.ludioCapture = LudioCapture(view: self.camPreview!)
        
        cameraButton.isUserInteractionEnabled = true
        
        let cameraButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.startCapture))
        
        cameraButton.addGestureRecognizer(cameraButtonRecognizer)
        
        cameraButton.frame = CGRect(x: 5, y: 5, width: 30, height: 30)
        
        cameraButton.backgroundColor = UIColor.blue
        
        camPreview.addSubview(cameraButton)
        self.ludioPlayer?.add(listener: self)
        self.ludioPlayer?.load(videoUrl: "https://mkplayer.z13.web.core.windows.net/squat.mp4")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func startCapture() {
        ludioCapture?.startRecording()
    }

}

