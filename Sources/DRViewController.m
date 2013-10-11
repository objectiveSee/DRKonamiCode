//
//  DRViewController.m
//  DRKonamiCode
//
//  Created by Danny Ricciotti on 3/4/12.
//

#import "DRViewController.h"

@interface DRViewController()
- (void)_konamiGestureRecognized:(DRKonamiGestureRecognizer*)gesture;
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

    [self.NESControllerView setHidden:YES];

    self.statusLabel.text = nil;
}

- (void)viewDidUnload
{
    [self.view removeGestureRecognizer:self.konamiGestureRecognizer];
    _konamiGestureRecognizer = nil;
    [super viewDidUnload];
}

#pragma mark -
#pragma mark DRKonamiRecognizerDelegate

- (void)DRKonamiGestureRecognizerNeedsABEnterSequence:(DRKonamiGestureRecognizer*)gesture
{
    [self.NESControllerView setHidden:NO];
}

- (void)DRKonamiGestureRecognizer:(DRKonamiGestureRecognizer*)gesture didFinishNeedingABEnterSequenceWithError:(BOOL)error
{
    [self.NESControllerView setHidden:YES];
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
