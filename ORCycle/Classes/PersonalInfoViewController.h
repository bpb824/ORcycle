/**ORcycle, Copyright 2014, PSU Transportation, Technology, and People Lab
 *
 * @author Bryan.Blanc <bryanpblanc@gmail.com>
 * For more info on the project, go to http://www.pdx.edu/transportation-lab/orcycle
 *
 * Updated/modified for Oregon Department of Transportation app deployment. Based on the CycleTracks codebase for SFCTA
 * Cycle Atlanta, and RenoTracks.
 *
** Reno Tracks, Copyright 2012, 2013 Hack4Reno
 *
 *   @author Brad.Hellyar <bradhellyar@gmail.com>
 *
 *   Updated/Modified for Reno, Nevada app deployment. Based on the
 *   CycleTracks codebase for SFCTA, and the Atlanta Cycle app repo.
 *
 ** CycleTracks, Copyright 2009,2010 San Francisco County Transportation Authority
 *                                    San Francisco, CA, USA
 *
 *   @author Matt Paul <mattpaul@mopimp.com>
 *
 *   This file is part of CycleTracks.
 *
 *   CycleTracks is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   CycleTracks is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with CycleTracks.  If not, see <http://www.gnu.org/licenses/>.
 */

//
//  PersonalInfoViewController.h
//  CycleTracks
//
//  Copyright 2009-2010 SFCTA. All rights reserved.
//  Written by Matt Paul <mattpaul@mopimp.com> on 9/23/09.
//	For more information on the project,
//	e-mail Billy Charlton at the SFCTA <billy.charlton@sfcta.org>

#import <UIKit/UIKit.h>
#import "PersonalInfoDelegate.h"
#import "Checkbox.h"

@class User;


@interface PersonalInfoViewController : UITableViewController <UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIActionSheetDelegate,UIAlertViewDelegate, UIWebViewDelegate>
{
	id <PersonalInfoDelegate> delegate;
	NSManagedObjectContext *managedObjectContext;
	User *user;
    
	UITextField *age;
	UITextField *email;
    NSString *feedback;
	UITextField *gender;
    UITextField *ethnicity;
    UITextField *occupation;
    UITextField *income;
    UITextField *hhWorkers;
    UITextField *hhVehicles;
    UITextField *numBikes;
	UITextField *homeZIP;
	UITextField *workZIP;
	UITextField *schoolZIP;
    UITextField *cyclingFreq;
    UITextField *cyclingWeather;
    UITextField *riderAbility;
    UITextField *riderType;
    UITextField *riderHistory;
    UIToolbar *doneToolbar;
    UIActionSheet *actionSheet;
    UIPickerView *pickerView;
    UITextField *currentTextField;
    
    NSArray *genderArray;
    NSArray *ageArray;
    NSArray *ethnicityArray;
    NSArray *occupationArray;
    NSArray *incomeArray;
    NSArray *hhWorkersArray;
    NSArray *hhVehiclesArray;
    NSArray *numBikesArray;
    NSArray *cyclingFreqArray;
    NSArray *cyclingWeatherArray;
    NSArray *riderAbilityArray;
    NSArray *riderTypeArray;
    NSArray *riderHistoryArray;
    NSArray *bikeTypesArray;
    
    NSInteger ageSelectedRow;
    NSInteger genderSelectedRow;
    NSInteger ethnicitySelectedRow;
    NSInteger occupationSelectedRow;
    NSInteger incomeSelectedRow;
    NSInteger hhWorkersSelectedRow;
    NSInteger hhVehiclesSelectedRow;
    NSInteger numBikesSelectedRow;
    NSInteger cyclingFreqSelectedRow;
    NSInteger cyclingWeatherRow;
    NSInteger riderAbilityRow;
    NSInteger riderTypeSelectedRow;
    NSInteger riderHistorySelectedRow;
    NSInteger selectedItem;
    
    NSMutableArray *selectedItems;
    NSMutableArray *bikeTypesSelectedRows;
    
    NSString *otherBikeTypes;
    NSString *otherEthnicity;
    NSString *otherGender;
    NSString *otherOccupation;
    NSString *otherRiderType;
}


@property (nonatomic, retain) id <PersonalInfoDelegate> delegate;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) User *user;

@property (nonatomic, retain) UITextField	*age;
@property (nonatomic, retain) UITextField	*email;
@property (nonatomic, retain) NSString	*feedback;
@property (nonatomic, retain) UITextField	*gender;
@property (nonatomic, retain) UITextField   *ethnicity;
@property (nonatomic, retain) UITextField   *occupation;
@property (nonatomic, retain) UITextField   *income;
@property (nonatomic, retain) UITextField   *hhWorkers;
@property (nonatomic, retain) UITextField   *hhVehicles;
@property (nonatomic, retain) UITextField   *numBikes;
@property (nonatomic, retain) UITextField	*homeZIP;
@property (nonatomic, retain) UITextField	*workZIP;
@property (nonatomic, retain) UITextField	*schoolZIP;

@property (nonatomic, retain) UITextField   *cyclingFreq;
@property (nonatomic, retain) UITextField   *cyclingWeather;
@property (nonatomic, retain) UITextField   *riderAbility;
@property (nonatomic, retain) UITextField   *riderType;
@property (nonatomic, retain) UITextField   *riderHistory;

@property (nonatomic) NSInteger ageSelectedRow;
@property (nonatomic) NSInteger genderSelectedRow;
@property (nonatomic) NSInteger ethnicitySelectedRow;
@property (nonatomic) NSInteger occupationSelectedRow;
@property (nonatomic) NSInteger incomeSelectedRow;
@property (nonatomic) NSInteger hhWorkersSelectedRow;
@property (nonatomic) NSInteger hhVehiclesSelectedRow;
@property (nonatomic) NSInteger numBikesSelectedRow;
@property (nonatomic) NSInteger cyclingFreqSelectedRow;
@property (nonatomic) NSInteger cyclingWeatherSelectedRow;
@property (nonatomic) NSInteger riderAbilitySelectedRow;
@property (nonatomic) NSInteger riderTypeSelectedRow;
@property (nonatomic) NSInteger riderHistorySelectedRow;
@property (nonatomic) NSInteger selectedItem;

@property (nonatomic, retain) NSString* otherBikeTypes;
@property (nonatomic, retain) NSString* otherEthnicity;
@property (nonatomic, retain) NSString* otherGender;
@property (nonatomic, retain) NSString* otherOccupation;
@property (nonatomic, retain) NSString* otherRiderType;

@property (nonatomic,retain) NSMutableArray *selectedItems;
@property (nonatomic,retain) NSMutableArray *bikeTypesSelectedRows;

@property (nonatomic,retain) IBOutlet UIButton *choiceButton;

// DEPRECATED
- (id)initWithManagedObjectContext:(NSManagedObjectContext*)context;

- (void)done;

@end