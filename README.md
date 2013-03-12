DRKonamiCode
============

![](http://upload.wikimedia.org/wikipedia/commons/thumb/e/e2/Konami_Code.svg/300px-Konami_Code.svg.png)

[Konami code](http://en.wikipedia.org/wiki/Konami_Code) gesture recognizer for iOS. The recognizer is a subclass of UIGestureRecognizer has can be used in the same way as any other recognizer. Swipe gestures correspond to the Up/Down/Left/Right parts of the sequence. An optional feature allows you to implement a custom B+A+Enter action.

![](http://grab.by/fbga)

Contact me via Twitter [@topwobble](https://twitter.com/topwobble) 

### Add it to your project in 2 Steps! ###

You can add this code in to your App in just two short steps:

1. Drag DRKonamiGestureRecognizer.h and DRKonamiGestureRecognizer.m into your project
2. Add the gesture recognizer to one of your app's UIViews using the following code.

```objective-c
- (void)addKonami
{
	konami = [[DRKonamiGestureRecognizer alloc] initWithTarget:self action:@selector(_konamiHappened:)];
	[self.view addGestureRecognizer:konami];
}

- (void)_konamiHappened:(DRKonamiGestureRecognizer *)recognizer
{
	NSLog(@"Konami Code Recognized!");
}

```

### Are you using ARC? ###

If you are using ARC then there is a 3rd step. You need to to disable ARC for DRKonamiGestureRecognizer.m in your own project. In Xcode4 go to your project file, then "Build Phases" then "Compile Sources" then add the compiler flag "-fno-objc-arc" to DRKonamiCodeGestureRecognizer.m.

![](http://grab.by/jnLA)


### TIPS ###

* TIP 1: NSLog() statements are disabled inside of DRKonamiGestureRecognizer.m. You can enable them at the top of the file and then the console will print the konami state.
* TIP 2: Practice actually doing the konami gesture with the sample app. Some people have a hard time figuring out how to actually get it going.

### B+A+Unlock (OPTIONAL) ###

Optionally, you can require the user to enter B+A+Enter in order for the gesture to be recognized. You will need to implement the DRKonamiGestureProtocol which has required methods that let your UI respond to the request for the A, B, or Enter action. If you are not using the B+A+Enter feature than you do not need to set the recognizer's delegate.


```objective-c
- (void)addKonami
{
	konami = [[DRKonamiGestureRecognizer alloc] initWithTarget:self action:@selector(_konamiHappened:)];
	[konami setKonamiDelegate:self];
	[konami setRequiresABEnterToUnlock:YES];
	[self.view addGestureRecognizer:konami];
}

- (void)_konamiHappened:(DRKonamiGestureRecognizer *)recognizer
{
	NSLog(@"Konami Code Recognized!");
}

#pragma mark -
#pragma mark DRKonamiRecognizerDelegate

- (void)DRKonamiGestureRecognizerNeedsABEnterSequence:(DRKonamiGestureRecognizer*)gesture
{
	/// your code here. 
}

- (void)DRKonamiGestureRecognizer:(DRKonamiGestureRecognizer*)gesture didFinishNeedingABEnterSequenceWithError:(BOOL)error
{
	/// your code here.
}
```

### DRKonamiGestureProtocol ###

The DRKonamiGestureProtocol protocol is required only if you are using the B+A+Enter feature. The recognizer will inform its delegate when the B+A+Enter sequence is needed and when the sequence is no longer needed (due to gesture failing or succeeding).
