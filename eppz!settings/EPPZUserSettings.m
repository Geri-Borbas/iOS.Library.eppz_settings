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


@interface EPPZUserSettings ()

@property (nonatomic, weak) NSUserDefaults *userDefaults;
@property (nonatomic, weak) NSUbiquitousKeyValueStore *keyValueStore;
@property (nonatomic) EPPZUserSettingsMode mode;
@property (nonatomic) BOOL _isSyncingEnabled;

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
        // Shortcuts.
        self.userDefaults = [NSUserDefaults standardUserDefaults];
        self.keyValueStore = [NSUbiquitousKeyValueStore defaultStore];
        self.iCloud = (mode == EPPZUserSettingsModeiCloud);
        self.delegate = delegate;
        
        [self createDictionaryRepresentation];
        
        NSDictionary *storedDictionaryRepresentation;
        if (self.iCloud)
        {
            [self checkAccount];
            [self observeKeyValueStore];
            BOOL synced = [self.keyValueStore synchronize]; // Kick off sync (if any remote change)
            USLog(@"synced: %@", (synced) ? @"YES" : @"NO");
            
            // Representation.
            storedDictionaryRepresentation = [self.keyValueStore objectForKey:self.className];
        }
        else
        {
            // Register defaults.
            NSString *defaultsPlistPath = [[NSBundle mainBundle] pathForResource:self.className ofType:@"plist"];
            NSDictionary *defaultProperties = [NSDictionary dictionaryWithContentsOfFile:defaultsPlistPath];
            NSDictionary *defaults = (defaultProperties != nil) ? @{ self.className : defaultProperties } : nil;
            [self.userDefaults registerDefaults:defaults];
            
            // Representation.
            storedDictionaryRepresentation = [self.userDefaults objectForKey:self.className];
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

-(void)createDictionaryRepresentation
{
    self.dictionaryRepresentation = [NSMutableDictionary new];
    for (NSString *eachPropertyName in [self.class persistablePropertyNames])
    { [self.dictionaryRepresentation setObject:[NSNull null] forKey:eachPropertyName]; }
    
    USLog(@"createDictionaryRepresentation: %@", self.dictionaryRepresentation);
}

-(void)dealloc
{
    // Tear down observers.
    [self finishObservingPersistableProperties];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Archiving

+(NSString*)name { return NSStringFromClass(self); }
-(NSString*)className { return [self.class name]; }
-(NSString*)prefixedKeyForKey:(NSString*) key { return [NSString stringWithFormat:@"%@.%@", self.className, key]; }

-(void)populateFromDictionary:(NSDictionary*) dictionaryRepresentation
{
    self.suspendPropertyObserving = YES;
    BOOL somethingHasNotMerged = NO;
    
        for (NSString *eachPropertyName in dictionaryRepresentation.allKeys)
        {
            // Get value (from NSUserDefaults dictionary).
            id value = [dictionaryRepresentation valueForKey:eachPropertyName];
            
            // Set property safely.
            @try
            {
                BOOL shouldSet = [self shouldMergeRemoteValue:value forKey:eachPropertyName];
                if (shouldSet)
                {
                    [self setValue:value forKey:eachPropertyName]; // Object
                    [self.dictionaryRepresentation setValue:value forKey:eachPropertyName]; // Dictionary
                }
                else
                {
                    somethingHasNotMerged = YES;
                }
            }
            @catch (NSException *exception) { }
            @finally { }
        }
    
    self.suspendPropertyObserving = NO;
    
    // Save "merged" result.
    if (somethingHasNotMerged) [self save];
}

-(BOOL)shouldMergeRemoteValue:(id) value forKey:(NSString*) key
{ return YES; }

-(void)observeValueForKeyPath:(NSString*) keyPath
                     ofObject:(id)object
                       change:(NSDictionary*) change
                      context:(void*) context
{
    if (self.suspendPropertyObserving) return; // May be skipped while populating values in this class
    
    // New value.
    id value = [change objectForKey:NSKeyValueChangeNewKey];
    
    // Update dictionary representation.
    [self.dictionaryRepresentation setValue:value forKey:keyPath];

    USLog(@"About to save: %@", self.dictionaryRepresentation);
    // Set on store.
    if (self.iCloud)
    { [self.keyValueStore setObject:self.dictionaryRepresentation forKey:self.className]; }
    else
    { [self.userDefaults setObject:self.dictionaryRepresentation forKey:self.className]; }
    
    // Set local.
    if (self.saveOnEveryChange)
    { [self save]; }
}


#pragma mark - Observe propery changes

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


#pragma mark - Observe iCloud

-(void)observeKeyValueStore
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyValueStoreAvailibilityDidChange:)
                                                 name:NSUbiquityIdentityDidChangeNotification
                                               object:nil];
    
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

