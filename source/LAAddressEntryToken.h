//
//  LAAddressEntryToken.h
//  Letters
//
//  Created by Samuel Goodwin on 4/10/10.
//  Copyright 2010 Letters App. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
    LAAddressEntryFirstName = 0,
    LAAddressEntryLastName,
    LAAddressEntryEmail,
} LAAddressEntryMatchField;

// A generic object to return the chosen name/email so that it can be tokenized.
@interface LAAddressEntryToken : NSObject{
	NSString *firstName, *lastName;
	NSString *email;
	LAAddressEntryMatchField matchField;
}
@property(nonatomic, retain) NSString *firstName, *lastName;
@property(nonatomic, retain) NSString *email;
@property(nonatomic, assign) LAAddressEntryMatchField matchField;

- (NSString*)editingString;
@end
