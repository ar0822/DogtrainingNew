//
//  SecoViewController.swift
//  DogTraining
//
//  Created by 長江龍示 on 2015/08/06.
//  Copyright (c) 2015年 rnagae. All rights reserved.
//
// 「いじ」のボタンはテキストカラーを白にした。「いじ」のボタンを使用して接続を維持するのではなく、画面のロックをしないことによつて接続を維持することにした。2020年5月4日

import UIKit
import MultipeerConnectivity
import AVFoundation

class SecoViewController: UIViewController, MCBrowserViewControllerDelegate,
MCSessionDelegate{
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        //
    }
    
    
    
    
    let serviceType = "LCOC-Chat"
    
    var browser : MCBrowserViewController! //接続可能な端末を表示する画面を表示
    var assistant : MCAdvertiserAssistant! //相手からの接続要求で呼び出される
    var session : MCSession! //セッションの確立後、これを使ってデータを送信する。受信はMCSessionDelegateで受け取る
    var peerID: MCPeerID! //自分のデバイス
    
    var player:AVAudioPlayer?
    
    var i = 0
    
    //このスイッチは現在使用してない
    var Sw1 = 0
    
    var timer = Timer()


    
//    @IBOutlet var chatView: UITextView!
//    @IBOutlet var messageField: UITextField!
//    @IBOutlet weak var TextChangOut: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.startTimer()
        
        //スリープ状態にしないようにする2020年5月4日
        UIApplication.shared.isIdleTimerDisabled = true
        
        //自分のデバイス名を取得
        self.peerID = MCPeerID(displayName: UIDevice.current.name)
        self.session = MCSession(peer: peerID)
        self.session.delegate = self
        
        // create the browser viewcontroller with a unique service name
        self.browser = MCBrowserViewController(serviceType:serviceType,
            session:self.session)
        
        self.browser.delegate = self;
        
        self.assistant = MCAdvertiserAssistant(serviceType:serviceType,
            discoveryInfo:nil, session:self.session)
        
        // tell the assistant to start advertising our fabulous chat
        self.assistant.start()
        