-(void)save
{
    if (self.iCloud)
    { [self.keyValueStore synchronize]; }
    else
    { [self.userDefaults synchronize]; }
    
    [self checkAccount];
}

-(void)applicationWillResignActive
{ [self save]; }

-(void)applicationDidEnterBackground
{ [self save]; }

-(void)applicationDidBecomeActive
{ [self.keyValueStore synchronize]; }

-(void)keyValueStoreAvailibilityDidChange:(NSNotification*) notification
{
    NSLog(@"keyValueStoreAvailibilityDidChange: (%@)", notification.userInfo);
}

-(BOOL)isSyncingEnabled
{ return self._isSyncingEnabled; }

-(void)checkAccount
{
    NSURL *containerURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    id token = [[NSFileManager defaultManager] ubiquityIdentityToken];
    NSLog(@"containerURL: %@", containerURL);
    NSLog(@"token: %@", token);  // <43b26e49 f45b084a 7d8117ab 7971eae3 d8a30f83>
    
    self._isSyncingEnabled = (containerURL != nil);
    /*
     NSData *storedTokenData = [[NSUserDefaults standardUserDefaults] objectForKey:@"com.eppz.settings.UbiquityIdentityToken"];
     id storedToken = [NSKeyedUnarchiver unarchiveObjectWithData:storedTokenData];
     BOOL tokenIsTheSame = [token isEqual:storedToken];
     NSLog(@"tokenIsTheSame: (%@)", (tokenIsTheSame) ? @"YES" : @"NO");
     // Can prompt something if nil.
     */
}

-(void)keyValueStoreDidChange:(NSNotification*) notification
{
    NSLog(@"keyValueStoreDidChange: (%@)", notification.userInfo);
    
    // Change.
    NSNumber *reason = [[notification userInfo] objectForKey:NSUbiquitousKeyValueStoreChangeReasonKey];
    NSArray *changedkeys = [[notification userInfo] objectForKey:NSUbiquitousKeyValueStoreChangedKeysKey];
    NSDictionary *reasonDescriptions = @{
                                         @(NSUbiquitousKeyValueStoreServerChange) : @"Server change",
                                         @(NSUbiquitousKeyValueStoreInitialSyncChange) : @"Initial sync change",
                                         @(NSUbiquitousKeyValueStoreQuotaViolationChange) : @"Quota Violation change",
                                         @(NSUbiquitousKeyValueStoreAccountChange) : @"Account change"
                                         };
    
    BOOL isChange = (reason.integerValue == NSUbiquitousKeyValueStoreServerChange ||
                     reason.integerValue == NSUbiquitousKeyValueStoreInitialSyncChange ||
                     reason.integerValue == NSUbiquitousKeyValueStoreAccountChange);
    BOOL isSaveError = (reason.integerValue == NSUbiquitousKeyValueStoreQuotaViolationChange);
    
    NSLog(@"keyValueStoreDidChange: %@", reasonDescriptions[reason]);
    
    [self checkAccount];
    
    // Change runtime object.
    if (isChange)
    {
        NSLog(@"changedkeys: %@", changedkeys);
        NSDictionary *remoteDictionaryRepresentation = [self.keyValueStore objectForKey:self.className];
        [self populateFromDictionary:remoteDictionaryRepresentation];
        NSLog(@"storedDictionaryRepresentation: %@", remoteDictionaryRepresentation);
        
        // Callback.
        [self.delegate settingsDidChangeRemotely:self];
    }
    
    if (isSaveError)
    {
        // Callback.
        [self.delegate settingsSyncDidFail:self];
    }
}


#pragma mark - Properties to represent

+(NSArray*)persistablePropertyNames { return self.propertyNames; }

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
