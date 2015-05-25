//
//  EPPZUserSettings.h
//  eppz!tools
//
//  Created by Borbás Geri on 7/11/13.
//  Copyright (c) 2013 eppz! development, LLC.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>


#define EPPZ_USER_SETTINGS_LOGGING YES
#define USLog if (EPPZ_USER_SETTINGS_LOGGING) NSLog



@class EPPZUserSettings;
@protocol EPPZUserSettingsDelegate <NSObject>

/*! 
 
 Called when settings did change due to an iCloud sync event.
 
 @param settings Settings object that changed remotely.

 */
-(void)settingsDidChangeRemotely:(EPPZUserSettings*) settings;

/*!
 
 Called when writing changes to iCloud is failed (probably quota exceeded).

 @param settings Settings object that should be changed.
 
 */
-(void)settingsSyncDidFail:(EPPZUserSettings*) settings;

@end


typedef enum
{
    EPPZUserSettingsModeUserDefaults,
    EPPZUserSettingsModeiCloud
} EPPZUserSettingsMode;


/*!
 
 Handy class to encapsulate saving / archiving of object properties, typical
 use case is to handle user settings. Gets stored to @p NSUserDefaults also
 gets synced to iCloud key-value store.
 
 */
@interface EPPZUserSettings : NSObject

+(NSArray*)persistablePropertyNames; // Subclass template [Optional]
-(BOOL)shouldMergeRemoteValue:(id) value forKey:(NSString*) key; // Subclass template [Optional]

/*!
 
 Designated factory method.
 
 @param delegate Delegate to call back with iCloud results.
 
 */
+(instancetype)settingsWithMode:(EPPZUserSettingsMode) mode
                       delegate:(id<EPPZUserSettingsDelegate>) delegate;

/*!
 
 Returns true when iCloud Drive is enabled for the given app in device settings.
 
 */
@property (nonatomic, readonly) BOOL isSyncingEnabled;


@end
