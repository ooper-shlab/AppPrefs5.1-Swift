//
//  RootViewController.swift
//  AppPrefs
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/01.
//
//
/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:

  The main UIViewController containing the app's user interface.
 */

import UIKit

// The value for the 'Text Color' setting is stored as an integer between
// one and three inclusive.  This enumeration provides a mapping between
// the integer value, and color.
enum TextColor: Int {
    case blue = 1
    case red
    case green
}


// It's best practice to define constant strings for each preference's key.
// These constants should be defined in a location that is visible to all
// source files that will be accessing the preferences.
let kFirstNameKey = "firstNameKey"
let kLastNameKey = "lastNameKey"
let kNameColorKey = "nameColorKey"


@objc(RootViewController)
class RootViewController: UITableViewController {
    
    // Values from the app's preferences
    var firstName: String?
    var lastName: String?
    var nameColor: UIColor?
    
    
    //| ----------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Only iOS 8 and above supports the UIApplicationOpenSettingsURLString
        // used to launch the Settings app from your application.  If the
        // UIApplicationOpenSettingsURLString is not present, we're running on an
        // old version of iOS.  Remove the Settings button from the navigation bar
        // since it won't be able to do anything.
        let RTLD_DEFAULT = UnsafeMutablePointer<Void>(bitPattern: -2)
        if dlsym(RTLD_DEFAULT, "UIApplicationOpenSettingsURLString") == nil {
            self.navigationItem.leftBarButtonItem = nil
        }
    }
    
    
    //| ----------------------------------------------------------------------------
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Load our preferences.  Preloading the relevant preferences here will
        // prevent possible diskIO latency from stalling our code in more time
        // critical areas, such as tableView:cellForRowAtIndexPath:, where the
        // values associated with these preferences are actually needed.
        self.onDefaultsChanged(nil)
        
        // Begin listening for changes to our preferences when the Settings app does
        // so, when we are resumed from the backround, this will give us a chance to
        // update our UI
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: #selector(RootViewController.onDefaultsChanged(_:)),
            name: NSUserDefaultsDidChangeNotification,
            object: nil)
    }
    
    
    //| ----------------------------------------------------------------------------
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Stop listening for the NSUserDefaultsDidChangeNotification
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSUserDefaultsDidChangeNotification, object: nil)
    }
    
    
    //| ----------------------------------------------------------------------------
    //! Unwind action for the Done button on the Info screen.
    //
    @IBAction func unwindFromInfoScreen(_: UIStoryboardSegue) {
    }
    
    //MARK: -
    //MARK: Preferences
    
    //| ----------------------------------------------------------------------------
    //! Launches the Settings app.  The Settings app will automatically navigate to
    //! to the settings page for this app.
    //
    @IBAction func openApplicationSettings(_: AnyObject) {
        if #available(iOS 8.0, *) {
            // UIApplicationOpenSettingsURLString is only availiable in iOS 8 and above.
            // The following code will crash if run on a prior version of iOS.  See the
            // check in -viewDidLoad.
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
        } else {
            // Fallback on earlier versions
        }
    }
    
    
    //| ----------------------------------------------------------------------------
    //  Handler for the NSUserDefaultsDidChangeNotification.  Loads the preferences
    //  from the defaults database into the holding properies, then asks the
    //  tableView to reload itself.
    //
    func onDefaultsChanged(aNotification: NSNotification?) {
        let standardDefaults = NSUserDefaults.standardUserDefaults()
        
        self.firstName = standardDefaults.objectForKey(kFirstNameKey) as! String?
        self.lastName = standardDefaults.objectForKey(kLastNameKey) as! String?
        
        // The value for the 'Text Color' setting is stored as an integer between
        // one and three inclusive.  Convert the integer into a UIColor object.
        if let textColor = TextColor(rawValue: standardDefaults.integerForKey(kNameColorKey)) {
            switch textColor {
            case .blue:
                self.nameColor = UIColor.blueColor()
            case .red:
                self.nameColor = UIColor.redColor()
            case .green:
                self.nameColor = UIColor.greenColor()
            }
        } else {
            assert(false, "Got an unexpected value \(standardDefaults.integerForKey(kNameColorKey)) for \(kNameColorKey)")
        }
        
        self.tableView.reloadData()
    }
    
    //MARK: -
    //MARK: UITableViewDataSource
    
    //| ----------------------------------------------------------------------------
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    //| ----------------------------------------------------------------------------
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NameCell")!
        
        cell.textLabel!.text = "\(self.firstName!) \(self.lastName!)"
        cell.textLabel!.textColor = self.nameColor
        
        return cell
    }
    
}