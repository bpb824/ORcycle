//
//  TripInfoViewController.h
//  ORCycle
//
//  Created by orcycle on 7/21/14.
//
//

#import <UIKit/UIKit.h>
#import "TripInfoDelegate.h"
#import "Checkbox.h"
#import "RenoTracksAppDelegate.h"

@interface TripInfoViewController : UIViewController <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIActionSheetDelegate, UIWebViewDelegate, UITableViewDelegate, UITableViewDataSource>
{
    id <TripInfoDelegate> delegate;
    RenoTracksAppDelegate *appDelegate;
    UITableView *infoTableView;
	NSManagedObjectContext *managedObjectContext;

    UITextField *routeFreq;
    UITextField *routePrefs;
    UITextField *routeComfort;
    UITextField *routeSafety;
    UITextField *ridePassengers;
    UITextField *rideSpecial;
    UITextField *rideConflict;
    UITextField *routeStressors;
    UIToolbar *doneToolbar;
    UIActionSheet *actionSheet;
    UIPickerView *pickerView;
    UITextField *currentTextField;

    NSArray *routeFreqArray;
    NSArray *routePrefsArray;
    NSArray *routeComfortArray;
    NSArray *routeSafetyArray;
    NSArray *ridePassengersArray;
    NSArray *rideSpecialArray;
    NSArray *rideConflictArray;
    NSArray *routeStressorsArray;

    NSInteger routeFreqSelectedRow;
    NSMutableArray *routePrefsSelectedRows;
    NSInteger routeComfortSelectedRow;
    NSInteger routeSafetySelectedRow;
    NSMutableArray *ridePassengersSelectedRows;
    NSMutableArray *rideSpecialSelectedRows;
    NSInteger rideConflictSelectedRow;
    NSMutableArray *routeStressorsSelectedRows;
    NSInteger selectedItem;
    NSMutableArray *selectedItems;
}

@property (nonatomic, retain) id <TripInfoDelegate> delegate;
@property (nonatomic, retain) RenoTracksAppDelegate *appDelegate;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic,retain) UITextField *routeFreq;
@property (nonatomic,retain) UITextField *routePrefs;
@property (nonatomic,retain) UITextField *routeComfort;
@property (nonatomic,retain) UITextField *routeSafety;
@property (nonatomic,retain) UITextField *ridePassengers;
@property (nonatomic,retain) UITextField *rideSpecial;
@property (nonatomic,retain) UITextField *rideConflict;
@property (nonatomic,retain) UITextField *routeStressors;

@property (nonatomic) NSInteger routeFreqSelectedRow;
@property (nonatomic,retain) NSMutableArray *routePrefsSelectedRows;
@property (nonatomic) NSInteger routeComfortSelectedRow;
@property (nonatomic) NSInteger routeSafetySelectedRow;
@property (nonatomic,retain) NSMutableArray *ridePassengersSelectedRows;
@property (nonatomic,retain) NSMutableArray *rideSpecialSelectedRows;
@property (nonatomic) NSInteger rideConflictSelectedRow;
@property (nonatomic,retain) NSMutableArray *routeStressorsSelectedRows;
@property (nonatomic) NSInteger selectedItem;
@property (nonatomic,retain) NSMutableArray *selectedItems;

@property (nonatomic, retain) IBOutlet UITableView *infoTableView;


-(IBAction)skip:(id)sender;
-(IBAction)saveInfo:(id)sender;

// DEPRECATED
- (id)initWithManagedObjectContext:(NSManagedObjectContext*)context;
    
//- (void)done;

@end