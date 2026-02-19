import UIKit
import KinescopeSDK

final class DownloadedListViewController: UIViewController {

    private var videoIds: [String] = []
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Downloaded", comment: "")
        view.backgroundColor = .systemGroupedBackground
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneTapped)
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadList()
    }

    @objc private func doneTapped() {
        dismiss(animated: true)
    }

    private func reloadList() {
        videoIds = Kinescope.shared.videoDownloader.downloadedList()
        tableView.reloadData()
    }

    private func playVideo(videoId: String) {
        guard let url = Kinescope.shared.videoDownloader.getLocation(by: videoId) else {
            let alert = UIAlertController(
                title: NSLocalizedString("Error", comment: ""),
                message: NSLocalizedString("File not found.", comment: ""),
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
            present(alert, animated: true)
            return
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "VideoViewController") as? VideoViewController else {
            let alert = UIAlertController(
                title: NSLocalizedString("Error", comment: ""),
                message: NSLocalizedString("Could not open player.", comment: ""),
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
            present(alert, animated: true)
            return
        }
        vc.videoId = videoId
        vc.localVideoURL = url
        vc.uiEnabled = true
        navigationController?.pushViewController(vc, animated: true)
    }

    private func deleteVideo(videoId: String, at indexPath: IndexPath) {
        let deleted = Kinescope.shared.videoDownloader.delete(videoId: videoId)
        if deleted {
            videoIds.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } else {
            let alert = UIAlertController(
                title: NSLocalizedString("Error", comment: ""),
                message: NSLocalizedString("Could not delete video.", comment: ""),
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
            present(alert, animated: true)
        }
    }
}

extension DownloadedListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        videoIds.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = videoIds[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        playVideo(videoId: videoIds[indexPath.row])
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteVideo(videoId: videoIds[indexPath.row], at: indexPath)
        }
    }
}
