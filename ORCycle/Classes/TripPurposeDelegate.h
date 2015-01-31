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
* 	http://www.pdx.edu/transportation-lab/orcycle 
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
//  TripPurposeDelegate.h
//  CycleTracks
//
//  Copyright 2009-2010 SFCTA. All rights reserved.
//  Written by Matt Paul <mattpaul@mopimp.com> on 9/22/09.
//	For more information on the project, 
//	e-mail Billy Charlton at the SFCTA <billy.charlton@sfcta.org>


#define kTripPurposeCommute		0
#define kTripPurposeSchool		1
#define kTripPurposeWork		2
#define kTripPurposeExercise	3
#define kTripPurposeSocial		4
#define kTripPurposeShopping	5
#define kTripPurposeTranspoAccess	6
#define kTripPurposeOther		7
//#define kTripPurposeRecording   8

#define kTripPurposeCommuteIcon         @"commute.png"
#define kTripPurposeSchoolIcon          @"school.png"
#define kTripPurposeWorkIcon            @"workRelated.png"
#define kTripPurposeExerciseIcon        @"exercise.png"
#define kTripPurposeSocialIcon          @"social.png"
#define kTripPurposeShoppingIcon        @"shopping.png"
#define kTripPurposeTranspoAccessIcon   @"errands.png"
#define kTripPurposeOtherIcon           @"other.png"
#define kTripPurposeOtherRedIcon        @"otherRed.png"



#define kNoteThisAsset                  @"noteAssetPicker.png"
#define kNoteThisIssueWhite             @"noteassetmapglyph-white.png"
#define kNoteThisIssueRed               @"noteassetmapglyph-red.png"
#define kNoteThisIssueOrange            @"noteassetmapglyph-orange.png"
#define kNoteThisIssueYellow            @"noteassetmapglyph-yellow.png"
#define kNoteThisIssueGreen             @"noteassetmapglyph-green.png"
#define kNoteThisIssueBlue              @"noteassetmapglyph-blue.png"
#define kNoteThisCrashWhite             @"noteassetmapglyph-white.png"
#define kNoteThisCrashRed               @"WarmRedCrashSmall.png"
#define kNoteThisCrashOrange            @"WarmOrangeCrashSmall.png"
#define kNoteThisCrashYellow            @"WarmYellowCrashSmall.png"
#define kNoteThisCrashGreen             @"WarmGreenCrashSmall.png"
#define kNoteThisCrashBlue              @"WarmBlueCrashSmall.png"
#define kNoteBlank                      @"noteBlankPicker.png"

#define kTripPurposeCommuteString       @"Commute"
#define kTripPurposeSchoolString        @"School"
#define kTripPurposeWorkString          @"Work-Related"
#define kTripPurposeExerciseString      @"Exercise"
#define kTripPurposeSocialString        @"Social"
#define kTripPurposeShoppingString      @"Shopping/Errand"
//#define kTripPurposeErrandString        @"Errand"
#define kTripPurposeTranspoAccessString @"Transport Access"
#define kTripPurposeOtherString         @"Other"
#define kTripPurposeRecordingString     @"Recording..."


@protocol TripPurposeDelegate <NSObject>

@required
- (NSString *)getPurposeString:(unsigned int)index;
- (NSString *)setPurpose:(unsigned int)index;
- (void)setSaved:(BOOL)value;

@optional
- (void)didCancelPurpose;
- (void)didCancelNote;
- (void)didCancelNoteDelete;
- (void)didPickPurpose:(unsigned int)index;
- (void)didEnterTripPurposeOther:(NSString *)purposeOther;
- (void)didPickNoteType:(NSNumber *)index;
- (void)didEnterNoteDetails:(NSString *)details;
- (void)didEnterTripDetails:(NSString *)details;
- (void)didSaveImage:(NSData *)imgData;
- (void)getNoteThumbnail:(NSData *)imgData;
- (void)getTripThumbnail:(NSData *)imgData;
- (void)saveNote;
- (void)saveTrip;

- (void)didPickRouteFreq: (NSNumber *)index;
- (void)didPickRoutePrefs: (NSString *) routePrefsString;
- (void)didPickRouteComfort: (NSNumber *)index;
- (void)didPickRouteStressors: (NSString *) routeStressorsString;

- (void)didEnterOtherRoutePrefs: (NSString *) otherRoutePrefsString;
- (void)didEnterOtherRouteStressors: (NSString *) otherRoutePrefsStressors;


@end
