//
//  DRKonamiGestureRecognizer.m
//  DRKonamiCode
//
//  Created by Danny Ricciotti on 3/4/12.
//

#import "DRKonamiGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>   // required for subclassing UIGestureRecognizer

///////////////////////////////////////////////////////////////

// Line below disables logging if uncommented
#define NSLog(...);

// Constant Declarations
static const CGFloat kKonamiSwipeDistanceTolerance = 50.0f;     // Max tolerence in direction perpendicular to expected swipe state
static const CGFloat kKonamiSwipeDistanceMin = 50.0f;           // Min distance to detect a swipe gesture
static const NSTimeInterval kKonamiGestureMaxTimeBetweenGestures = 1.0f; // The max time allowed between swipe gestures.
static const NSTimeInterval kKonamiGestureMaxTimeDuringGesture = 1.0f; // The max time allowed during swipe gestures.

///////////////////////////////////////////////////////////////

// Some helper functions
void getCheckValuesAfterTouchesEnded(DRKonamiGestureState konamiState, BOOL* pCheckXLeft, BOOL* pCheckXRight, BOOL* pCheckYUp, BOOL* pCheckYDown);

void getCheckValuesDuringDrag(DRKonamiGestureState konamiState, BOOL* pCheckX, BOOL* pCheckY);


///////////////////////////////////////////////////////////////

@interface DRKonamiGestureRecognizer ()
@property (nonatomic, readwrite) DRKonamiGestureState konamiState;
@property (nonatomic, strong, readwrite) NSDate* lastGestureDate;
@property (nonatomic, readwrite) CGPoint lastGestureStartPoint;
@end

///////////////////////////////////////////////////////////////

@implementation DRKonamiGestureRecognizer

#pragma mark -
#pragma mark Lifecycle

- (id) initWithTarget:(id)target action:(SEL)action
{
    self = [super initWithTarget:target action:action];
    if ( self != nil )
    {
        self.konamiState = DRKonamiGestureStateNone;
        self.lastGestureDate = [NSDate new];
        self.lastGestureStartPoint = CGPointZero;
        self.requiresABEnterToUnlock = NO;
        self.cancelsTouchesInView = NO;
    }
    return self;
}

#pragma mark -
#pragma mark Touches

- (void)reset
{
    self.konamiState = DRKonamiGestureStateNone;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer
{
    // basically we don't prevent any other recognizer from being recoginzed.
    // TODO: Explore the idea of returning YES if self.konamiState != DRKonamiGestureStateNone.
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Fail when more than 1 finger detected.
    if ([[event touchesForGestureRecognizer:self] count] > 1)
    {
        [self setState:UIGestureRecognizerStateFailed];
    }
    else
    {
        if ( self.state == UIGestureRecognizerStateChanged )
        {
            // If an existing touch already exists (ie. state is UIGestureRecognizerStateChanged) then see if the pause between gestures took too long. However, if the konami code state has reached DRKonamiGestureStateRight2 then the timeout between gestures no longer applies. DRKonamiGestureRecognizer is either waiting for A+B+Enter or a logic error has occured.
            if ( self.konamiState < DRKonamiGestureStateRight2 )
            {
                // Check whether the time between now and the previous gesture was too long.
                NSDate* now = [NSDate date];
                if ( [now timeIntervalSinceDate:self.lastGestureDate] > kKonamiGestureMaxTimeBetweenGestures )
                {
                    NSLog(@"Waited too long between gestures. Re-starting the konami sequence.");
                    self.konamiState = DRKonamiGestureStateBegan;
                }
            }
        }
        else if ( self.state == UIGestureRecognizerStatePossible )      // default beginning state.
        {
            NSLog(@"Starting the konami sequence");
            [self setState:UIGestureRecognizerStateBegan];
            self.konamiState = DRKonamiGestureStateBegan;
        }
        else
        {
            // unexpected case. Handle with failure and return.
            NSLog(@"Invalid UIGestureRecognizerState: %d", self.state);
            [self setState:UIGestureRecognizerStateFailed];
            return;
        }
        
        self.lastGestureDate = [NSDate new];
        UITouch *touch = [touches anyObject];
        self.lastGestureStartPoint = [touch locationInView:self.view];
    }
}

/**
 Determine whether the gesture is still happening during a swipe event.
 */
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ( self.konamiState >= DRKonamiGestureStateRight2 )
    {
        // in this case the touch-based part of the sequence is done. We either have recognized Konami or are waiting on the B+A inputs.
        return;
    }
    
    // Check whether the gesture is being completed fast enough
    NSDate* now = [NSDate date];
    if ( [now timeIntervalSinceDate:self.lastGestureDate] > kKonamiGestureMaxTimeDuringGesture )
    {
        NSLog(@"Failed to swipe quick enough!");
        [self setState:UIGestureRecognizerStateFailed];
        return;
    }
    
    // Check if user has dragged finger too far away from the gesture axis
    BOOL checkY = NO;
    BOOL checkX = NO;
    getCheckValuesDuringDrag(self.konamiState + 1, &checkX, &checkY);   // use the next konami state since we are detecting that one.
    
    // TODO add timeout on swipe gestures
    
    // Check if the X and/or Y distance of the swipe was so far that the gesture if considered failed
    if (( checkX == YES) || (checkY == YES))
    {
        // Only 1 touch object is possible.
        BOOL cancelGesture = NO;
        UITouch *touch = [touches anyObject];
        UIView *view = [self view];
        CGPoint currentTouchPoint = [touch locationInView:view];
        
        if ( checkX == YES )
        {
            CGFloat xdifference = fabs( currentTouchPoint.x - self.lastGestureStartPoint.x );
            if ( xdifference > kKonamiSwipeDistanceTolerance )
            {
                // finger moved too far (in the X direction) from the expected vertical swipe.
                NSLog(@"Cancelling gesture. Xdifference = %2.2f", xdifference);
                cancelGesture = YES;
            }
        }
        else
        {
            // CheckY == YES
            CGFloat ydifference = fabs( currentTouchPoint.y - self.lastGestureStartPoint.y );
            if ( ydifference > kKonamiSwipeDistanceTolerance )
            {
                // finger moved too far (in the Y direction) from the expected horizontal swipe.
                NSLog(@"Cancelling gesture. Ydifference = %2.2f", ydifference);
                cancelGesture = YES;
            }
        }
        if ( cancelGesture == YES )
        {
            [self setState:UIGestureRecognizerStateFailed]; // Use cancelled or failed state?
        }
    }
}

