//
//  NSBezierPath+EMMBezierPath.h
//  TextToSvgPath
//

#import <Cocoa/Cocoa.h>

@interface NSBezierPath (EMMBezierPath)

- (void)appendBezierPathWithString:(NSString *)string font:(NSFont *)font;
- (void)transformIntoSVGCoordinateSpace;

@end
