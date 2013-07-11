//
//  EPPZUserDefault.m
//  eppz!box!client
//
//  Created by Gardrobe on 7/10/13.
//  Copyright (c) 2013 eppz!. All rights reserved.
//

#import "EPPZUserDefaults.h"


@interface EPPZUserDefaults ()
@property (nonatomic, weak) NSUserDefaults *userDefaults;
@property (nonatomic, strong, readonly) NSArray *propertyNames;
@property (nonatomic) BOOL saveOnEveryChange;
@end


@implementation EPPZUserDefaults


#pragma mark - Creation

-(id)init
{
    if (self = [super init])
    {        
        //Sugar.
        self.userDefaults = [NSUserDefaults standardUserDefaults];
        
        //Register defaults.
        NSString *defaultsPlistPath = [[NSBundle mainBundle] pathForResource:self.name ofType:@"plist"];
        NSDictionary *defaults = [NSDictionary dictionaryWithContentsOfFile:defaultsPlistPath];
        [self.userDefaults registerDefaults:defaults];
        
        //Populate properties.
        [self load];
        
        //Turn on saving.
        [self observePersistableProperties];
        self.saveOnEveryChange = YES;
    }
    return self;
}

-(void)dealloc
{
    //Tear down observers.
    [self finishObservingPersistableProperties];
}


#pragma mark - Archiving

+(NSString*)name { return NSStringFromClass(self); } 
-(NSString*)name { return [self.class name]; }
-(NSString*)prefixedKeyForKey:(NSString*) key { return [NSString stringWithFormat:@"%@.%@", [self.class name], key]; }

-(void)load
{
    for (NSString *eachPropertyName in [self.class persistablePropertyNames])
    {
        //Get value.
        id value = [self.userDefaults objectForKey:[self prefixedKeyForKey:eachPropertyName]];
        
        //Set property safely.
        @try { [self setValue:value forKey:eachPropertyName]; }
        @catch (NSException *exception) { }
        @finally { }
    }
}

-(void)save
{ [self.userDefaults synchronize]; }

-(void)observePersistableProperties
{
    for (NSString *eachPropertyName in [self.class persistablePropertyNames])
    {
        [self addObserver:self
               forKeyPath:eachPropertyName
                  options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                  context:nil];
    }
}

-(void)finishObservingPersistableProperties
{
    for (NSString *eachPropertyName in [self.class persistablePropertyNames])
    {
        [self removeObserver:self
                  forKeyPath:eachPropertyName];
    }
}

-(void)observeValueForKeyPath:(NSString*) keyPath ofObject:(id)object change:(NSDictionary*) change context:(void*) context
{
    id value = [change objectForKey:NSKeyValueChangeNewKey];
    NSLog(@"%@ observeValueForKeyPath:%@ value:%@", NSStringFromClass(self.class), keyPath, value);
    
    //Save to store as well (if need to represent).
    if (self.saveOnEveryChange)
        if (value != nil)
            if ([[self.class persistablePropertyNames] containsObject:keyPath])
            {
                [self.userDefaults setObject:value forKey:[self prefixedKeyForKey:keyPath]];
                [self save];
            }
}


#pragma mark - Properties to represent

+(NSArray*)persistablePropertyNames { return self.propertyNames; }

+(NSArray*)propertyNames
{ return [self propertyNamesOfClass:self]; }

+(NSArray*)propertyNamesOfClass:(Class) class
{
    NSMutableArray *propertyNamesArray = [NSMutableArray new];
    
    NSUInteger propertyCount;
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
