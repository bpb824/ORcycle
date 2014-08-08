/**ORcycle, Copyright 2014, PSU Transportation, Technology, and People Lab
 *
 * @author Bryan.Blanc <bryanpblanc@gmail.com>
 * For more info on the project, e-mail figliozzi@pdx.edu
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
 *   You should have received a copy of the GNU General Public License
 *   along with Reno Cycle.  If not, see <http://www.gnu.org/licenses/>.
 */

//
//  ZipUtil.h
//
//  Modified from http://www.clintharris.net/2009/how-to-gzip-data-in-memory-using-objective-c/
//

#import <Foundation/Foundation.h>
#import "zlib.h"  



@interface ZipUtil : NSObject

+(NSData*) gzipDeflate: (NSData*)pUncompressedData ;

@end
