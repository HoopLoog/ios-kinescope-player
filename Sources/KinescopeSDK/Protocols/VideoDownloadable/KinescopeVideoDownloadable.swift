import Foundation

public protocol KinescopeVideoDownloadable: AnyObject {

    func enqueueDownload(videoId: String, url: URL)
    func pauseDownload(videoId: String)
    func resumeDownload(videoId: String)
    func dequeueDownload(videoId: String)
    func isDownloaded(videoId: String) -> Bool
    func downloadedList() -> [String]
    func getLocation(by videoId: String) -> URL?
    @discardableResult
    func delete(videoId: String) -> Bool
    func clear()
    func add(delegate: KinescopeVideoDownloadableDelegate)
    func remove(delegate: KinescopeVideoDownloadableDelegate)
    func restore()

}

public extension KinescopeVideoDownloadable {

    func isDownloaded(videoId: String) -> Bool {
        return downloadedList().contains(videoId)
    }

    func enqueueDownload(videoId: String, url: URL, video: KinescopeVideo?) {
        enqueueDownload(videoId: videoId, url: url)
    }

}
