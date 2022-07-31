/* $Id: divtst.c 1266 2022-07-30 17:33:07Z mueller $ */
/* SPDX-License-Identifier: GPL-3.0-or-later */
/* Copyright 2014-2022 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de> */

/* Revision History:                                                         */
/* Date         Rev Version  Comment                                         */
/* 2014-07-24   570   1.0.1  use %06o throughout                             */
/* 2014-07-20   570   1.0    Initial version                                 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

doline(ibuf, obuf, trace)
char    *ibuf;
char    *obuf;
int     trace;
{
  int idat[3];
  int edat[3];
  int odat[3];
  int nscan;
  int eccn, eccz, eccv, eccc;
  int occn, occz, occv, occc;
  int nout = 0;

  if (trace) fprintf(stderr, "++line: '%s'\n", ibuf);

  /* handle ; comment lines or empty lines, simply return */
  if (ibuf[0]==0 || ibuf[0]==';') {
    return 0;
  }
  

  /* handle # comment lines, simply copy and return */
  if (ibuf[0] == '#') {
    strcpy(obuf, ibuf);
    return strlen(obuf);
  }

  /* handle command lines, parse input, quit on error */
  nscan = sscanf(ibuf, "%o %o %o : %1d%1d%1d%1d %o %o", 
                 idat+0, idat+1, idat+2,
                 &eccn, &eccz, &eccv, &eccc, edat+1, edat+2);
  if (trace) {
    fprintf(stderr, "++nscan: %d\n", nscan);
    fprintf(stderr, "++idat:  %06o %06o %06o\n", 
            idat[0], idat[1], idat[2]);
    fprintf(stderr, "++edat:  %d%d%d%d    %06o %06o\n",
            eccn, eccz, eccv, eccc, edat[1], edat[2]);
  }
  
  if (nscan != 9) return -1;

  /* perform div test */
  odat[0] = 0;
  odat[1] = 0;
  odat[2] = 0;
  dotst(idat, odat);

  occn = ((odat[0] & 010) != 0);              /* returned N */
  occz = ((odat[0] & 004) != 0);              /* returned Z */
  occv = ((odat[0] & 002) != 0);              /* returned V */
  occc = ((odat[0] & 001) != 0);              /* returned C */

  if (trace) {
    fprintf(stderr, "++odat:  %d%d%d%d %02o %06o %06o\n",
            occn, occz, occv, occc, odat[0], odat[1], odat[2]);
  }
  
  nout += sprintf(obuf+nout, "%06o %06o %06o : %d%d%d%d %06o %06o",
                  idat[0], idat[1], idat[2],
                  occn, occz, occv, occc,
                  odat[1], odat[2]);

  if (occv != eccv) nout += sprintf(obuf+nout, " VBAD");
  if (occc != eccc) nout += sprintf(obuf+nout, " CBAD");
  
  if (occv) {                               /* V=1 returned */
    if (odat[1] != idat[0]) nout += sprintf(obuf+nout, " R0MOD");
    if (odat[2] != idat[1]) nout += sprintf(obuf+nout, " R1MOD");
  } else {                                  /* V=0 returned */
    if (occn != eccn) nout += sprintf(obuf+nout, " NBAD");
    if (occz != eccz) nout += sprintf(obuf+nout, " ZBAD");
    if (odat[1] != edat[1]) nout += sprintf(obuf+nout, " QBAD");
    if (odat[2] != edat[2]) nout += sprintf(obuf+nout, " RBAD");
  }
  return strlen(obuf);
}


main(argc, argv)
int     argc;
char    *argv[];
{
  char  ibuf[132];
  char  obuf[132];
  int   trace = 0;
  int   argi;

  for (argi=1; argi<argc; argi++) {
    if (strcmp(argv[argi], "-v") == 0) trace = 1;
  }

  while (fgets(ibuf, 132, stdin)) {
    int nout = 0;
    int len = strlen(ibuf);
    if (len>0 && ibuf[len-1] == '\n') ibuf[len-1] = 0;
    obuf[0] = 0;
    nout = doline(ibuf, obuf, trace);
    if (nout < 0) {
      fprintf(stderr, "divtst-E: bad input line '%s'\n", ibuf);
      fprintf(stderr, "divtst-E: aborting divtst\n");
      exit(1);
    }
    if (nout > 0) fprintf(stdout, "%s\n", obuf);
  }

  exit(0);  
}
