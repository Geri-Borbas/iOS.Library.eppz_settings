## ![eppz!tools](http://www.eppz.eu/beacons/eppz!.png) eppz!settings
Drop-in NSUserDefaults settings manager for everyday use.

### A real time saver
Just create an object with settings, and done.
```
@interface EPPZSettings : EPPZUserDefaults

@property (nonatomic, strong) NSString *name;
@property (nonatomic) BOOL sound;
@property (nonatomic) float volume;
@property (nonatomic) BOOL messages;
@property (nonatomic) BOOL iCloud;

@end
```
Saving, loading, observing, default value management all happens under the hood (see sample project).

### Customization hooks

You can define default values by create a `.plist` named after the class defining the default values within.
You can define a subset of properties you want to persist implementing `persistablePropertyNames` class method.
```
+(NSArray*)persistablePropertyNames
{ return @[ @"lifeTimeTapCount" ]; }
```

### Limitations

Just as you would do instinctively, use NSUserDefaults acceptable data types only. Check third paragraph in [`NSUSerDefaults` documentation](http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/NSUserDefaults_Class/Reference/Reference.html) 

#### License
> Licensed under the [Open Source MIT license](http://en.wikipedia.org/wiki/MIT_License).