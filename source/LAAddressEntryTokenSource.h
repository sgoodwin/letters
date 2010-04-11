//
//  LAEmailAddressTokenFieldDelegate.h
//  Letters
//
//  Created by Samuel Goodwin on 4/10/10.
//  Copyright 2010 Letters App. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LAAddressEntryToken.h"

@interface LAAddressEntryTokenSource : NSObject <NSTokenFieldDelegate>{

}
+ (LAAddressEntryToken*)entryTokenFromEditingString:(NSString*)string;

- (NSArray *)tokenArrayFromPeople:(NSArray*)people withMatchField:(LAAddressEntryMatchField)field;
@end