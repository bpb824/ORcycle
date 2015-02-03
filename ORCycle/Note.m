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
*/

#import "Note.h"
#import "User.h"


@implementation Note

@dynamic details;
@dynamic speed;
@dynamic vAccuracy;
@dynamic longitude;
@dynamic image_url;
@dynamic note_type;
@dynamic latitude;
@dynamic hAccuracy;
@dynamic recorded;
@dynamic altitude;
@dynamic image_data;
@dynamic thumbnail;
@dynamic user;
@dynamic uploaded;
@dynamic reportDate;

@dynamic isCrash;
@dynamic urgency;
@dynamic severity;
@dynamic conflictWith;
@dynamic issueType;
@dynamic crashActions;
@dynamic crashReasons;

@dynamic otherConflictWith;
@dynamic otherIssueType;
@dynamic otherCrashReasons;
@dynamic otherCrashActions;

@end
