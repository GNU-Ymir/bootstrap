#include <ymir/parsing/Parser.hh>
#include <string.h>

#include "config.h"
#include "system.h"
#include "coretypes.h"
#include "input.h"
#include "diagnostic.h"

extern "C" void bootstrap_parse_file (YrtArray array);

extern "C" void bootstrap_fatal_error () {
    fatal_error (UNKNOWN_LOCATION, "%s", "");
}

void ymir_parse_file (const char * filename) {
    {	
	bootstrap_parse_file (YrtArray {strlen (filename), (void*) filename});
    }
}

void ymir_parse_files (int nb_files, const char ** files) {
    {     
	for (int i = 0 ; i < nb_files ; i++) {
	    ymir_parse_file (files [i]);
	}
    }
}
