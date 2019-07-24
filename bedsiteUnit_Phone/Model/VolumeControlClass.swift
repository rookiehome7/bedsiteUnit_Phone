//
//  VolumeControlClass.swift
//  bedsiteUnit_Phone
//
//  Created by Takdanai Jirawanichkul on 23/7/2562 BE.
//  Copyright © 2562 WiAdvance. All rights reserved.
//

import Foundation
import MediaPlayer

class VolumeControl
{
    static let sharedInstance : VolumeControl = VolumeControl()
    private var sliderView : UISlider!
    private var volumeView : MPVolumeView
    
    private init()
    {
        let controller = UIApplication.shared.delegate?.window!?.rootViewController
        
        let wrapper = UIView(frame: CGRect(x: 30,y: 200,width: 260,height: 20))
        wrapper.backgroundColor = .clear
        controller!.view.addSubview(wrapper)
        
        volumeView = MPVolumeView(frame: wrapper.bounds)
        volumeView.isHidden = true
        for subview in volumeView.subviews
        {
            if let slider = subview as? UISlider {
                sliderView = slider
            }
        }
        wrapper.addSubview(volumeView)
        if (sliderView == nil)
        {
            NSLog("Error: Error setting up Volume Controller")
        }
    }
    
    func setVolume(volume : Float)
    {
        if(sliderView != nil)
        {
            sliderView.setValue(volume, animated: false)
        }
    }
    
    func turnUp()
    {
        if(sliderView != nil)
        {
            sliderView.setValue(sliderView.value+0.0625, animated: false)
        }
    }
    
    func turnDown()
    {
        if(sliderView != nil)
        {
            sliderView.setValue(sliderView.value-0.0625, animated: false)
        }
    }
    
    func getCurrentVolume() -> Float
    {
        if(sliderView != nil)
        {
            return sliderView.value
        } else
        {
            return 0.0
        }
    }
}
