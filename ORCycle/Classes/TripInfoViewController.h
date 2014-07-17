//
//  TripInfoViewController.h
//  ORCycle
//
//  Created by orcycle on 7/16/14.
//
//

#import <UIKit/UIKit.h>
#import "TripInfoDelegate.h"

@class Trip;

@interface TripInfoViewController : UITableViewController <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIActionSheetDelegate, UIWebViewDelegate>

{
    id <TripInfoDelegate> delegate;
	NSManagedObjectContext *managedObjectContext;
	Trip *trip;
    
    UITextField *routeFreq;
    UIToolbar *doneToolbar;
    UIActionSheet *actionSheet;
    UIPickerView *pickerView;
    UITextField *currentTextField;
    
    NSArray *routeFreqArray;
    
    NSInteger routeFreqSelectedRow;
    NSInteger selectedItem;
}

@property (nonatomic, retain) id <TripInfoDelegate> delegate;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) Trip *trip;

@property (nonatomic, retain) UITextField	*routeFreq;

@property (nonatomic) NSInteger routeFreqSelectedRow;
@property (nonatomic) NSInteger selectedItem;

// DEPRECATED
- (id)initWithManagedObjectContext:(NSManagedObjectContext*)context;

- (void)done;

@end
