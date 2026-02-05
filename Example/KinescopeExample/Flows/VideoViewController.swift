import UIKit
import KinescopeSDK

final class VideoViewController: UIViewController {

    private enum CustomPlayerOption: String {
        case share
    }

    @IBOutlet private weak var playerView: KinescopePlayerView!

    private var player: KinescopePlayer?
    private var downloadBarButtonItem: UIBarButtonItem?
    private var isDownloading = false

    var videoId: String = ""
    var uiEnabled: Bool = true

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let videoId = sender as? String else {
            return
        }
        self.videoId = videoId
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.delegate = self
        setupDownloadButton()
        Kinescope.shared.videoDownloader.add(delegate: self)

        if uiEnabled {
            playerView.setLayout(with: .accentTimeLineAndPlayButton(with: .orange))
        } else {
            playerView.setLayout(with: .builder()
                .setGravity(.resizeAspect)
                .setOverlay(nil)
                .setControlPanel(nil)
                .setShadowOverlay(nil)
                .build()
            )
        }

        PipManager.shared.closePipIfNeeded(with: videoId)
        
        let repeatingMode: RepeatingMode = uiEnabled ? .default : .infinite(interval: .seconds(5))

        player = KinescopeVideoPlayer(config: .init(videoId: videoId,
                                                    looped: !uiEnabled,
                                                    repeatingMode: repeatingMode))

        if #available(iOS 13.0, *) {
            if let shareIcon = UIImage(systemName: "square.and.arrow.up")?.withRenderingMode(.alwaysTemplate) {
                player?.addCustomPlayerOption(with: CustomPlayerOption.share, and: shareIcon)
            }
        }
        player?.disableOptions([.airPlay])

        player?.setDelegate(delegate: self)
        player?.attach(view: playerView)
        player?.play()
        player?.pipDelegate = PipManager.shared

    }

    deinit {
        Kinescope.shared.videoDownloader.remove(delegate: self)
    }

    private func setupDownloadButton() {
        let title = NSLocalizedString("Download", comment: "Download video button")
        let button = UIBarButtonItem(
            title: title,
            style: .plain,
            target: self,
            action: #selector(downloadTapped)
        )
        if #available(iOS 13.0, *) {
            button.image = UIImage(systemName: "arrow.down.circle")
        }
        downloadBarButtonItem = button
        navigationItem.rightBarButtonItem = button
    }

    @objc private func downloadTapped() {
        guard !isDownloading else { return }

        Kinescope.shared.inspector.video(
            id: videoId,
            onSuccess: { [weak self] video in
                self?.startDownload(video: video)
            },
            onError: { [weak self] error in
                self?.showAlert(title: NSLocalizedString("Error", comment: ""), message: error.localizedDescription)
            }
        )
    }

    private func startDownload(video: KinescopeVideo) {
        if Kinescope.shared.videoDownloader.isDownloaded(videoId: video.id) {
            showAlert(
                title: NSLocalizedString("Saved", comment: ""),
                message: NSLocalizedString("This video is already saved for offline.", comment: "")
            )
            return
        }

        guard let url = URL(string: video.hlsLink) else {
            showAlert(title: NSLocalizedString("Error", comment: ""), message: "Invalid video URL")
            return
        }

        isDownloading = true
        updateDownloadButton(title: NSLocalizedString("Downloading...", comment: ""), enabled: false)
        Kinescope.shared.videoDownloader.enqueueDownload(videoId: video.id, url: url, video: video)
    }

    private func updateDownloadButton(title: String?, enabled: Bool) {
        downloadBarButtonItem?.title = title
        downloadBarButtonItem?.isEnabled = enabled
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
        present(alert, animated: true)
    }

}

extension VideoViewController: UINavigationControllerDelegate {
    func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        return self.supportedInterfaceOrientations
    }
}

extension VideoViewController: KinescopeVideoPlayerDelegate {

    func player(didSelectCustomOptionWith optionId: AnyHashable, anchoredAt view: UIView) {
        guard let option = optionId as? CustomPlayerOption else {
            return
        }

        switch option {
        case .share:
            let items = [player?.config.shareLink]
            let activityViewController = UIActivityViewController(activityItems: items as [Any],
                                                                  applicationActivities: nil)
            let presentationController = activityViewController.presentationController as? UIPopoverPresentationController
            presentationController?.sourceView = view
            presentationController?.permittedArrowDirections = .down
            present(activityViewController, animated: true)
        }
    }

}

extension VideoViewController: KinescopeVideoDownloadableDelegate {

    func videoDownloadProgress(videoId: String, progress: Double) {
        guard videoId == self.videoId else { return }
        DispatchQueue.main.async { [weak self] in
            self?.updateDownloadButton(
                title: String(format: NSLocalizedString("Downloading %.0f%%", comment: ""), progress),
                enabled: false
            )
        }
    }

    func videoDownloadError(videoId: String, error: KinescopeDownloadError) {
        guard videoId == self.videoId else { return }
        DispatchQueue.main.async { [weak self] in
            self?.isDownloading = false
            self?.updateDownloadButton(title: NSLocalizedString("Download", comment: ""), enabled: true)
            self?.showAlert(
                title: NSLocalizedString("Download failed", comment: ""),
                message: error.localizedDescription
            )
        }
    }

    func videoDownloadComplete(videoId: String) {
        guard videoId == self.videoId else { return }
        DispatchQueue.main.async { [weak self] in
            self?.isDownloading = false
            self?.updateDownloadButton(title: NSLocalizedString("Download", comment: ""), enabled: true)
            self?.showAlert(
                title: NSLocalizedString("Saved", comment: ""),
                message: NSLocalizedString("Video saved for offline playback.", comment: "")
            )
        }
    }

}
