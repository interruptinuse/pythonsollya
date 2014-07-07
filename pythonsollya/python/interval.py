# -*- coding: utf-8 -*-
###############################################################################
# This file is part of the metalibm Proof Of Concept project
# copyrights : Nicolas Brunie, Florent de Dinechin (2012-2013)
# all rights reserved
###############################################################################

import PythonSollyaInterface as PSI

def Interval(a, b = None): 
	if b is None: return PSI.SollyaObject.Interval(a, a)
	else: return PSI.SollyaObject.Interval(a, b)

		
