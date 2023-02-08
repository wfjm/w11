/* $Id: tst_serloop.c 1369 2023-02-08 18:59:50Z mueller $ */
/* SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright 2011-2023 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
 *
 * Revision History: 
 * Date         Rev Version  Comment
 * 2023-02-08  1369   1.1.2  use %9.1f cps, it can be > 1000000.0
 * 2016-03-25   751   1.1.1  clear ASYNC_SPD_CUST if not needed
 * 2015-02-01   641   1.1    add non-standart baud rates (via custom divisor)
 * 2011-12-22   442   1.0.2  more text in usage()
 * 2011-12-18   440   1.0.1  add -lowlat command (optionally, linux specific)
 * 2011-12-09   438   1.0    Initial version (from sys_s3board/tst_serport/...)
*/

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <termios.h>
#include <string.h>
#include <limits.h>
#include <sys/time.h>
#include <time.h>
#include <signal.h>

#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <fcntl.h>

#include <linux/serial.h>

typedef unsigned int  u_int;
typedef unsigned char u_char;

static char c_xon  = 0x11;                  /* XON  char -> ^Q = hex 11 */
static char c_xoff = 0x13;                  /* XOFF char -> ^S = hex 13 */
static char c_xesc = 0x1b;                  /* XESC char -> ^[ = ESC = hex 1B */

static int nsigint = 0;
static int trace = 0;
static int xesc  = 0;
static unsigned int iseed = 1234567;

void usage(FILE* of);
int get_pint(char* p);
double get_double(char* p);
#ifdef HAS_LOWLAT
void do_lowlat(int fd);
#endif
void do_ptios(struct termios* tios, struct serial_struct* sioctl);
void do_break(int fd);
void do_write(int fd, char* buf, int nc);
void do_read(int fd);
void do_txblast(int fd, int nsec);
void do_rxblast(int fd, int nsec, int nbyt);
void do_loop(int fd, int nsec, int nbyt);
void do_sleep(int nms, int pe);
void do_sleep1(double dms);
void prt_time(void);
double get_time(void);
void mysleep(double dt);
double myrandom(void);

void sigint_handler(int signum)
{
  printf("\n");
  nsigint += 1;
  if (nsigint > 3) {
    fprintf(stderr, "tst_serloop-I: 3rd ^C, aborting\n");
    exit(EXIT_FAILURE);
  }
  return;
}

