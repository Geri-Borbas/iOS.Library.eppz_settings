//
//  EPPZSettings.h
//  eppz!settings
//
//  Created by Gardrobe on 7/11/13.
//  Copyright (c) 2013 eppz!. All rights reserved.
//

#import "EPPZUserDefaults.h"

@interface EPPZSettings : EPPZUserDefaults

@property (nonatomic, strong) NSString *name;
@property (nonatomic) BOOL sound;
@property (nonatomic) float volume;
@property (nonatomic) BOOL pushNotifications;
@property (nonatomic) BOOL iCloud;

@end
