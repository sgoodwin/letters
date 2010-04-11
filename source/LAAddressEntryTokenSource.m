//
//  LAEmailAddressTokenFieldDelegate.m
//  Letters
//
//  Created by Samuel Goodwin on 4/10/10.
//  Copyright 2010 Letters App. All rights reserved.
//

#import "LAAddressEntryTokenSource.h"
#import "LAAddressBookViewController.h"
#import <AddressBook/AddressBook.h>

@implementation LAAddressEntryTokenSource

- (NSString *)tokenField:(NSTokenField *)tokenField displayStringForRepresentedObject:(id)representedObject{
	if([representedObject respondsToSelector:@selector(firstName)])
		return [NSString stringWithFormat:@"%@ %@", [representedObject valueForKey:@"firstName"], [representedObject valueForKey:@"lastName"]];
	return representedObject;
}

- (NSTokenStyle)tokenField:(NSTokenField *)tokenField styleForRepresentedObject:(id)representedObject{
	if([representedObject respondsToSelector:@selector(editingString)])
		return NSRoundedTokenStyle;
	return NSPlainTextTokenStyle;
}

- (NSArray *)tokenField:(NSTokenField *)tokenField completionsForSubstring:(NSString *)substring indexOfToken:(NSInteger)tokenIndex indexOfSelectedItem:(NSInteger *)selectedIndex{
	ABAddressBook *book = [ABAddressBook sharedAddressBook];
	ABSearchElement *search = [ABPerson searchElementForProperty:kABFirstNameProperty label:nil key:nil value:substring comparison:kABPrefixMatchCaseInsensitive];
	NSArray *matchingEntries = [book recordsMatchingSearchElement:search];
	NSArray *results = [self tokenArrayFromPeople:matchingEntries withMatchField:LAAddressEntryFirstName];
	NSLog(@"first name matches: %@", results);
	
	search = [ABPerson searchElementForProperty:kABLastNameProperty label:nil key:nil value:substring comparison:kABPrefixMatchCaseInsensitive];
	matchingEntries  = [book recordsMatchingSearchElement:search];
	results = [results arrayByAddingObjectsFromArray:[self tokenArrayFromPeople:matchingEntries withMatchField:LAAddressEntryLastName]];
	NSLog(@"last name matches: %@", results);
	
	search = [ABPerson searchElementForProperty:kABEmailProperty label:nil key:nil value:substring comparison:kABPrefixMatchCaseInsensitive];
	matchingEntries  = [book recordsMatchingSearchElement:search];
	results = [results arrayByAddingObjectsFromArray:[self tokenArrayFromPeople:matchingEntries withMatchField:LAAddressEntryEmail]];
	NSLog(@"email matches: %@", results);
	
	return results;
}

- (NSString *)tokenField:(NSTokenField *)tokenField editingStringForRepresentedObject:(id)representedObject{
	if([representedObject respondsToSelector:@selector(editingString)])
		return [(LAAddressEntryToken*)representedObject editingString];
	return representedObject;
}

- (id)tokenField:(NSTokenField *)tokenField representedObjectForEditingString:(NSString *)editingString{
	return [LAAddressEntryToken entryTokenFromEditingString:editingString];
}

- (NSArray *)tokenField:(NSTokenField *)tokenField shouldAddObjects:(NSArray *)tokens atIndex:(NSUInteger)index{
	return tokens;
}

- (NSArray *)tokenArrayFromPeople:(NSArray*)people withMatchField:(LAAddressEntryMatchField)field{
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:[people count]];
	LAAddressEntryToken *token = [[LAAddressEntryToken alloc] init];
	[people enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop){
		ABMultiValue *values = [(ABPerson*)obj valueForProperty:kABEmailProperty];
		NSString *firstName = [(ABPerson*)obj valueForProperty:kABFirstNameProperty];
		NSString *lastName = [(ABPerson*)obj valueForProperty:kABLastNameProperty];
								
		for(NSUInteger i = 0; i < [values count];i++){
			NSString *email = [values valueAtIndex:i];
			if(!!email){
				token.email = email;
				token.firstName = firstName;
				token.lastName = lastName;
				token.matchField = field;
				[result addObject:[token editingString]];
			}
		}
		return;
	}];
	return result;
}
@end