/**
 At the end of each swipe event determine if the gesture failed or not.
 */
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ( self.konamiState >= DRKonamiGestureStateRight2 )
    {
        // if in DRKonamiGestureStateRight2 or higher than B+A sequence is being waited upon. We no longer are concerned with touch gestures.
        return;
    }
    
    // Perform final check to make sure a tap was not misinterpreted.
    if ( self.state != UIGestureRecognizerStateChanged ) {
        
        NSLog(@"Gesture failed. touchesEnded state is not UIGestureRecognizerStateChanged");
        [self setState:UIGestureRecognizerStateFailed];
        return;
    }
    
    // Check whether the correct gesture happened
    BOOL checkYUp = NO;
    BOOL checkYDown = NO;
    BOOL checkXLeft = NO;
    BOOL checkXRight = NO;
    getCheckValuesAfterTouchesEnded(self.konamiState + 1, &checkXLeft, &checkXRight, &checkYUp, &checkYDown);
    if ( checkXLeft || checkXRight || checkYDown || checkYUp )
    {
        // Only 1 touch object is possible.
        BOOL cancelGesture = NO;
        UITouch *touch = [touches anyObject];
        UIView *view = [self view];
        CGPoint currentTouchPoint = [touch locationInView:view];
        if ( checkXLeft || checkXRight )
        {
            CGFloat xdifference = currentTouchPoint.x - self.lastGestureStartPoint.x;
            if ( (checkXLeft == YES) && (xdifference < -1 * kKonamiSwipeDistanceMin) )
            {
                NSLog(@"Konami X-Left passed!");
            }
            else if ( (checkXRight == YES) && (xdifference > kKonamiSwipeDistanceMin) )
            {
                NSLog(@"Konami X-Right passed!");
            }
            else
            {
                NSLog(@"Konami X failed!. xdifference = %2.2f", xdifference);
                cancelGesture = YES;
            }
        }
        else
        {
            // checkYUP or checkYDown
            CGFloat ydifference = currentTouchPoint.y - self.lastGestureStartPoint.y;
            if ( (checkYUp == YES) && (ydifference < -1 * kKonamiSwipeDistanceMin) )
            {
                NSLog(@"Konami Y-Up passed!");
            }
            else if ( (checkYDown == YES) && (ydifference > kKonamiSwipeDistanceMin) )
            {
                NSLog(@"Konami Y-Down passed!");
            }
            else
            {
                NSLog(@"Konami Y failed!. ydifference = %2.2f", ydifference);
                cancelGesture = YES;
            }
        }
        if ( cancelGesture == YES )
        {
            NSLog(@"Konami Failed on state %d", self.konamiState);
            [self setState:UIGestureRecognizerStateFailed];
            return;
        }
    }
    
    self.konamiState++;
    self.lastGestureDate = [NSDate new];
    
    [self setState:UIGestureRecognizerStateChanged];
    
    if ( self.konamiState >= DRKonamiGestureStateRight2 )
    {
        // if we need B+A+Enter to finish, then do so. Else, gesture is success.
        if ( self.requiresABEnterToUnlock == YES )
        {
            if ( self.konamiDelegate == nil )
            {
                NSLog(@"Warning: Konami Gesture delegate was not set.");
                [self setState:UIGestureRecognizerStateFailed];
                return;
            }
            [self.konamiDelegate DRKonamiGestureRecognizerNeedsABEnterSequence:self];
        }
        else
        {
            // Gesture complete!
            NSLog(@"Konami Gesture recognized!");
            self.konamiState = DRKonamiGestureStateRecognized;
            [self setState:UIGestureRecognizerStateRecognized];
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self setState:UIGestureRecognizerStateFailed];
}

