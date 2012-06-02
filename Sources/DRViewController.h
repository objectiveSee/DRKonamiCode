//
//  DRViewController.h
//  DRKonamiCode
//
//  Created by Danny Ricciotti on 3/4/12.
//

#import "DRKonamiGestureRecognizer.h"

@interface DRViewController : UIViewController <DRKonamiGestureProtocol>
{
@protected
    DRKonamiGestureRecognizer* _konamiGestureRecognizer;

@protected
    UIView* _NESControllerView;
    UILabel *_statusLabel;
}

@property (nonatomic, readonly) IBOutlet UIView *NESControllerView;
@property (nonatomic, readonly) IBOutlet UILabel *statusLabel;
@property (nonatomic, readonly) DRKonamiGestureRecognizer* konamiGestureRecognizer;

- (IBAction)aButtonWasPressed:(id)sender;

- (IBAction)bButtonWasPressed:(id)sender;

- (IBAction)enterButtonWasPressed:(id)sender;

- (IBAction)nesControllerWasPressed:(id)sender;

- (IBAction)advancedModeSwitchValueChanged:(id)sender;

@end
