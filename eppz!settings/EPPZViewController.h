//
//  EPPZViewController.h
//  eppz!settings
//
//  Created by Gardrobe on 7/11/13.
//  Copyright (c) 2013 eppz!. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EPPZSettings.h"
#import "EPPZTapCounts.h"
#import "NSObject+EPPZKeyMap.h"


@interface EPPZViewController : UIViewController

    <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *nameTextField;
@property (nonatomic, weak) IBOutlet UISwitch *soundSwitch;
@property (nonatomic, weak) IBOutlet UISlider *volumeSlider;
@property (nonatomic, weak) IBOutlet UISwitch *pushNotifications;
@property (nonatomic, weak) IBOutlet UISwitch *iCloudSwitch;
@property (nonatomic, weak) IBOutlet UITextField *lifeTimeTapCountTextField;
@property (nonatomic, weak) IBOutlet UITextField *tapCountTextField;
-(IBAction)anyControlChanged:(id) sender;
-(IBAction)tap;

@end
