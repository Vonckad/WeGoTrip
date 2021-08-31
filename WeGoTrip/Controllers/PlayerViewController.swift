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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playerView.layer.cornerRadius = 15
        if #available(iOS 13.0, *) {
            playerPanGesture.isEnabled = false
            modalPresentationStyle = .automatic
        } else {
            playerPanGesture.isEnabled = true
            modalPresentationStyle = .overFullScreen
        }
        
        titleLabel.text = mainTitle
        playerViewTitleLabel.text = stepModels[0].title
        textView.text = stepModels[0].text
        
        let maxTime = Float(player.currentItem?.asset.duration.seconds ?? 0)
        mySlider.maximumValue = maxTime
        rightTimeLabel.text = "\(maxTime)"
        
        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1000), queue: DispatchQueue.main) { time in
            self.leftTimeLabel.text = "\(time.seconds)"
            self.mySlider.value = Float(time.seconds)
        }
        
        if player.timeControlStatus == .playing {
            playButton.setImage(UIImage(named: "icons8-pause-64"), for: .normal)
        } else {
            playButton.setImage(UIImage(named: "icons8-play-64"), for: .normal)
        }
    }
    @IBAction func sliderAction(_ sender: Any) {
        player.seek(to: CMTime(seconds: Double(mySlider.value), preferredTimescale: 1000))
        leftTimeLabel.text = "\(mySlider.value)"
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

extension PlayerViewController: StepListViewControllerDelegate {
    func setIndex(_ index: Int) {
        print(#line, stepModels[index].title)
    }
}
