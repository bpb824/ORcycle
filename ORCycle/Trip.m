/**ORcycle, Copyright 2014, PSU Transportation, Technology, and People Lab
 *
 * @author Bryan.Blanc <bryanpblanc@gmail.com>
 * For more info on the project, e-mail figliozzi@pdx.edu
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
@dynamic duration;
@dynamic saved;
@dynamic coords;
@dynamic thumbnail;
@dynamic user;

@dynamic routeFreq;
@dynamic routePrefs;
@dynamic routeComfort;
@dynamic routeStressors;

@end
