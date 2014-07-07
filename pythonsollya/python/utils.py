# -*- coding: utf-8 -*-
###############################################################################
# This file is part of the metalibm Proof Of Concept project
# copyrights : Nicolas Brunie, Florent de Dinechin (2012)
# all rights reserved
###############################################################################

import PythonSollyaInterface as PSI


# The chunk size should be configure so that hexa value of such size
# are less than the max integer (generally equivalent to int type size)
CHUNK_SIZE = 6

def sub_convert_hexa(s):
	""" s is an hexadecimal number [[:xdigit:]]+ to be converted """
	number = PSI.SollyaObject(0)
	i = 0
	while i < len(s):
		new_i = i+CHUNK_SIZE if i +CHUNK_SIZE < len(s)  else len(s)
		shift = (new_i - i) * 4
		mant_field = s[i:new_i]
		number = (number * 2**PSI.SollyaObject(shift)) + PSI.SollyaObject(int(mant_field, 16))
		i += CHUNK_SIZE
	return number



def convert_hexa(s):
	""" convert a number in hexadecimal notation e.g: -0x6.8ep-4 
		into sollya object """
	if s == "": raise Exception("empty hexadecimal number")
	negative = -1 if (s[0] == "-") else 1
	mant_index = 3 if negative == -1 else 2 # skipping -?0x
	if '.' in s:
		point_index = s.find('.') 
		p_index = s.find("p")
		pre_mant = s[mant_index:point_index]
		frac = s[point_index+1:p_index]
		exp = int(s[p_index+1:])

		mantissa = sub_convert_hexa(pre_mant)
		i = 0
		while i < len(frac):
			new_i = i+CHUNK_SIZE if i +CHUNK_SIZE < len(frac)  else len(frac)
			shift = (new_i - i) * 4
			mant_field =frac[i:new_i]
			mantissa = (mantissa * 2**PSI.SollyaObject(shift)) + PSI.SollyaObject(int(mant_field, 16))
			i += CHUNK_SIZE
		return negative * mantissa * 2**(PSI.SollyaObject(exp - len(frac) * 4))
	else:
		p_index = s.find("p")
		pre_mant = s[mant_index:p_index]
		exp = int(s[p_index+1:])
		mantissa = sub_convert_hexa(pre_mant)
		return negative * mantissa * 2**(PSI.SollyaObject(exp))


def convert_dyadic(s):
	""" convert dyadic string to SollyaObject number """
	b_index = s.index("b")
	field = s[:b_index]
	sign = 1
	if field[0] == "-":
		sign = -1
		field = field[1:]
	power10 = PSI.SollyaObject(1)
	acc = 0 
	while field != "":
		acc += PSI.SollyaObject(int(field[-6:])) * power10
		power10 *= 10**6
		field = field[:-6]
	exp = int(s[(b_index+1):])
	return sign * acc * PSI.SollyaObject(2)**(exp)


def binary32ToAsm(cst):
	""" dummy function, not to be used """
	exp = int(PSI.log2(PSI.abs(cst))) + 127
	mant = int(PSI.abs(cst) * (PSI.SollyaObject(2)**(-exp + 23)))
	sgn = 1 if cst < 0 else 0
	field = (sgn << 31) | (exp << 23) | (mant & 0x7fffff)
	return field

def binary64ToAsm(cst):
	""" dummy function, not to be used """
	exp = int(PSI.log2(PSI.abs(cst))) + 1023
	mant = int(PSI.abs(cst) * (PSI.SollyaObject(2)**(-exp + 52)))
	sgn = 1 if cst < 0 else 0
	field = (sgn << 63) | (exp << 52) | (mant & 0x3ffffffffff)
	return field


def round_fixed(f, frac_precision):
	""" round the number f towar fixed-precision format with frac_precision bits 
		of fractionnary part """
	tmp = f * PSI.S2**frac_precision
	return PSI.nearestint(tmp) * PSI.S2**(-frac_precision)

def hex_binary_to_number(hex_value, exp_width, mant_width):
    """ conversion between hex encoded floating-point number to the corresponding SollyaObject number """
    num_value = int(hex_value, 16)
    sign = num_value >> (exp_width + mant_width)
    mantissa = num_value & (2**mant_width - 1)
    exponent = (num_value >> mant_width) & (2**exp_width-1)

    bias = 2**(exp_width-1) - 1

    if exponent == 2**exp_width - 1:
        if mantissa == 0:
            return PSI.infty if sign == 0 else -PSI.infty
        else:
            return PSI.NaN
    elif exponent == 0:
        # subnormal number
        return (+1 if sign == 0 else -1) * mantissa * PSI.S2**(-bias + 1 - mant_width)
    else:
        return (+1 if sign == 0 else -1) * ((1 << mant_width) + mantissa) * PSI.S2**(-mant_width + exponent - bias)


def number_to_hex_binary_truncated(pre_value, exp_width, mant_width):
    # conversion with truncation

    def build_hex_binary(sign, exp, mant):
        sign_shift = (sign << (exp_width + mant_width)) 
        exp_shift = (exp << mant_width) 
        print "bhb: ", hex(sign_shift), hex(exp_shift), hex(mant)
        return sign_shift | exp_shift | mant

    value = PSI.SollyaObject(pre_value)
    sign = 1 if value < 0 else 0
    if value == PSI.infty:
        exp = (1 << exp_width) - 1
        mant = 0
        return build_hex_binary(sign, exp, mant)
    elif value.test_NaN():
        exp = (1 << exp_width) - 1
        mant = (1 << mant_width) - 1
        return build_hex_binary(sign, exp, mant)
    if 1:
        bias = 2**(exp_width-1) - 1
        exp = int(PSI.floor(PSI.log2(PSI.abs(value))))
        #print "bias: ", bias, " exp: ", exp
        if exp+bias > 2**exp_width - 2:
            #print "overflow"
            return build_hex_binary(sign, 2**exp_width - 1, 0)
        elif exp+bias <= 0:
            emin = (-(2**(exp_width-1)) + 2)
            #print "subnormal ", emin
            mant = int((PSI.abs(value) / (PSI.S2**emin)) * (2**mant_width))
            return build_hex_binary(sign, 0, mant)
        else:
            #print "label ", exp+bias
            mant = int((PSI.abs(value) / (PSI.S2**exp)) * (PSI.S2**mant_width)) - 2**mant_width
            return build_hex_binary(sign, exp + bias, mant)
    

hex_binary16_to_number = lambda v: hex_binary_to_number(v, 5, 10)
hex_binary32_to_number = lambda v: hex_binary_to_number(v, 8, 23)
hex_binary64_to_number = lambda v: hex_binary_to_number(v, 11, 52)
	

number_to_hex_binary16 = lambda v: number_to_hex_binary_truncated(v, 5, 10)
number_to_hex_binary32 = lambda v: number_to_hex_binary_truncated(v, 8, 23)
number_to_hex_binary64 = lambda v: number_to_hex_binary_truncated(v, 11, 52)


	
