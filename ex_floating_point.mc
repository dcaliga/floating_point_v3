/* $Id: ex16.mc,v 2.1 2005/06/14 22:16:51 jls Exp $ */

/*
 * Copyright 2005 SRC Computers, Inc.  All Rights Reserved.
 *
 *	Manufactured in the United States of America.
 *
 * SRC Computers, Inc.
 * 4240 N Nevada Avenue
 * Colorado Springs, CO 80907
 * (v) (719) 262-0213
 * (f) (719) 262-0223
 *
 * No permission has been granted to distribute this software
 * without the express permission of SRC Computers, Inc.
 *
 * This program is distributed WITHOUT ANY WARRANTY OF ANY KIND.
 */

#include <libmap.h>

void subr (double  d_arr[], double  d_sum[], int msize, int64_t *tm, int mapnum) {
    OBM_BANK_A (AL, double, MAX_OBM_SIZE)
    int64_t t0, t1;
    int i;

    Stream_64 SA,SB;


#pragma src parallel sections
{
#pragma src section
{
 int i;
    streamed_dma_cpu_64 (&SA, PORT_TO_STREAM, d_arr, msize*msize*sizeof(int64_t));
}
#pragma src section
{
    int i,err,row,col,reset;
    double  v64,v;
    double  res;
    int64_t i64,j64;

    read_timer (&t0);

// we are performing a sum over the values in the upper right portion of the matrix
// since we have to read in all of the matrix, go ahead and do a sum but make the lower
// tridiagonal values zero


    for (row=0; row<msize; row++)  {
      for (col=0; col<msize; col++)  {
        get_stream_dbl_64 (&SA, &v64);

        if (col<row) v = 0.;
        else         v = v64;

        fp_accum_64 (v, col==(msize-1), 1, col==0, &res, &err);
        put_stream_dbl_64 (&SB, res, col==(msize-1));
      }
    }

    read_timer (&t1);
    *tm = t1 - t0;

}
#pragma src section
{
    streamed_dma_cpu_64 (&SB, STREAM_TO_PORT, d_sum, msize*sizeof(int64_t));
}
}


    }
