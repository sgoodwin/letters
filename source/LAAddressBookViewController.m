//
//  LAAddressBookViewController.m
//  Letters
//
//  Created by Samuel Goodwin on 3/25/10.
//  Copyright 2010 Letters App. All rights reserved.
//

#import "LAAddressBookViewController.h"
#import <AddressBook/AddressBook.h>

@implementation LAAddressBookViewController
@synthesize peoplePicker, accessoryView, delegate;

+ (LAAddressBookViewController*)newAddressBookViewControllerWithDelegate:(id<LAAddressBookViewDelegate, NSObject>)aDelegate{
    
    LAAddressBookViewController *addressbookVC = [[LAAddressBookViewController alloc] initWithWindowNibName:@"LAAddressBookView"];
	addressbookVC.delegate = aDelegate;
    
    return [addressbookVC autorelease];
}

- (void)awakeFromNib{
	[self.peoplePicker setAccessoryView:self.accessoryView];
	self.peoplePicker.target = self;
	[self.peoplePicker setNameDoubleAction:@selector(to:)];
}

- (LAAddressEntryToken *)selectedEntry{
	NSString *email = nil;
	ABPerson *person = nil;
	
	NSArray *values = [self.peoplePicker selectedValues];
	if(!!values && [values count] > 0){
		email =  [values objectAtIndex:0];
	}
	if(!email){
		NSLog(@"No use in inserting address entries with no email value.");
		return nil;
	}
	values = nil;
	
	values = [self.peoplePicker selectedRecords];
	if(!!values && [values count] > 0){
		person = [values objectAtIndex:0];
	}
	
	LAAddressEntryToken *entry = [[LAAddressEntryToken alloc] init];
	entry.firstName = [person valueForProperty:kABFirstNameProperty];
	entry.lastName = [person valueForProperty:kABLastNameProperty];
	entry.email = email;
	
	return entry;
}

- (IBAction)to:(id)sender{
	if(!!self.delegate && [self.delegate respondsToSelector:@selector(addToAddress:)]){
		LAAddressEntryToken *token = [self selectedEntry];
		if(!!token)
			[self.delegate addToAddress:token];
	}
}

- (IBAction)cc:(id)sender{
	if(!!self.delegate && [self.delegate respondsToSelector:@selector(addToAddress:)]){
		LAAddressEntryToken *token = [self selectedEntry];
		if(!!token)
			[self.delegate addCcAddress:token];
	}
}

- (IBAction)bcc:(id)sender{
	if(!!self.delegate && [self.delegate respondsToSelector:@selector(addToAddress:)]){
		LAAddressEntryToken *token = [self selectedEntry];
		if(!!token)
			[self.delegate addBccAddress:token];
	}
}

@end
