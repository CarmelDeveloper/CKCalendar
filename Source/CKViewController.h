#import <UIKit/UIKit.h>
#import "CMFramework.h"

// Delegate Protocol
@protocol CKViewControllerDelegate <NSObject>

@required

-(void)dismissCalendarViewControllerDoneWithStartDate:(NSDate *) startDate AndEndDate:(NSDate *) endDate;
-(void)dismissCalendarViewControllerCancel;

@end

@interface CKViewController : UIViewController<UITextFieldDelegate>

@property (nonatomic, assign) id <CKViewControllerDelegate> delegate;
@property (atomic, strong) NSDate *startDate;
@property (atomic, strong) NSDate *endDate;

@end