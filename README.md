## ![eppz!tools](http://www.eppz.eu/beacons/eppz!.png) eppz!settings
Drop-in NSUserDefaults settings manager for everyday use. Just create a settings model object, and done.
```
@interface EPPZSettings : EPPZUserDefaults

@property (nonatomic, strong) NSString *name;
@property (nonatomic) BOOL sound;
@property (nonatomic) float volume;
@property (nonatomic) BOOL pushNotifications;
@property (nonatomic) BOOL iCloud;

@end
```
Saving, loading, default value management happens under the hood.

### Customization hooks

You can define default values by create a `.plist` named after the class defining the default values within.
You can define a subset of properties you want to persist implementing `persistablePropertyNames` class method.
```
+(NSArray*)persistablePropertyNames
{ return @[ @"lifeTimeTapCount" ]; }
```

#### License
> Licensed under the [Open Source MIT license](http://en.wikipedia.org/wiki/MIT_License).
