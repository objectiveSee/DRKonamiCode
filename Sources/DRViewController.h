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
    UIView* __weak _NESControllerView;
    UILabel *__weak _statusLabel;
}

@property (weak, nonatomic, readonly) IBOutlet UIView *NESControllerView;
@property (weak, nonatomic, readonly) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic, readonly) IBOutlet UILabel *guideLabel;
@property (nonatomic, readonly) DRKonamiGestureRecognizer* konamiGestureRecognizer;

- (IBAction)aButtonWasPressed:(id)sender;

- (IBAction)bButtonWasPressed:(id)sender;

- (IBAction)enterButtonWasPressed:(id)sender;

- (IBAction)nesControllerWasPressed:(id)sender;

- (IBAction)advancedModeSwitchValueChanged:(id)sender;

@end
