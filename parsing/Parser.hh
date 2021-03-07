#pragma once

#include <string>


struct YrtArray {
    ulong len;
    const void * data;
};

/**
 * \brief Main function called by GCC internals
 * \brief Will procude a module for each file and perform syntax and semantic analyses
 * \brief Once semantic analyse is done, if no error occurs it will produce a gimple gimple target code for each file
 * \param nb_files the number of file in input
 * \param files the list of file names
 */
extern void ymir_parse_files (int nb_files, const char ** files);

