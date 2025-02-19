/*
 Copyright (c) 2025 Qualcomm Innovation Center, Inc. All rights reserved.
 SPDX-License-Identifier: BSD-3-Clause-Clear
*/

#include "common.h"
#include <stdlib.h>
#include <inttypes.h>
#include <math.h>

#if defined(HAVE_SME)

/* Function prototypes */
extern void sgemm_direct_sme1_preprocess(uint64_t nbr, uint64_t nbc,\
                                  const float * restrict a, float *  a_mod) __asm__("sgemm_direct_sme1_preprocess");
extern void sgemm_direct_sme1_2VLx2VL(uint64_t m, uint64_t k, uint64_t n,\
                               const float * matLeft,\
                               const float * restrict matRight,\
                               const float * restrict matResult) __asm__("sgemm_direct_sme1_2VLx2VL");

/* Function Definitions */
uint64_t sve_cntw() {
    uint64_t cnt;
    asm volatile(
        "rdsvl  %[res], #1\n"
        "lsr    %[res], %[res], #2\n"
        : [res] "=r" (cnt) ::
    );
    return cnt;
}

/*void sgemm_kernel_direct (BLASLONG M, BLASLONG N, BLASLONG K,\
       float * __restrict A, BLASLONG strideA, float * __restrict B,\
       BLASLONG strideB , float * __restrict R, BLASLONG strideR)
*/
void CNAME (BLASLONG M, BLASLONG N, BLASLONG K, float * __restrict A,\
            BLASLONG strideA, float * __restrict B, BLASLONG strideB ,\
            float * __restrict R, BLASLONG strideR){
                
        uint64_t m_mod, vl_elms;
        
        vl_elms = sve_cntw();

        m_mod = ceil((double)M/(double)vl_elms) * vl_elms;

        float *A_mod = (float *) malloc(m_mod*K*sizeof(float));
		
        /* Pre-process the left matrix to make it suitable for 
           matrix sum of outer-product calculation
         */
        sgemm_direct_sme1_preprocess(M, K, A, A_mod);
        
        /* Calculate C = A*B */
        sgemm_direct_sme1_2VLx2VL(M, K, N, A_mod, B, R);
        
        free(A_mod);
}

#endif
