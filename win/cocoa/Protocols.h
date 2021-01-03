//
//  Protocols.h
//  NetHackCocoa
//
//  Created by Bryce on 3/22/10.
//  Copyright 2010 Bryce Cogswell. All rights reserved.
//

/*
 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation, version 2
 of the License.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#import <Cocoa/Cocoa.h>

#if 0 && __MAC_OS_X_VERSION_MIN_REQUIRED < 1060
// Prior to 10.6 these were informal protocols, but we define them here so we can compile against 10.5 or 10.6
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
