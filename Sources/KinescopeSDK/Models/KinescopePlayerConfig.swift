//
//  KinescopePlayerConfig.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 29.03.2021.
//

import Foundation

/// Configuration entity required to connect resource with player
public struct KinescopePlayerConfig {

    /// Id of concrete video. For example from [GET Videos list](https://documenter.getpostman.com/view/10589901/TVCcXpNM)
    public let videoId: String

    /// If value is `true` show video in infinite loop.
    public let looped: Bool
    
    /// Repeating mode for player
    public let repeatingMode: RepeatingMode

    /// Local file URL for offline playback (e.g. downloaded video). When set, player uses this URL instead of streaming.
    public let localPlaybackURL: URL?

    /// Default link to share video and play it on web.
    public var shareLink: URL? {
        URL(string: "https://kinescope.io/\(videoId)")
    }

    /// - parameter videoId: Id of concrete video. For example from [GET Videos list](https://documenter.getpostman.com/view/10589901/TVCcXpNM)
    /// - parameter looped: If value is `true` show video in infinite loop. By default is `false`
    /// - parameter repeatingMode: Mode which will be used to repeat failed requests.
    /// - parameter localPlaybackURL: Optional local file URL for offline playback (e.g. downloaded video with or without DRM).
    public init(videoId: String, looped: Bool = false, repeatingMode: RepeatingMode = .default, localPlaybackURL: URL? = nil) {
        self.videoId = videoId
        self.looped = looped
        self.repeatingMode = repeatingMode
        self.localPlaybackURL = localPlaybackURL
    }

}