int main(int argc,char *argv[])
{
  int argi = 0;
  int fd = -1;
  int baud = -1;
  int flow = -1;
  tcflag_t baudbits = 0;
  struct termios oldtios;
  struct termios newtios;
  struct termios chktios;
  struct serial_struct sioctl;
  int cdivisor = 0;

  struct sigaction new_action;

  char devnam[256];
     
  new_action.sa_handler = sigint_handler;
  sigemptyset (&new_action.sa_mask);
  new_action.sa_flags = 0;
  sigaction (SIGINT, &new_action, NULL);

  if (argc < 4) {
    fprintf(stderr, "tst_serloop-E: missing port, speed, or flow\n");
    usage(stderr);
    return EXIT_FAILURE;
  }
  
  if (argv[1][0] == '/') {
    strncpy(devnam, argv[1], 256);
    devnam[255] = 0;
  } else {
    strcpy(devnam, "/dev/tty");
    strncpy(devnam+strlen(devnam), argv[1], 256-strlen(devnam));
    devnam[255] = 0;
  }
  
  fd = open(devnam,			    /* open tty device */
	    O_RDWR|O_NOCTTY);		    /* read/write, not controlling TTY*/

  if (fd == -1) {
    fprintf(stderr, "tst_serloop-E: failed to open \"%s\"\n", devnam);
    perror("open:");
    return EXIT_FAILURE;
  }
  
  if (!isatty(fd)) {
    fprintf(stderr, "tst_serloop-E: \"%s\" is not a tty port\n", devnam);
    return EXIT_FAILURE;
  }
  
  if(tcgetattr(fd, &oldtios) == -1) {	    /* save old tios */
    perror("failed to tcgetattr:");
    return EXIT_FAILURE;
  }

  if (ioctl(fd, TIOCGSERIAL, &sioctl) < 0) {
    perror("failed to ioctl(TIOCGSERIAL):");
    return EXIT_FAILURE;
  }

  baud = get_pint(argv[2]);
  if (baud < 0) return EXIT_FAILURE;

  /* Note: allow all baud rates above 2400 baud which are defined by linux
   *       in /usr/include/bits/termios.h . Only a subset of them might be 
   *       supported in a given device.
   */
  switch (baud) {
    case    2400:   baudbits =    B2400; break;
    case    4800:   baudbits =    B4800; break;
    case    9600:   baudbits =    B9600; break;
    case   19200:   baudbits =   B19200; break;
    case   38400:   baudbits =   B38400; break;
    case   57600:   baudbits =   B57600; break;
    case  115200:   baudbits =  B115200; break;
    case  230400:   baudbits =  B230400; break;
    case  460800:   baudbits =  B460800; break;
    case  500000:   baudbits =  B500000; break;
    case  576000:   baudbits =  B576000; break;
    case  921600:   baudbits =  B921600; break;
    case 1000000:   baudbits = B1000000; break;
    case 1152000:   baudbits = B1152000; break;
    case 1500000:   baudbits = B1500000; break;
    case 2000000:   baudbits = B2000000; break;
    case 2500000:   baudbits = B2500000; break;
    case 3000000:   baudbits = B3000000; break;
    case 3500000:   baudbits = B3500000; break;
    case 4000000:   baudbits = B4000000; break;
  }

  if (baudbits == 0) {
    double fcdivisor = (double)sioctl.baud_base / (double)baud;
    cdivisor = fcdivisor + 0.5;
    baudbits = B38400;
    // printf("+++ fcdivisor = %6.2f\n", fcdivisor);
  }

  flow = get_pint(argv[3]);
  if (flow < 0) return EXIT_FAILURE;
  if (flow > 2) {
    fprintf(stderr, "tst_serloop-E: flow must be 0,1,2; seen: %d\n", flow);
    return EXIT_FAILURE;
  }
  if (flow == 2) xesc = 1;

  memset(&newtios,0,sizeof(newtios));	    /* clear new tios */
  newtios.c_iflag = IGNPAR;                 /* ignore parity errors */
  newtios.c_oflag = 0;
  newtios.c_cflag = CS8|                    /* 8 bit chars */
                    CSTOPB|		    /* 2 stop bits */
                    CREAD|                  /* enable receiver */
                    CLOCAL|                 /* ignore modem control */
                    baudbits;               /* baud rate flags */
  newtios.c_lflag = 0;
  newtios.c_cc[VTIME] =  1;                 /* timeout after 100 ms */
  newtios.c_cc[VMIN]  =  0;                 /* don't wait for char's */

  if (flow == 1) {
    newtios.c_cflag |= CRTSCTS;             /* enable rts/cts flow control */
  } else if (flow == 2) {
    newtios.c_iflag |= IXON|                /* XON/XOFF flow control output */
                       IXOFF;               /* XON/XOFF flow control input */
    newtios.c_cc[VSTART] = c_xon;           /* setup XON  -> ^Q */
    newtios.c_cc[VSTOP]  = c_xoff;          /* setup XOFF -> ^S */
  }

  if (tcsetattr(fd, TCSANOW, &newtios) == -1) { /* set tios */
    perror("failed to tcsetattr:");
    return EXIT_FAILURE;
  }

  if (sioctl.flags & ASYNC_SPD_CUST) {      /* old CUST set ? */
    sioctl.flags          &= ~(ASYNC_SPD_CUST);
    sioctl.custom_divisor  = 0;
    if (ioctl(fd, TIOCSSERIAL, &sioctl) < 0) {
      perror("failed to ioctl(TIOCSSERIAL):");
      tcsetattr(fd, TCSANOW, &oldtios);
      return EXIT_FAILURE;
    }
  }

  if (cdivisor != 0) {                      /* new CUST needed ? */
    sioctl.flags          |= ASYNC_SPD_CUST;
    sioctl.custom_divisor  = cdivisor;
    if (ioctl(fd, TIOCSSERIAL, &sioctl) < 0) {
      perror("failed to ioctl(TIOCSSERIAL):");
      tcsetattr(fd, TCSANOW, &oldtios);
      return EXIT_FAILURE;
    }
  }
  

  if (tcgetattr(fd, &chktios) == -1) {	    /* verify tios */
    perror("failed to tcgetattr:");
    tcsetattr(fd, TCSANOW, &oldtios);
    return EXIT_FAILURE;
  }

  for (argi = 4; argi < argc; ) {
    if (strcmp(argv[argi],"-help") == 0) {
      argi += 1;
      usage(stdout);
      return EXIT_SUCCESS;

#ifdef HAS_LOWLAT
    } else if (strcmp(argv[argi],"-lowlat") == 0) {
      argi += 1;
      do_lowlat(fd);
#endif

    } else if (strcmp(argv[argi],"-ptios") == 0) {
      argi += 1;
      do_ptios(&newtios, &sioctl);

    } else if (strcmp(argv[argi],"-break") == 0) {
      argi += 1;
      do_break(fd);

    } else if (strcmp(argv[argi],"-trace") == 0) {
      argi += 1;
      trace = 1;

    } else if (strcmp(argv[argi],"-write") == 0) {
      char buf[4096];
      int  nc = 0;
      argi += 1;
      while(argi < argc && nc < 4096) {
        char *argp = argv[argi];
        int doneg = 0;
        int val = 0;
        if (argp[0] == '-') break;
        if (strcmp(argp,"XON") == 0) {
          val = c_xon;
        } else if (strcmp(argp,"XOFF") == 0) {
          val = c_xoff;
        } else if (strcmp(argp,"XESC") == 0) {
          val = c_xesc;
        } else {        
          if (argp[0] == '~') {
            argp += 1;
            doneg = 1;
          }
          val = get_pint(argp);
          if (val < 0) {
            nc = 0;
            break;
          }
          if (doneg) val = ~val;
        }
        
        argi += 1;
        buf[nc++] = val;
      }
      if (nc == 0) {
        fprintf(stderr, "tst_serloop-E: bad char list\n");
        break;
      }
      
      do_write(fd, buf, nc);

    } else if (strcmp(argv[argi],"-read") == 0) {
      argi += 1;
      do_read(fd);

    } else if (strcmp(argv[argi],"-txblast") == 0) {
      int nsec = -1;
      argi += 1;
      if (argi < argc) nsec = get_pint(argv[argi++]);
      if (nsec >= 0) do_txblast(fd, nsec);
      else {
        fprintf(stderr, "tst_serloop-E: bad args for -txblast\n");
        break;
      }

    } else if (strcmp(argv[argi],"-rxblast") == 0) {
      int nsec = -1;
      int nbyt = -1;
      argi += 1;
      if (argi < argc) nsec = get_pint(argv[argi++]);
      if (argi < argc) nbyt = get_pint(argv[argi++]);
      if (nsec >= 0 && nbyt > 0 && nbyt <= 4096) do_rxblast(fd, nsec, nbyt);
      else {
        fprintf(stderr, "tst_serloop-E: bad args for -rxblast\n");
        break;
      }

    } else if (strcmp(argv[argi],"-loop") == 0) {
      int nsec = -1;
      int nbyt = -1;
      argi += 1;
      if (argi < argc) nsec = get_pint(argv[argi++]);
      if (argi < argc) nbyt = get_pint(argv[argi++]);
      if (nsec >= 0 && nbyt > 0 && nbyt <= 4096) do_loop(fd, nsec, nbyt);
      else {
        fprintf(stderr, "tst_serloop-E: bad args for -loop\n");
        break;
      }

    } else if (strcmp(argv[argi],"-sleep") == 0) {
      int nms = -1;
      argi += 1;
      if (argi < argc) nms = get_pint(argv[argi++]);	
      if (nms > 0) do_sleep(nms, 1);
      else {
        fprintf(stderr, "tst_serloop-E: bad args for -sleep\n");
        break;
      }
      
    } else if (strcmp(argv[argi],"-sleep1") == 0) {
      double dms = -1.;
      argi += 1;
      if (argi < argc) dms = get_double(argv[argi++]);
      if (dms > 0) do_sleep1(dms);
      else {
        fprintf(stderr, "tst_serloop-E: bad args for -sleep1\n");
        break;
      }
      
    } else {
      fprintf(stderr, "tst_serloop-E: unknown option %s\n", argv[argi]);
      usage(stderr);
      return EXIT_FAILURE;
    }
  }

  /* a delay is needed between tcdrain() and tcsetattr() because the baud 
   * rate reset can take effect in FT232Rs before the internal tx buffer is
   * transmitted, so some late chars will be send with oldtios baud rate.
  */

  tcdrain(fd);
  do_sleep(50, 0);
  tcsetattr(fd, TCSANOW, &oldtios);
  return EXIT_SUCCESS;
}

