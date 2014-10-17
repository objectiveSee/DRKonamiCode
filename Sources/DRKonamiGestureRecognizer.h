//
//  DRKonamiGestureRecognizer.h
//  DRKonamiCode
//
//  Created by Danny Ricciotti on 3/4/12.
//

/**
 The delegate (DRKonamiGestureProtocol) is optional! If you are using the delegate, however, then you must implement all of the required methods. The delegate is only needed if you wish to include A+B+Enter as the final steps of the Konami sequence.
 The Konami Gesture protocol implements communication between the gesture recognizer and the delegate when the A+B+Enter action is required to complete the gesture. If the A+B+Enter sequence is not used then none of the protocol methods are required.
 */
@class DRKonamiGestureRecognizer;
@protocol DRKonamiGestureProtocol <NSObject>
@required

/**
 Informs the delegate that the gesture recognizer has reached the point where the B+A+Enter sequence is requied to complete the gesture. This is when your code would add UI on the screen to represent the B+A+Enter options.
 */
- (void)DRKonamiGestureRecognizerNeedsABEnterSequence:(DRKonamiGestureRecognizer*)gesture;

/**
 Informs the delegate that the gesture recognizer no longers requires the B+A+Enter sequence. This will happen either because the sequence has succeeded or failed. This is where you can remove the B+A+Enter options from the screen.
 */
- (void)DRKonamiGestureRecognizer:(DRKonamiGestureRecognizer*)gesture didFinishNeedingABEnterSequenceWithError:(BOOL)error;

@end

//////////////////////////////////////////////////////////////////////

/**
 Konami code states.  Mostly used internally, but you will need to use 'DRKonamiGestureStateRecognized'.
 */
typedef NS_ENUM(NSInteger, DRKonamiGestureState)
{
    DRKonamiGestureStateNone = 0,
    DRKonamiGestureStateBegan,
    DRKonamiGestureStateUp1,
    DRKonamiGestureStateUp2,
    DRKonamiGestureStateDown1,
    DRKonamiGestureStateDown2,
    DRKonamiGestureStateLeft1,
    DRKonamiGestureStateRight1,
    DRKonamiGestureStateLeft2,
    DRKonamiGestureStateRight2,     // 9
    DRKonamiGestureStateB,          // 10
    DRKonamiGestureStateA,          // 11
    DRKonamiGestureStateRecognized  // 12
};

/**
 @class DRKonamiGestureRecognizer
 @brief A custom UIGestureRecognizer which recognized the Konami Code.
 @todo Reset the state of self.konamiState on gesture fails due to timeout between swipes in sequence.
 */
@interface DRKonamiGestureRecognizer : UIGestureRecognizer

/**
 Indicates whether the konami sequence requires B+A+Enter to finish the sequence. If NO then the sequence is finished successfully after the final RIGHT gesture. Default value is NO.
 */
@property (nonatomic, readwrite) BOOL requiresABEnterToUnlock;

/**
 The current state of the konami gesture.
 */
@property (nonatomic, readonly) DRKonamiGestureState konamiState;

/**
 The delegate of the gesture. If the delegate is set then the delegate must conform to DRKonamiGestureRecognizer. The delegate does not need to be used if requiresABEnterToUnlock is set to NO.
 */
@property (nonatomic, weak, readwrite) id<DRKonamiGestureProtocol> konamiDelegate;

/**
 Methods used by the delegate (if delegate exists) to specify when the A, B, and Enter actions occur.
 */
- (void) AButtonAction;
- (void) BButtonAction;
- (void) enterButtonAction;

/**
 Cancels the gesture recognizer from waiting on the A+B+Enter sequence. Also sets the gesture recognizer state to failed.
 Used by the delegate (if delegate exists).
 */
- (void) cancelSequence;

@end
