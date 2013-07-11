//
//  EPPZViewController.m
//  eppz!settings
//
//  Created by Gardrobe on 7/11/13.
//  Copyright (c) 2013 eppz!. All rights reserved.
//

#import "EPPZViewController.h"

@interface EPPZViewController ()

@property (nonatomic, strong) EPPZSettings *settings;
@property (nonatomic, strong) EPPZTapCounts *tapCounts;

@property (nonatomic, readonly) NSDictionary *keyMap;

@end


@implementation EPPZViewController


#pragma mark - Launch

-(void)viewDidLoad
{
    [super viewDidLoad];

    self.settings = [EPPZSettings new];
    self.tapCounts = [EPPZTapCounts new];
    
    [self populateUI];
}


#pragma mark - Interactions (Settings)

-(IBAction)anyControlChanged:(id) sender
{ [self populateModel]; }

-(BOOL)textFieldShouldReturn:(UITextField*) textField
{ [textField resignFirstResponder]; return YES; }


#pragma mark - Interactions (Tap counts)

-(IBAction)tap
{
    //Manipulate models (invoking setters).
    self.tapCounts.lifeTimeTapCount = self.tapCounts.lifeTimeTapCount + 1;
    self.tapCounts.tapCount = self.tapCounts.tapCount + 1;
    
    [self populateUI];
}



#pragma mark - Map model to UI

-(NSDictionary*)keyMap
{
    return @{
             @"settings.name" : @"nameTextField.text",
             @"settings.sound" : @"soundSwitch.on",
             @"settings.volume" : @"volumeSlider.value",
             @"settings.pushNotifications" : @"pushNotifications.on",
             @"settings.iCloud" : @"iCloudSwitch.on",
             @"tapCounts.lifeTimeTapCount" : @"lifeTimeTapCountTextField.text",
             @"tapCounts.tapCount" : @"tapCountTextField.text"
             };
}

-(void)populateUI
{ [self applyKeyMap:self.keyMap]; }

-(void)populateModel
{ [self applyKeyMapToLeft:self.keyMap]; }


@end
