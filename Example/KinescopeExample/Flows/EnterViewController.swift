import UIKit

final class EnterViewController: UIViewController {

    @IBOutlet weak var field: UITextField!
    @IBOutlet weak var uiSwitch: UISwitch!

    private let initialVideoId: String = {
#if targetEnvironment(simulator)
        "9L8KmbNuhQSxQofn5DR4Vg"
#else
        "b6a0ce69-3135-496d-8064-c8ed51ac4b2e"
#endif
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        field.text = initialVideoId
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("Downloaded", comment: ""),
            style: .plain,
            target: self,
            action: #selector(showDownloadedTapped)
        )
    }

    @objc private func showDownloadedTapped() {
        let list = DownloadedListViewController()
        let nav = UINavigationController(rootViewController: list)
        present(nav, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "Player",
              let destination = segue.destination as? VideoViewController,
              let videoId = sender as? String else {
            return
        }
        destination.videoId = videoId
        destination.uiEnabled = uiSwitch.isOn
    }

    @IBAction func didTapPlay(_ sender: Any) {
        tryToPlay()
    }
    
}

private extension EnterViewController {
    
    func tryToPlay() {
        if let videoId = field.text?.trimmingCharacters(in: .whitespacesAndNewlines), !videoId.isEmpty {
            showPlayer(for: videoId)
        } else {
            showAlert()
        }
    }

    func showPlayer(for videoId: String) {
        performSegue(withIdentifier: "Player", sender: videoId)
    }

    func showAlert() {
        let alert = UIAlertController(title: "Error",
                                      message: "videoId should not be empty",
                                      preferredStyle: .alert)
        alert.addAction(.init(title: "Ok", style: .cancel))
        present(alert, animated: true)
    }

}
