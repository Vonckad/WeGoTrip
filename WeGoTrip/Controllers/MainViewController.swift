//
//  ViewController.swift
//  WeGoTrip
//
//  Created by Vlad Ralovich on 28.08.21.
//

import UIKit
import MediaPlayer

class MainViewController: UIViewController {

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
    }
    
    func loadModel() {
        excursionModel
            .append(
                ExcursionModel(name: "first",
                                             step: [StepModel(title: "Tokio",
                                                            text: """
                                                            cute anime
                                                            """,
                                                              imageArray: urlImageArray,
                                                              sound: "Tokio")]))
    }
    
    @IBAction func testButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let playerVC = storyboard.instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
        playerVC.stepModels = excursionModel[0].step
        present(playerVC, animated: true)
    }
}