#pragma mark -
#pragma mark Button actions

- (void) AButtonAction
{
    if ( self.konamiState == DRKonamiGestureStateB )
    {
        self.konamiState ++;
        [self setState:UIGestureRecognizerStateChanged];
        NSLog(@"A-Button was pressed. Konami state is now %d", self.konamiState);
    }
    else
    {
        NSLog(@"Konami gesture failed due to pressing A-Button at incorrect time. State was %d", self.konamiState);
        [self setState:UIGestureRecognizerStateFailed];
        [self.konamiDelegate DRKonamiGestureRecognizer:self didFinishNeedingABEnterSequenceWithError:YES];
    }
}

- (void) BButtonAction
{
    if ( self.konamiState == DRKonamiGestureStateRight2 )
    {
        self.konamiState ++;
        [self setState:UIGestureRecognizerStateChanged];
    }
    else
    {
        NSLog(@"Konami gesture failed due to pressing B-Button at incorrect time. State was %d", self.konamiState);
        [self setState:UIGestureRecognizerStateFailed];
        [self.konamiDelegate DRKonamiGestureRecognizer:self didFinishNeedingABEnterSequenceWithError:YES];
    }
}

- (void) enterButtonAction
{
    if ( self.konamiState == DRKonamiGestureStateA )
    {
        self.konamiState ++;
        NSLog(@"Enter-Button was pressed. Konami state is now %d. Gesture complete!", self.konamiState);
        [self setState:UIGestureRecognizerStateRecognized];
        [self.konamiDelegate DRKonamiGestureRecognizer:self didFinishNeedingABEnterSequenceWithError:NO];
    }
    else
    {
        NSLog(@"Konami gesture failed due to pressing Enter-Button at incorrect time. State was %d", self.konamiState);
        [self setState:UIGestureRecognizerStateFailed];
        [self.konamiDelegate DRKonamiGestureRecognizer:self didFinishNeedingABEnterSequenceWithError:YES];
    }
}

- (void) cancelSequence
{
    NSLog(@"Konami gesture failed due to calling cancelSequence");
    [self setState:UIGestureRecognizerStateFailed];
    [self.konamiDelegate DRKonamiGestureRecognizer:self didFinishNeedingABEnterSequenceWithError:YES];
}

@end

#pragma mark -
#pragma mark C Helper Functiona

/**
 Determines whether the gesture recognizer needs to check the X and Y touch coordinates depending on the gesture state.
 */
void getCheckValuesAfterTouchesEnded(DRKonamiGestureState konamiState, BOOL* pCheckXLeft, BOOL* pCheckXRight, BOOL* pCheckYUp, BOOL* pCheckYDown)
{
    switch (konamiState)
    {
        case DRKonamiGestureStateBegan:
        case DRKonamiGestureStateUp1:
        case DRKonamiGestureStateUp2:
            *pCheckYUp = YES;
            break;
        case DRKonamiGestureStateDown1:
        case DRKonamiGestureStateDown2:
            *pCheckYDown = YES;
            break;
            
        case     DRKonamiGestureStateLeft1:
        case     DRKonamiGestureStateLeft2:
            *pCheckXLeft = YES;
            break;
            
        case     DRKonamiGestureStateRight1:
        case     DRKonamiGestureStateRight2:
            *pCheckXRight = YES;
            break;
            
        case     DRKonamiGestureStateB:
        case    DRKonamiGestureStateA:
            break;
            
        case DRKonamiGestureStateRecognized:
        case DRKonamiGestureStateNone:
        default:
            NSLog(@"unexpected gesture state %d (in %s)", konamiState, __FUNCTION__);
            break;
            
    }
}

/**
 Determines whether the gesture recognizer needs to check the X and Y touch coordinates depending on the gesture state.
 */
void getCheckValuesDuringDrag(DRKonamiGestureState konamiState, BOOL* pCheckX, BOOL* pCheckY)
{
    switch (konamiState)
    {
        case DRKonamiGestureStateBegan:
        case DRKonamiGestureStateUp1:
        case DRKonamiGestureStateUp2:
        case DRKonamiGestureStateDown1:
        case DRKonamiGestureStateDown2:
            *pCheckX = YES;
            break;
            
        case DRKonamiGestureStateLeft1:
        case DRKonamiGestureStateRight1:
        case DRKonamiGestureStateLeft2:
        case DRKonamiGestureStateRight2:
            *pCheckY = YES;
            break;
            
        case DRKonamiGestureStateB:
        case DRKonamiGestureStateA:
            break;
            
        case DRKonamiGestureStateRecognized:
        case DRKonamiGestureStateNone:
        default:
            NSLog(@"unexpected gesture state %d (in %s)", konamiState, __FUNCTION__);
            break;
    }
}

