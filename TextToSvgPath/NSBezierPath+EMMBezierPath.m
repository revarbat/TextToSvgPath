//
//  NSBezierPath+EMMBezierPath.m
//  TextToSvgPath
//
// Initial implementation of appendBezierPathWithString:font: by Alex Raftis,
// with modifications suggested by Douglas Davidson.
// http://www.cocoabuilder.com/archive/cocoa/22415-how-to-get-glyph-from-character.html


#import "NSBezierPath+EMMBezierPath.h"

@implementation NSBezierPath (EMMBezierPath)

- (void)appendBezierPathWithString:(NSString *)string font:(NSFont *)font
{
    NSLayoutManager *lm = [[NSLayoutManager alloc] init];
    NSTextContainer *tc = [[NSTextContainer alloc] init];
    [lm addTextContainer: tc];
    
    NSTextStorage *ts = [[NSTextStorage alloc] initWithString: string];
    [ts addLayoutManager: lm];
    [ts setFont: font];
    
    NSRange range = [lm glyphRangeForCharacterRange: (NSRange){0, [string length]}
                               actualCharacterRange: NULL];
    
    NSGlyph *glyphs = (NSGlyph *) NSZoneMalloc([self zone], sizeof(NSGlyph) *
                                               (range.length * 2));
    [lm getGlyphs: glyphs range: range];
    
    [self appendBezierPathWithGlyphs: glyphs
                               count: range.length
                              inFont: font];
    
    NSZoneFree([self zone], glyphs);
    [ts release];
    [lm release];
    [tc release];
}

- (void)transformIntoSVGCoordinateSpace
{
    NSAffineTransform *affine = [NSAffineTransform transform];
    NSAffineTransformStruct transform;
    
    transform.m11 =  1.0;
    transform.m12 =  0.0;
    transform.tX  =  0.0;
    transform.m21 =  0.0;
    transform.m22 = -1.0;
    transform.tY  =  0.0;
    [affine setTransformStruct:transform];
    [self transformUsingAffineTransform:affine];
    
    transform.m11 =  1.0;
    transform.m12 =  0.0;
    transform.tX  = -[self bounds].origin.x;
    transform.m21 =  0.0;
    transform.m22 =  1.0;
    transform.tY  = -[self bounds].origin.y;
    [affine setTransformStruct:transform];
    [self transformUsingAffineTransform:affine];
}

@end