/*--------------------------------------------------------------------------*/

void usage(FILE* of) 
{
  fprintf(of, "Usage:  tst_serloop port speed flow [option...]\n");
  fprintf(of, "    port     name of /dev file, e.g. /dev/ttyUSB0\n");
  fprintf(of, "    speed    baud rate: 2400,4800,9600,19200,38400,57600\n");
  fprintf(of, "               115200,230400,460800,500000,921600,1000000\n");
  fprintf(of, "               1152000,1500000,2000000,2500000,3000000\n");
  fprintf(of, "               3500000,4000000, others via custom divisor\n");
  fprintf(of, "    flow     0 no flow control\n");
  fprintf(of, "             1 hardware flow control (RTS/CTS)\n");
  fprintf(of, "             2 software flow control (XON/XOFF)\n");
  fprintf(of, "-help        this text\n");
  fprintf(of, "-ptios       print tios structures\n");
#ifdef HAS_LOWLAT
  fprintf(of, "-lowlat      set low latency mode\n");
#endif
  fprintf(of, "-break       send break\n");
  fprintf(of, "-trace       trace i/o in blast and loop\n");
  fprintf(of, "-write c..   write sequence of chars\n");
  fprintf(of, "-read        read chars till timeout\n");
  fprintf(of, "-txblast ns  read txblast output for ns sec (ns=0->forever)\n");
  fprintf(of, "-rxblast ns nb write rxblast input for ns sec, nb byte bufs \n");
  fprintf(of, "-loop ns nb  write/read loop-back data for ns sec, nb bufs\n");
  fprintf(of, "-sleep n     wait n msec (n int, 1msec resolutions)\n");
  fprintf(of, "-sleep1 dt   wait dt msec (dt float, busy wait)\n");
}

