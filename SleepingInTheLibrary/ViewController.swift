//
//  ViewController.swift
//  SleepingInTheLibrary
//
//  Created by Jarrod Parkes on 11/3/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

import UIKit

// MARK: - ViewController: UIViewController

class ViewController: UIViewController {

    // MARK: Outlets
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoTitleLabel: UILabel!
    @IBOutlet weak var grabImageButton: UIButton!
    
    // MARK: Actions
    
    @IBAction func grabNewImage(sender: AnyObject) {
        setUIEnabled(false)
        getImageFromFlickr()
    }
    
    
    let methodParameters = [
        Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.GalleryPhotosMethod,
        Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
        Constants.FlickrParameterKeys.GalleryID: Constants.FlickrParameterValues.GalleryID,
        Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
        Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
        Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
    ]
    
    // MARK: Configure UI
    
    private func setUIEnabled(enabled: Bool) {
        photoTitleLabel.enabled = enabled
        grabImageButton.enabled = enabled
        
        if enabled {
            grabImageButton.alpha = 1.0
        } else {
            grabImageButton.alpha = 0.5
        }
    }
    
    // MARK: Make Network Request
    
    private func getImageFromFlickr() {
        
    
        let URLString = Constants.Flickr.APIBaseURL +
            escapedParameters(methodParameters)
        
        let url = NSURL(string: URLString)!
        
        // Creating a request from a NSURLRequest so we have access to the different request methods. Default is "GET"
        let request = NSURLRequest(URL: url)
        
        // request.HTTPMethod = "GET"
        
        // Create a task
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, reponse, error) in
            
            if error == nil {
                // data is now raw data JSON
                // To get the data out of its optional form to usable Foundation object such as NSDictionary
                // GUARD: Was there any data returned?
                guard let data = data else {
                    
                    print("No data was returned by the request!")
                    return
                }
                    let parsedResult: AnyObject!
                    
                    do {
                    // Serialize means converting object to streams of bytes
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                    } catch {
                        print("Coult not parse the data as JSON: '\(data)'")
                        return
                    }
                    
                    // Get data from the JSON
                    // First initialize a dictionary that has key as string and object as value
                    // Serializing JSON: 
                    // 1. Get the photos dictionary at the "photos" key
                    // 2. in the photos dictionary, get the array of photo dictionaries at the "photo" key 
                    // 3. print the first photo dictionary
                    if let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String: AnyObject], photoArray = photosDictionary["photo"] as? [[String:AnyObject]] {
                            // print(photoArray[0])
                        // Generate a random photo index. Return from 0 to the number specified.
                        let randomPhotoIndex = Int(arc4random_uniform(UInt32(photoArray.count)))
                        
                        let photoDictionary = photoArray[randomPhotoIndex] as [String: AnyObject]
                        
                        if let imageURLString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String,
                            let photoTitle = photoDictionary[Constants.FlickrResponseKeys.Title] as? String {
                            print(imageURLString)
                            print(photoTitle)
                            
                            // Make the string into a NSURL object
                            let imageURL = NSURL(string: imageURLString)
                            // Use the imageURL to make an ImageData
                            if let imageData = NSData(contentsOfURL: imageURL!) {
                                // Make sure to update the UI on main
                                performUIUpdatesOnMain() {
        
                                // Now set the Image view to imageData and set title to Label
                                self.photoImageView.image = UIImage(data: imageData)
                                self.photoTitleLabel.text = photoTitle
                                // re-enable UI if we want to grab another image
                                self.setUIEnabled(true)
                                }
                            }
                        
                        }
                    }
                }
            }
        

        // Start the task
        task.resume()
    }
    
    
    // A function that takes in a dictionary, the key being a string, the value being any object. 
    // Returns a string
    private func escapedParameters(parameters: [String: AnyObject]) -> String {
        // Check to see if parameters is provided. If not, return an empty string
        if parameters.isEmpty {
            return ""
        }
        else {
            // Initialize a String array to store the key, value pairs.
            var keyValuePairs = [String]()
            
            for (key, value) in parameters {
                // Convert the value into a string
                let stringValue = "\(value)"
                
                // escape it
                // Convert the string into an ASCII compliant of a string (adding percent if needed) - Return characters only considered safe ASCII string
                let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
                
                // append it
                keyValuePairs.append(key + "=" + "\(escapedValue!)")
            }
            // Join the strings in the arround to one string with "&" as separator
            return "?\(keyValuePairs.joinWithSeparator("&"))"
        }
    }
}