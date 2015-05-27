//
//  EPPZUserSettings.m
//  eppz!tools
//
//  Created by Borbás Geri on 7/11/13.
//  Copyright (c) 2013 eppz! development, LLC.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "EPPZUserSettings.h"


#define NULL_VALUE @"<null>"


@interface EPPZUserSettings ()

@property (nonatomic, weak) NSUserDefaults *userDefaults;
@property (nonatomic, weak) NSUbiquitousKeyValueStore *keyValueStore;
@property (nonatomic) EPPZUserSettingsMode mode;
@property (nonatomic, strong) NSDictionary *defaults;

@property (nonatomic, strong, readonly) NSArray *propertyNames;
@property (nonatomic, strong) NSMutableDictionary *dictionaryRepresentation;
@property (nonatomic) BOOL suspendPropertyObserving;
@property (nonatomic) BOOL saveOnEveryChange;

@property (nonatomic) BOOL iCloud;
@property (nonatomic, assign) id<EPPZUserSettingsDelegate> delegate;

@end


@implementation EPPZUserSettings


#pragma mark - Creation

+(instancetype)settingsWithMode:(EPPZUserSettingsMode) mode
                       delegate:(id<EPPZUserSettingsDelegate>) delegate;
{
    return [[self alloc] initWithMode:mode delegate:delegate];
}

-(instancetype)initWithMode:(EPPZUserSettingsMode) mode
                   delegate:(id<EPPZUserSettingsDelegate>) delegate
{
    if (self = [super init])
    {
        // Properties.
        self.iCloud = (mode == EPPZUserSettingsModeiCloud);
        self.delegate = delegate;
        
        // Shortcuts.
        self.userDefaults = [NSUserDefaults standardUserDefaults];
        self.keyValueStore = [NSUbiquitousKeyValueStore defaultStore];
        
        // Create dictionarial representation in memory.
        [self allocateDictionaryRepresentation];
        
        NSDictionary *storedDictionaryRepresentation;
        if (self.iCloud)
        {
            [self observeKeyValueStore];
            [self.keyValueStore synchronize]; // Kick off iCloud sync (changes get called back on `keyValueStoreDidChange:`)
            
            // Representation.
            storedDictionaryRepresentation = [self.keyValueStore objectForKey:self.key];
            if (storedDictionaryRepresentation == nil)
            {
                // Get populated from defaults if no stored state.
                storedDictionaryRepresentation = self.defaults;
            }
        }
        else
        {
            // Register defaults.
            NSDictionary *defaults = (self.defaults != nil) ? @{ self.key : self.defaults } : nil;
            [self.userDefaults registerDefaults:defaults];
            
            // Representation.
            storedDictionaryRepresentation = [self.userDefaults objectForKey:self.key];
        }
        
        // Populate.
        USLog(@"storedDictionaryRepresentation: %@", storedDictionaryRepresentation);
        [self populateFromDictionary:storedDictionaryRepresentation];
        
        // Turn on saving.
        [self observePersistableProperties];
        self.saveOnEveryChange = YES;
        
        // Application observers.
        [self observeApplicationStates];
    }
    return self;
}

-(void)dealloc
{
    // Tear down observers.
    [self finishObservingPersistableProperties];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Dictionary representation

+(NSString*)key
{ return NSStringFromClass(self); }

-(NSString*)key
{ return self.class.key; }

-(void)allocateDictionaryRepresentation
{
    [self changeWithoutObservation:^
    {
        self.dictionaryRepresentation = [NSMutableDictionary new];
        for (NSString *eachPropertyName in [self.class persistablePropertyNames])
        { [self setDictionaryRepresentationValue:nil forKey:eachPropertyName]; }
    }];
}

-(NSDictionary*)defaults
{
    if (_defaults == nil)
    {
        NSString *defaultsPlistPath = [[NSBundle mainBundle] pathForResource:self.key ofType:@"plist"];
        _defaults = [NSDictionary dictionaryWithContentsOfFile:defaultsPlistPath];
    }
    return _defaults;
}

-(void)populateFromDictionary:(NSDictionary*) dictionaryRepresentation
{
    [self changeWithoutObservation:^
    {
        // Check if everything is merged as in dictionary.
        BOOL changed = NO;
        
        for (NSString *eachPropertyName in dictionaryRepresentation.allKeys)
        {
            id value = [dictionaryRepresentation valueForKey:eachPropertyName];
            if ([value isKindOfClass:[NSString class]] && [(NSString*)value isEqualToString:NULL_VALUE])
            { value = nil; } // Reconstruct `nil` values
            
            @try // Safely
            {
                BOOL shouldSet = [self shouldMergeRemoteValue:value forKey:eachPropertyName]; // Ask class if any override
                if (shouldSet)
                {
                    [self setValue:value forKey:eachPropertyName]; // Object
                    [self setDictionaryRepresentationValue:value forKey:eachPropertyName]; // Dictionary
                }
                else
                {
                    changed = YES;
                }
            }
            @catch (NSException *exception) { }
            @finally { }
        }
        
        // Save "merged" result if any change.
        if (changed) [self synchronize];
    }];
}

-(BOOL)shouldMergeRemoteValue:(id) value forKey:(NSString*) key
{ return YES; }



#pragma mark - Key-Value observing

-(void)observePersistableProperties
{
    for (NSString *eachPropertyName in [self.class persistablePropertyNames])
        [self addObserver:self forKeyPath:eachPropertyName options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
}

-(void)finishObservingPersistableProperties
{
    for (NSString *eachPropertyName in [self.class persistablePropertyNames])
        [self removeObserver:self forKeyPath:eachPropertyName];
}

-(void)changeWithoutObservation:(void(^)()) block
{
    self.suspendPropertyObserving = YES;
    block();
    self.suspendPropertyObserving = NO;
}

-(void)observeValueForKeyPath:(NSString*) keyPath
                     ofObject:(id)object
                       change:(NSDictionary*) change
                      context:(void*) context
{
    if (self.suspendPropertyObserving) return; // May be skipped (while populating values in this class)
    
    // Update dictionary representation.
    id value = [change objectForKey:NSKeyValueChangeNewKey]; // New value
    [self setDictionaryRepresentationValue:value forKey:keyPath];
    
    // Set on store.
    if (self.iCloud) { [self.keyValueStore setObject:self.dictionaryRepresentation forKey:self.key]; }
                else { [self.userDefaults setObject:self.dictionaryRepresentation forKey:self.key]; }
    
    // Set local.
    if (self.saveOnEveryChange) { [self synchronize]; }
}

-(void)setDictionaryRepresentationValue:(id) value forKey:(NSString*) key
{
    if (value == [NSNull null] || value == nil) // Don't set `CFNull` as value
    { [self.dictionaryRepresentation setValue:NULL_VALUE forKey:key]; /* Custom string for `nil` */ }
    else
    { [self.dictionaryRepresentation setValue:value forKey:key]; }
}


#pragma mark - Observe iCloud

-(void)observeKeyValueStore
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyValueStoreDidChange:)
                                                 name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification
                                               object:[NSUbiquitousKeyValueStore defaultStore]];
}


