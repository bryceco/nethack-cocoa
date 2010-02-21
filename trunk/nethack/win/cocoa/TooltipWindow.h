//
//  TooltipWindow.h
//  NetHackCocoa
//
//  Created by Bryce on 2/21/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TooltipWindow : NSWindow {

}

-(id)initWithText:(NSString *)text location:(NSPoint)point;

@end
