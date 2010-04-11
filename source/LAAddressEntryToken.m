//
//  LAAddressEntryToken.m
//  Letters
//
//  Created by Samuel Goodwin on 4/10/10.
//  Copyright 2010 Letters App. All rights reserved.
//

#import "LAAddressEntryToken.h"

@implementation LAAddressEntryToken
@synthesize firstName, lastName, email, matchField;

- (NSString*)editingString{
	// Returns it's editing string for a NSTokenField based on it's match. If no matchField has been specified, it
	// should default to a "John Doe <john.doe@me.com>" type string.
	switch(self.matchField){
		case LAAddressEntryFirstName:
			NSLog(@"first name match");
			return [NSString stringWithFormat:@"%@ %@ <%@>", self.firstName, self.lastName, self.email];
			break;
		case LAAddressEntryLastName:
			NSLog(@"last name match");
			return [NSString stringWithFormat:@"%@ %@ <%@>", self.lastName, self.firstName, self.email];
			break;
		case LAAddressEntryEmail:
			NSLog(@"email match");
			return [NSString stringWithFormat:@"%@ (%@ %@)", self.email, self.firstName, self.lastName];
			break;
		default:
			NSLog(@"default");
			return [NSString stringWithFormat:@"%@ %@ <%@>", self.firstName, self.lastName, self.email];
			break;
	}
}
@end
