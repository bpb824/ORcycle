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
 *   along with Reno Tracks.  If not, see <http://www.gnu.org/licenses/>.
 */

#import <MobileCoreServices/UTCoreTypes.h>
#import "NoteViewController.h"
#import "LoadingView.h"
#import "TripPurposeDelegate.h"
#import "Note.h"
#import "UIImageViewResizable.h"
#import "constants.h"

#define kFudgeFactor	1.5
#define kInfoViewAlpha	0.8
#define kMinLatDelta	0.0039
#define kMinLonDelta	0.0034

@interface NoteViewController ()

@end

@implementation NoteViewController

@synthesize doneButton, flipButton, infoView, note;
@synthesize delegate;

- (id)initWithNote:(Note *)_note
{
	if (self = [super initWithNibName:@"NoteViewController" bundle:nil]) {
		NSLog(@"NoteViewController initWithNote");
		self.note = _note;
		noteView.delegate = self;
    }
    return self;
}



- (void)infoAction:(UIButton*)sender
{
	NSLog(@"infoAction");
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:animationIDfinished:finished:context:)];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.75];
	
	[UIView setAnimationTransition:([infoView superview] ?
									UIViewAnimationTransitionFlipFromLeft : UIViewAnimationTransitionFlipFromRight)
						   forView:self.view cache:YES];
	
	if ([infoView superview])
		[infoView removeFromSuperview];
	else
		[self.view addSubview:infoView];
	
	[UIView commitAnimations];
	
	// adjust our done/info buttons accordingly
	if ([infoView superview] == self.view)
		self.navigationItem.rightBarButtonItem = doneButton;
	else
		self.navigationItem.rightBarButtonItem = flipButton;
}

