# BesiteUnit_PhoneCall

This IOS application using SIP Protocol and MQTT Message to receive calling command

Setting file
 
Installation 

## View Controller
->ViewController.swift  ( Main View )
-> OutgoingCallViewController.swift
    - When call to another device this view controller will appear and disappear when call end.
-> ReceiveCallViewController.swift
    - When another device call to this device this view controller will appear and disappear when call end.
-> SettingViewController.swift
    - SIP Phone / MQTT Server Setting  and save data by using userdefault
           
## Swift Program
-> LinphoneManager.swift
    Linphone manager class / Configure file / Registration,Call State callback function
        
-> LinphoneUtil.swift
    Function to make username from address
    
-> ApplicationStatus.swift
    Enum of SipRegistrationStatus 
    
-> LocalUserData.swift
    This swift class have function to get & set userdata file from app storage. 
    



## Programming Language
Swift: A general-purpose, multi-paradigm, compiled programming language developed by Apple Inc. 
Library 
liblinphone: A high-level library integrating all SIP calls and instant messaging features into a single easy-to-use API.
Cocoa MQTT : A MQTT client library for iOS/macOS/tvOS


## Documentation : 



How to build linphone to your project
http://blog.codylab.com/ios-build-linphone-iphone-sdk/

Cocoa MQTT Documentation:
https://github.com/emqx/CocoaMQTT

USERDEFAULT Documentation:
https://medium.com/@nimjea/userdefaults-in-swift-4-d1a278a0ec79

