//
//  NSObject+EPPZKeyMap.m
//  eppz!tools
//
//  Created by Borbás Geri on 7/11/13.
//  Copyright (c) 2013 eppz! development, LLC.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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
        // Some type conversion (NSString to NSNumber integer yet).
        if ([targetValue isKindOfClass:[NSNumber class]] &&
            [value isKindOfClass:[NSString class]])
             value = @([value integerValue]);
        if ([targetValue isKindOfClass:[NSString class]] &&
            [value isKindOfClass:[NSNumber class]])
            value = [value stringValue];
        
        // Set safely.
        @try {[ self setValue:value forKeyPath:targetKeyPath]; }
        @catch (NSException *exception) { }
        @finally { }
    }
}


@end
