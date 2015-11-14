---
layout: post
title: "Bluetooth low energy the fun way"
date: 2015-10-08 18:17:28 +0200
comments: false
author: marcin
categories: 
---

Today Bluetooth Low Energy can be found in many cool applications, it can be used from simple data exchange to payment terminals and the more popular usage with iBeacons. But what if we want to build something funny with it? Like some simple game not even realtime, it may be even turn based game. Imagine you do not need to go through this long setup, waiting for server players to be ready etc.

Everyone knows that building good multiplayer game is hard, multiplayer itself is hard... But here I want to show you my small proof of concept of working bluetooth low enery multiplayer game.
<!--more-->
It can be used in any kind of game! Strategy, board, rpg, race. I built§ a small demo project to show this in details but now let's focus on basics:

Pros:  

1. It's simple!  
2. Works with any device  
3. No need to pair, login etc. Just come near other phone  

Cons:  

1. Bandwith (approx 30bytes of data per packet which todays is nothing)  
2. Limited distance (work well in approx 20m range)  

We have our interface class that will be used to extend functionality on both server and client logic (we use central and peripheral mode of our phone)

```Swift

enum KWSPacketType : Int8 {
    
    case HearBeat
    case Connect
    case Disconnect
    case MoveUp
    case MoveDown
    case Jump
    case Attack
    case DefenseUp
    case DefenseDown
    case Restart
    case GameEnd
}

protocol KWSBlueToothLEDelegate: class {

    func interfaceDidUpdate(interface interface: KWSBluetoothLEInterface, command: KWSPacketType, data: NSData?)
}

class KWSBluetoothLEInterface: NSObject {
    
    weak var delegate : KWSBlueToothLEDelegate?
    weak var ownerViewController : UIViewController?

    var interfaceConnected : Bool = false

    init(ownerController : UIViewController, delegate: KWSBlueToothLEDelegate) {
        
        self.ownerViewController = ownerController
        self.delegate = delegate
        super.init()
    }
    
    func sendCommand(command command: KWSPacketType, data: NSData?) {
        
        self.doesNotRecognizeSelector(Selector(__FUNCTION__))
    }
}


```

As you can see, it's very simple - one send and one receive method as delegate. As both recive and send arguments, we can get the command used in your game to recognize packet type and data which will come along with this command.

Now we need to implement our server and client logic, i don't want to describe in details how to setup BluetoothLE on iPhone so insted I will highlight only important methods like receiving and sending packet on both client and server side.

`KWSBluetoothLEClient`

```Swift
class KWSBluetoothLEClient: KWSBluetoothLEInterface, CBPeripheralManagerDelegate  {
  
 	override func sendCommand(command command: KWSPacketType, data: NSData?) {
    
        if !interfaceConnected {
        
            return
        }
        
        var header : Int8 = command.rawValue
        let dataToSend : NSMutableData = NSMutableData(bytes: &header, length: sizeof(Int8))
        
        if let data = data {
        
            dataToSend.appendData(data)
        }
        
        if dataToSend.length > kKWSMaxPacketSize {
            
            print("Error data packet to long!")
            
            return
        }
        
        self.peripheralManager.updateValue( dataToSend,
                         forCharacteristic: self.readCharacteristic,
                      onSubscribedCentrals: nil)
        
  }

 	func peripheralManager(peripheral: CBPeripheralManager, didReceiveWriteRequests requests: [CBATTRequest]) {
        
        if requests.count == 0 {
            
            return;
        }
        
        for req in requests as [CBATTRequest] {
        
            let data : NSData = req.value!
            let header : NSData = data.subdataWithRange(NSMakeRange(0, sizeof(Int8)))
            
            let remainingVal = data.length - sizeof(Int8)
            
            var body : NSData? = nil
            
            if remainingVal > 0 {
            
                body = data.subdataWithRange(NSMakeRange(sizeof(Int8), remainingVal))
            }
            
            let actionValue : UnsafePointer<Int8> = UnsafePointer<Int8>(header.bytes)
            let action : KWSPacketType = KWSPacketType(rawValue: actionValue.memory)!
            
            self.delegate?.interfaceDidUpdate(interface: self, command: action, data: body)
            
            self.peripheralManager.respondToRequest(req, withResult: CBATTError.Success)
        }
  }
}
```

`KWSBluetoothLEServer`

