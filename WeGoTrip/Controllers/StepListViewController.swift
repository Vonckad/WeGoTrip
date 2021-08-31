//
//  StepListViewController.swift
//  WeGoTrip
//
//  Created by Vlad Ralovich on 31.08.21.
//

import UIKit

protocol StepListViewControllerDelegate {
    func setIndex(_ index: Int)
}

class StepListViewController: UIViewController {

    var titleText = ""
    var step: [StepModel] = []
    var delegate: StepListViewControllerDelegate?
    
    @IBOutlet weak var stepListTableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var stepPanGesture: UIPanGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = titleText
        stepListTableView.tableFooterView = UIView()
        if #available(iOS 13.0, *) {
            stepPanGesture.isEnabled = false
            modalPresentationStyle = .automatic
        } else {
            stepPanGesture.isEnabled = true
            modalPresentationStyle = .overFullScreen
        }
    }
    
    //MARK: - Action
    @IBAction func dismissButton(_ sender: Any) {
        dismiss(animated: true)
    }
    @IBAction func stepPanGestureAction(_ sender: Any) {
        if stepPanGesture.velocity(in: view).y > 1000 {
            dismiss(animated: true, completion: nil)
        }
    }
}

extension StepListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return step.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = step[indexPath.row].title
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.setIndex(indexPath.row)
        print("Выбран этап \(step[indexPath.row].title)")
    }
    
}
