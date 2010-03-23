//
//  Protocols.h
//  NetHackCocoa
//
//  Created by Bryce on 3/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#if __MAC_OS_X_VERSION_MIN_REQUIRED < 1060
@protocol NSApplicationDelegate <NSObject>
@end
@protocol NSWindowDelegate <NSObject>
@end
@protocol NSTableViewDataSource <NSObject>
@end
@protocol NSTableViewDelegate <NSObject>
@end
@protocol NSMenuDelegate <NSObject>
@end
#endif
