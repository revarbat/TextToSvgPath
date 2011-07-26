

#import "SpeedyCategories.h"



@implementation BezierNSLayoutManager

- (void) dealloc {
	self.theBezierPath = nil;
	[super dealloc];
}

- (NSBezierPath *)theBezierPath {
    return [[theBezierPath retain] autorelease];
}

- (void)setTheBezierPath:(NSBezierPath *)value {
    if (theBezierPath != value) {
        [theBezierPath release];
        theBezierPath = [value retain];
    }
}

	/* convert the NSString into a NSBezierPath using a specific font. */
- (void)showPackedGlyphs:(char *)glyphs length:(unsigned)glyphLen
		glyphRange:(NSRange)glyphRange atPoint:(NSPoint)point font:(NSFont *)font
		color:(NSColor *)color printingAdjustment:(NSSize)printingAdjustment {
	
		/* if there is a NSBezierPath associated with this
		layout, then append the glyphs to it. */
	NSBezierPath *bezier = [self theBezierPath];
	
	if ( nil != bezier ) {
	
			/* add the glyphs to the bezier path */
		[bezier moveToPoint:point];
		[bezier appendBezierPathWithPackedGlyphs: glyphs];
	
	}
}

@end


@implementation NSString (BezierConversions)

- (NSBezierPath*) bezierWithFont: (NSFont*) theFont {
	NSBezierPath *bezier = nil; /* default result */
	
		/* put the string's text into a text storage
		so we can access the glyphs through a layout. */
	NSTextStorage *textStore = [[NSTextStorage alloc] initWithString: self];
	NSTextContainer *textContainer = [[NSTextContainer alloc] init];
	BezierNSLayoutManager *myLayout = [[BezierNSLayoutManager alloc] init];
	[myLayout addTextContainer: textContainer];
	[textStore addLayoutManager: myLayout];
	[textStore setFont: theFont];
	
		/* create a new NSBezierPath and add it to the custom layout */
	[myLayout setTheBezierPath: [NSBezierPath bezierPath]];
	
		/* to call drawGlyphsForGlyphRange, we need a destination so we'll
		set up a temporary one.  Size is unimportant and can be small.  */
	NSImage* theImage = [[NSImage alloc] initWithSize: NSMakeSize(10.0, 10.0)];
		 /* lines are drawn in reverse order, so we will draw the text upside down
		 and then flip the resulting NSBezierPath right side up again to achieve
		 our final result with the lines in the right order and the text with
		 proper orientation.  */
    [theImage lockFocusFlipped:YES];

		/* draw all of the glyphs to collecting them into a bezier path
		using our custom layout class. */
	NSRange glyphRange = [myLayout glyphRangeForTextContainer:textContainer];
	[myLayout drawGlyphsForGlyphRange:glyphRange atPoint: NSMakePoint(0.0, 0.0)];
	
		/* clean up our temporary drawing environment */
	[theImage unlockFocus];
	[theImage release];
	
		/* retrieve the glyphs from our BezierNSLayoutManager instance */
	bezier = [myLayout theBezierPath];
	
    NSAffineTransform *affine = [NSAffineTransform transform];
    NSAffineTransformStruct transform;

    transform.m11 =  1.0;
    transform.m12 =  0.0;
    transform.tX  =  0.0;
    transform.m21 =  0.0;
    transform.m22 = -1.0;
    transform.tY  =  0.0;
    [affine setTransformStruct:transform];
    [bezier transformUsingAffineTransform:affine];
    
    transform.m11 =  1.0;
    transform.m12 =  0.0;
    transform.tX  = -[theFont leading];
    transform.m21 =  0.0;
    transform.m22 =  1.0;
    transform.tY  = -[bezier bounds].origin.y+[theFont descender];
    //transform.tY  = -[theFont ascender]; // +[theFont descender];
    [affine setTransformStruct:transform];
    [bezier transformUsingAffineTransform:affine];
    
    /* clean up our text storage objects */
	[textStore release];
	[textContainer release];
	[myLayout release];
    
		/* return the new bezier path */
	return bezier;
}
	
@end




