# GNUmakefile - this file is part of Cynthiune
#
# Copyright (C) 2005  Wolfgang Sourdeau
#
# Author: Wolfgang Sourdeau <wolfgang@contre.com>
#
# This file is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.
#
# This file is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; see the file COPYING.  If not, write to
# the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
# Boston, MA 02111-1307, USA.

include $(GNUSTEP_MAKEFILES)/common.make


#
# Subprojects
#



#
# Bundle
#

PACKAGE_NAME=WaveOut
BUNDLE_NAME=WaveOut
BUNDLE_EXTENSION=.output
BUNDLE_INSTALL_DIR=$(GNUSTEP_BUNDLES)/Cynthiune
WaveOut_PRINCIPAL_CLASS=WaveOut
WaveOut_LANGUAGES=
WaveOut_LOCALIZED_RESOURCE_FILES=

#
# Additional libraries
#

WaveOut_LIBRARIES_DEPEND_UPON += 

#
# Resource files
#

WaveOut_RESOURCE_FILES=

#
# Header files
#

WaveOut_HEADERS= \
WaveOut.h

#
# Class files
#

WaveOut_OBJC_FILES= \
WaveOut.m

ADDITIONAL_INCLUDE_DIRS += -I../../Frameworks

FRAMEWORKS_DIRS = ../../Frameworks/Cynthiune
FRAMEWORKS = Cynthiune

include ../../frameworks.make

-include GNUmakefile.preamble
-include GNUmakefile.local
include $(GNUSTEP_MAKEFILES)/bundle.make
-include GNUmakefile.postamble
