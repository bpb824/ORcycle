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
 *   Reno Tracks is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   Reno Tracks is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with Reno Tracks.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "DetailViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "NoteManager.h"
#import "ImageResize.h"

@interface DetailViewController ()
static UIImage *shrinkImage(UIImage *original, CGSize size);

- (void)updateDisplay;
- (void)getMediaFromSource:(UIImagePickerControllerSourceType)sourceType;
@end

@implementation DetailViewController
@synthesize noteDelegate;
@synthesize detailTextView;
@synthesize addPicButton;
@synthesize imageView;
@synthesize image;
@synthesize imageFrame;
@synthesize imageFrameView;
@synthesize lastChosenMediaType;
@synthesize imageData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)viewDidLoad
{
    //[self.detailTextView setText:@"Enter More Details Here"];
    //[self.detailTextView becomeFirstResponder];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if (![UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera]) {
        addPicButton.hidden = YES;
    }
    
//    detailTextView.layer.borderWidth = 1.0;
//    detailTextView.layer.borderColor = [[UIColor blackColor] CGColor];
    self.imageFrame = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"photoFrame" ofType:@"png"]];
    imageFrameView.image = imageFrame;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateDisplay];

}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}


-(IBAction)skip:(id)sender{
    NSLog(@"Skip");
    [noteDelegate didCancelNote];
    
    details = @"";
    image = nil;
    
    [noteDelegate didEnterNoteDetails:details];
    [noteDelegate didSaveImage:nil];
    [noteDelegate saveNote];
}


-(IBAction)saveDetail:(id)sender{
    NSLog(@"Save Detail");
    [detailTextView resignFirstResponder];
    [noteDelegate didCancelNote];
    
    details = detailTextView.text;
    
    [noteDelegate didEnterNoteDetails:details];
    [noteDelegate didSaveImage:imageData];
    
    //[self dismissViewControllerAnimated:YES completion:nil];
    
    [noteDelegate saveNote];
    
}

- (IBAction)getPicture:(id)sender {
    
    UIAlertView *pictureType = [[UIAlertView alloc]
                            initWithTitle:@"Image Source"
                            message:nil
                            delegate:self
                            cancelButtonTitle:@"Cancel"
                            otherButtonTitles:@"Take Photo", @"Photo Gallery", nil];
    
    [pictureType show];
    //[self getMediaFromSource:UIImagePickerControllerSourceTypeCamera];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:@"Image Source"]){
        
        if(buttonIndex == 1){
            [self getMediaFromSource:UIImagePickerControllerSourceTypeCamera];
            alertView.delegate = nil;
            [alertView.delegate release];
        }
        if( buttonIndex == 2 ) 
        {
            [self getMediaFromSource:UIImagePickerControllerSourceTypePhotoLibrary];
            alertView.delegate = nil;
            [alertView.delegate release];
        }
    }
}




/*
- (IBAction)shootPictureOrVideo:(id)sender {
    [self getMediaFromSource:UIImagePickerControllerSourceTypeCamera];
}

- (IBAction)selectExistingPictureOrVideo:(id)sender {
    [self getMediaFromSource:UIImagePickerControllerSourceTypePhotoLibrary];
}
 */

#pragma mark UIImagePickerController delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    //original
    UIImage *castedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    //save to library
    UIImageWriteToSavedPhotosAlbum(castedImage,self, nil, nil);
    
    imageData = [[NSData alloc] initWithData:UIImageJPEGRepresentation([ImageResize imageWithImage:castedImage scaledToSize:CGSizeMake(480, 320)], 1)];
    UIImage *thumbnail = [ImageResize imageWithImage:castedImage scaledToSizeWithSameAspectRatio:CGSizeMake(290, 192)];
    
    NSLog(@"Size of Image(bytes):%d",[imageData length]);
    self.image = thumbnail;
    [picker dismissViewControllerAnimated:YES completion:^{
        picker.delegate = nil;
        [picker release];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        picker.delegate = nil;
        [picker release];
    }];
    
}

#pragma mark  -

static UIImage *shrinkImage(UIImage *original, CGSize size) {
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

- (void)updateDisplay {
    imageView.image = image;
    imageView.hidden = NO;
}

- (void)getMediaFromSource:(UIImagePickerControllerSourceType)sourceType {
    //NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    if ([UIImagePickerController isSourceTypeAvailable:
         sourceType]) {
        //NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        //picker.mediaTypes = mediaTypes;
        //picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        self.navigationController.navigationBar.translucent = NO;
        picker.navigationBar.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0];
        picker.navigationBar.barStyle = self.navigationController.navigationBar.barStyle;
        UIView *fixItView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
        fixItView.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0]; //change this to match your navigation bar
        if (sourceType == UIImagePickerControllerSourceTypePhotoLibrary){
            [picker.view addSubview:fixItView];
        }
        picker.delegate = self;
        picker.modalPresentationStyle = UIModalPresentationCurrentContext;
        picker.sourceType = sourceType;
        self.imagePickerController = picker;
        [self presentViewController:picker animated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Error accessing media"
                              message:@"Device doesn’t support that media source."
                              delegate:nil
                              cancelButtonTitle:@"Drat!"
                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    self.noteDelegate = nil;
    self.detailTextView = nil;
    self.addPicButton = nil;
    self.imageView = nil;
    self.imageFrameView = nil;
    self.image = nil;
    self.imageFrame = nil;
    self.imageData = nil;
    self.lastChosenMediaType = nil;
    
    [noteDelegate release];
    [detailTextView release];
    [addPicButton release];
    [imageView release];
    [imageFrameView release];
    [image release];
    [imageFrame release];
    [imageData release];
    [lastChosenMediaType release];
    
    [super dealloc];
}


@end
