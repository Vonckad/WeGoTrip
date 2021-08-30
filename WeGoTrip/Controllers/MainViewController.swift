//
//  ViewController.swift
//  WeGoTrip
//
//  Created by Vlad Ralovich on 28.08.21.
//

import UIKit
import MediaPlayer

class MainViewController: UIViewController {

    @IBOutlet weak var mainProgressView: UIProgressView!
    @IBOutlet weak var playerButton: UIButton!
//    @IBOutlet weak var miniTitle: UILabel!
    @IBOutlet weak var testButton: UIButton!
    
    var player: AVPlayer!
    
    var excursionModel: [ExcursionModel] = []
    let urlImageArray = [ "https://cdn.pixabay.com/photo/2017/04/01/10/59/tokyo-2193354_960_720.jpg",
        "https://cdn.pixabay.com/photo/2013/11/25/09/47/buildings-217878_960_720.jpg",
        "https://cdn.pixabay.com/photo/2019/07/14/08/08/night-4336403_960_720.jpg",
        "https://cdn.pixabay.com/photo/2014/03/20/01/49/tokyo-290980_960_720.jpg",
        "https://cdn.pixabay.com/photo/2019/06/08/11/30/japan-4259948_960_720.jpg"
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        loadModel()
        
        
        
        testButton.setTitle(excursionModel[0].step[0].title, for: .normal)
        
        let urlSound = URL(fileURLWithPath: Bundle.main.path(forResource: excursionModel[0].step[0].sound, ofType: "mp3")!)
        player = AVPlayer(url: urlSound)
        player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1/30.0, preferredTimescale: Int32(NSEC_PER_SEC)), queue: nil) { time in
            let duration = CMTimeGetSeconds(self.player.currentItem!.duration)
            self.mainProgressView.progress = Float(time.seconds) / Float(duration)
        }
        
    }
    
    //MARK: - CreateModel
    func loadModel() {
        excursionModel.append(ExcursionModel(name: "first",step: [StepModel(title: "Tokio",
        text: """
        cute anime cute anime cute anime cute anime
        cute anime cute anime cute anime cute anime
        cute anime cute anime cute anime cute anime
        cute anime cute anime cute anime cute anime
        cute anime cute anime cute anime cute anime
        cute anime cute anime cute anime cute anime
        cute anime cute anime cute anime cute anime
        cute anime cute anime cute anime cute anime
        cute anime cute anime cute anime cute anime
        cute anime cute anime cute anime cute anime
        cute anime cute anime cute anime cute anime
        cute anime cute anime cute anime cute anime
        """,imageArray: urlImageArray,sound: "Tokio")]))
    }
    
    
    //MARK: - Action
    @IBAction func testButtonAction(_ sender: Any) {
        createPlayerVC()
    }
    @IBAction func playerButtonAction(_ sender: Any) {
        if player.timeControlStatus == .playing {
            player.pause()
        } else { player.play() }
    }
    @IBAction func threePointButtonAction(_ sender: Any) {
        createPlayerVC()
    }
    @IBAction func backFiveSButtonAction(_ sender: Any) {
        rewind(isForward: false)
    }
    @IBAction func forwardFiveSButtonAction(_ sender: Any) {
        rewind(isForward: true)
    }
    
    func createPlayerVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let playerVC = storyboard.instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
        playerVC.stepModels = excursionModel[0].step
        playerVC.player = player
        showDetailViewController(playerVC, sender: nil)
    }
    
    
    //MARK: - RewindPlayer
    func rewind(isForward: Bool) {
        guard let duration  = player?.currentItem?.duration else {
            return
        }
        let playerCurrentTime = CMTimeGetSeconds(player!.currentTime())
        
        if isForward {
            let newTime = playerCurrentTime + 5
            if newTime < (CMTimeGetSeconds(duration) - 5) {
                
                let time2: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
                player!.seek(to: time2, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
            }
        } else {
            var newTime = playerCurrentTime - 5
            
            if newTime < 0 {
                newTime = 0
            }
            let time2: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
            player!.seek(to: time2, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        }
    }
}
