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

@interface LAAddressEntryTokenSource (PrivateBits)
+ (LAAddressEntryToken*)handleParenthesisVersion:(NSString*)string;
+ (LAAddressEntryToken*)handleBracketVersion:(NSString*)string;
@end

@implementation LAAddressEntryTokenSource

+ (LAAddressEntryToken*)entryTokenFromEditingString:(NSString*)string{
	if([string rangeOfString:@"<"].location != NSNotFound && [string rangeOfString:@">"].location != NSNotFound){
		return [self handleParenthesisVersion:string];
	}
	if([string rangeOfString:@"("].location != NSNotFound && [string rangeOfString:@")"].location != NSNotFound){
		return [self handleParenthesisVersion:string];
	}
	return nil;
}

+ (LAAddressEntryToken*)handleParenthesisVersion:(NSString*)string{
	NSRange aRange = [string rangeOfString:@"("];
	NSString *email = [string substringToIndex:aRange.location];
	
	NSCharacterSet *parenSet = [NSCharacterSet characterSetWithCharactersInString:@"()"];
	NSString *name = [[string substringFromIndex:aRange.location] stringByTrimmingCharactersInSet:parenSet];
	NSArray *names = [name componentsSeparatedByString:@" "];
	NSString *firstName = [names objectAtIndex:0];
	NSString *lastName = nil;
	if([names count] > 1)
		lastName = [names objectAtIndex:1];
	
	LAAddressEntryToken *token = [[LAAddressEntryToken alloc] init];
	token.email = email;
	token.firstName = firstName;
	if(!!lastName)
		token.lastName = lastName;
	return token;
}
	
+ (LAAddressEntryToken*)handleBracketVersion:(NSString*)string{	
	NSRange aRange = [string rangeOfString:@"<"];
	NSString *name = [string substringToIndex:aRange.location];
	NSArray *names = [name componentsSeparatedByString:@" "];
	NSString *firstName = [names objectAtIndex:0];
	NSString *lastName = nil;
	if([names count] > 1)
		lastName = [names objectAtIndex:1];
	
	NSCharacterSet *bracketSet = [NSCharacterSet characterSetWithCharactersInString:@"<>"];
	NSString *email = [[string substringFromIndex:aRange.location] stringByTrimmingCharactersInSet:bracketSet];
	
	LAAddressEntryToken *token = [[LAAddressEntryToken alloc] init];
	token.email = email;
	token.firstName = firstName;
	if(!!lastName)
		token.lastName = lastName;
	return token;
}


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
	NSArray *firstNameEntries = [book recordsMatchingSearchElement:search];
	NSArray *results = [self tokenArrayFromPeople:firstNameEntries withMatchField:LAAddressEntryFirstName];
	
	search = [ABPerson searchElementForProperty:kABLastNameProperty label:nil key:nil value:substring comparison:kABPrefixMatchCaseInsensitive];
	NSMutableArray *lastNameEntries  = [[book recordsMatchingSearchElement:search] mutableCopy];
	[lastNameEntries removeObjectsInArray:firstNameEntries];
	results = [results arrayByAddingObjectsFromArray:[self tokenArrayFromPeople:lastNameEntries withMatchField:LAAddressEntryLastName]];
	
	search = [ABPerson searchElementForProperty:kABEmailProperty label:nil key:nil value:substring comparison:kABPrefixMatchCaseInsensitive];
	NSMutableArray *emailEntries = [[book recordsMatchingSearchElement:search] mutableCopy];
	[emailEntries removeObjectsInArray:firstNameEntries];
	[emailEntries removeObjectsInArray:lastNameEntries];
	results = [results arrayByAddingObjectsFromArray:[self tokenArrayFromPeople:emailEntries withMatchField:LAAddressEntryEmail]];
	
	return results;
}

- (NSString *)tokenField:(NSTokenField *)tokenField editingStringForRepresentedObject:(id)representedObject{
	if([representedObject respondsToSelector:@selector(editingString)])
		return [(LAAddressEntryToken*)representedObject editingString];
	return representedObject;
}

- (id)tokenField:(NSTokenField *)tokenField representedObjectForEditingString:(NSString *)editingString{
	return [LAAddressEntryTokenSource entryTokenFromEditingString:editingString];
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
