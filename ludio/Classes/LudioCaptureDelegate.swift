//
//  LudioCaptureDelegate.swift
//  ludio
//
//  Created by Cory Zachman on 12/20/20.
//

import Foundation

public protocol LudioCaptureDelegate: class {
    func onCaptureStarted()

    func onCaptureCompleted()

    func onError()
}