/*--------------------------------------------------------------------------*/

int get_pint(char* p)
{
  char *endptr;
  long num = 0;

  num = strtol(p, &endptr, 0);
  if ((endptr && *endptr) || num < 0 || num > INT_MAX) {
    fprintf(stderr, "tst_serloop-E: \"%s\" not a non-negative integer\n", p);
    return -1;
  }
  return num;
}

/*--------------------------------------------------------------------------*/

double get_double(char* p)
{
  char *endptr;
  double num = 0.;

  num = strtod(p, &endptr);
  if ((endptr && *endptr) || num < 0.) {
    fprintf(stderr, "tst_serloop-E: \"%s\" not a valid positive float\n", p);
    return -1.;
  }
  return num;
}

/*--------------------------------------------------------------------------*/

#ifdef HAS_LOWLAT
void do_lowlat(int fd)
{
  struct serial_struct serial_ioctl;

  if (ioctl(fd, TIOCGSERIAL, &serial_ioctl) != 0) 
    perror("do_lowlat->ioctl(TIOCGSERIAL):");
  printf("old: serial_ioctl.flags = %8.8x\n", serial_ioctl.flags);

  serial_ioctl.flags |= ASYNC_LOW_LATENCY;

  if (ioctl(fd, TIOCSSERIAL, &serial_ioctl) != 0) 
    perror("do_lowlat->ioctl(TIOCSSERIAL):");
  if (ioctl(fd, TIOCGSERIAL, &serial_ioctl) != 0) 
    perror("do_lowlat->ioctl(TIOCGSERIAL)(2):");
  printf("new: serial_ioctl.flags = %8.8x\n", serial_ioctl.flags);
  return;
}
#endif

