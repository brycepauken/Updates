//
//  NSColor+UPDColors.m
//  Updates
//
//  Created by Bryce Pauken on 7/15/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UIColor+UPDColors.h"

#include <iostream>
#include <vector>

@implementation UIColor (UPDColors)

+ (UIColor *)colorFromImage:(UIImage *)image {
    struct Pixel {
        unsigned char r, g, b, a;
    };
    struct PixelCount {
        Pixel pixel;
        int count;
    };
    struct PixelCountComparison {
        PixelCountComparison(Pixel compareTo) : compareTo(compareTo) {}
        bool operator()(PixelCount pc) const {return  pc.pixel.r==compareTo.r&&pc.pixel.g==compareTo.g&&pc.pixel.b==compareTo.b&&pc.pixel.a==compareTo.a;}
    private:
        Pixel compareTo;
    };
    struct Pixel *pixels = (struct Pixel*) calloc(1, image.size.width * image.size.height * sizeof(struct Pixel));
    if(pixels != nil) {
        CGContextRef context = CGBitmapContextCreate((void *)pixels, image.size.width, image.size.height, 8, image.size.width * 4, CGImageGetColorSpace(image.CGImage), kCGImageAlphaPremultipliedLast);
        if(context != NULL) {
            std::vector<PixelCount>pixelCounts;
            CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, image.size.width, image.size.height), image.CGImage);
            int pixelsRemaining = image.size.width * image.size.height;
            while(pixelsRemaining > 0) {
                auto existingPixel = std::find_if(pixelCounts.begin(), pixelCounts.end(), PixelCountComparison(*pixels));
                if(existingPixel != std::end(pixelCounts)) {
                    existingPixel->count++;
                    while(existingPixel != std::begin(pixelCounts) && existingPixel->count>(existingPixel-1)->count) {
                        iter_swap(existingPixel, existingPixel-1);
                        existingPixel--;
                    }
                }
                else {
                    Pixel newPixel = {.r = pixels->r, .b = pixels->b, .g = pixels->g, .a = pixels->a};
                    PixelCount newPixelCount = {.pixel = newPixel, .count = 1};
                    pixelCounts.push_back(newPixelCount);
                }
                pixels++;
                pixelsRemaining--;
            }
            CGContextRelease(context);
            Pixel commonPixel = pixelCounts.at(0).pixel;
            return [UIColor colorWithRed:(commonPixel.r/255.0f) green:(commonPixel.g/255.0f) blue:(commonPixel.b/255.0f) alpha:(commonPixel.a/255.0f)];
        }
        free(pixels);
    }
    return [UIColor whiteColor];
}

+ (UIColor *)UPDBrightBlueColor {
    static UIColor *brightBlueColor = nil;
    static dispatch_once_t dispatchOnceToken;
    
    dispatch_once(&dispatchOnceToken, ^{
        brightBlueColor = [UIColor colorWithRed:99/255.0 green:161/255.0 blue:247/255.0 alpha:1];
    });
    
    return brightBlueColor;
}

+ (UIColor *)UPDLightBlueColor {
    static UIColor *lightBlueColor = nil;
    static dispatch_once_t dispatchOnceToken;
    
    dispatch_once(&dispatchOnceToken, ^{
        lightBlueColor = [UIColor colorWithRed:115/255.0f green:167/255.0f blue:197/255.0f alpha:1];
    });
    
    return lightBlueColor;
}

+ (UIColor *)UPDLighterBlueColor {
    static UIColor *lighterBlueColor = nil;
    static dispatch_once_t dispatchOnceToken;
    
    dispatch_once(&dispatchOnceToken, ^{
        lighterBlueColor = [UIColor colorWithRed:172/255.0f green:198/255.0f blue:213/255.0f alpha:1];
    });
    
    return lighterBlueColor;
}

+ (UIColor *)UPDLightGreyBlueColor {
    static UIColor *lightBlueColor = nil;
    static dispatch_once_t dispatchOnceToken;
    
    dispatch_once(&dispatchOnceToken, ^{
        lightBlueColor = [UIColor colorWithRed:126/255.0f green:152/255.0f blue:167/255.0f alpha:1];
    });
    
    return lightBlueColor;
}

+ (UIColor *)UPDLightGreyColor {
    static UIColor *lightGrayColor = nil;
    static dispatch_once_t dispatchOnceToken;
    
    dispatch_once(&dispatchOnceToken, ^{
        lightGrayColor = [UIColor colorWithWhite:0.90 alpha:1];
    });
    
    return lightGrayColor;
}

+ (UIColor *)UPDMoreOffWhiteColor {
    static UIColor *offMoreWhiteColor = nil;
    static dispatch_once_t dispatchOnceToken;
    
    dispatch_once(&dispatchOnceToken, ^{
        offMoreWhiteColor = [UIColor colorWithWhite:0.94 alpha:1];
    });
    
    return offMoreWhiteColor;
}

+ (UIColor *)UPDOffBlackColor {
    static UIColor *offBlackColor = nil;
    static dispatch_once_t dispatchOnceToken;
    
    dispatch_once(&dispatchOnceToken, ^{
        offBlackColor = [UIColor colorWithWhite:0.1 alpha:1];
    });
    
    return offBlackColor;
}

+ (UIColor *)UPDOffWhiteColor {
    static UIColor *offWhiteColor = nil;
    static dispatch_once_t dispatchOnceToken;
    
    dispatch_once(&dispatchOnceToken, ^{
        offWhiteColor = [UIColor colorWithWhite:0.98 alpha:1];
    });
    
    return offWhiteColor;
}

+ (UIColor *)UPDOffWhiteColorTransparent {
    static UIColor *UPDOffWhiteColorTransparent = nil;
    static dispatch_once_t dispatchOnceToken;
    
    dispatch_once(&dispatchOnceToken, ^{
        UPDOffWhiteColorTransparent = [UIColor colorWithWhite:0.98 alpha:0.5];
    });
    
    return UPDOffWhiteColorTransparent;
}

@end
