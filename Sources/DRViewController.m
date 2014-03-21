//
//  DRViewController.m
//  DRKonamiCode
//
//  Created by Danny Ricciotti on 3/4/12.
//

#import "DRViewController.h"

@interface DRViewController()
- (void)_konamiGestureRecognized:(DRKonamiGestureRecognizer*)gesture;
@property (nonatomic) UILabel *nesLabel;
@end

#pragma mark -

@implementation DRViewController
@synthesize NESControllerView = _NESControllerView;
@synthesize konamiGestureRecognizer = _konamiGestureRecognizer;
@synthesize statusLabel = _statusLabel;

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _konamiGestureRecognizer = [[DRKonamiGestureRecognizer alloc] initWithTarget:self action:@selector(_konamiGestureRecognized:)];
    [self.konamiGestureRecognizer setKonamiDelegate:self];
    [self.konamiGestureRecognizer setRequiresABEnterToUnlock:YES];
    [self.view addGestureRecognizer:self.konamiGestureRecognizer];
    
    if ( !self.nesLabel )
    {
        UILabel *nesLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.NESControllerView.frame), CGRectGetWidth(self.view.bounds)-20, 66)];
        nesLabel.text = @"Hit B, then A, then the enter button (right button in middle of NES controller) to finish Konami sequence.";
        nesLabel.numberOfLines = 0;
        [nesLabel setFont:[UIFont systemFontOfSize:15]];
        nesLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:nesLabel];
        nesLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        self.nesLabel = nesLabel;
    }
    
    // initially hidden. Shown when user has completed the Konami sequence up to the A+B+Enter part.
    self.NESControllerView.alpha = 0;
    self.NESControllerView.transform = CGAffineTransformMakeScale(.8, .8);
    self.nesLabel.alpha = 0;

    self.statusLabel.text = nil;
}

- (void)viewDidUnload
{
    [self.view removeGestureRecognizer:self.konamiGestureRecognizer];
    _konamiGestureRecognizer = nil;
    [super viewDidUnload];
}

#pragma mark -
#pragma mark DRKonamiGestureProtocol

- (void)DRKonamiGestureRecognizerNeedsABEnterSequence:(DRKonamiGestureRecognizer*)gesture
{
    [UIView animateWithDuration:0.3 animations:^{
        self.NESControllerView.alpha = 1;
        self.NESControllerView.transform = CGAffineTransformIdentity;
        self.nesLabel.alpha = 1;
    }];
}

- (void)DRKonamiGestureRecognizer:(DRKonamiGestureRecognizer*)gesture didFinishNeedingABEnterSequenceWithError:(BOOL)error
{
    [UIView animateWithDuration:0.3 animations:^{
        self.NESControllerView.alpha = 0;
        self.NESControllerView.transform = CGAffineTransformMakeScale(.8, .8);
        self.nesLabel.alpha = 0;
    }];

}

#pragma mark -
#pragma mark Public

- (IBAction)advancedModeSwitchValueChanged:(id)sender
{
    NSAssert([sender isKindOfClass:[UISwitch class]] == YES, @"Invalid class.");
    UISwitch *theSwitch = (UISwitch *)sender;

    self.konamiGestureRecognizer.requiresABEnterToUnlock = [theSwitch isOn];
}

- (IBAction)aButtonWasPressed:(id)sender
{
    [self.konamiGestureRecognizer AButtonAction];
}

- (IBAction)bButtonWasPressed:(id)sender
{
    [self.konamiGestureRecognizer BButtonAction];
}

- (IBAction)enterButtonWasPressed:(id)sender
{
    [self.konamiGestureRecognizer enterButtonAction];
}

- (IBAction)nesControllerWasPressed:(id)sender
{
    [self.konamiGestureRecognizer cancelSequence];
}

#pragma mark -
#pragma mark Private

- (void)_konamiGestureRecognized:(DRKonamiGestureRecognizer*)gesture
{
    static NSString* konamiProgressString = @"↑↑↓↓←→←→BA";

    if ( gesture.state == UIGestureRecognizerStateRecognized )
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Konami!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss",nil];
        [alert show];
    }
    else if ( gesture.state == UIGestureRecognizerStateChanged )
    {
        DRKonamiGestureState konamiState = gesture.konamiState;
        NSInteger indexOfSubString = konamiState - DRKonamiGestureStateUp1 + 1;

        if ( indexOfSubString > 0 )
        {
            NSString *progressString = [konamiProgressString substringToIndex:indexOfSubString];
            self.statusLabel.text = progressString;
        }
        else
        {
            self.statusLabel.text = nil;
        }
    }
    else
    {
        self.statusLabel.text = nil;
    }
}    

@end
