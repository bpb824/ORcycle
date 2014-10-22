/**ORcycle, Copyright 2014, PSU Transportation, Technology, and People Lab
 *
 * @author Bryan.Blanc <bryanpblanc@gmail.com>
 * For more info on the project, go to http://www.pdx.edu/transportation-lab/orcycle
 *
 * Updated/modified for Oregon Department of Transportation app deployment. Based on the CycleTracks codebase for SFCTA
 * Cycle Atlanta, and RenoTracks.
 */

#import "Trip.h"
#import "Coord.h"
#import "User.h"


@implementation Trip

@dynamic distance;
@dynamic start;
@dynamic notes;
@dynamic uploaded;
@dynamic purpose;
@dynamic purposeOther;
@dynamic duration;
@dynamic saved;
@dynamic coords;
@dynamic thumbnail;
@dynamic user;

@dynamic routeFreq;
@dynamic routePrefs;
@dynamic routeComfort;
@dynamic routeStressors;

@dynamic otherRouteStressors;
@dynamic otherRoutePrefs;

@end
