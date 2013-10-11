#import <CoreGraphics/CoreGraphics.h>
#import "CKViewController.h"
#import "CKCalendarView.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface CKViewController () <CKCalendarDelegate>

@property(nonatomic, strong) CKCalendarView *calendar;
@property(nonatomic, strong) UILabel *dateStartLabel;
@property(nonatomic, strong) UILabel *dateEndLabel;
@property(nonatomic, strong) NSDateFormatter *dateFormatter;
@property(nonatomic, strong) NSDate *minimumDate;
@property(nonatomic, strong) NSArray *disabledDates;

@end

@implementation CKViewController

- (id)init {
    self = [super init];
    if (self) {
        CKCalendarView *calendar = [[CKCalendarView alloc] initWithStartDay:startMonday];
        self.calendar = calendar;
        calendar.delegate = self;

        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateFormat:@"MM/dd/yyyy"];
        self.minimumDate = [self.dateFormatter dateFromString:@"01/01/2013"];

        /*self.disabledDates = @[
                [self.dateFormatter dateFromString:@"05/01/2013"],
                [self.dateFormatter dateFromString:@"06/01/2013"],
                [self.dateFormatter dateFromString:@"07/01/2013"]
        ];*/

        calendar.onlyShowCurrentMonth = NO;
        calendar.adaptHeightToNumberOfWeeksInMonth = YES;

        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
            calendar.frame = CGRectMake(10, 55, 519, 500);
        else
            calendar.frame = CGRectMake(10, 10, 519, 500);
            
        [self.view addSubview:calendar];

        self.dateStartLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, CGRectGetMaxY(calendar.frame) + 9, self.view.bounds.size.width, 24)];
        [self.view addSubview:self.dateStartLabel];
        self.dateEndLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, CGRectGetMaxY(calendar.frame) + 35, self.view.bounds.size.width, 24)];
        [self.view addSubview:self.dateEndLabel];

        self.view.backgroundColor = [UIColor whiteColor];
        
        UIBarButtonItem *cancelButton =
        [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(dismissCalendarCancel)];
        self.navigationItem.leftBarButtonItem = cancelButton;
        
        UIBarButtonItem *doneButton =
        [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                         style:UIBarButtonItemStyleDone
                                        target:self
                                        action:@selector(dismissCalendarDone)];
        self.navigationItem.rightBarButtonItem = doneButton;


        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localeDidChange) name:NSCurrentLocaleDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)localeDidChange {
    [self.calendar setLocale:[NSLocale currentLocale]];
}

- (BOOL)dateIsDisabled:(NSDate *)date {
    for (NSDate *disabledDate in self.disabledDates) {
        if ([disabledDate isEqualToDate:date]) {
            return YES;
        }
    }
    return NO;
}

-(void) dismissCalendarDone {
    if (self.startDate && self.endDate) {
        [self.delegate dismissCalendarViewControllerDoneWithStartDate: self.startDate AndEndDate: self.endDate];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dates Not Set" message:@"The Anticipated Start and End Dates have not been set. Please try and enter them again or press cancel to close this window without setting the dates." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
}

-(void) dismissCalendarCancel {
    [self.delegate dismissCalendarViewControllerCancel];
}

#pragma mark -
#pragma mark - CKCalendarDelegate

- (void)calendar:(CKCalendarView *)calendar configureDateItem:(CKDateItem *)dateItem forDate:(NSDate *)date {
    // TODO: play with the coloring if we want to...
    if ([self dateIsDisabled:date]) {
        dateItem.backgroundColor = [UIColor redColor];
        dateItem.textColor = [UIColor whiteColor];
    }
}

- (BOOL)calendar:(CKCalendarView *)calendar willSelectDate:(NSDate *)date {
    return ![self dateIsDisabled:date];
}

- (void)calendar:(CKCalendarView *)calendar didSelectStartDate:(NSDate *)date {
    self.startDate = date;
    self.dateStartLabel.text = @"Anticipated Start Date: ";
    self.dateStartLabel.text = [self.dateStartLabel.text stringByAppendingString:[self.dateFormatter stringFromDate:date]];
    //[self.delegate anticipatedStartDate:date];
}

- (void)calendar:(CKCalendarView *)calendar didSelectEndDate:(NSDate *)date {
    self.dateEndLabel.text = @"Anticipated End Date: ";
    self.endDate = nil;
    if ([[self.dateFormatter dateFromString:@"12/31/2011"] compare:date] == NSOrderedAscending) {
        self.dateEndLabel.text = [self.dateEndLabel.text stringByAppendingString:[self.dateFormatter stringFromDate:date]];
        self.endDate = date;
    }
    //[self.delegate anticipatedEndDate:date];
}

- (BOOL)calendar:(CKCalendarView *)calendar willChangeToMonth:(NSDate *)date {
    if ([date laterDate:self.minimumDate] == date) {
        self.calendar.backgroundColor = [UIColor blackColor];
        return YES;
    } else {
        self.calendar.backgroundColor = [UIColor redColor];
        return NO;
    }
}

- (void)calendar:(CKCalendarView *)calendar didLayoutInRect:(CGRect)frame {
  //  NSLog(@"calendar layout: %@", NSStringFromCGRect(frame));
}

@end