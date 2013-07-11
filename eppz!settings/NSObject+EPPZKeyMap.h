//
//  NSObject+EPPZKeyMap.h
//  eppz!settings
//
//  Created by Gardrobe on 7/11/13.
//  Copyright (c) 2013 eppz!. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSObject (EPPZKeyMap)
-(void)setValueAtKeyPath:(NSString*) oneKeyPath forKeyPath:(NSString*) otherKeyPath;
-(void)applyKeyMap:(NSDictionary*) keyMap;
-(void)applyKeyMapToRight:(NSDictionary*) keyMap;
-(void)applyKeyMapToLeft:(NSDictionary*) keyMap;
@end
