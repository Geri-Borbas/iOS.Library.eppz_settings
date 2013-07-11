//
//  EPPZUserDefault.h
//  eppz!box!client
//
//  Created by Gardrobe on 7/10/13.
//  Copyright (c) 2013 eppz!. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>


@interface EPPZUserDefaults : NSObject

+(NSArray*)persistablePropertyNames; //Optional (!) subclass template (read only once per lifetime).

-(void)load;
-(void)save;


@end
