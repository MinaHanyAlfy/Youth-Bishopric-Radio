//
//  ViewController.swift
//  Youth Bishopric Radio
//
//  Created by Petra Software on 15/08/2021.
//

import UIKit
import AVFoundation
import Alamofire
import Kanna
class ViewController: UIViewController {
    let numLikes : Int? = 0
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var likeButton: SSBadgeButton!
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var waveProgressView: WavedProgressView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var navImageView: UIImageView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var commentsTableView: UITableView!
    var timer = Timer()
    var likeState = 0
    var comments = [Comment]()
    var player : AVPlayer!
    fileprivate let endpoint = "https://petrasoftware.net/radioservice/"
    fileprivate let url = "http://52.57.74.202:8000/index.html?sid=1"
    let state : Int = 0
    @IBOutlet weak var commentTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        likeButton.tintColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        shareButton.tintColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        commentButton.tintColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        listButton.tintColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        let service = Netwwork.init(baseUrl: endpoint)
        service.getComments()
        reload(network: service)
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        registCells()
        
        //let url = "http://listen.shoutcast.com/radiodeltalebanon"
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
        likeButton.badgeEdgeInsets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 15)
        playButton.clipsToBounds =  true
        playButton.layer.cornerRadius = playButton.frame.width / 2
        navImageView.roundCorners(corners: [.bottomLeft,.bottomRight], radius: navImageView.frame.width / 2)
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
            self.scrapeNYCMetalScene()
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
        }
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
//        likeButton.badge = "\(comments[indexPath.row].likes!)"
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
        let origImage2 = UIImage(named: "listFill")
//        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        commentButton.setImage(origImage, for: .normal)
        listButton.setImage(origImage2, for: .normal)
    }
    @IBAction func likeAction(_ sender: Any) {
 
        var myValue = Configuration.value(defaultValue: likeState, forKey: "key_1")
        let service = Netwwork.init(baseUrl: endpoint)

        if myValue == 0  {
            likeButton.setImage(UIImage(named: "likeFill.png"), for: .normal)
            likeState = 1
            myValue = likeState
      
//            service.getComments()
//            reload(network: service)
//            commentsTableView.reloadData()
//            likeButton.badge = "\(comments[0].likes!)"
            service.likeOrUnlike(state: likeState)
            Configuration.value(value: likeState, forKey: "key_1")
            likeButton.badge = "\(Int(comments[0].likes!)! + 1 )"
        }
        else{
            likeState = 0
            myValue = likeState
            likeButton.setImage(UIImage(named: "like.png"), for: .normal)
            Configuration.value(value: likeState, forKey: "key_1")
           
            likeButton.badge = "\(Int(comments[0].likes!)! - 1 )"
            service.likeOrUnlike(state: likeState)

        }
        
        service.getComments()
        reload(network: service)
        self.commentsTableView.reloadData()

    }

    @IBAction func commentAction(_ sender: Any) {
        let origImage = UIImage(named: "commentFill")
        commentButton.setImage(origImage, for: .normal)
        let origImage2 = UIImage(named: "list")
        listButton.setImage(origImage2, for: .normal)
        self.commentsTableView.reloadData()
        commentsTableView.isHidden = false
        sendButton.isHidden = false
        commentTextField.isHidden = false
        
        
    }
    @IBAction func shareAction(_ sender: Any) {
        //        commentButton.tintColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
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
extension ViewController {
    // Grabs the HTML from nycmetalscene.com for parsing.
    func scrapeNYCMetalScene() -> Void {
        AF.request(url).responseString { [self] response in
            print("\(response)")
            self.heelo()
        }
    }
    func heelo(){
        let myURL = URL(string: self.url)
        
        do {
            let myHTMLString = try String(contentsOf: myURL!, encoding: .ascii)
            if let doc = try? HTML(html: myHTMLString, encoding: .utf8) {
                print(doc.title)
                for link in doc.xpath("//b | //link") {
                    print("here\(link.text)")
                    print(link["href"])
                    if link.text == "Stream is currently down." {
                        playButton.setImage(UIImage(named: "play"), for: .normal)
                        player.pause()
                        
                    }
                }
            }
            
        }catch {
            print(error)
        }
        
    }
}
extension UIViewController {
    class Configuration {

        static func value<T>(defaultValue: T, forKey key: String) -> T{

            let preferences = UserDefaults.standard
            return preferences.object(forKey: key) == nil ? defaultValue : preferences.object(forKey: key) as! T
        }

        static func value(value: Any, forKey key: String){

            UserDefaults.standard.set(value, forKey: key)
        }

    }
}
