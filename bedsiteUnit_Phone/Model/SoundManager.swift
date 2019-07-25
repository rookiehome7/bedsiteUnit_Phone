//
//  SoundManager.swift
//  bedsiteUnit_Phone
//
//  Created by Takdanai Jirawanichkul on 24/7/2562 BE.
//

import Foundation
import FilesProvider

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

class SoundManager: FileProviderDelegate
{
    
    var defaultSoundFilename = "defaultSound.m4a"
    var recordingSoundFilename = "recording.m4a"
    var waitingSoundFilename = "waitingsound.m4a"
    
    let documentsProvider = LocalFileProvider()
    
    init(){
        documentsProvider.delegate = self as FileProviderDelegate
    }

    func getDefaultSoundURL() -> URL {
        //Another way
        //let audioURL = Bundle.main.url(forResource: "toy-mono", withExtension: "wav")
        // To get String
        //let stringPath = Bundle.main.path(forResource: "toy-mono", ofType: "wav")
        let url = Bundle.main.url(forResource: "defaultSound", withExtension: "m4a")!
        return url
    }
    
    func getDefaultSoundPath() -> String {
        let path = URL(fileURLWithPath: Bundle.main.bundlePath).appendingPathComponent("defaultSound.m4a").absoluteString
        return path
    }
    
//    func getRecordSoundPath() -> String {
//        let path = URL(fileURLWithPath: Bundle.main.bundlePath).appendingPathComponent("recording.m4a").absoluteString
//        return path
//    }
    
    func getWaitngSoundName() -> String {
        let name = "waitingSoundFilename"
        return name
    }
    
    func copySound_Record_to_Waiting() {
        //documentsProvider.delegate = self as FileProviderDelegate
        documentsProvider.removeItem(path: waitingSoundFilename, completionHandler: nil)
        documentsProvider.copyItem(path: recordingSoundFilename ,to: waitingSoundFilename ,overwrite: true, completionHandler: nil)
    }
    
    func copySound_Default_to_Waiting() {
        //documentsProvider.delegate = self as FileProviderDelegate
        let defaultSoundPath = URL(fileURLWithPath: Bundle.main.bundlePath).appendingPathComponent(defaultSoundFilename).absoluteString
        documentsProvider.removeItem(path: waitingSoundFilename, completionHandler: nil)
        documentsProvider.copyItem(path: defaultSoundPath ,to: waitingSoundFilename ,overwrite: true, completionHandler: nil)
    }
    
    func fileproviderSucceed(_ fileProvider: FileProviderOperations, operation: FileOperationType) {
        switch operation {
        case .copy(source: let source, destination: let dest):
            print("\(source) copied to \(dest).")
        case .remove(path: let path):
            print("\(path) has been deleted.")
        default:
            do {
                print("\(operation.actionDescription) from \(operation.source) to \(String(describing: operation.destination)) succeed")
            }
        }
    }
    
    func fileproviderFailed(_ fileProvider: FileProviderOperations, operation: FileOperationType, error: Error) {
        switch operation {
        case .copy(source: let source):
            print("copy of \(source) failed.")
        case .remove:
            print("file can't be deleted.")
        default:
            print("\(operation.actionDescription) from \(operation.source) to \(String(describing: operation.destination)) failed")
        }
    }
    
    func fileproviderProgress(_ fileProvider: FileProviderOperations, operation: FileOperationType, progress: Float) {
        switch operation {
        case .copy(source: let source, destination: let dest):
            print("Copy\(source) to \(dest): \(progress * 100) completed.")
        default:
            break
        }
    }
    
    
    
}
