//
//  ViewController.swift
//  Multipeer Connectivity
//
//  Created by Lindberg, Paul on 3/12/20.
//  Copyright © 2020 Lindberg, Paul. All rights reserved.
//

//Adapted from https://www.hackingwithswift.com/example-code/networking/how-to-create-a-peer-to-peer-network-using-the-multipeer-connectivity-framework

import UIKit
import MultipeerConnectivity

var peerID: MCPeerID!
var mcSession: MCSession!
var mcAdvertiserAssistant: MCAdvertiserAssistant!

class ViewController: UIViewController, MCSessionDelegate, MCBrowserViewControllerDelegate {
    @IBOutlet weak var imageOutlet: UIImageView!
    @IBAction func sendCow(_ sender: Any) {
        sendImage(img: #imageLiteral(resourceName: "cow.jpeg"))
    }
    @IBAction func sendPiano(_ sender: Any) {
        sendImage(img: #imageLiteral(resourceName: "piano.jpg"))
    }
    @IBAction func sendKey(_ sender: Any) {
        sendImage(img: #imageLiteral(resourceName: "key.png"))
    }
    
    @IBOutlet weak var labelStatus: UILabel!
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        var sStatus = "Fatal Error"
        switch state {
        case MCSessionState.connected:
            sStatus = "Connected: \(peerID.displayName)"
        
        case MCSessionState.connecting:
            sStatus = "Connecting: \(peerID.displayName)"
            
        case MCSessionState.notConnected:
            sStatus = "Not Connected: \(peerID.displayName)"
        
        @unknown default:
            print("Fatal Error")
        }
        print(sStatus)
        labelStatus.text = sStatus
    }
    //send image
    func sendImage(img: UIImage) {
        if mcSession.connectedPeers.count > 0 {
            if let imageData = img.pngData() {
                do {
                    try mcSession.send(imageData, toPeers: mcSession.connectedPeers, with: .reliable)
                } catch let error as NSError {
                    let ac = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    present(ac, animated: true)
                }
            }
        }
    }
    
    //receive image
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let image = UIImage(data: data) {
            DispatchQueue.main.async { [unowned self] in
                // do something with the image
                self.imageOutlet.image = image
            }
        }
    }
    
    func startHosting(action: UIAlertAction!) {
        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "hws-kb", discoveryInfo: nil, session: mcSession)
        mcAdvertiserAssistant.start()
    }
    
    func joinSession(action: UIAlertAction!) {
        let mcBrowser = MCBrowserViewController(serviceType: "hws-kb", session: mcSession)
        mcBrowser.delegate = self
        present(mcBrowser, animated: true)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("not used")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("not used")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        print("not used")
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        peerID = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
//
//        imageOutlet.image = #imageLiteral(resourceName: "No_Picture.jpg")
        
        //no idea how to make these work at the moment
        startHosting(action: UIAlertAction(title: "Host", style: .default))
        joinSession(action: UIAlertAction(title: "Join", style: .default))
    }

}



