//
//  LudioPlayerDelegate.swift
//  ludio
//
//  Created by Cory Zachman on 12/19/20.
//

import Foundation

public protocol LudioPlayerDelegate: class {
    func timeChanged(time: Double);
    func rateChanged(rate: Double);
    func stallStarted();
    func stallEnded();
    func onError(code: Int)
    func onPlay();
    func onPause();
}