- (void)initInfoView
{
	infoView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,560)];
    NSInteger textLength = self.note.details.length;
    int row = 1+(textLength-1)/34;
    
    //Mark date details
    NSDateFormatter *outputDateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [outputDateFormatter setDateStyle:kCFDateFormatterLongStyle];
    
    NSDateFormatter *outputTimeFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [outputTimeFormatter setTimeStyle:kCFDateFormatterShortStyle];
    
    NSString *newDateString = [outputDateFormatter stringFromDate:self.note.recorded];
    NSString *newTimeString = [outputTimeFormatter stringFromDate:self.note.recorded];
    
    NSString *severityString = [[NSString alloc]init];
    switch ([self.note.note_type intValue]) {
        case 0:
            severityString = @"No severity level indicated";
            break;
        case 1:
            severityString = @"Major crash/accident";
            break;
        case 2:
            severityString = @"Minor crash/accident";
            break;
        case 3:
            severityString = @"Near crash/accident";
            break;
        case 4:
            severityString = @"Did not feel safe";
            break;
        case 5:
            severityString = @"Uncomfortable";
            break;
        default:
            severityString = @"No severity level indicated";
            break;
    }
    
    NSLog(@"severity string = %@", severityString);
    
    
    NSMutableArray *conflictWithTemp = [[self.note.conflictWith componentsSeparatedByString:@","] mutableCopy];
    
    NSMutableString *conflictWithString = [[NSMutableString alloc]init];
    
    if([conflictWithTemp count] != 0){
        NSMutableArray *conflictWithArray = [[NSMutableArray alloc] init];
        for (NSString *s in conflictWithTemp)
        {
            NSNumber *num = [NSNumber numberWithInt:[s intValue]];
            [conflictWithArray addObject:num];
        }
        
        if ([conflictWithArray[0] integerValue]==1){
            [conflictWithString appendString:@", Auto Traffic"];
        }
        if ([conflictWithArray[1] integerValue]==1){
            [conflictWithString appendString:@", Large commercial vehicles (trucks)"];
        }
        if ([conflictWithArray[2] integerValue]==1){
            [conflictWithString appendString:@", Public transport (buses, light rail, streetcar)"];
        }
        if ([conflictWithArray[3] integerValue]==1){
            [conflictWithString appendString:@", Parked vehicles (being doored)"];
        }
        if ([conflictWithArray[4] integerValue]==1){
            [conflictWithString appendString:@", Other cyclists"];
        }
        if ([conflictWithArray[5] integerValue]==1){
            [conflictWithString appendString:@", Pedestrians"];
        }
        if ([conflictWithArray[6] integerValue]==1){
            [conflictWithString appendString:@", Poles/barriers/infrastructure"];
        }
        if ([conflictWithArray[7] integerValue]==1){
            [conflictWithString appendString:@", Other"];
        }
        if (conflictWithString.length != 0){
            NSRange range = {0,2};
            [conflictWithString deleteCharactersInRange:range];
        }
    }
    if (conflictWithString.length == 0){
        conflictWithString = [NSMutableString stringWithFormat:@"No conflicts documented"];
    }

    
    NSMutableArray *issueTypeTemp = [[self.note.issueType componentsSeparatedByString:@","] mutableCopy];
    
    NSMutableString *issueTypeString = [[NSMutableString alloc]init];
    
    if([issueTypeTemp count] != 0){
        NSMutableArray *issueTypeArray = [[NSMutableArray alloc] init];
        for (NSString *s in issueTypeTemp)
        {
            NSNumber *num = [NSNumber numberWithInt:[s intValue]];
            [issueTypeArray addObject:num];
        }
        
        if ([issueTypeArray[0] integerValue]==1){
            [issueTypeString appendString:@", Narrow Bicycle Lane"];
        }
        if ([issueTypeArray[1] integerValue]==1){
            [issueTypeString appendString:@", No bike lane or seperation"];
        }
        if ([issueTypeArray[2] integerValue]==1){
            [issueTypeString appendString:@", High vehicle speeds"];
        }
        if ([issueTypeArray[3] integerValue]==1){
            [issueTypeString appendString:@", High traffic volumes"];
        }
        if ([issueTypeArray[4] integerValue]==1){
            [issueTypeString appendString:@", Right/left turning vehicles"];
        }
        if ([issueTypeArray[5] integerValue]==1){
            [issueTypeString appendString:@", Traffic signal timing"];
        }
        if ([issueTypeArray[6] integerValue]==1){
            [issueTypeString appendString:@", No traffic signal detection"];
        }
        if ([issueTypeArray[7] integerValue]==1){
            [issueTypeString appendString:@", Truck traffic"];
        }
        if ([issueTypeArray[8] integerValue]==1){
            [issueTypeString appendString:@", Bus traffic/stop"];
        }
        if ([issueTypeArray[9] integerValue]==1){
            [issueTypeString appendString:@", Parked vehicles"];
        }
        if ([issueTypeArray[10] integerValue]==1){
            [issueTypeString appendString:@", Pavement condition"];
        }
        if ([issueTypeArray[11] integerValue]==1){
            [issueTypeString appendString:@", Other"];
        }
        if (issueTypeString.length != 0){
            NSRange range = {0,2};
            [issueTypeString deleteCharactersInRange:range];
        }
    }
    if(issueTypeString.length == 0){
        issueTypeString = [NSMutableString stringWithFormat:@"No infrastructure issues documented"];
    }
    
	if (self.note.image_data != nil && textLength != 0) {
        infoView.alpha = 1.0;
        infoView.backgroundColor = [UIColor blackColor];
        
        UIScrollView *scrollView = [[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 427)] autorelease];
        
        UIImageViewResizable *noteImageResize = [[[UIImageViewResizable alloc] initWithFrame:CGRectMake(0, 0, 320, 427)] autorelease];
        
        noteImageResize.image= [UIImage imageWithData:self.note.image_data];
        noteImageResize.contentMode = UIViewContentModeScaleAspectFill;
        
        [scrollView addSubview:noteImageResize];
        
        [infoView addSubview:scrollView];
        
        UIImageView *bgImageHeader      = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 80)] autorelease];
        bgImageHeader.backgroundColor = [UIColor blackColor];
        bgImageHeader.alpha = 0.8;
        [infoView addSubview:bgImageHeader];
        
        UILabel *notesHeader		= [[[UILabel alloc] initWithFrame:CGRectMake(10,5,250,25)] autorelease];
        notesHeader.backgroundColor = [UIColor clearColor];
        notesHeader.font			= [UIFont boldSystemFontOfSize:18.0];
        notesHeader.opaque			= NO;
        notesHeader.text			= @"Safety Mark Details";
        notesHeader.textColor		= [UIColor whiteColor];
        notesHeader.textAlignment = NSTextAlignmentLeft;
        [infoView addSubview:notesHeader];
        
