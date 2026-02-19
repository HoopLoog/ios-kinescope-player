import AVKit

final class PipManager: NSObject, AVPictureInPictureControllerDelegate {

    static let shared = PipManager()

    private var pipController: AVPictureInPictureController?
    private var currentVideoId = ""
    private var plaingVideoId = ""

    private override init() {}

    func closePipIfNeeded(with videoId: String) {
        currentVideoId = videoId
        if currentVideoId == plaingVideoId {
            pipController?.stopPictureInPicture()
        }
    }

    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        plaingVideoId = currentVideoId
        self.pipController = pictureInPictureController
    }

    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        self.pipController = nil
        self.plaingVideoId = ""
    }

}
