//
//  ViewController.swift
//  ios-client-sample
//
//  Created 田中 厳貴 on 8/5/19.
//  Copyright © 2019 田中 厳貴. All rights reserved.
//

import UIKit
import SocketIO
import Starscream

class ViewController: UIViewController {
    
    var manager: SocketManager?
    var socket: WebSocket!
    
    var connectType: ConnectType = .default
    enum ConnectType {
        case `default`
        case socketIO
        case starScream
    }
    
    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.layer.cornerRadius = 4.0
            textView.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var connectSocketIOButton: UIButton!
    @IBOutlet weak var connectStarscreamButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSocketIO()
        setupStarscream()
    }
    
    
    func setupSocketIO() {
        manager = SocketManager(socketURL: URL(string: "http://localhost:8080")!, config: [.log(true), .compress, .reconnectAttempts(0)])
        let socket = manager?.defaultSocket
        socket?.on(clientEvent: .connect) { [weak self] data, ack in
            guard let self = self else { return }
            self.textView.text = self.textView.text + "---socket.io connected---\n"
            self.connectType = .socketIO
        }
        
        socket?.on(clientEvent: .disconnect) { [weak self] _, _ in
            guard let self = self else { return }
            self.textView.text = self.textView.text + "---socket.io disconnected---\n"
            self.connectType = .default
        }
        
        socket?.on("reply", callback: { [weak self] (data, ack) in
            guard let self = self else { return }
            guard let text = data[0] as? String else {
                self.textView.text = self.textView.text + "parse error\n"
                return
            }
            self.textView.text = self.textView.text + "Received:\(text)\n"
        })
    }
    
    func setupStarscream() {
        var request = URLRequest(url: URL(string: "http://localhost:8080/echo")!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
    }
    
    @IBAction func tapConnectSocketIO(_ sender: Any) {
        if manager?.defaultSocket.status == .connected {
            manager?.defaultSocket.disconnect()
            connectSocketIOButton.setTitle("connect SocketIO", for: .normal)
        } else {
            manager?.defaultSocket.connect()
            connectSocketIOButton.setTitle("disconnect SocketIO", for: .normal)
        }
    }
    
    @IBAction func tapConnectStarscream(_ sender: Any) {
        if socket.isConnected {
            socket.disconnect()
            connectStarscreamButton.setTitle("connect Starscream", for: .normal)
        } else {
            socket.connect()
            connectStarscreamButton.setTitle("disconnect Starscream", for: .normal)
        }
    }
    
    @IBAction func tapSendButton(_ sender: Any) {
        switch connectType {
        case .default:
            self.textView.text = self.textView.text + "not connected.\n"
        case .socketIO:
            manager?.defaultSocket.emit("notice", "push!")
        case .starScream:
            socket.write(string: "Please Data")
        }
    }
}

extension ViewController: WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
        self.textView.text = self.textView.text + "---starscream is connected---\n"
        connectType = .starScream
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        if let e = error as? WSError {
            self.textView.text = self.textView.text + "---starscreamt is disconnected: \(e.message)---\n"
        } else if let e = error {
            self.textView.text = self.textView.text + "---starscream is disconnected: \(e.localizedDescription)---\n"
        } else {
            self.textView.text = self.textView.text + "---starscream disconnected---\n"
        }
        connectType = .default
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        self.textView.text = self.textView.text + "Received text: \(text)\n"
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        guard let user = try? Example_User(serializedData: data) else {
            self.textView.text = self.textView.text + "Received data couldn't parsed"
            return
        }
        self.textView.text = self.textView.text + "Received data: \(user)\n"
    }
}
