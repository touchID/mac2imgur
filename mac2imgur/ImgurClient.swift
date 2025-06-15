/* This file is part of mac2imgur.
 *
 * mac2imgur is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 
 * mac2imgur is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 
 * You should have received a copy of the GNU General Public License
 * along with mac2imgur.  If not, see <http://www.gnu.org/licenses/>.
 */

import Foundation

class ImgurClient: NSObject {
    
    static let shared = ImgurClient()
    
    var externalWebViewCompletionHandler: (() -> Void)?
    
    // MARK: Defaults keys
    
    let refreshTokenKey = "RefreshToken"
    let imgurAlbumKey = "ImgurAlbum"
    
    // MARK: Imgur tokens
    
    let clientID = "5867856c9027819"
    let clientSecret = "7c2a63097cbb0f10f260291aab497be458388a64"
    
    // MARK: General
    
    var uploadAlbumID: String? {
        get {
            return UserDefaults.standard.string(forKey: imgurAlbumKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: imgurAlbumKey)
        }
    }
    
    /// Prepare ImgurClient for use.
    func setup() {
        if let refreshToken = UserDefaults.standard.string(forKey: refreshTokenKey) {
            configure(asAnonymous: false)
            
//            IMGSession.sharedInstance()
//                .authenticate(withRefreshToken: refreshToken)
        } else {
            configure(asAnonymous: true)
        }
    }
    
    func handle(error: Error?, title: String) {
        
        UserNotificationController.shared.displayNotification(
            withTitle: title,
            informativeText: description(of: error))
        
        if let error = error {
            NSLog("%@: %@", title, error as NSError)
        }
    }
    
    func description(of error: Error?) -> String {

        if let error = error as NSError? {
            
            let localizedDescription = error.userInfo[NSLocalizedDescriptionKey]
            
            if localizedDescription is String {
                
                return error.localizedDescription
                
            } else if let data = localizedDescription as? [String: Any],
                let message = data["message"] as? String {
                
                return message

            }
            
        }
        
        return "An unknown error occurred."
    }
    
    /// Configures the `IMGSession.sharedInstance()`
    /// - parameter anonymous: If the session should be configured for anonymous
    /// API access, or alternatively authenticated.
    func configure(asAnonymous anonymous: Bool) {
    }
    
    func authenticate() {
        configure(asAnonymous: false)
    }
    
    func deauthenticate() {
        // Clear stored refresh token
        UserDefaults.standard.removeObject(forKey: refreshTokenKey)
        UserDefaults.standard.removeObject(forKey: imgurAlbumKey)
        
        configure(asAnonymous: true)
    }
    
    /// Returns a PNG image representation data of the supplied image data,
    /// reduced to non-retina scale
    func downscaleRetinaImageData(_ data: Data) -> Data? {
        return nil
    }
    
    // MARK: Imgur Upload
    
    /// Uploads the image at the specified URL.
    /// - parameter imageURL: The URL to the image to be uploaded
    /// - parameter isScreenshot: Whether the image is a screenshot or not,
    /// affects which preferences will be applied to the upload
    func uploadImage(withURL imageURL: URL, isScreenshot: Bool) {
        
        var imageData: Data
        
        do {
            imageData = try Data(contentsOf: imageURL)
        } catch let error {
            uploadFailureHandler(dataTask: nil, error: error)
            return
        }
        
        let imageName = imageURL.lastPathComponent
        
        uploadImage(withData: imageData,
                    imageTitle: NSString(string: imageName).deletingPathExtension)
    }
    
    /// Uploads the specified image data
    /// - parameter imageData: The image data of which to upload
    /// - parameter imageTitle: The title of the image (defaults to "Untitled")
    func uploadImage(withData imageData: Data, imageTitle: String = "Untitled") {
        
//        IMGImageRequest.uploadImage(with: imageData,
//                                    title: imageTitle,
//                                    description: nil,
//                                    linkToAlbumWithID: uploadAlbumID,
//                                    progress: nil,
//                                    success: uploadSuccessHandler,
//                                    failure: uploadFailureHandler)

    }
    
    func uploadFailureHandler(dataTask: URLSessionDataTask?, error: Error?) {
        handle(error: error, title: "Imgur Upload Failed")
    }
        
    // MARK: External WebView Handler
    
    func handleExternalWebViewEvent(withResponseURL url: URL) {
        guard let query = url.query?.components(separatedBy: "&") else {
            NSLog("Unable to find URL query component: \(url)")
            return
        }
        
        for parameter in query {
            let pair = parameter.components(separatedBy: "=")
            
            if pair.count == 2 && pair[0] == "code" {
//                IMGSession.sharedInstance().authenticate(withCode: pair[1])
                externalWebViewCompletionHandler?()
                externalWebViewCompletionHandler = nil
                return
            }
        }
    }
    
}
