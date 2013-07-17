## ![eppz!tools](http://www.eppz.eu/beacons/eppz!.png) eppz!settings
Drop-in NSUserDefaults settings manager for everyday use. You can read in more detail at [Save to NSUserDefaults | Advanced yet simple store of objects](http://eppz.eu/blog/save-to-nsuserdefaults/).

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

![eppz!settings](http://eppz.eu/blog/wp-content/uploads/save_objects_to_nsuserdefaults.png)

### Customization hooks

You can define default values by create a `.plist` named after the class defining the default values within.
You can define a subset of properties you want to persist implementing `persistablePropertyNames` class method.
```
+(NSArray*)persistablePropertyNames
{ return @[ @"lifeTimeTapCount" ]; }
```

### Limitations

Just as you would do instinctively, use `NSUserDefaults` acceptable data types only. Check third paragraph in [`NSUSerDefaults`](http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/NSUserDefaults_Class/Reference/Reference.html) documentation.

#### License

Donate us with a share <a href="https://twitter.com/share" class="twitter-share-button" data-url="https://github.com/eppz/eppz-settings" data-text="A Drop-in NSUserDefaults settings manager for everyday use. #iosdev #tools via @_eppz" data-size="large">Tweet</a>
<script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+'://platform.twitter.com/widgets.js';fjs.parentNode.insertBefore(js,fjs);}}(document, 'script', 'twitter-wjs');</script>


> Licensed under the [Open Source MIT license](http://en.wikipedia.org/wiki/MIT_License).

[![githalytics.com alpha](https://cruel-carlota.pagodabox.com/0bc3cb553edfb0077e022a7bc524332b "githalytics.com")](http://githalytics.com/eppz/eppz-settings)
