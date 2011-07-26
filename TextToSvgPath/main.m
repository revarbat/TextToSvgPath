//
//  main.m
//  TextToSvgPath
//
//  Created by Garth Minette on 7/24/11.
//  Copyright 2011 Belfry DevWorks. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SpeedyCategories.h"


void usage(const char* arg0);


int main (int argc, const char * argv[])
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    NSString *text = nil;
    NSString *fontName = @"Times New Roman";
    NSInteger fontSize = 72;
    BOOL doHeaders = NO;
    BOOL isBold = NO;
    BOOL isItalic = NO;

    for (int i = 1; i < argc; i++) {
        if (argv[i][0] == '-') {
            switch (argv[i][1]) {
                case 'f': // -f Font   Font Name
                    if (i >= argc-1) {
                        usage(argv[0]);
                        exit(-1);
                    }
                    fontName = [NSString stringWithCString:argv[++i] encoding:NSUTF8StringEncoding];
                    break;
                    
                case 's': // -s Size   Font Size
                    if (i >= argc-1) {
                        usage(argv[0]);
                        exit(-1);
                    }
                    fontSize = strtod(argv[++i], NULL);
                    break;
                    
                case 'b': // -b        Bold
                    isBold = YES;
                    break;
                    
                case 'i': // -i        Italic
                    isItalic = YES;
                    break;
                    
                case 'w': // -i        Italic
                    doHeaders = YES;
                    break;
                    
                default:
                    break;
            }
        } else {
            NSString *newText = [NSString stringWithCString:argv[i] encoding:NSUTF8StringEncoding];
            if (text == nil) {
                text = newText;
            } else {
                text = [NSString stringWithFormat:@"%@ %@", text, newText];
            }
        }
    }
    if (text == nil) {
        usage(argv[0]);
        exit(-1);
    }
    
    NSFontSymbolicTraits traits = 0;
    if (isBold) {
        traits |= NSBoldFontMask;
    } else {
        traits |= NSUnboldFontMask;
    }
    if (isItalic) {
        traits |= NSItalicFontMask;
    } else {
        traits |= NSUnitalicFontMask;
    }
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    NSFont *font = [fontManager fontWithFamily:fontName traits:traits weight:5 size:fontSize];
    if (font == nil) {
        fprintf(stderr, "Unknown font: '%s'\n", [fontName UTF8String]);
        exit(-2);
    }
    NSBezierPath *bezierPath = [text bezierWithFont:font];
    
    NSMutableString *outStr = [[[NSMutableString alloc] init] autorelease];
    NSInteger elements = [bezierPath elementCount];
    for (int i = 0; i < elements; i++) {
        NSPoint points[3];
        
        if (i != 0) {
            [outStr appendString:@" "];
        }
        switch ([bezierPath elementAtIndex:i associatedPoints:points]) {
            case NSMoveToBezierPathElement:
                // MoveTo
                if (i < elements-1) {
                    [outStr appendFormat:@"M %.1f %.1f", points[0].x, points[0].y];
                }
                break;
            case NSLineToBezierPathElement:
                // LineTo
                [outStr appendFormat:@"L %.1f %.1f", points[0].x, points[0].y];
                break;
            case NSCurveToBezierPathElement:
                // CurveTo
                [outStr appendFormat:@"C %.1f %.1f %.1f %.1f %.1f %.1f",
                    points[0].x, points[0].y,
                    points[1].x, points[1].y,
                    points[2].x, points[2].y];
                break;
            case NSClosePathBezierPathElement:
                // ClosePath
                [outStr appendString:@"Z"];
                break;
        }
    }

    if (doHeaders) {
        fprintf(stdout, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
        fprintf(stdout, "<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\" \"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\">\n");
        fprintf(stdout, "<svg xmlns=\"http://www.w3.org/2000/svg\" xml:space=\"preserve\" style=\"shape-rendering:geometricPrecision; text-rendering:geometricPrecision; image-rendering:optimizeQuality; fill-rule:evenodd; clip-rule:evenodd\" xmlns:xlink=\"http://www.w3.org/1999/xlink\">\n");
        fprintf(stdout, "<path d=\"");
    }
    
    fprintf(stdout, "%s", [outStr UTF8String]);
    
    if (doHeaders) {
        fprintf(stdout, "\" />\n");
        fprintf(stdout, "<path d=\"M 150 0 L 0 0 L 0 72 L 150 72\" stroke=\"black\" fill=\"none\" />\n");
        fprintf(stdout, "</svg>\n");
    } else {
        fprintf(stdout, "\n");
    }

    [pool drain];
    return 0;
}



void usage(const char* arg0)
{
    fprintf(stderr, "Usage: %s [-f FONT] [-s FLOAT] [-b] [-i] [-w] TEXT\n", arg0);
    exit(-1);
}


