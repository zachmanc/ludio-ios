//
//  LudioPlayerConfiguration.swift
//  ludio
//
//  Created by Cory Zachman on 12/19/20.
//

import Foundation

public class LudioPlayerConfiguration {

    var loopVideo: Bool = false

    var autoplay: Bool = false

    public init(loopVideo: Bool = false, autoplay: Bool = false) {
        self.loopVideo = loopVideo
        self.autoplay = autoplay
    }

}
