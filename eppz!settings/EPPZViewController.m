//
//  EPPZViewController.m
//  eppz!tools
//
//  Created by Borbás Geri on 7/11/13.
//  Copyright (c) 2013 eppz! development, LLC.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "EPPZViewController.h"


@interface EPPZViewController ()
@property (nonatomic, strong) EPPZSettings *settings;
@end


@implementation EPPZViewController


#pragma mark - Launch

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.settings = [EPPZSettings settingsWithMode:EPPZUserSettingsModeiCloud
                                          delegate:self];
    [self populateUI];
}


#pragma mark - Interactions

-(IBAction)anyControlChanged:(id) sender
{ [self populateModel]; }

-(BOOL)textFieldShouldReturn:(UITextField*) textField
{ [textField resignFirstResponder]; return YES; }


#pragma mark - iCloud

-(void)settingsDidChangeRemotely:(EPPZSettings*) settings
{
    NSLog(@"%@.settingsDidChangeRemotely:", NSStringFromClass(self.class));
    [self populateUI];
}

-(void)settingsSyncDidFail:(EPPZSettings*) settings
{ /* May indicate some "Not synced" message */ }


#pragma mark - Map model to UI

-(void)populateUI
{
    NSLog(@"%@.populateUI", NSStringFromClass(self.class));

    self.nameTextField.text = self.settings.name;
    [self.soundSwitch setOn:self.settings.sound animated:YES];
    [self.volumeSlider setValue:self.settings.volume animated:YES];
    [self.unlockedSwitch setOn:self.settings.unlocked animated:YES];
    self.syncedLabel.text = (self.settings.isSyncingEnabled) ? @"synced" : @"not synced, enable app in device iCloud settings";
}

-(void)populateModel
{
    NSLog(@"%@.populateModel", NSStringFromClass(self.class));
    
    self.settings.name = self.nameTextField.text;
    self.settings.sound = self.soundSwitch.isOn;
    self.settings.volume = self.volumeSlider.value;
    self.settings.unlocked = self.unlockedSwitch.isOn;
}


@end
