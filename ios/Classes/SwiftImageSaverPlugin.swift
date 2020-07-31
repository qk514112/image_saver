import Flutter
import UIKit
import Photos

enum MediaType: Int {
    case image
    case video
}

public class SwiftImageSaverPlugin: NSObject, FlutterPlugin {
    let path = "path"
    let albumName = "albumName"

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "image_saver", binaryMessenger: registrar.messenger())
        let instance = SwiftImageSaverPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "saveImage" {
            self.saveMedia(call, .image, result)
        } else if call.method == "saveVideo" {
            self.saveMedia(call, .video, result)
        } else if call.method == "getPlatformVersion" {
            result("iOS " + UIDevice.current.systemVersion)
        } else {
            result(FlutterMethodNotImplemented)
        }
    }

    func saveMedia(_ call: FlutterMethodCall, _ mediaType: MediaType, _ result: @escaping FlutterResult) {
        let args = call.arguments as? Dictionary<String, Any>
        let path = args![self.path] as! String
        let albumName = args![self.albumName] as? String
        let status = PHPhotoLibrary.authorizationStatus()

        if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized {
                    self._saveMediaToAlbum(path, mediaType, albumName, result)
                } else {
                    result(false);
                }
            })
        } else if status == .authorized {
            self._saveMediaToAlbum(path, mediaType, albumName, result)
        } else {
            // 被拒绝的情况？
            result(false);
        }
    }

    private func _saveMediaToAlbum(_ imagePath: String, _ mediaType: MediaType, _ albumName: String?,
                                   _ flutterResult: @escaping FlutterResult) {
        if(nil == albumName) {
            self.saveFile(imagePath, mediaType, nil, flutterResult)
        } else if let album = fetchAssetCollectionForAlbum(albumName!) {
            self.saveFile(imagePath, mediaType, album, flutterResult)
        } else {
            // create photos album
            createAppPhotosAlbum(albumName: albumName!) { (error) in
                // 确保 error 为空
                guard error == nil else {
                    // 不为空则返回失败
                    flutterResult(false)
                    return
                }

                if let album = self.fetchAssetCollectionForAlbum(albumName!) {
                    self.saveFile(imagePath, mediaType, album, flutterResult)
                } else {
                    flutterResult(false)
                }
            }
        }
    }

    private func saveFile(_ filePath: String, _ mediaType: MediaType, _ album: PHAssetCollection?,
    _ flutterResult: @escaping FlutterResult) {
        let url = URL(fileURLWithPath: filePath)
        PHPhotoLibrary.shared().performChanges({
            let assetCreationRequest = mediaType == .image ?
                PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: url)
                : PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url);
            if (album != nil) {
                guard let assetCollectionChangeRequest = PHAssetCollectionChangeRequest(for: album!),
                    let createdAssetPlaceholder = assetCreationRequest?.placeholderForCreatedAsset else {
                        // assetCollectionChangeRequest 为空则直接返回
                        // TODO: 没有异常处理
                            return
                    }
                assetCollectionChangeRequest.addAssets(NSArray(array: [createdAssetPlaceholder]))
            } else {
                // TODO: album 为空怎么处理
            }
        }) { (success, error) in
            if success {
                flutterResult(true)
            } else {
                flutterResult(false)
            }
        }
    }

    private func fetchAssetCollectionForAlbum(_ albumName: String) -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)

        if let _: AnyObject = collection.firstObject {
            return collection.firstObject
        }
        return nil
    }

    private func createAppPhotosAlbum(albumName: String, completion: @escaping (Error?) -> ()) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
        }) { (_, error) in
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
}