```Swift
class KWSBluetoothLEServer: KWSBluetoothLEInterface, CBCentralManagerDelegate, CBPeripheralDelegate {

    override func sendCommand(command command: KWSPacketType, data: NSData?){
        
        if !interfaceConnected {
            
            return
        }

        var header : Int8 = command.rawValue
        let dataToSend : NSMutableData = NSMutableData(bytes: &header, length: sizeof(Int8))
        
        if let data = data {
            
            dataToSend.appendData(data)
        }
        
        if dataToSend.length > kKWSMaxPacketSize {
            
            print("Error data packet to long!")
            
            return
        }
        
        if let discoveredPeripheral = self.discoveredPeripheral {
        
            discoveredPeripheral.writeValue( dataToSend,
                          forCharacteristic: self.writeCharacteristic,
                                       type: .WithResponse)
        }
    }
  
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        if let error = error {
            print("didUpdateValueForCharacteristic error: \(error.localizedDescription)")
            return
        }
        
        let data : NSData = characteristic.value!
        let header : NSData = data.subdataWithRange(NSMakeRange(0, sizeof(Int8)))
        
        let remainingVal = data.length - sizeof(Int8)
        var body : NSData? = nil
        
        if remainingVal > 0 {
            
            body = data.subdataWithRange(NSMakeRange(sizeof(Int8), remainingVal))
        }

        let actionValue : UnsafePointer<Int8> = UnsafePointer<Int8>(header.bytes)
        let action : KWSPacketType = KWSPacketType(rawValue: actionValue.memory)!
        
        self.delegate?.interfaceDidUpdate(interface: self, command: action, data: body)
    }
}
```

In both cases sending and reciving is the same:

Sending:  
  
1. Take raw value of the command  
2. Save into NSData  
3. Append using additional data that comes with the command  
4. Send to peripheral/central  

Receive:  
  
1. Take NSData from central / peripheral (update request status if needed)  
2. Get first byte to recognize command type  
3. Take subset of Data by removing 1st byte and store it as value coming along with command   
4. Take value of header byte and cast it to our PacketType  
5. Send it to delegate  

Thanks to that we can build our game logic like this:

Setup:  

```Swift

func setupGameLogic(becomeServer:Bool) {
    
        self.isServer = becomeServer
        
        if self.isServer {
            
            self.communicationInterface = KWSBluetoothLEServer(ownerController: self, delegate: self)
        }
        else {
            
            self.communicationInterface = KWSBluetoothLEClient(ownerController: self, delegate: self)
        }
   
}
```

Sending data to other player:  

```Swift

//player is dead notify other player
self.communicationInterface!.sendCommand(command: .GameEnd, data: nil)

//send some basic data about your player state (life, position)

let currentPlayer = self.gameScene.selectedPlayer
        
    var packet = syncPacket()
        packet.healt = currentPlayer!.healt
        packet.posx = Float16CompressorCompress(Float32(currentPlayer!.position.x))
        
    let packetData = NSData(bytes: &packet, length: sizeof(syncPacket))
    self.communicationInterface!.sendCommand(command: .HearBeat, data: packetData)

//send some other info 

let directionData = NSData(bytes: &currentPlayer!.movingLeft, length: sizeof(Bool))
self.communicationInterface!.sendCommand(command: .MoveDown, data: directionData)

```

Reciving data:

```Swift
func interfaceDidUpdate(interface interface: KWSBluetoothLEInterface, command: KWSPacketType, data: NSData?)
{

	switch( command ) {
  
	case .HearBeat:
	if let data = data {
                
		let subData : NSData = data.subdataWithRange(NSMakeRange(0, sizeof(syncPacket)))
		let packetMemory = UnsafePointer<syncPacket>(subData.bytes)
		let packet = packetMemory.memory
                
		self.gameScene.otherPlayer!.healt = packet.healt
		self.gameScene.otherPlayer!.applyDamage(0)
                
		let decoded = Float16CompressorDecompress(packet.posx)
		let realPos = self.gameScene.otherPlayer!.position
		let position = CGPointMake(CGFloat(decoded), CGFloat(realPos.y))
                
		self.gameScene.otherPlayer!.position = position
	}

	case .Jump:
		self.gameScene.otherPlayer!.playerJump()

	case .Restart:
		self.unlockControls()
            
	case .GameEnd:
		self.lockControls()
        
	}
}
```

And i get some pretty promising results:

{% img center /images/bluetooth_low_energy/multi_btle.gif %}

Game works smoothly, there are no lags in connection and you can play almost instantly! And of course it allows you to integrate mutliplayer in your game in few minutes.

If you are starting your journey with gamedev or iOS and plan to build simple SpriteKit game with some basic multiplayer support it may be worth considering this option.

Demo project used to present the mechanics is available as always on [github](https://github.com/noxytrux/KnightWhoSaidSwift)

Game require at least two iPhone 5 to test and play. To start simply open game, one of the players choose server, other one client mode and bring your phone next to each another. Once you do that you should be notified about successfull connection by tone sound.

