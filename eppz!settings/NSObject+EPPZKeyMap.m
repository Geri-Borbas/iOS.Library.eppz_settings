//
//  NSObject+EPPZKeyMap.m
//  eppz!settings
//
//  Created by Gardrobe on 7/11/13.
//  Copyright (c) 2013 eppz!. All rights reserved.
//

#import "NSObject+EPPZKeyMap.h"


@implementation NSObject (EPPZKeyMap)


-(void)applyKeyMap:(NSDictionary*) keyMap
{ [self applyKeyMapToRight:keyMap]; }

-(void)applyKeyMapToRight:(NSDictionary*) keyMap
{
    for (NSString *eachLeftKeyPath in keyMap.keyEnumerator)
    {
        NSString *eachRightKeyPath = [keyMap objectForKey:eachLeftKeyPath];
        [self setValueAtKeyPath:eachLeftKeyPath forKeyPath:eachRightKeyPath];
    }
}

-(void)applyKeyMapToLeft:(NSDictionary*) keyMap
{
    for (NSString *eachLeftKeyPath in keyMap.keyEnumerator)
    {
        NSString *eachRightKeyPath = [keyMap objectForKey:eachLeftKeyPath];
        [self setValueAtKeyPath:eachRightKeyPath forKeyPath:eachLeftKeyPath];
    }
}

-(void)setValueAtKeyPath:(NSString*) valueKeyPath forKeyPath:(NSString*) targetKeyPath
{
    id value = [self valueForKeyPath:valueKeyPath];
    id targetValue = [self valueForKeyPath:targetKeyPath];
    
    if (value != nil)
    {
        //Some type conversion (NSString to NSNumber integer yet).
        if ([targetValue isKindOfClass:[NSNumber class]] &&
            [value isKindOfClass:[NSString class]])
             value = @([value integerValue]);
        if ([targetValue isKindOfClass:[NSString class]] &&
            [value isKindOfClass:[NSNumber class]])
            value = [value stringValue];
        
        //Set safely.
        @try {[ self setValue:value forKeyPath:targetKeyPath]; }
        @catch (NSException *exception)
        {
            NSLog(@"Incompatible properties.");
        }
        @finally { }
    }
}


@end
