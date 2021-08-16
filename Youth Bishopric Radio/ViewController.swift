//
//  ViewController.swift
//  Youth Bishopric Radio
//
//  Created by Petra Software on 15/08/2021.
//

import UIKit
import AVFoundation
import Alamofire
class ViewController: UIViewController {
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var waveProgressView: WavedProgressView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var navImageView: UIImageView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var commentsTableView: UITableView!
    var timer = Timer()
    var comments = [Comment]()
    var player : AVPlayer!
    fileprivate let endpoint = "https://petrasoftware.net/radioservice/"
    let state : Int = 0
    @IBOutlet weak var commentTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // get Api Comment
        let service = Netwwork.init(baseUrl: endpoint)
        service.getComments()
        reload(network: service)
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        registCells()
        
        //      let url = "http://listen.shoutcast.com/radiodeltalebanon"
        let url = "http://52.57.74.202:8000/listen.pls?sid=1"
        player = AVPlayer(url: URL(string: url)!)
        player.volume = 10.0
        player.rate = 1.0
        player.pause()
        commentsTableView.isHidden = true
        commentTextField.isHidden = true
        sendButton.isHidden = true
        let tap = UITapGestureRecognizer(target: self, action:  #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playButton.clipsToBounds =  true
        playButton.layer.cornerRadius = playButton.frame.width / 2
        navImageView.roundCorners(corners: [.bottomLeft,.bottomRight], radius: navImageView.frame.width / 2)
    }
    
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCounting), userInfo: nil, repeats: true)
    }
    @objc func updateCounting(){
        waveProgressView.volumes.append(CGFloat.random(in: 0..<1))
        waveProgressView.drawVerticalLines()
        
    }
    
    @objc func playTapped(){
        print("playTapped")
        if playButton.imageView?.image == UIImage(named: "pause") {
            playButton.setImage(UIImage(named: "play"), for: .normal)
            //            waveProgressView.clearVolumes()
            player.pause()
        }
        else {
            playButton.setImage(UIImage(named: "pause"), for: .normal)
            scheduledTimerWithTimeInterval()
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
                print("AVAudioSession Category Playback OK")
                do {
                    try AVAudioSession.sharedInstance().setActive(true)
                    print("AVAudioSession is Active")
                    
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            player.play()
            //            if waveProgressView.volumes.count == 30 {
            //                waveProgressView.clearVolumes()
            ////                waveProgressView.drawVerticalLines()
            //            }
            //        }
        }
    }
    @objc func changeProgressView(){
        waveProgressView.volumes.append(CGFloat.random(in: 0..<1))
        waveProgressView.drawVerticalLines()
    }
    
    func registCells(){
        commentsTableView.register(UINib(nibName: "CommentTableViewCell", bundle: nil), forCellReuseIdentifier: "CommentTableViewCell")
    }
    
}

extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
}
extension ViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = commentsTableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell", for: indexPath) as! CommentTableViewCell
        cell.commentDescLabel.text = comments[indexPath.row].text
        cell.dateLabel.text = comments[indexPath.row].datetime
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(tableView.frame.height / 2 )
    }
    
}
//Call Api Comment , Likes
extension ViewController{
    @IBAction func sendAction(_ sender: Any) {
        let service = Netwwork.init(baseUrl: endpoint)
        if commentTextField.text != ""{
            service.sendComment(text: commentTextField.text!)
            service.getComments()
            reload(network: service)
            self.commentsTableView.reloadData()
        }
    }
    @IBAction func listAction(_ sender: Any) {
        commentsTableView.isHidden = true
        let origImage = UIImage(named: "comment")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        commentButton.setImage(tintedImage, for: .normal)
    }
    @IBAction func likeAction(_ sender: Any) {
        //        commentsTableView.isHidden = true
        let origImage = UIImage(named: "like")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        likeButton.setImage(tintedImage, for: .normal)
        if likeButton.tintColor == #colorLiteral(red: 0.9546738267, green: 0.5322668552, blue: 0.6495662928, alpha: 1) {
        likeButton.tintColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        }
        else{
            likeButton.tintColor = #colorLiteral(red: 0.9546738267, green: 0.5322668552, blue: 0.6495662928, alpha: 1)
        }
        let service = Netwwork.init(baseUrl: endpoint)
        service.likeOrUnlike(state: likeOrUn())
    }
    func likeOrUn () -> Int {
        if likeButton.tintColor == #colorLiteral(red: 0.9546738267, green: 0.5322668552, blue: 0.6495662928, alpha: 1)
        {
            return 1
        }
        else {
            return 0
        }
    }
    @IBAction func commentAction(_ sender: Any) {
        let origImage = UIImage(named: "comment")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        commentButton.setImage(tintedImage, for: .normal)
        //        commentButton.tintColor = #colorLiteral(red: 0.9546738267, green: 0.5322668552, blue: 0.6495662928, alpha: 1)
        self.commentsTableView.reloadData()
        commentsTableView.isHidden = false
        sendButton.isHidden = false
        commentTextField.isHidden = false
     
        
    }
    @IBAction func shareAction(_ sender: Any) {
        
    }
    func reload(network:Netwwork){
        network.completionHandler { [weak self] (comments,status , message) in
            if status {
                guard let self = self else {
                    return
                }
                guard let _comments = comments else {
                    return
                }
                self.comments = _comments
                
            }
            
        }
    }
}
