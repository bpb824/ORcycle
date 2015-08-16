/*
**	ORcycle, Copyright 2014, 2015, PSU Transportation, Technology, and People Lab. 
* 
*	ORcycle 2.2.0 has introduced new app features: safety focus with new buttons 
*	to report safety issues and crashes (new questionnaires), expanded trip 
*	questionnaire (adding questions besides trip purpose), app utilization 
*	reminders, app tutorial, and updated font and color schemes. 
*
*	@author Bryan.Blanc <bryanpblanc@gmail.com>    (code)
*	@author Miguel Figliozzi <figliozzi@pdx.edu> and ORcycle team (general app 
*	design and features, report questionnaires and new ORcycle features) 
*
*	For more information on the project, go to 
* 	http://www.pdx.edu/transportation-lab/orcycle  and http://www.pdx.edu/transportation-lab/app-development
*
*	Updated/modified for Oregon pilot study and app deployment. 
*
*	ORcycle is free software: you can redistribute it and/or modify it under the 
*	terms of the GNU General Public License as published by the Free Software 
*	Foundation, either version 3 of the License, or any later version.
*	ORcycle is distributed in the hope that it will be useful, but WITHOUT ANY 
*	WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR 
*	A PARTICULAR PURPOSE. See the GNU General Public License for more details.
*	You should have received a copy of the GNU General Public License along with 
*	ORcycle. If not, see <http://www.gnu.org/licenses/>.
*
*
** 	Reno Tracks, Copyright 2012, 2013 Hack4Reno
*
*   @author Brad.Hellyar <bradhellyar@gmail.com>
*
*   Updated/Modified for Reno, Nevada app deployment. Based on the
*   CycleTracks codebase for SFCTA, and the Atlanta Cycle app repo.
*
** 	CycleTracks, Copyright 2009,2010 San Francisco County Transportation Authority
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
//  constants.h
//  CycleTracks
//
//  Copyright 2009-2010 SFCTA. All rights reserved.
//  Written by Matt Paul <mattpaul@mopimp.com> on 8/25/09.
//	For more information on the project, 
//	e-mail Billy Charlton at the SFCTA <billy.charlton@sfcta.org>


#define kActionSheetButtonConfirm	0
#define kActionSheetButtonChange	1
#define kActionSheetButtonDiscard	2
#define kActionSheetButtonCancel	3

#define kActivityIndicatorSize	20.0

#define kCounterTimeInterval	0.5

#define kCustomButtonWidth		136.0
#define kCustomButtonHeight		48.0

#define kCounterFontSize		26.0
#define kMinimumFontSize		16.0

#define kStdButtonWidth			106.0
#define kStdButtonHeight		40.0

#define kJpegQuality        1.0

// error messages
#define kConnectionError	@"Server unreachable, \n try again later."
#define kServerError		@"Upload failed, \n try again later."

// alert titles
#define kBatteryTitle		@"Battery Low"
#define kRetryTitle			@"Retry Upload?"
#define	kSavingTitle		@"Uploading your trip"
#define kSavingNoteTitle    @"Uploading your note"
#define kSuccessTitle		@"Upload complete"
#define kTripNotesTitle		@"Enter Comments Below"
#define kConsentFor18Title  @"In order to send route data to the City of Reno, you must be at least 18."


#define kInterruptedTitle		@"Recording Interrupted"
#define kInterruptedMessage		@"Oops! Looks like a previous trip recording has been interrupted."
#define kUnsyncedTitle			@"Found Unsynced Trip(s)"
#define kUnsyncedMessage		@"You have at least one saved trip that has not yet been uploaded."
#define kZeroDistanceTitle		@"Recalculate Trip Distance?"
#define kZeroDistanceMessage	@"Your trip distance estimates may need to be recalculated..."

// alert messages
#define kConsentFor18Message @"Are you at least 18 years old?"
#define kBatteryMessage		@"Recording of your trip has been halted to preserve battery life."
#define kConnecting			@"Contacting server..."
#define kPreparingData		@"Preparing your trip data for transfer."
#define kRetryMessage		@"This trip has not yet been uploaded successfully. Try again?"
#define kSaveSuccess		@"Your trip has been uploaded successfully. Thank you."
#define kSaveAccepted		@"Your trip has already been uploaded. Thank you."
#define kSaveError			@"Your trip has been saved. Please try uploading again later."

//#define kInfoURL			@"https://renotracks.nevadabike.org/"
#define kInstructionsURL	@"https://www.pdx.edu/transportation-lab/ios-instructions"
#define kMainURL            @"https://www.pdx.edu/transportation-lab/orcycle"
#define kPrivacyURL         @"https://www.pdx.edu/transportation-lab/privacy-policy"

#define kSaveURL            @"https://orcycle2.cecs.pdx.edu/post/"
#define kAgencyURL          @"https://www.pdx.edu/transportation-lab/reporting-road-hazards"
#define kReportMapURL       @"https://www.pdx.edu/transportation-lab/orcycle-maps"

//Colors 
#define psuGreen [UIColor colorWithRed:106.0f/255.0f green:127.0f/255.0f blue:16.0f/255.0f alpha:1.000]
#define plainWhite [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.000]
#define unSelected [UIColor colorWithRed:207.0f/255.0f green:207.0f/255.0f blue:207.0f/255.0f alpha:1.000]

#define kTripNotesPlaceholder	@"Comments"

// CustomView metrics used by UIPickerViewDataSource, UIPickerViewDelegate
#define MAIN_FONT_SIZE		18
#define MIN_MAIN_FONT_SIZE	16

// Detect iOS version
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

