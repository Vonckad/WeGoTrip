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
    
    var player: AVPlayer!
    var stepModels: [StepModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = stepModels[0].title
        textView.text = stepModels[0].text
        
        let soundPath = URL(fileURLWithPath: Bundle.main.path(forResource: stepModels[0].sound, ofType: "mp3")!)
        
        player = .init(url: soundPath)
        
    }
    @IBAction func playButtonAction(_ sender: Any) {
        player.play()
    }
}
