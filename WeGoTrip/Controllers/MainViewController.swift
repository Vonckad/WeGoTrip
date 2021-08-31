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
    var excursionModel: ExcursionModel = .init(name: "Токио", step: [])
    
    var mySetImage = UIImageView()
    var frame = CGRect.zero
    var urlImageArray: [String] = []
    var currentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainScrollView.delegate = self
        loadModel()
        setupMainScrollView(currentIndex: currentIndex)
        setupPlayer(currentIndex: currentIndex)
        testButton.titleLabel?.numberOfLines = 2
    }
    
    //MARK: - setup UI
    func setupPlayer(currentIndex: Int) {
        mainTitleLabel.text = excursionModel.step[currentIndex].title
        mainProgressView.setProgress(0.0, animated: false)
        testButton.setAttributedTitle(NSAttributedString(string: excursionModel.step[currentIndex].title), for: .normal)
        
        let urlSound = URL(fileURLWithPath: Bundle.main.path(forResource: excursionModel.step[currentIndex].sound, ofType: "mp3")!)
        player = AVPlayer(url: urlSound)
        player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1/30.0, preferredTimescale: Int32(NSEC_PER_SEC)), queue: nil) { time in
            let duration = CMTimeGetSeconds(self.player.currentItem!.duration)
            self.mainProgressView.progress = Float(time.seconds) / Float(duration)
        }
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(animationDidFinish(_:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: player.currentItem)
    }
    
    @objc func animationDidFinish(_ notification: NSNotification) {
        playOrPause(false)
        player.seek(to: CMTime(seconds: 0.0, preferredTimescale: 1000))
    }
    
    func setupMainScrollView(currentIndex: Int) {
        for sub in mainScrollView.subviews {
            sub.removeFromSuperview()
        }
        mainPageControl.numberOfPages = excursionModel.step[currentIndex].imageArray.count

        for index in excursionModel.step[currentIndex].imageArray.indices {
            
            frame.origin.x = mainScrollView.frame.size.width * CGFloat(index)
            frame.size = mainScrollView.frame.size
            mySetImage = UIImageView(frame: frame)
            mySetImage.contentMode = .scaleAspectFit
            self.mainScrollView.addSubview(mySetImage)
            getImage(link: excursionModel.step[currentIndex].imageArray[index], imageV: mySetImage)
        }
        mainScrollView.contentSize.width =  mainScrollView.frame.size.width * CGFloat(excursionModel.step[currentIndex].imageArray.count)
    }
    
    func playOrPause(_ bool: Bool) {
        if bool {
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
        playerVC.stepModels = excursionModel.step
        playerVC.player = player
        playerVC.mainTitle = excursionModel.name
        playerVC.playerVCDelegate = self
        playerVC.currentIndex = currentIndex
        playerVC.currentPlayerTime = player.currentTime()
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
    
    func index(_ index: Int) {
        currentIndex = index
        player.pause()
        playOrPause(false)
        setupMainScrollView(currentIndex: index)
        setupPlayer(currentIndex: index)
    }
    
    func isPlaing(_ bool: Bool) {
        playOrPause(bool)
    }
}

    //MARK: - CreateModel
extension MainViewController {
    func loadModel() {
        let tokyo1 = StepModel(title: "Добро пожаловать в Токио", text: """
            Токио манит яркими огнями: как будто попал в будущее и столько нового предстоит изучить! Токио - огромный и многогранный город, и чтобы не потеряться в его суете, предлагаем вам обзорную экскурсию по самым увлекательным местам японской столицы!
            
            Посетив Токио с обзорной экскурсией, вы убедитесь, что Япония невозможна без традиций и изысканного очарования прошлого. Восточный сад императорского дворца - место покоя и единения с природой посреди каменных "джунглей" города. Сторожевые башни стен дворца, прекрасный сад с прудом, созданные в 17 веке отвлекут от суеты и покажут другую сторону Японии. (Восточный сад закрыт по понедельникам и пятницам. Если экскурсия выпадает на один из этих дней, мы прогуляемся по обширному парку вокруг территории дворца, полюбуемся на мост "Нидзюбаси".)
            """, imageArray: ["https://wikiway.com/upload/resize_cache/hl-photo/a85/720_400_1/televizionnaya_bashnya_tokio_42.jpg", "https://wikiway.com/upload/resize_cache/hl-photo/02d/720_400_1/televizionnaya_bashnya_tokio_39.jpg", "https://wikiway.com/upload/resize_cache/hl-photo/ff4/720_400_1/televizionnaya_bashnya_tokio_38.jpg", "https://wikiway.com/upload/resize_cache/hl-photo/a25/720_400_1/televizionnaya_bashnya_tokio_33.jpg", "https://wikiway.com/upload/resize_cache/hl-photo/e8e/720_400_1/televizionnaya_bashnya_tokio_5.jpg"], sound: "Tokio")
                
        let tokyo2 = StepModel(title: "Императорский Дворец", text: """
            Если Токио и имеет какой-то единый центр, то это нынешний Императорский дворец, который стоит на месте замка Эдо (сёгунат Токугава правил отсюда Японией на протяжении 265 лет). Дворец был почти полностью уничтожен бомбардировками Второй мировой войны, затем восстановлен с использованием железобетона. Это здание — наименее интересная часть некогда самой обширной фортификационной системы в мире, хотя попасть внутрь все равно не удастся. Во дворце по-прежнему проживает императорская семья, а потому его территория доступна для посещения лишь два дня в году — 2 января и 23 декабря. Но и в эти дни вам будет непросто пробиться сквозь многотысячные толпы японцев, желающих засвидетельствовать почтение своему императору. При этом аллея, окружающая дворцовую территорию, ежедневно используется сотнями любителей бега.
            
            Что вы действительно сможете увидеть, так это красивый Восточный сад, ров с массивными каменными стенами и несколько образцов классической японской архитектуры — ворота, мосты, арсеналы, сторожевые башни, — сохранившихся с XVII в. Чтобы попасть в Восточный сад (вт—чт, сб, вс 9.00—16.30, 15 апреля — август 9.00— 17.00, ноябрь — февраль 9.00—16.00), от станции метро «Otemachi» пройдите через ворота Отемон и далее прогуляйтесь вдоль живой изгороди из белых и красных азалий, по берегам прудов и у маленьких водопадов в окружении сосен, сливовых деревьев, канарских пальм и нежной зелени криптомерии японской. Над верхушками деревьев время от времени будут просматриваться небоскребы современного Токио. К северу от сада, а также в пределах периметра, очерченного дворцовым рвом, раскинулся густо засаженный деревьями парк Китаномару со сложенной из красного кирпича Галереей ремесел (вт—вс 10.00—17.00). Галерея занимает здание эпохи Мэйдзи, и ее экспозиция послужит прекрасным введением в историю японского искусства и традиционных промыслов. В парке также располагаются Музей науки (вт—в с 9.30—16.50) с интерактивными и высокотехнологичными экспонатами и яркий по своей архитектуре зал боевых искусств Ниппон Будокан.

            Прогулка по часовой стрелке сначала приведет вас к живописному мосту Нидзюбаси и воротам Сэймон, через которые публика допускается на территорию дворца. Далее вы минуете самые заметные из современных правительственных зданий страны, занимаемые Национальным парламентом и Верховным судом. Полный обход территории позволит увидеть Национальный театр и Национальный музей современного искусства.
            """, imageArray: ["https://wikiway.com/upload/resize_cache/hl-photo/707/720_400_1/imperatorskiy_dvorets_v_tokyo_64.jpg", "https://wikiway.com/upload/resize_cache/hl-photo/d49/720_400_1/imperatorskiy_dvorets_v_tokyo_65.jpg", "https://wikiway.com/upload/resize_cache/hl-photo/abe/720_400_1/imperatorskiy_dvorets_v_tokyo_82.jpg", "https://wikiway.com/upload/resize_cache/hl-photo/92f/720_400_1/imperatorskiy_dvorets_v_tokyo_79.jpg"],  sound: "Tokyo2")
        
        let tokyo3 = StepModel(title: "Синтоистский Храм Ясукуни", text: """
            В случае, если Восточный сад императорского дворца будет закрыт, прогулку по парку возле дворца можно заменить на посещение Мэйдзи-дзингу и района Харадзюку. Для самих японцев одним из важнейших духовных мест является святилище Мэйдзи – Мэйдзи-дзингу. Сюда приходят за благословением будь это свадьба, рождение ребенка, деловые решения или другое ключевое событие в жизни. Святилище находится в большом парке, что создает отстраненную и спокойную атмосферу даже в центре оживленного города. Совсем рядом со святилищем расположен самый модный район города – Харадзюку. Молодежь со всего города стекается сюда, чтобы побродить по местным магазинчикам в поисках стильной и оригинальной одежды.

            Опция. Если вы мечтаете увидеть роботов в Японии, в качестве опционной части программы можете забронировать у нас посещение выставочного центра Хонда. Здесь не только увидите автомобили и мотоциклы этого производителя, но и насладитесь шоу робота Асимо без толп туристов и даже сможете сфотографироваться с ним! Шоу, как правило, проводится по расписанию 2-3 раза в день, иногда бывают выходные.
            """, imageArray: ["https://wikiway.com/upload/resize_cache/hl-photo/bbf/53e/720_400_1/ostrov-khokkaydo_158.jpg", "https://wikiway.com/upload/resize_cache/hl-photo/81a/720_400_1/kinkakuji_3.jpg", "https://wikiway.com/upload/resize_cache/hl-photo/67a/720_400_1/imperatorskiy_dvorets_v_tokyo_54.jpg"], sound: "Tokyo3")
        
        excursionModel.step.append(tokyo1)
        excursionModel.step.append(tokyo2)
        excursionModel.step.append(tokyo3)
    }
}
