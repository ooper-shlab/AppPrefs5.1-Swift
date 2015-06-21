//
//  AppPrefsAppDelegate.swift
//  AppPrefs
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/11/30.
//
//
/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:

  The application' delegate.  Handles loading and registering the default values
  for each setting from the Settings bundle.
 */

import UIKit

@UIApplicationMain
@objc(AppPrefsAppDelegate)
class AppPrefsAppDelegate : NSObject, UIApplicationDelegate {
    
    var window: UIWindow?
    
    //| ----------------------------------------------------------------------------
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        // The registration domain is volatile.  It does not persist across launches.
        // You must register your defaults at each launch; otherwise you will get
        // (system) default values when accessing the values of preferences the
        // user (via the Settings app) or your app (via set*:forKey:) has not
        // modified.  Registering a set of default values ensures that your app
        // always has a known good set of values to operate on.
        self.populateRegistrationDomain()
        
        return true;
    }
    
    
    //| ----------------------------------------------------------------------------
    //! Locates the file representing the root page of the settings for this app,
    //! invokes loadDefaults:fromSettingsPage:inSettingsBundleAtURL: on it,
    //! and registers the loaded values as the app's defaults.
    //
    func populateRegistrationDomain() {
        let settingsBundleURL = NSBundle.mainBundle().URLForResource("Settings", withExtension: "bundle")!
        
        // Invoke loadDefaultsFromSettingsPage:inSettingsBundleAtURL: on the property
        // list file for the root settings page (always named Root.plist).
        let appDefaults = self.loadDefaultsFromSettingsPage("Root.plist", inSettingsBundleAtURL: settingsBundleURL)!
        
        // appDefaults is now populated with the preferences and their default values.
        // Add these to the registration domain.
        NSUserDefaults.standardUserDefaults().registerDefaults(appDefaults as! [String : AnyObject])
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    
    //| ----------------------------------------------------------------------------
    //! Helper function that parses a Settings page file, extracts each preference
    //! defined within along with its default value.  If the page contains a
    //! 'Child Pane Element', this method will recurs on the referenced page file.
    //
    func loadDefaultsFromSettingsPage(plistName: String, inSettingsBundleAtURL settingsBundleURL: NSURL) -> NSDictionary? {
        // Each page of settings is represented by a property-list file that follows
        // the Settings Application Schema:
        // <https://developer.apple.com/library/ios/#documentation/PreferenceSettings/Conceptual/SettingsApplicationSchemaReference/Introduction/Introduction.html>.
        
        // Create an NSDictionary from the plist file.
        let settingsDict = NSDictionary(contentsOfURL: settingsBundleURL.URLByAppendingPathComponent(plistName))!
        
        // The elements defined in a settings page are contained within an array
        // that is associated with the root-level PreferenceSpecifiers key.
        let prefSpecifierArray = settingsDict["PreferenceSpecifiers"] as! NSArray?
        
        // If prefSpecifierArray is nil, something wen't wrong.  Either the
        // specified plist does ot exist or is malformed.
        if prefSpecifierArray == nil {
            return nil
        }
        
        // Create a dictionary to hold the parsed results.
        let keyValuePairs = NSMutableDictionary()
        
        for prefItem in prefSpecifierArray as! [NSDictionary] {
            // Each element is itself a dictionary.
            // What kind of control is used to represent the preference element in the
            // Settings app.
            let prefItemType = prefItem["Type"] as! String
            // How this preference element maps to the defaults database for the app.
            let prefItemKey = prefItem["Key"] as! String?
            // The default value for the preference key.
            let prefItemDefaultValue = prefItem["DefaultValue"] as! NSObject?    //###
            
            if prefItemType == "PSChildPaneSpecifier" {
                // If this is a 'Child Pane Element'.  That is, a reference to another
                // page.
                // There must be a value associated with the 'File' key in this preference
                // element's dictionary.  Its value is the name of the plist file in the
                // Settings bundle for the referenced page.
                let prefItemFile = prefItem["File"] as! String
                
                // Recurs on the referenced page.
                let childPageKeyValuePairs = self.loadDefaultsFromSettingsPage(prefItemFile, inSettingsBundleAtURL: settingsBundleURL)!
                
                // Add the results to our dictionary
                keyValuePairs.addEntriesFromDictionary(childPageKeyValuePairs as [NSObject : AnyObject])
            } else if prefItemKey != nil && prefItemDefaultValue != nil {
                // Some elements, such as 'Group' or 'Text Field' elements do not contain
                // a key and default value.  Skip those.
                keyValuePairs[prefItemKey!] = prefItemDefaultValue
            }
        }
        
        return keyValuePairs
    }
    
}