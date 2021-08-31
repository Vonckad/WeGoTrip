//
//  ViewController.swift
//  WeGoTrip
//
//  Created by Vlad Ralovich on 28.08.21.
//

import UIKit
import MediaPlayer

class MainViewController: UIViewController {

    @IBOutlet weak var mainTitleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var mainPageControl: UIPageControl!
    
    @IBOutlet weak var mainProgressView: UIProgressView!
    @IBOutlet weak var playerButton: UIButton!
    @IBOutlet weak var testButton: UIButton!
    
    var player: AVPlayer!
    var excursionModel: [ExcursionModel] = []

    var mySetImage = UIImageView()
    var frame = CGRect.zero //для scrollView
    var urlImageArray: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadModel()
        
        mainScrollView.delegate = self
        mainPageControl.numberOfPages = excursionModel[0].step[0].imageArray.count
        setupMainScrollView()

        testButton.setAttributedTitle(NSAttributedString(string: excursionModel[0].step[0].title), for: .normal)
        testButton.titleLabel?.numberOfLines = 2
        
        let urlSound = URL(fileURLWithPath: Bundle.main.path(forResource: excursionModel[0].step[0].sound, ofType: "mp3")!)
        player = AVPlayer(url: urlSound)
        player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1/30.0, preferredTimescale: Int32(NSEC_PER_SEC)), queue: nil) { time in
            let duration = CMTimeGetSeconds(self.player.currentItem!.duration)
            self.mainProgressView.progress = Float(time.seconds) / Float(duration)
        }
    }
    
    func setupMainScrollView() {
        
        for index in excursionModel[0].step[0].imageArray.indices {
            
            frame.origin.x = mainScrollView.frame.size.width * CGFloat(index)
            frame.size = mainScrollView.frame.size
            mySetImage = UIImageView(frame: frame)
            mySetImage.contentMode = .scaleToFill
            self.mainScrollView.addSubview(mySetImage)
            getImage(link: excursionModel[0].step[0].imageArray[index], imageV: mySetImage)
        }
        mainScrollView.contentSize.width =  mainScrollView.frame.size.width * CGFloat(excursionModel[0].step[0].imageArray.count)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if player.timeControlStatus == .playing {
            playerButton.setImage(UIImage(named: "icons8-pause-60"), for: .normal)
        } else {
            playerButton.setImage(UIImage(named: "icons8-play-60"), for: .normal)
        }
    }
    
    // MARK: - load Image
    func getImage(link: String, imageV: UIImageView) {
        
        guard let imageURL = URL(string: link) else { return }
        DispatchQueue.global().async {
            guard let imageData = try? Data(contentsOf: imageURL) else { return }
            let image = UIImage(data: imageData)
            DispatchQueue.main.async {
                imageV.image = image
            }
        }
    }
    
    //MARK: - CreateModel
    func loadModel() {
        
        urlImageArray = ["https://images.unsplash.com/photo-1557409518-691ebcd96038?ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTR8fHRva3lvfGVufDB8fDB8fA%3D%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60",
                         "https://images.unsplash.com/photo-1533050487297-09b450131914?ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTF8fHRva3lvfGVufDB8fDB8fA%3D%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60",
                         "https://images.unsplash.com/photo-1513407030348-c983a97b98d8?ixid=MnwxMjA3fDB8MHxzZWFyY2h8Nnx8dG9reW98ZW58MHx8MHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60",
                         "https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8dG9reW98ZW58MHx8MHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60"]
        
        excursionModel.append(ExcursionModel(name: "Токио",step: [StepModel(title: "Добро пожаловать в Токио",
        text: """
        Токио манит яркими огнями: как будто попал в будущее и столько нового предстоит изучить! Токио - огромный и многогранный город, и чтобы не потеряться в его суете, предлагаем вам обзорную экскурсию по самым увлекательным местам японской столицы!

        Посетив Токио с обзорной экскурсией, вы убедитесь, что Япония невозможна без традиций и изысканного очарования прошлого. Восточный сад императорского дворца - место покоя и единения с природой посреди каменных "джунглей" города. Сторожевые башни стен дворца, прекрасный сад с прудом, созданные в 17 веке отвлекут от суеты и покажут другую сторону Японии. (Восточный сад закрыт по понедельникам и пятницам. Если экскурсия выпадает на один из этих дней, мы прогуляемся по обширному парку вокруг территории дворца, полюбуемся на мост "Нидзюбаси".)
        """,imageArray: urlImageArray,sound: "Tokio")]))
    }
    
    
    //MARK: - Action
    @IBAction func testButtonAction(_ sender: Any) {
        createPlayerVC()
    }
    @IBAction func playerButtonAction(_ sender: Any) {
        if player.timeControlStatus == .playing {
            player.pause()
            playerButton.setImage(UIImage(named: "icons8-play-60"), for: .normal)
        } else {
            player.play()
            playerButton.setImage(UIImage(named: "icons8-pause-60"), for: .normal)
        }
    }
    @IBAction func threePointButtonAction(_ sender: Any) {
        createPlayerVC()
    }
    @IBAction func backFiveSButtonAction(_ sender: Any) {
        MainViewController.rewind(player: player, isForward: false)
    }
    @IBAction func forwardFiveSButtonAction(_ sender: Any) {
        MainViewController.rewind(player: player, isForward: true)
    }
    
    //MARK: - showPlayerViewController
    func createPlayerVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let playerVC = storyboard.instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
        playerVC.stepModels = excursionModel[0].step
        playerVC.player = player
        playerVC.mainTitle = excursionModel[0].name
        playerVC.playerVCDelegate = self
        showDetailViewController(playerVC, sender: nil)
    }
    
    
    //MARK: - RewindPlayer
    static func rewind(player: AVPlayer, isForward: Bool) {
        guard let duration  = player.currentItem?.duration else {
            return
        }
        let playerCurrentTime = CMTimeGetSeconds(player.currentTime())
        
        if isForward {
            let newTime = playerCurrentTime + 5
            if newTime < (CMTimeGetSeconds(duration) - 5) {
                
                let time2: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
                player.seek(to: time2, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
            }
        } else {
            var newTime = playerCurrentTime - 5
            
            if newTime < 0 {
                newTime = 0
            }
            let time2: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
            player.seek(to: time2, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        }
    }
}

    //MARK: - UIScrollViewDelegate
extension MainViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = mainScrollView.contentOffset.x / mainScrollView.frame.size.width
        mainPageControl.currentPage = Int(pageNumber)
    }
}

    //MARK: - PlayerViewControllerDelegate
extension MainViewController: PlayerViewControllerDelegate {
    func isPlaing(_ bool: Bool) {
        if bool {
            playerButton.setImage(UIImage(named: "icons8-pause-60"), for: .normal)
        } else {
            playerButton.setImage(UIImage(named: "icons8-play-60"), for: .normal)
        }
    }
}