//        UIImageView *bgImageText      = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 30, 320, 25*row+25)] autorelease];
//        bgImageText.backgroundColor = [UIColor blackColor];
//        bgImageText.alpha = 0.8;
//        [infoView addSubview:bgImageText];
        
        UITextView *notesText		= [[[UITextView alloc] initWithFrame:CGRectMake(0,30,320,25*row+25)] autorelease];
        notesText.backgroundColor	= [UIColor clearColor];
        notesText.editable			= NO;
        notesText.font				= [UIFont systemFontOfSize:16.0];
        notesText.text				= [NSString stringWithFormat:@"Date: %@ at %@ \nSeverity Level: %@ \nConflict With: %@ \nIssue Type(s): %@ \nComments: %@", newDateString, newTimeString, severityString, conflictWithString, issueTypeString, self.note.details];
        NSLog(@"note text = %@",notesText.text);
        notesText.textColor			= [UIColor whiteColor];
        [infoView addSubview:notesText];
    }
    else if (self.note.image_data != nil && textLength == 0) {
        infoView.alpha = 1.0;
        infoView.backgroundColor = [UIColor blackColor];
        
        UIScrollView *scrollView = [[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 427)] autorelease];
        
        UIImageViewResizable *noteImageResize = [[[UIImageViewResizable alloc] initWithFrame:CGRectMake(0, 0, 320, 427)] autorelease];
        
        noteImageResize.image= [UIImage imageWithData:note.image_data];
        noteImageResize.contentMode = UIViewContentModeScaleAspectFill;
        
        [scrollView addSubview:noteImageResize];
        
        [infoView addSubview:scrollView];
        
        UIImageView *bgImageHeader      = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 80)] autorelease];
        bgImageHeader.backgroundColor = [UIColor blackColor];
        bgImageHeader.alpha = 0.8;
        [infoView addSubview:bgImageHeader];
        
        UILabel *notesHeader		= [[[UILabel alloc] initWithFrame:CGRectMake(10,5,250,25)] autorelease];
        notesHeader.backgroundColor = [UIColor clearColor];
        notesHeader.font			= [UIFont boldSystemFontOfSize:18.0];
        notesHeader.opaque			= NO;
        notesHeader.text			= @"Safety Mark Details";
        notesHeader.textColor		= [UIColor whiteColor];
        notesHeader.textAlignment = NSTextAlignmentLeft;
        [infoView addSubview:notesHeader];
        
        //        UIImageView *bgImageText      = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 30, 320, 25*row+25)] autorelease];
        //        bgImageText.backgroundColor = [UIColor blackColor];
        //        bgImageText.alpha = 0.8;
        //        [infoView addSubview:bgImageText];
        
        UITextView *notesText		= [[[UITextView alloc] initWithFrame:CGRectMake(0,30,320,25*row+25)] autorelease];
        notesText.backgroundColor	= [UIColor clearColor];
        notesText.editable			= NO;
        notesText.font				= [UIFont systemFontOfSize:16.0];
        notesText.text				= [NSString stringWithFormat:@"Date: %@ at %@ \nSeverity Level: %@ \nConflict With: %@ \nIssue Type(s): %@", newDateString, newTimeString, severityString, conflictWithString, issueTypeString];
        NSLog(@"note text = %@",notesText.text);
        notesText.textColor			= [UIColor whiteColor];
        [infoView addSubview:notesText];
    }
    else if (self.note.image_data == nil && textLength != 0) {
        infoView.alpha				= kInfoViewAlpha;
        infoView.backgroundColor	= [UIColor blackColor];
        
        UILabel *notesHeader		= [[[UILabel alloc] initWithFrame:CGRectMake(10,5,250,25)] autorelease];
        notesHeader.backgroundColor = [UIColor clearColor];
        notesHeader.font			= [UIFont boldSystemFontOfSize:18.0];
        notesHeader.opaque			= NO;
        notesHeader.text			= @"Safety Mark Details";
        notesHeader.textColor		= [UIColor whiteColor];
        notesHeader.textAlignment = NSTextAlignmentLeft;
        [infoView addSubview:notesHeader];
        
        UITextView *notesText		= [[[UITextView alloc] initWithFrame:CGRectMake(0,30,320,400)] autorelease];
        notesText.backgroundColor	= [UIColor clearColor];
        notesText.editable			= NO;
        notesText.font				= [UIFont systemFontOfSize:16.0];
        notesText.text				= [NSString stringWithFormat:@"Date: %@ at %@ \n\nSeverity Level: %@ \n\nConflict With: %@ \n\nIssue Type(s): %@ \n\nComments: %@", newDateString, newTimeString, severityString, conflictWithString, issueTypeString, self.note.details];
        NSLog(@"note text = %@",notesText.text);
        notesText.textColor			= [UIColor whiteColor];
        [infoView addSubview:notesText];
    }
    else{
        infoView.alpha				= kInfoViewAlpha;
        infoView.backgroundColor	= [UIColor blackColor];
        
        UILabel *notesHeader		= [[[UILabel alloc] initWithFrame:CGRectMake(10,5,250,25)] autorelease];
        notesHeader.backgroundColor = [UIColor clearColor];
        notesHeader.font			= [UIFont boldSystemFontOfSize:18.0];
        notesHeader.opaque			= NO;
        notesHeader.text			= @"Safety Mark Details";
        notesHeader.textColor		= [UIColor whiteColor];
        notesHeader.textAlignment = NSTextAlignmentLeft;
        [infoView addSubview:notesHeader];
        
        UITextView *notesText		= [[[UITextView alloc] initWithFrame:CGRectMake(0,30,320,400)] autorelease];
        notesText.backgroundColor	= [UIColor clearColor];
        notesText.editable			= NO;
        notesText.font				= [UIFont systemFontOfSize:16.0];
        notesText.text				= [NSString stringWithFormat:@"Date: %@ at %@ \n\nSeverity Level: %@ \n\nConflict With: %@ \n\nIssue Type(s): %@", newDateString, newTimeString, severityString, conflictWithString, issueTypeString];
        NSLog(@"note text = %@",notesText.text);
        notesText.textColor			= [UIColor whiteColor];
        [infoView addSubview:notesText];

    }
     
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    //Navigation bar color
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
//    [[UINavigationBar appearance] setBackgroundColor:psuGreen];
    
   
    self.navigationController.navigationBarHidden = NO;
    self.tabBarItem.title = @"My Safety Marks";


    
	if ( self.note )
	{
        
        NSString *title = [[[NSString alloc] init] autorelease];
        switch ([self.note.note_type intValue]) {
            case 0:
                title = @"No severity level indicated";
                break;
            case 1:
                title = @"Major crash/accident";
                break;
            case 2:
                title = @"Minor crash/accident";
                break;
            case 3:
                title = @"Near crash/accident";
                break;
            case 4:
                title = @"Did not feel safe";
                break;
            case 5:
                title = @"Uncomfortable";
                break;
            default:
                break;
        }

		self.title = title;
		
        doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(infoAction:)];
			
            
        UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
        infoButton.showsTouchWhenHighlighted = YES;
        [infoButton addTarget:self action:@selector(infoAction:) forControlEvents:UIControlEventTouchUpInside];
        flipButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
        self.navigationItem.rightBarButtonItem = flipButton;
			
        [self initInfoView];
        
        CLLocationCoordinate2D noteCoordinate;
        noteCoordinate.latitude = [self.note.latitude doubleValue];
        noteCoordinate.longitude = [self.note.longitude doubleValue];
        NSLog(@"noteCoordinate is: %f, %f", noteCoordinate.latitude, noteCoordinate.longitude);
        
        MKPointAnnotation *notePoint = [[[MKPointAnnotation alloc] init] autorelease];
        notePoint.coordinate = noteCoordinate;
        notePoint.title = @"Mark Safety";
        [noteView addAnnotation:notePoint];
        
        
        MKCoordinateRegion region = { { noteCoordinate.latitude, noteCoordinate.longitude }, { 0.0078, 0.0068 }};
        [noteView setRegion:region animated:NO];
        
    }
    else{
        MKCoordinateRegion region = { { 44.1419049, -120.5380992 }, { 0.10825, 0.10825 } };
		[noteView setRegion:region animated:NO];
    }
    
    LoadingView *loading = (LoadingView*)[self.parentViewController.view viewWithTag:999];
	//NSLog(@"loading: %@", loading);
	[loading performSelector:@selector(removeView) withObject:nil afterDelay:0.5];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    UIImage *thumbnailOriginal;
    thumbnailOriginal = [self screenshot];
    
    CGRect clippedRect  = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+160, self.view.frame.size.width, self.view.frame.size.height);
    CGImageRef imageRef = CGImageCreateWithImageInRect([thumbnailOriginal CGImage], clippedRect);
    UIImage *newImage   = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    CGSize size;
    size.height = 72;
    size.width = 72;
    
    UIImage *thumbnail;
    thumbnail = shrinkImage1(newImage, size);
    
    NSData *thumbnailData = [[[NSData alloc] initWithData:UIImageJPEGRepresentation(thumbnail, 0)] autorelease];
    NSLog(@"Size of Thumbnail Image(bytes):%d",[thumbnailData length]);
    NSLog(@"Size: %f, %f", thumbnail.size.height, thumbnail.size.width);
    
    [delegate getNoteThumbnail:thumbnailData];
}


