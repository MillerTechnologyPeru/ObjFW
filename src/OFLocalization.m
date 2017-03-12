/*
 * Copyright (c) 2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017
 *   Jonathan Schleifer <js@heap.zone>
 *
 * All rights reserved.
 *
 * This file is part of ObjFW. It may be distributed under the terms of the
 * Q Public License 1.0, which can be found in the file LICENSE.QPL included in
 * the packaging of this file.
 *
 * Alternatively, it may be distributed under the terms of the GNU General
 * Public License, either version 2 or 3, which can be found in the file
 * LICENSE.GPLv2 or LICENSE.GPLv3 respectively included in the packaging of this
 * file.
 */

#include "config.h"

#include <locale.h>

#import "OFLocalization.h"
#import "OFString.h"
#import "OFArray.h"
#import "OFDictionary.h"

#import "OFInvalidArgumentException.h"
#import "OFInvalidEncodingException.h"

static OFLocalization *sharedLocalization = nil;

@implementation OFLocalization
@synthesize language = _language, territory = _territory, encoding = _encoding;
@synthesize decimalPoint = _decimalPoint;

+ (instancetype)sharedLocalization
{
	return sharedLocalization;
}

+ (OFString*)language
{
	return [sharedLocalization language];
}

+ (OFString*)territory
{
	return [sharedLocalization territory];
}

+ (of_string_encoding_t)encoding
{
	return [sharedLocalization encoding];
}

+ (OFString*)decimalPoint
{
	return [sharedLocalization decimalPoint];
}

+ (void)addLanguageDirectory: (OFString*)path
{
	[sharedLocalization addLanguageDirectory: path];
}

- initWithLocale: (char*)locale
{
	self = [super init];

	@try {
		_localizedStrings = [[OFMutableArray alloc] init];
	} @catch (id e) {
		[self release];
		@throw e;
	}

	if (locale == NULL) {
		_encoding = OF_STRING_ENCODING_UTF_8;
		_decimalPoint = @".";

		sharedLocalization = self;

		return self;
	}

	locale = of_strdup(locale);

	@try {
		char *tmp;

		/* We don't care for extras behind the @ */
		if ((tmp = strrchr(locale, '@')) != NULL)
			*tmp = '\0';

		/* Encoding */
		if ((tmp = strrchr(locale, '.')) != NULL) {
			*tmp++ = '\0';

			@try {
				const of_string_encoding_t ascii =
				    OF_STRING_ENCODING_ASCII;

				_encoding = of_string_parse_encoding([OFString
				    stringWithCString: tmp
					     encoding: ascii]);
			} @catch (OFInvalidEncodingException *e) {
			}
		}

		/* Territory */
		if ((tmp = strrchr(locale, '_')) != NULL) {
			*tmp++ = '\0';

			_territory = [[OFString alloc]
			    initWithCString: tmp
				   encoding: OF_STRING_ENCODING_ASCII];
		}

		_language = [[OFString alloc]
		    initWithCString: locale
			   encoding: OF_STRING_ENCODING_ASCII];

		_decimalPoint = [[OFString alloc]
		    initWithCString: localeconv()->decimal_point
			   encoding: _encoding];
	} @catch (id e) {
		[self release];
		@throw e;
	} @finally {
		free(locale);
	}

	sharedLocalization = self;

	return self;
}

- (void)dealloc
{
	[_language release];
	[_territory release];
	[_decimalPoint release];
	[_localizedStrings release];

	[super dealloc];
}

- (void)addLanguageDirectory: (OFString*)path
{
	void *pool = objc_autoreleasePoolPush();
	OFString *mapPath =
	    [path stringByAppendingPathComponent: @"languages.json"];
	OFDictionary *map =
	    [[OFString stringWithContentsOfFile: mapPath] JSONValue];
	OFString *language, *territory, *languageFile;

	language = [_language lowercaseString];
	territory = [_territory lowercaseString];

	languageFile = [[map objectForKey: language] objectForKey: territory];
	if (languageFile == nil)
		languageFile = [[map objectForKey: language]
		    objectForKey: @""];

	if (languageFile == nil) {
		objc_autoreleasePoolPop(pool);
		return;
	}

	languageFile = [path stringByAppendingPathComponent:
	    [languageFile stringByAppendingString: @".json"]];

	[_localizedStrings addObject:
	    [[OFString stringWithContentsOfFile: languageFile] JSONValue]];

	objc_autoreleasePoolPop(pool);
}

- (OFString*)localizedStringForID: (OFConstantString*)ID
			 fallback: (OFConstantString*)fallback, ...
{
	OFString *ret;
	va_list args;

	va_start(args, fallback);
	ret = [self localizedStringForID: ID
				fallback: fallback
			       arguments: args];
	va_end(args);

	return ret;
}

- (OFString*)localizedStringForID: (OFConstantString*)ID
			 fallback: (OFConstantString*)fallback
			arguments: (va_list)arguments
{
	OFMutableString *ret = [OFMutableString string];
	void *pool = objc_autoreleasePoolPush();
	const char *UTF8String = NULL;
	size_t last, UTF8StringLength;
	int state = 0;

	for (OFDictionary *strings in _localizedStrings) {
		id string = [strings objectForKey: ID];

		if (string == nil)
			continue;

		if ([string isKindOfClass: [OFArray class]])
			string = [string componentsJoinedByString: @""];

		UTF8String = [string UTF8String];
		UTF8StringLength = [string UTF8StringLength];
		break;
	}

	if (UTF8String == NULL) {
		UTF8String = [fallback UTF8String];
		UTF8StringLength = [fallback UTF8StringLength];
	}

	state = 0;
	last = 0;
	for (size_t i = 0; i < UTF8StringLength; i++) {
		switch (state) {
		case 0:
			if (UTF8String[i] == '%') {
				[ret appendUTF8String: UTF8String + last
					       length: i - last];

				last = i + 1;
				state = 1;
			}
			break;
		case 1:
			if (UTF8String[i] == '[') {
				last = i + 1;
				state = 2;
			} else {
				[ret appendString: @"%"];
				state = 0;
			}
			break;
		case 2:
			if (UTF8String[i] == ']') {
				va_list argsCopy;
				OFConstantString *name;

				OFString *var = [OFString
				    stringWithUTF8String: UTF8String + last
						  length: i - last];

				/*
				 * We loop, as most of the time, we only have
				 * one or maybe two variables, meaning looping
				 * is faster than constructing a dictionary.
				 */
				va_copy(argsCopy, arguments);
				while ((name = va_arg(argsCopy,
				    OFConstantString*)) != nil) {
					id value = va_arg(argsCopy, id);

					if (value == nil)
						@throw
						    [OFInvalidArgumentException
						    exception];

					if ([name isEqual: var]) {
						[ret appendString:
						    [value description]];
						break;
					}
				}

				last = i + 1;
				state = 0;
			}
			break;
		}
	}
	switch (state) {
	case 1:
		[ret appendString: @"%"];
		/* Explicit fall-through */
	case 0:
		[ret appendUTF8String: UTF8String + last
			       length: UTF8StringLength - last];
		break;
	}

	objc_autoreleasePoolPop(pool);

	[ret makeImmutable];

	return ret;
}
@end
