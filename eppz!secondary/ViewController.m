//
//  ViewController.m
//  eppz!secondary
//
//  Created by eppz! production on 24/05/15.
//  Copyright (c) 2015 eppz!. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@property (nonatomic, weak) NSUbiquitousKeyValueStore *keyValueStore;

@end


@implementation ViewController


#pragma mark - Observe iCloud

-(void)observeKeyValueStore
{
    self.keyValueStore = [NSUbiquitousKeyValueStore defaultStore];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyValueStoreDidChange:)
                                                 name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification
                                               object:[NSUbiquitousKeyValueStore defaultStore]];
}

-(void)keyValueStoreDidChange:(NSNotification*) notification
{
    NSArray *changedKeys = [[notification userInfo] objectForKey:NSUbiquitousKeyValueStoreChangedKeysKey];
    for (NSString *eachChangedKey in changedKeys)
    {
        id eachValue = [self.keyValueStore objectForKey:eachChangedKey];
        NSLog(@"%@: %@", eachChangedKey, eachValue);
    }
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    [self observeKeyValueStore];
}

-(IBAction)syncTouchedUp:(id) sender
{
    [self.keyValueStore synchronize]; // Kick off iCloud sync
}


@end