UIImage *shrinkImage1(UIImage *original, CGSize size) {
    CGFloat scale = [UIScreen mainScreen].scale;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(NULL, size.width * scale,
                                                 size.height * scale, 8, 0, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(context,
                       CGRectMake(0, 0, size.width * scale, size.height * scale),
                       original.CGImage);
    CGImageRef shrunken = CGBitmapContextCreateImage(context);
    UIImage *final = [UIImage imageWithCGImage:shrunken];
    
    CGContextRelease(context);
    CGImageRelease(shrunken);
    CGColorSpaceRelease(colorSpace);
    return final;
}


- (UIImage*)screenshot
{
    NSLog(@"Screen Shoot");
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    else
        UIGraphicsBeginImageContext(imageSize);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Iterate over every window from back to front
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen])
        {
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(context);
            // Center the context around the window's anchor point
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(context, [window transform]);
            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(context,
                                  -[window bounds].size.width * [[window layer] anchorPoint].x,
                                  -[window bounds].size.height * [[window layer] anchorPoint].y+50);
            
            // Render the layer hierarchy to the current context
            [[window layer] renderInContext:context];
            
            // Restore the context
            CGContextRestoreGState(context);
        }
    }
    
    // Retrieve the screenshot image
    UIImage *screenImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return screenImage;
}


- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation
{

    MKAnnotationView *noteAnnotation = (MKAnnotationView*)[noteView dequeueReusableAnnotationViewWithIdentifier:@"notePin"];
    
    if (!noteAnnotation)
    {
        // If an existing pin view was not available, create one
        noteAnnotation = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"notePin"]
                          autorelease];
        switch ([self.note.note_type integerValue]){
            case 0:
                noteAnnotation.image = [UIImage imageNamed:kNoteThisIssueBlack];
                break;
            case 1:
                noteAnnotation.image = [UIImage imageNamed:kNoteThisIssueRed];
                break;
            case 2:
                noteAnnotation.image = [UIImage imageNamed:kNoteThisIssueOrange];
                break;
            case 3:
                noteAnnotation.image = [UIImage imageNamed:kNoteThisIssueYellow];
                break;
            case 4:
                noteAnnotation.image = [UIImage imageNamed:kNoteThisIssueGreen];
                break;
            case 5:
                noteAnnotation.image = [UIImage imageNamed:kNoteThisIssueGreen];
                break;
            default:
                noteAnnotation.image = [UIImage imageNamed:kNoteThisIssueBlack];
                break;
        }
        //noteAnnotation.image = [UIImage imageNamed:@"noteIssueMapGlyph.png"];
        //noteAnnotation.centerOffset = CGPointMake(-(noteAnnotation.image.size.width/4),(noteAnnotation.image.size.height/3));
        NSLog(@"Note Pin Note This Issue");

        /*
        if ([note.note_type intValue]>=0 && [note.note_type intValue]<=5) {
            noteAnnotation.image = [UIImage imageNamed:@"noteIssueMapGlyph.png"];
            //noteAnnotation.centerOffset = CGPointMake(-(noteAnnotation.image.size.width/4),(noteAnnotation.image.size.height/3));
            NSLog(@"Note Pin Note This Issue");
        }
        else if ([note.note_type intValue]>=6 && [note.note_type intValue]<=11) {
            noteAnnotation.image = [UIImage imageNamed:@"noteAssetMapGlyph.png"];
            //noteAnnotation.centerOffset = CGPointMake(-(noteAnnotation.image.size.width/4),(noteAnnotation.image.size.height/3));
            NSLog(@"Note Pin Note This Asset");
        }
         */
    }
    
    return noteAnnotation;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark MKMapViewDelegate methods


- (void)mapViewWillStartLoadingMap:(MKMapView *)noteView
{
	//NSLog(@"mapViewWillStartLoadingMap");
}


- (void)mapViewDidFailLoadingMap:(MKMapView *)noteView withError:(NSError *)error
{
	NSLog(@"mapViewDidFailLoadingMap:withError: %@", [error localizedDescription]);
}


- (void)mapViewDidFinishLoadingMap:(MKMapView *)_noteView
{
	//NSLog(@"mapViewDidFinishLoadingMap");
	LoadingView *loading = (LoadingView*)[self.parentViewController.view viewWithTag:999];
	//NSLog(@"loading: %@", loading);
	[loading removeView];
}

- (void)dealloc {

    self.note = nil;
    self.doneButton = nil;
    self.flipButton = nil;
    self.infoView = nil;
    self.delegate = nil;
    
    [delegate release];
	[doneButton release];
	[flipButton release];
    [infoView release];
    [note release];
    
    [noteView release];
    
    [super dealloc];
}

@end