#pragma mark - Observe application states

-(void)observeApplicationStates
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}


#pragma mark - Application state dependent saving / loading

-(void)synchronize
{
    if (self.iCloud) { [self.keyValueStore synchronize]; }
                else { [self.userDefaults synchronize]; }
}

-(void)applicationWillResignActive
{ [self synchronize]; }

-(void)applicationDidEnterBackground
{ [self synchronize]; }

-(void)applicationDidBecomeActive
{ [self.keyValueStore synchronize]; /* Kick off iCloud sync */ }

-(BOOL)isSyncingEnabled
{
    // Look up if there is a local container for iCloud Documents.
    NSURL *containerURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    return (containerURL != nil);
}

-(void)keyValueStoreDidChange:(NSNotification*) notification
{
    // Change type.
    NSNumber *reason = [[notification userInfo] objectForKey:NSUbiquitousKeyValueStoreChangeReasonKey];
    BOOL isChange = (reason.integerValue == NSUbiquitousKeyValueStoreServerChange ||
                     reason.integerValue == NSUbiquitousKeyValueStoreInitialSyncChange ||
                     reason.integerValue == NSUbiquitousKeyValueStoreAccountChange);
    BOOL isSaveError = (reason.integerValue == NSUbiquitousKeyValueStoreQuotaViolationChange);
    
    USLog(@"keyValueStoreDidChange: %@", [self changeReasonDecription:reason]);
    
    if (isChange)
    {
        NSDictionary *remoteDictionaryRepresentation = [self.keyValueStore objectForKey:self.key];
        [self populateFromDictionary:remoteDictionaryRepresentation];
        if (self.delegate != nil) [self.delegate settingsDidChangeRemotely:self]; // Callback
    }
    
    if (isSaveError)
    {
        if (self.delegate != nil) [self.delegate settingsSyncDidFail:self]; // Callback
    }
}

-(NSString*)changeReasonDecription:(NSNumber*) reason
{
    NSDictionary *reasonDescriptions = @{
                                         @(NSUbiquitousKeyValueStoreServerChange) : @"Server change",
                                         @(NSUbiquitousKeyValueStoreInitialSyncChange) : @"Initial sync change",
                                         @(NSUbiquitousKeyValueStoreQuotaViolationChange) : @"Quota Violation change",
                                         @(NSUbiquitousKeyValueStoreAccountChange) : @"Account change"
                                         };
    if ([reasonDescriptions.allKeys containsObject:reason] == NO) { return @"Unknown"; }
    return reasonDescriptions[reason];
}


#pragma mark - Properties to represent

+(NSArray*)persistablePropertyNames
{ return self.propertyNames; }

+(NSArray*)propertyNames
{ return [self propertyNamesOfClass:self]; }

+(NSArray*)propertyNamesOfClass:(Class) class
{
    NSMutableArray *propertyNamesArray = [NSMutableArray new];
    
    unsigned int propertyCount;
    objc_property_t *properties = class_copyPropertyList(class, &propertyCount);
    
    for (int index = 0; index < propertyCount; index++)
    {
        NSString *key = [NSString stringWithUTF8String:property_getName(properties[index])];
        [propertyNamesArray addObject:key];
    }
    
    free(properties);
    
    return [NSArray arrayWithArray:propertyNamesArray];
}


@end