/*--------------------------------------------------------------------------*/
void do_ptios(struct termios* tios, struct serial_struct* sioctl)
{
  printf("  sioctl->flags:           0x%8.8x\n", sioctl->flags);
  printf("  sioctl->custom_divisor:  %8d\n",     sioctl->custom_divisor);
  printf("  sioctl->baud_base:       %8d\n",     sioctl->baud_base);
  return;
}

/*--------------------------------------------------------------------------*/
void do_break(int fd)
{
  char buf[1];
  buf[0] = 0x80;
  
  if (tcflush(fd, TCIOFLUSH) < 0) perror("do_break->tcflush:");
  if (tcsendbreak(fd, 0) < 0)     perror("do_break->tcsendbreak:");
  if (write(fd, buf, 1) != 1)     perror("do_break->write:");
  if (tcdrain(fd) < 0)            perror("do_break->tcdrain:");
  return;
}

/*--------------------------------------------------------------------------*/

void do_write(int fd, char* buf, int nc)
{
  int rc;
  int i;
  rc = write(fd, buf, nc);
  prt_time();
  printf("write %3d char:", nc);
  for (i = 0; i < nc; i++) printf(" %2.2x", (u_char)buf[i]);
  printf("\n");
  if (rc < 0) perror("do_write->write:");
  return;
}


/*--------------------------------------------------------------------------*/

void do_read(int fd)
{
  int rc;
  int i;
  char buf[4096];
  while (1) {
    rc = read(fd, buf, 4096);
    if (rc == 0) break;
    prt_time();
    printf("read  %3d char:", rc);
    for (i = 0; i < rc; i++) printf(" %2.2x", (u_char)buf[i]);
    printf("\n");
    if (rc < 0) perror("do_read->read:");
  }
  return;
}

/*--------------------------------------------------------------------------*/

void do_txblast(int fd, int nsec)
{
  char buf[4096];
  double t_start;
  double t_first;
  double t_lastto;
  double t_delta;
  double ntot = 0.;
  char cval = 0;
  int xesc_pend = 0;
  int i;

  prt_time();
  printf("read txblast output for %d seconds\n", nsec);

  t_start  = get_time();
  t_first  = t_start;
  t_lastto = t_start;
  
  while (nsec == 0 || (get_time()-t_start) < nsec) {
    if (nsigint > 0) break;

    int nc;
    while (1) {
      nc = read(fd, buf, 4096);
      if (nc >= 0 || errno != EINTR) break;
    }
    if (nc < 0) {
      perror("do_txblast->read:");
      break;
    }
    if (trace) {
      prt_time();
      printf("got %4d char:  ", nc);
      if (nc <= 5) {
        int i;
        for (i = 0; i < nc; i++) printf(" %2.2x", (u_char)buf[i]);
      } else {
        printf(" %2.2x %2.2x", (u_char)buf[0], (u_char)buf[1]);
        printf(" .. %2.2x %2.2x", (u_char)buf[nc-2], (u_char)buf[nc-1]);
      }
      printf("\n");
    }
    if (nc == 0) {
      double t_now = get_time();
      if (t_now-t_lastto > 1.) {
        prt_time();
        printf("time out, no data seen\n");
        t_lastto = t_now;
      }
    }

    for (i = 0; i < nc; i++) {
      char dat = buf[i];
      if (xesc) {
        if (dat == c_xesc) {
          xesc_pend = 1;
          continue;
        }
        if (xesc_pend) {
          dat = ~dat;
          xesc_pend = 0;
        }
      }
      if (ntot == 0.) {
        cval = dat;
        prt_time();
        printf("sequence starts with %2.2x\n", (u_char)dat);
        t_first  = get_time();
      } else {
        cval += 1;
        if (cval != dat) {
          prt_time();
          printf("error: seen %2.2x expect %2.2x after %10.0f char\n", 
                 (u_char)dat, (u_char)cval, ntot);
          cval = dat;
        }
      }
      ntot += 1.;
    }
  }

  t_delta = get_time() - t_first;
  if (t_delta > 0. && ntot > 0.) {
    prt_time();
    printf("%10.0f char in %7.2f sec -> %8.1f char/sec\n", 
           ntot, t_delta, ntot/t_delta);
  }

  return;
}

