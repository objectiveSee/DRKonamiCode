DRKonamiCode
============

Konami code gesture recognizer for iOS. The recognizer is a subclass of UIGestureRecognizer has can be used in the same way as any other recognizer. An optional feature allows you to implement a custom A+B+Enter action.

![](http://grab.by/fbga)

### Adding Konami Code to your Project ###

1. Drag DRKonamiGestureRecognizer.h and DRKonamiGestureRecognizer.m into your project
2. Add the gesture recognizer to one of your views using the following code.

```objective-c
_konamiGestureRecognizer = [[DRKonamiGestureRecognizer alloc] initWithTarget:self action:@selector(_konamiGestureRecognized:)];
[self.view addGestureRecognizer:self.konamiGestureRecognizer];
'''

### A+B+Unlock ###

Optionally, you can require the user to enter A+B+Enter in order for the gesture to be recognized. You will need to implement the DRKonamiGestureProtocol which has required methods that let your UI respond to the request for the A, B, or Enter action. If you are not using the A+B+Enter feature than you do not need to set the recognizer's delegate.

```objective-c
 _konamiGestureRecognizer = [[DRKonamiGestureRecognizer alloc] initWithTarget:self action:@selector(_konamiGestureRecognized:)];
[self.konamiGestureRecognizer setKonamiDelegate:self];
[self.konamiGestureRecognizer setRequiresABEnterToUnlock:YES];
[self.view addGestureRecognizer:self.konamiGestureRecognizer];

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
'''
