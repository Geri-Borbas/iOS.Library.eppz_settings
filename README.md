## ![eppz!tools](http://www.eppz.eu/beacons/eppz!.png) eppz!settings
Drop-in NSUserDefaults settings manager for everyday use. You can read in more detail at [Advanced yet simple way to save to NSUserDefaults](http://eppz.eu/blog/save-to-nsuserdefaults/) at eppz! blog.

**Donate eppz!settings** by <a href="https://twitter.com/intent/tweet?url=https://github.com/eppz/eppz-reachability&text=A%20Drop-in%20NSUserDefaults%20settings%20manager%20for%20everyday%20use%20via%20@_eppz&hashtags=eppz,tools,iosdev"><img src="http://www.eppz.eu/beacons/eppz!_tweet.png" align="absmiddle"></a> this or follow <a href="https://twitter.com/intent/user?original_referer=https%3A%2F%2Ftwitter.com%2Fabout%2Fresources%2Fbuttons&region=following&screen_name=_eppz&tw_p=followbutton&variant=2.0"><img src="http://www.eppz.eu/beacons/eppz!_follow.png" align="absmiddle"></a>

___

### A real time saver
Just create an object with settings, and done.
```
@interface Settings : EPPZUserSettings

@property (nonatomic, strong) NSString *name;
@property (nonatomic) BOOL sound;
@property (nonatomic) float volume;
@property (nonatomic) BOOL unlocked;

@end
```
Saving, loading, observing, default value management all happens under the hood (see sample project).



![eppz!settings](http://eppz.eu/blog/wp-content/uploads/save_objects_to_nsuserdefaults.png)

### Customization hooks

You can define default values by create a `.plist` named after the class defining the default values within.
You can define a subset of properties you want to persist implementing `persistablePropertyNames` class method.
```
+(NSArray*)persistablePropertyNames
{ return @[ @"sound", @"volume", @"unlocked" ]; }
```

### Limitations

Use `NSUserDefaults` acceptable data types only. Check third paragraph in [`NSUSerDefaults`](http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/NSUserDefaults_Class/Reference/Reference.html) documentation.

#### License

> Licensed under the [Open Source MIT license](http://en.wikipedia.org/wiki/MIT_License).
