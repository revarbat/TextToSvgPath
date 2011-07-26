#import <Cocoa/Cocoa.h>



@interface BezierNSLayoutManager: NSLayoutManager {
	NSBezierPath* theBezierPath;
}
- (void) dealloc;

@property (nonatomic, copy) NSBezierPath* theBezierPath;

	/* convert the NSString into a NSBezierPath using a specific font. */
- (void)showPackedGlyphs:(char *)glyphs length:(unsigned)glyphLen
		glyphRange:(NSRange)glyphRange atPoint:(NSPoint)point font:(NSFont *)font
		color:(NSColor *)color printingAdjustment:(NSSize)printingAdjustment;
@end


@interface NSString (BezierConversions)

	/* convert the NSString into a NSBezierPath using a specific font. */
- (NSBezierPath*) bezierWithFont: (NSFont*) theFont;

@end


