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

#import "OFString.h"

const of_char16_t of_windows_1252_table[] = {
	0x20AC, 0xFFFF, 0x201A, 0x0192, 0x201E, 0x2026, 0x2020, 0x2021,
	0x02C6, 0x2030, 0x0160, 0x2039, 0x0152, 0xFFFF, 0x017D, 0xFFFF,
	0xFFFF, 0x2018, 0x2019, 0x201C, 0x201D, 0x2022, 0x2013, 0x2014,
	0x02DC, 0x2122, 0x0161, 0x203A, 0x0153, 0xFFFF, 0x017E, 0x0178,
	0x00A0, 0x00A1, 0x00A2, 0x00A3, 0x00A4, 0x00A5, 0x00A6, 0x00A7,
	0x00A8, 0x00A9, 0x00AA, 0x00AB, 0x00AC, 0x00AD, 0x00AE, 0x00AF,
	0x00B0, 0x00B1, 0x00B2, 0x00B3, 0x00B4, 0x00B5, 0x00B6, 0x00B7,
	0x00B8, 0x00B9, 0x00BA, 0x00BB, 0x00BC, 0x00BD, 0x00BE, 0x00BF,
	0x00C0, 0x00C1, 0x00C2, 0x00C3, 0x00C4, 0x00C5, 0x00C6, 0x00C7,
	0x00C8, 0x00C9, 0x00CA, 0x00CB, 0x00CC, 0x00CD, 0x00CE, 0x00CF,
	0x00D0, 0x00D1, 0x00D2, 0x00D3, 0x00D4, 0x00D5, 0x00D6, 0x00D7,
	0x00D8, 0x00D9, 0x00DA, 0x00DB, 0x00DC, 0x00DD, 0x00DE, 0x00DF,
	0x00E0, 0x00E1, 0x00E2, 0x00E3, 0x00E4, 0x00E5, 0x00E6, 0x00E7,
	0x00E8, 0x00E9, 0x00EA, 0x00EB, 0x00EC, 0x00ED, 0x00EE, 0x00EF,
	0x00F0, 0x00F1, 0x00F2, 0x00F3, 0x00F4, 0x00F5, 0x00F6, 0x00F7,
	0x00F8, 0x00F9, 0x00FA, 0x00FB, 0x00FC, 0x00FD, 0x00FE, 0x00FF
};
const size_t of_windows_1252_table_offset =
    256 - (sizeof(of_windows_1252_table) / sizeof(*of_windows_1252_table));

bool
of_unicode_to_windows_1252(const of_unichar_t *input, unsigned char *output,
    size_t length, bool lossy)
{
	for (size_t i = 0; i < length; i++) {
		of_unichar_t c = input[i];

		if OF_UNLIKELY (c > 0xFF) {
			if OF_UNLIKELY (c > 0xFFFF) {
				if (lossy) {
					output[i] = '?';
					continue;
				} else
					return false;
			}

			switch ((of_char16_t)c) {
			case 0x20AC:
				output[i] = 0x80;
				break;
			case 0x201A:
				output[i] = 0x82;
				break;
			case 0x192:
				output[i] = 0x83;
				break;
			case 0x201E:
				output[i] = 0x84;
				break;
			case 0x2026:
				output[i] = 0x85;
				break;
			case 0x2020:
				output[i] = 0x86;
				break;
			case 0x2021:
				output[i] = 0x87;
				break;
			case 0x2C6:
				output[i] = 0x88;
				break;
			case 0x2030:
				output[i] = 0x89;
				break;
			case 0x160:
				output[i] = 0x8A;
				break;
			case 0x2039:
				output[i] = 0x8B;
				break;
			case 0x152:
				output[i] = 0x8C;
				break;
			case 0x17D:
				output[i] = 0x8E;
				break;
			case 0x2018:
				output[i] = 0x91;
				break;
			case 0x2019:
				output[i] = 0x92;
				break;
			case 0x201C:
				output[i] = 0x93;
				break;
			case 0x201D:
				output[i] = 0x94;
				break;
			case 0x2022:
				output[i] = 0x95;
				break;
			case 0x2013:
				output[i] = 0x96;
				break;
			case 0x2014:
				output[i] = 0x97;
				break;
			case 0x2DC:
				output[i] = 0x98;
				break;
			case 0x2122:
				output[i] = 0x99;
				break;
			case 0x161:
				output[i] = 0x9A;
				break;
			case 0x203A:
				output[i] = 0x9B;
				break;
			case 0x153:
				output[i] = 0x9C;
				break;
			case 0x17E:
				output[i] = 0x9E;
				break;
			case 0x178:
				output[i] = 0x9F;
				break;
			default:
				if (lossy)
					output[i] = '?';
				else
					return false;

				break;
			}
		} else {
			if OF_UNLIKELY (c >= 0x80 && c <= 0x9F) {
				if (lossy)
					output[i] = '?';
				else
					return false;
			} else
				output[i] = (unsigned char)c;
		}
	}

	return true;
}