/*--------------------------------------------------------------------------*/

void do_rxblast(int fd, int nsec, int nbyt)
{
  char buf[8192];
  double t_start;
  double t_delta;
  double ntot = 0.;
  char cval = 0;
  int i;

  prt_time();
  printf("write rxblast input for %d seconds\n", nsec);

  t_start  = get_time();
  
  while (nsec == 0 || (get_time()-t_start) < nsec) {
    if (nsigint > 0) break;

    int nc = 0;
    for (i = 0; i < nbyt; i++) {
      if (xesc && (cval==c_xon || cval==c_xoff || cval==c_xesc)) {
        buf[nc++] = c_xesc;
        buf[nc++] = ~cval;
      } else {
        buf[nc++] = cval;
      }
      cval += 1;
    }

    int ndone = 0;
    while (ndone < nc) {
      int rc = write(fd, buf+ndone, nc-ndone);
      if (rc > 0) {
        ndone += rc;
      } else {
        if (errno != EINTR) {
          perror("do_rxblast->write:");
          nsigint += 1;
          break;
        }
      }
    }
    /*tcdrain(fd);*/
    ntot += nbyt;
  }

  t_delta = get_time() - t_start;
  if (t_delta > 0. && ntot > 0.) {
    prt_time();
    printf("%10.0f char in %7.2f sec -> %8.1f char/sec\n", 
           ntot, t_delta, ntot/t_delta);
  }

  return;
}

/*--------------------------------------------------------------------------*/

