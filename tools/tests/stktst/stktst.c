/* $Id: stktst.c 1269 2022-08-05 06:00:38Z mueller $ */
/* SPDX-License-Identifier: GPL-3.0-or-later */
/* Copyright 2022- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de> */

/* Revision History:                                                         */
/* Date         Rev Version  Comment                                         */
/* 2022-08-04  1269   1.1    rename -s to -p; warmup before r,w,h            */
/* 2022-08-03  1268   1.0    Initial version                                 */

#include <stdlib.h>
#include <stdio.h>
#include <limits.h>
#include <errno.h>
#include <string.h>

int doconv(arg)
  char  *arg;
{
  char  *eptr = NULL;
  long  res = 0;
  int   ires = 0;
  if (arg[0] == 0) {
    fprintf(stderr, "stktst-E: empty string instead of a number\n");
    exit(1);
  }
  res = strtol(arg, &eptr, 0);
  if (eptr[0] != 0) {
    fprintf(stderr, "stktst-E: number '%s' invalid after '%s' \n", arg, eptr);
    exit(1);    
  }
  
  if (errno == ERANGE || res > 0xFFFFL || res < -0x8000L) {
    fprintf(stderr, "stktst-E: number '%s' out of range\n", arg);
    exit(1);
  }

  ires = res;
  return ires;
}

print_stack(str, odat, nodat)
  char *str;
  unsigned int *odat;
  int nodat;
{
  unsigned int val, np, nc, no;
  int i;
  printf("%s", str);
  for (i=0; i<nodat; i++) {
    val = *odat++;
    np = 7-(val>>13);
    nc = 127-((val&017777)>>6);
    no = 64-(val&077);
    printf(" %06o (%1d,%3d,%2d);", val, np, nc, no);
  }
  printf("\n");
}

int main(argc, argv)
  int     argc;
  char    *argv[];
{
  int   argi = 0;
  char  cmd  = 0;
  int   rcnt = 0;
  int   cnt  = 0;
  int   idat[5];
  unsigned int   odat[3];
  int   optrwh = 0;
  int   dotst();

  if (argc < 3) {
    fprintf(stderr, "stktst-E: at least two arguments required\n");
    exit(1);
  }

  cmd  = argv[1][0];                        /* get command */
  rcnt = doconv(argv[2]);
  idat[0] = 0;                              /* command code */
  idat[1] = 0;                              /* command repeat */
  idat[2] = 0;                              /* -c repeat */
  idat[3] = 0;                              /* -p repeat */
  idat[4] = 0;                              /* -o offset */

  /* check that command is valid */
  switch (cmd) {
  case 'r':
  case 'w':
  case 'h':
    optrwh = 1;
    break;
  case 'I':
  case 'i':
  case 'l':
  case 'f':
  case 'd':
    break;
  default:
    fprintf(stderr, "stktst-E: invalid command %c\n", cmd);
    exit(1);
  }

  if (optrwh) {           /* handle r,w,h tests */
    /* warmup: noop test to get ps and call printf to get stack action */
    idat[0] = 'I';
    dotst(idat, odat);
    print_stack("stktst-I: before sp", odat, 1);
    /* now do r,w, or h test, nothing to print afterwards */
    idat[0] = cmd;
    idat[1] = rcnt;
    dotst(idat, odat);
    exit(0);
  }
  
  /* process options only for normal tests */
  for (argi=3; argi<argc; argi+=2) {
    if (argi+1 >= argc) {
      fprintf(stderr, "stktst-E: no value after %s \n", argv[argi]);
      exit(1);
    }
    cnt = doconv(argv[argi+1]);
    if (strcmp(argv[argi], "-c") == 0) {
      idat[2] = cnt;
    } else if (strcmp(argv[argi], "-p") == 0) {
      idat[3] = cnt;
    } else if (strcmp(argv[argi], "-o") == 0) {
      idat[4] = cnt;
    } else {
      fprintf(stderr, "stktst-E: bad option %s \n", argv[argi]);
      exit(1);
    }  
  }

  /* call test: 1st round */
  idat[0] = cmd;
  dotst(idat, odat);
  print_stack("stktst-I: before sp", odat, 2);

  /* call test: 2nd round */
  idat[1] = rcnt;
  dotst(idat, odat);
  print_stack("stktst-I: after  sp", odat, 3);

  exit(0);
}
