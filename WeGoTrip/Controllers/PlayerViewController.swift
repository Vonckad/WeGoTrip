//
//  PlayerViewController.swift
//  WeGoTrip
//
//  Created by Vlad Ralovich on 28.08.21.
//

import UIKit
import MediaPlayer

class PlayerViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mySlider: UISlider!
    @IBOutlet weak var leftTimeLabel: UILabel!
    @IBOutlet weak var rightTimeLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    var stepModels: [StepModel] = []
    
    var player: AVPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = stepModels[0].title
        textView.text = stepModels[0].text
        
        let maxTime = Float(player.currentItem?.asset.duration.seconds ?? 0)
        mySlider.maximumValue = maxTime
        rightTimeLabel.text = "\(maxTime)"
        
        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1000), queue: DispatchQueue.main) { time in
            self.leftTimeLabel.text = "\(time.seconds)"
            self.mySlider.value = Float(time.seconds)
        }
    }
    @IBAction func sliderAction(_ sender: Any) {
        player.seek(to: CMTime(seconds: Double(mySlider.value), preferredTimescale: 1000))
        leftTimeLabel.text = "\(mySlider.value)"
    }
    
    @IBAction func playButtonAction(_ sender: Any) {

        if player.timeControlStatus == .paused {
            playButton.setTitle("Pause", for: .normal)
            player.play()
        } else {
            player.pause()
            playButton.setTitle("Play", for: .normal)
        }
    }
    
    @IBAction func dismisVC(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func panGesture(_ sender: Any) {
        let recognizer = sender as! UIPanGestureRecognizer
        if recognizer.velocity(in: view).y > 1000 {
            dismiss(animated: true, completion: nil)
        }
    }
}
