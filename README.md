## ![eppz!tools](http://www.eppz.eu/beacons/eppz!.png) eppz!settings

sDrop-in NSUserDefaults settings manager for everyday use, extended with iCloud support.

<a href="https://twitter.com/intent/user?original_referer=https%3A%2F%2Ftwitter.com%2Fabout%2Fresources%2Fbuttons&region=following&screen_name=_eppz&tw_p=followbutton&variant=2.0"><img src="http://www.eppz.eu/beacons/eppz!_follow.png" align="absmiddle"></a>


### A real time saver
Just create a class with settings, and done.
```
@interface Settings : EPPZUserSettings

@property (nonatomic, strong) NSString *name;
@property (nonatomic) BOOL sound;
@property (nonatomic) float volume;
@property (nonatomic) BOOL unlocked;

@end
```
One you instantiated, saving, loading, observing, default value management all happens under the hood (see sample project).
```
self.settings = [EPPZSettings settingsWithMode:EPPZUserSettingsModeUserDefaults delegate:nil];
```


### iCloud support

Can be saved into iCloud Key-Value store as well. Simply set the mode to `EPPZUserSettingsModeiCloud` upon instantiating. Delegate methods, like `settingsDidChangeRemotely:`, will call back when a remote value has set after an iCloud sync.
```
self.settings = [EPPZSettings settingsWithMode:EPPZUserSettingsModeiCloud delegate:self];
```

### Customization hooks

Can define the key under the dictionary representation gets stored overriding `+(NSString*)key` class method.

You can define default values by create a `.plist` named after the class (or the custom key described above) defining the default values within.

You can define a subset of properties you want to persist implementing `persistablePropertyNames` class method.
```
+(NSArray*)persistablePropertyNames
{ return @[ @"sound", @"volume", @"unlocked" ]; }
```

To manage merging of remote values, you can implement `shouldMergeRemoteValue:forKey:` to not merge some remote values if not intended.
```
-(BOOL)shouldMergeRemoteValue:(id) value forKey:(NSString*) key
{
    if ([key isEqualToString:@"unlocked"] &&
        [value boolValue] == NO)
    { return NO; }

    return YES;
}
```

### Limitations

Use `NSUserDefaults` acceptable data types only. Check third paragraph in [`NSUSerDefaults`](http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/NSUserDefaults_Class/Reference/Reference.html) documentation. Also won't serialize custom classes, intended for manage really flat settings.

#### License

> Licensed under the [Open Source MIT license](http://en.wikipedia.org/wiki/MIT_License).