//        timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "timer2", userInfo: nil, repeats: true)

        
    }
    
    //スリープ状態を元に戻す処理
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    //音を発生するメソッド
    func play(soundName: String){
        let soundPath = Bundle.main.path(forResource: soundName, ofType: "mp3")
        print(soundName)
       // print(soundPath ?? <#default value#>)
        let url:NSURL? = NSURL.fileURL(withPath: soundPath!) as NSURL
       // print(url)
        player = try? AVAudioPlayer(contentsOf: url! as URL, fileTypeHint:"mp3")
//        player?.numberOfLoops = 0
        player?.prepareToPlay()
        player?.play()
        
        
        
    }
    
    @IBAction func sendChat(sender: UIButton) {
        // Bundle up the text in the message field, and send it off to all
        // connected peers
        
        //ボタンのタグをString型へ変換
        let msgHozon:String = String(sender.tag)
        
        //ここで、メッセージを送信可能なコードへ変換している。allowLossyConversionで、変換できたか確認している。
        //        let msg = self.messageField.text.dataUsingEncoding(NSUTF8StringEncoding,
        //            allowLossyConversion: false)
        
        let msg = msgHozon.data(using: String.Encoding.utf8,
            allowLossyConversion: false)
        
        var error : NSError?
        
        do {
            //送信のときに使用されるメソッド
            try self.session.send(msg!, toPeers: self.session.connectedPeers,
                                  with: MCSessionSendDataMode.unreliable)
        } catch let error1 as NSError {
            error = error1
        }
        
        if error != nil {
            print("Error sending data: \(String(describing: error?.localizedDescription))", terminator: "")
        }
        
        //下の関数を呼び出している
        //        self.updateChat(self.messageField.text, fromPeer: self.peerID)
        self.updateChat(text: msgHozon as NSString, fromPeer: self.peerID)
        
        //送信用に作ったメッセージをクリアする
//        self.messageField.text = ""
    }
    
    
    //この関数は、送信時と受信時に呼び出される
    func updateChat(text : NSString, fromPeer peerID: MCPeerID) {
        // Appends some text to the chat view
        
        // If this peer ID is the local device's peer ID, then show the name
        // as "Me"
//        var name : String
        
        //メッセージを送信した場合、Me　とし、それ以外は相手の端末名にする
//        switch peerID {
//        case self.peerID:
//            name = "Me"
//        default:
//            name = peerID.displayName
//        }
        
        // Add the name to the message and display it
        //ディスプレイに表示する
        //        let message = "\(name): \(text)\n"
        //        self.TextChangOut.text = self.TextChangOut.text + message
        
    }
    
    //Browserボタンがタップされると呼び出される
    @IBAction func showBrowser(sender: UIButton) {
        // Show the browser view controller
        self.present(self.browser, animated: true, completion: nil)
    }
    
    //BrowserのDoneをタップ時に呼び出される
    func browserViewControllerDidFinish(
        _ browserViewController: MCBrowserViewController)  {
            // Called when the browser view controller is dismissed (ie the Done
            // button was tapped)
            
        self.dismiss(animated: true, completion: nil)
            
    }
    
    //Browserボタンでキャンセルをタップ時に呼び出される
    func browserViewControllerWasCancelled(
        _ browserViewController: MCBrowserViewController)  {
            // Called when the browser view controller is cancelled
            
        self.dismiss(animated: true, completion: nil)
    }
    
    //データを受信したときに呼び出されるメソッド
    func session(_ session: MCSession, didReceive data: Data,
        fromPeer peerID: MCPeerID)  {
            // Called when a peer sends an NSData to us
            
            // This needs to run on the main queue
            //dispatch_async(dispatch_get_main_queu) {
        DispatchQueue.main.async {
            let msg = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                
            self.updateChat(text: msg!, fromPeer: peerID)
                
                switch msg! {
                case "1":
                    self.play(soundName: "ban1")
                    print("1")
                case "2":
                    self.play(soundName: "dissonance1")
                    print("2")
                case "3":
                    self.play(soundName: "cleaner_nearly")
                    print("3")
                case "4":
                    self.play(soundName: "shock4")
                    print("4")
                case "5":
                    self.play(soundName: "scream1")
                    print("5")
                case "6":
                    self.play(soundName: "m")
                    print("6")
                default:
                    print(msg!)
                    
                }
                
            }
            
    }
    
    // The following methods do nothing, but the MCSessionDelegate protocol
    // requires that we implement them.
    
    // オブジェクトを送信するメソッド
    func session(_ session: MCSession,
                 didStartReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID, with progress: Progress)  {
            
            // Called when a peer starts sending a file to us
    }
    
    //オブジェクトを送信するメソッド
    func session(session: MCSession,
        didFinishReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        atURL localURL: NSURL, withError error: NSError?)  {
            // Called when a file has finished transferring from another peer
    }
    
    //ストリームとしてデータを受信したときに呼び出されるメソッド
    func session(_ session: MCSession, didReceive stream: InputStream,
        withName streamName: String, fromPeer peerID: MCPeerID)  {
            // Called when a peer establishes a stream with us
    }
    
    //データを送信するときに使用するメソッド
    func session(_ session: MCSession, peer peerID: MCPeerID,
                 didChange state: MCSessionState)  {
            // Called when a connected peer changes state (for example, goes offline)
            
    }
    
//    func startTimer() {
//       let timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "timer", userInfo: nil, repeats: true)
//
//        timer.invalidate()
//    }
    
    @objc func timer2() {
        i+=1
        print("繰り返し処理できてます \(i)回目")
        
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //ボタンのタグをString型へ変換
        let msgHozon:String = String(6)
        
        //ここで、メッセージを送信可能なコードへ変換している。allowLossyConversionで、変換できたか確認している。
        //        let msg = self.messageField.text.dataUsingEncoding(NSUTF8StringEncoding,
        //            allowLossyConversion: false)
        
        let msg = msgHozon.data(using: String.Encoding.utf8,
            allowLossyConversion: false)
        
        var error : NSError?
        
        do {
            //送信のときに使用されるメソッド
            try self.session.send(msg!, toPeers: self.session.connectedPeers,
                                  with: MCSessionSendDataMode.unreliable)
        } catch let error1 as NSError {
            error = error1
        }
        
        if error != nil {
            print("Error sending data: \(String(describing: error?.localizedDescription))", terminator: "")
        }
        
        //下の関数を呼び出している
        //        self.updateChat(self.messageField.text, fromPeer: self.peerID)
        self.updateChat(text: msgHozon as NSString, fromPeer: self.peerID)

        ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    }
    @IBAction func tunagu(sender: UIButton) {
        
        
        
        if timer.isValid == true  {



            timer.invalidate()
            
//            sender.titleLabel?.text = "いじ"
            
            sender.setTitle("いじ", for: UIControl.State.normal)

        } else {

            timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.timer2), userInfo: nil, repeats: true)

//            sender.titleLabel?.text = "やめる"
            
            sender.setTitle("やめる", for: UIControl.State.normal)
            
        }

    }
    
    
    
    //    @IBAction func TextChang(sender: AnyObject) {
    ///
    //                        play("1.mp3")
    //
    //    }
}
