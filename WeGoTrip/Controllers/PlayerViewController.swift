//
//  PlayerViewController.swift
//  WeGoTrip
//
//  Created by Vlad Ralovich on 28.08.21.
//

import UIKit
import MediaPlayer

protocol PlayerViewControllerDelegate {
    func isPlaing(_ bool: Bool)
    func index(_ index: Int)
}

class PlayerViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var playerViewTitleLabel: UILabel!
    @IBOutlet weak var mySlider: UISlider!
    @IBOutlet weak var leftTimeLabel: UILabel!
    @IBOutlet weak var rightTimeLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet var playerPanGesture: UIPanGestureRecognizer!
    
    var playerVCDelegate: PlayerViewControllerDelegate?
    
    var stepModels: [StepModel] = []
    var mainTitle = ""
    var player: AVPlayer!
    var currentIndex = 0
    var currentPlayerTime = CMTime()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupText(currentIndex: currentIndex)
        playerView.layer.cornerRadius = 15
        
        if #available(iOS 13.0, *) {
            playerPanGesture.isEnabled = false
            modalPresentationStyle = .automatic
        } else {
            playerPanGesture.isEnabled = true
            modalPresentationStyle = .overFullScreen
        }
        
        guard let maxTime = player.currentItem?.asset.duration else { return }
        mySlider.maximumValue = Float(maxTime.seconds)
        rightTimeLabel.text = convertCMTimeToString(maxTime)
        mySlider.setValue(Float(currentPlayerTime.seconds), animated: false)
        leftTimeLabel.text = convertCMTimeToString(currentPlayerTime)
        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1000), queue: DispatchQueue.main) { time in
            self.leftTimeLabel.text = self.convertCMTimeToString(time)
            self.mySlider.value = Float(time.seconds)
        }
        playOrPauseImage(player.timeControlStatus == .playing)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(animationDidFinish(_:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: player.currentItem)
    }
    
    @objc func animationDidFinish(_ notification: NSNotification) {
        playOrPauseImage(false)
    }
    
    func convertCMTimeToString(_ time: CMTime) -> String {
        let secs = Int(time.seconds)
        return NSString(format: "%02d:%02d", secs/60, secs%60) as String
    }
    
    func playOrPauseImage(_ bool: Bool) {
        if bool {
            playButton.setImage(UIImage(named: "icons8-pause-64"), for: .normal)
        } else {
            playButton.setImage(UIImage(named: "icons8-play-64"), for: .normal)
        }
    }
    
    func setupText(currentIndex: Int) {
        titleLabel.text = mainTitle
        playerViewTitleLabel.text = stepModels[currentIndex].title
        textView.text = stepModels[currentIndex].text
    }
    
    // MARK: - Button Action

    @IBAction func playButtonAction(_ sender: Any) {

        if player.timeControlStatus == .paused {
            playButton.setImage(UIImage(named: "icons8-pause-64"), for: .normal)
            player.play()
            playerVCDelegate?.isPlaing(true)
        } else {
            player.pause()
            playerVCDelegate?.isPlaing(false)
            playButton.setImage(UIImage(named: "icons8-play-64"), for: .normal)
        }
    }
    @IBAction func forwardFive(_ sender: Any) {
        MainViewController.rewind(player: player, isForward: true)
    }
    
    @IBAction func dismisVC(_ sender: Any) {
        dismiss(animated: true)
    }
    @IBAction func showStepVCAction(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let stepVC = storyboard.instantiateViewController(withIdentifier: "StepListViewController") as? StepListViewController
        stepVC?.step = stepModels
        stepVC?.titleText = mainTitle
        stepVC?.delegate = self
        stepVC?.currentIndex = currentIndex
        showDetailViewController(stepVC!, sender: nil) //unwrap
    }
    @IBAction func backFive(_ sender: Any) {
        MainViewController.rewind(player: player, isForward: false)
    }
    
    @IBAction func panGesture(_ sender: Any) {
        if playerPanGesture.velocity(in: view).y > 1000 {
            dismiss(animated: true, completion: nil)
        }
    }
}

    //MARK: - StepListViewControllerDelegate
extension PlayerViewController: StepListViewControllerDelegate {
    func setIndex(_ index: Int) {
        playerVCDelegate?.index(index)
    }
}
