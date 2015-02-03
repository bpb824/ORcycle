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

#import "ImageResize.h"

@implementation ImageResize

+ (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToSize:(CGSize)targetSize;
{
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGImageRef imageRef = [sourceImage CGImage];
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
    
    if (bitmapInfo == kCGImageAlphaNone) {
        bitmapInfo = kCGImageAlphaNoneSkipLast;
    }
    
    CGContextRef bitmap;
    
    if (sourceImage.imageOrientation == UIImageOrientationUp || sourceImage.imageOrientation == UIImageOrientationDown) {
        bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
    } else {
        bitmap = CGBitmapContextCreate(NULL, targetHeight, targetWidth, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
    }
    
    if (sourceImage.imageOrientation == UIImageOrientationLeft) {
        CGContextRotateCTM (bitmap, M_PI_2); // + 90 degrees
        CGContextTranslateCTM (bitmap, 0, -targetHeight);
        
    } else if (sourceImage.imageOrientation == UIImageOrientationRight) {
        CGContextRotateCTM (bitmap, -M_PI_2); // - 90 degrees
        CGContextTranslateCTM (bitmap, -targetWidth, 0);
        
    } else if (sourceImage.imageOrientation == UIImageOrientationUp) {
        // NOTHING
    } else if (sourceImage.imageOrientation == UIImageOrientationDown) {
        CGContextTranslateCTM (bitmap, targetWidth, targetHeight);
        CGContextRotateCTM (bitmap, -M_PI); // - 180 degrees
    }
    
    CGContextDrawImage(bitmap, CGRectMake(0, 0, targetWidth, targetHeight), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* newImage = [UIImage imageWithCGImage:ref];
    
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return newImage;
}


+ (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToSizeWithSameAspectRatio:(CGSize)targetSize;
{
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor) {
            scaleFactor = widthFactor; // scale to fit height
        }
        else {
            scaleFactor = heightFactor; // scale to fit width
        }
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    CGImageRef imageRef = [sourceImage CGImage];
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
    
    if (bitmapInfo == kCGImageAlphaNone) {
        bitmapInfo = kCGImageAlphaNoneSkipLast;
    }
    
    CGContextRef bitmap;
    
    if (sourceImage.imageOrientation == UIImageOrientationUp || sourceImage.imageOrientation == UIImageOrientationDown) {
        bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
    } else {
        bitmap = CGBitmapContextCreate(NULL, targetHeight, targetWidth, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
    }
    
    // In the right or left cases, we need to switch scaledWidth and scaledHeight,
    // and also the thumbnail point
    if (sourceImage.imageOrientation == UIImageOrientationLeft) {
        thumbnailPoint = CGPointMake(thumbnailPoint.y, thumbnailPoint.x);
        CGFloat oldScaledWidth = scaledWidth;
        scaledWidth = scaledHeight;
        scaledHeight = oldScaledWidth;
        
        CGContextRotateCTM (bitmap, M_PI_2); // + 90 degrees
        CGContextTranslateCTM (bitmap, 0, -targetHeight);
        
    } else if (sourceImage.imageOrientation == UIImageOrientationRight) {
        thumbnailPoint = CGPointMake(thumbnailPoint.y, thumbnailPoint.x);
        CGFloat oldScaledWidth = scaledWidth;
        scaledWidth = scaledHeight;
        scaledHeight = oldScaledWidth;
        
        CGContextRotateCTM (bitmap, -M_PI_2); // - 90 degrees
        CGContextTranslateCTM (bitmap, -targetWidth, 0);
        
    } else if (sourceImage.imageOrientation == UIImageOrientationUp) {
        // NOTHING
    } else if (sourceImage.imageOrientation == UIImageOrientationDown) {
        CGContextTranslateCTM (bitmap, targetWidth, targetHeight);
        CGContextRotateCTM (bitmap, -M_PI); // - 180 degrees
    }
    
    CGContextDrawImage(bitmap, CGRectMake(thumbnailPoint.x, thumbnailPoint.y, scaledWidth, scaledHeight), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* newImage = [UIImage imageWithCGImage:ref];
    
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return newImage;
}


@end