void do_loop(int fd, int nsec, int nbyt)
{
  char buftx[8192];
  char bufrx[8192];
  double t_start;
  double t_delta;
  double ntot = 0.;
  double nloop = 0.;
  char cval = 0;
  int i;

  prt_time();
  printf("write/read loop-back data for %d seconds\n", nsec);

  t_start  = get_time();
  
  while (nsec == 0 || (get_time()-t_start) < nsec) {
    if (nsigint > 0) break;

    int nc = 0;
    for (i = 0; i < nbyt; i++) {
      if (xesc && (cval==c_xon || cval==c_xoff || cval==c_xesc)) {
        buftx[nc++] = c_xesc;
        buftx[nc++] = ~cval;
      } else {
        buftx[nc++] = cval;
      }
      cval += 1;
    }

    int ndone = 0;
    while (ndone < nc) {
      int rc = write(fd, buftx+ndone, nc-ndone);
      if (rc > 0) {
        ndone += rc;
      } else {
        if (errno != EINTR) {
          perror("do_loop->write:");
          nsigint += 1;
          break;
        }
      }
    }

    if (trace) {
      prt_time();
      printf("tx %4d char:  ", nc);
      for (i = 0; i < nc; i++) {
        printf(" %2.2x", (u_char)buftx[i]);
        if ((i+1)%16==0 && i+1!=nc) printf("\n                               ");
      }
      printf("\n");
    }

    /*tcdrain(fd);*/

    ndone = 0;
    while (ndone < nc) {
      int rc = read(fd, bufrx+ndone, nc-ndone);
      if (rc > 0) {
        ndone += rc;
      } else if (rc == 0) {
        prt_time();
        printf("loop read time out, expected %4d seen %4d\n", nc, ndone);
        nsigint += 1;
        break;
      } else {
        if (errno != EINTR) {
          perror("do_loop->read:");
          nsigint += 1;
          break;
        }
      }
    }

    if (trace) {
      prt_time();
      printf("rx %4d char:  ", ndone);
      for (i = 0; i < ndone; i++) {
        printf(" %2.2x", (u_char)bufrx[i]);
        if ((i+1)%16==0 && i+1!=ndone) 
          printf("\n                               ");
      }
      printf("\n");
    }

    for (i = 0; i < nc; i++) {
      if (bufrx[i] != buftx[i]) {
        prt_time();
        printf("rx-tx mismatch: ind: %4d rx: %2.2x tx: %2.2x\n",
               i, (u_char)bufrx[i], (u_char)buftx[i]);
      }
    }

    ntot   += nbyt;
    nloop  += 1.;
  }

  t_delta = get_time() - t_start;
  if (t_delta > 0. && nloop > 0. && ntot > 0.) {
    prt_time();
    printf("%7.2fs %5.0f l %9.0f c: %5.1f lps %9.1f cps\n", 
           t_delta, nloop, ntot, nloop/t_delta, ntot/t_delta);
  }

  return;
}

/*--------------------------------------------------------------------------*/

void do_sleep(int nms, int pe) 
{
  struct timespec req;
  struct timespec rem;
  int irc;
  double t_start;
  double t_delta;

  req.tv_sec  = nms/1000;
  req.tv_nsec = 1000000*(nms%1000);
  
  t_start = get_time();
  irc = nanosleep(&req, &rem);
  if (irc < 0) perror("do_sleep->nanosleep:");
  t_delta = get_time() - t_start;
  if (pe) {
    prt_time();
    printf("slept for %8.6f seconds\n", t_delta);
  }
}

/*--------------------------------------------------------------------------*/

void do_sleep1(double dms) 
{
  double t_start;
  double t_delta;

  prt_time();
  t_start = get_time();
  mysleep(dms/1000.);
  t_delta = get_time() - t_start;
  printf("slept for %8.6f seconds\n", t_delta);
}

/*--------------------------------------------------------------------------*/

void prt_time(void)
{
  struct timeval tv;
  struct timezone tz;
  struct tm tmval;

  gettimeofday(&tv, &tz);
  localtime_r(&tv.tv_sec, &tmval);
  printf("%04d-%02d-%02d:%02d:%02d:%02d.%06d: ",
	 tmval.tm_year+1900, tmval.tm_mon+1, tmval.tm_mday,
	 tmval.tm_hour, tmval.tm_min, tmval.tm_sec, 
	 (int) tv.tv_usec);
}

/*--------------------------------------------------------------------------*/

double get_time(void)
{
  struct timeval tv;
  struct timezone tz;
  gettimeofday(&tv, &tz);
  return (double)tv.tv_sec + 1.e-6 * (double)tv.tv_usec;
}

/*--------------------------------------------------------------------------*/

void mysleep(double dt) 
{
  double t_start;
  double t_end;
  int nloop=0;

  t_start = get_time();
  t_end   = t_start + dt;

  while (dt>0. && get_time()<t_end) {
    nloop += 1;
  }
  
  //printf("used %8d loops for %9.6f sec\n", nloop, dt);
}

/*--------------------------------------------------------------------------*/

double myrandom(void)
{
  double rndm;

  iseed *= 69069;
  rndm = (double)(iseed>>8 & 0x00ffffff) / (256.*256.*256.);

  //printf("rndm() %9.6f\n", rndm);
  return rndm;
}

