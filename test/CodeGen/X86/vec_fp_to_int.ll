; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+sse2 | FileCheck %s --check-prefix=ALL --check-prefix=SSE --check-prefix=SSE2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx | FileCheck %s --check-prefix=ALL --check-prefix=AVX --check-prefix=AVX1
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx2 | FileCheck %s --check-prefix=ALL --check-prefix=AVX --check-prefix=AVX2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512f | FileCheck %s --check-prefix=ALL --check-prefix=AVX512 --check-prefix=AVX512F
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512f,+avx512vl | FileCheck %s --check-prefix=ALL --check-prefix=AVX512 --check-prefix=AVX512VL
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512dq,+avx512vl | FileCheck %s --check-prefix=ALL --check-prefix=AVX512 --check-prefix=AVX512VLDQ
;
; 32-bit tests to make sure we're not doing anything stupid.
; RUN: llc < %s -mtriple=i686-unknown-unknown
; RUN: llc < %s -mtriple=i686-unknown-unknown -mattr=+sse
; RUN: llc < %s -mtriple=i686-unknown-unknown -mattr=+sse2

;
; Double to Signed Integer
;

define <2 x i64> @fptosi_2f64_to_2i64(<2 x double> %a) {
; SSE-LABEL: fptosi_2f64_to_2i64:
; SSE:       # BB#0:
; SSE-NEXT:    cvttsd2si %xmm0, %rax
; SSE-NEXT:    movd %rax, %xmm1
; SSE-NEXT:    movhlps {{.*#+}} xmm0 = xmm0[1,1]
; SSE-NEXT:    cvttsd2si %xmm0, %rax
; SSE-NEXT:    movd %rax, %xmm0
; SSE-NEXT:    punpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm0[0]
; SSE-NEXT:    movdqa %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: fptosi_2f64_to_2i64:
; AVX:       # BB#0:
; AVX-NEXT:    vcvttsd2si %xmm0, %rax
; AVX-NEXT:    vmovq %rax, %xmm1
; AVX-NEXT:    vpermilpd {{.*#+}} xmm0 = xmm0[1,0]
; AVX-NEXT:    vcvttsd2si %xmm0, %rax
; AVX-NEXT:    vmovq %rax, %xmm0
; AVX-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm1[0],xmm0[0]
; AVX-NEXT:    retq
;
; AVX512F-LABEL: fptosi_2f64_to_2i64:
; AVX512F:       # BB#0:
; AVX512F-NEXT:    vcvttsd2si %xmm0, %rax
; AVX512F-NEXT:    vmovq %rax, %xmm1
; AVX512F-NEXT:    vpermilpd {{.*#+}} xmm0 = xmm0[1,0]
; AVX512F-NEXT:    vcvttsd2si %xmm0, %rax
; AVX512F-NEXT:    vmovq %rax, %xmm0
; AVX512F-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm1[0],xmm0[0]
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: fptosi_2f64_to_2i64:
; AVX512VL:       # BB#0:
; AVX512VL-NEXT:    vcvttsd2si %xmm0, %rax
; AVX512VL-NEXT:    vmovq %rax, %xmm1
; AVX512VL-NEXT:    vpermilpd {{.*#+}} xmm0 = xmm0[1,0]
; AVX512VL-NEXT:    vcvttsd2si %xmm0, %rax
; AVX512VL-NEXT:    vmovq %rax, %xmm0
; AVX512VL-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm1[0],xmm0[0]
; AVX512VL-NEXT:    retq
;
; AVX512VLDQ-LABEL: fptosi_2f64_to_2i64:
; AVX512VLDQ:       # BB#0:
; AVX512VLDQ-NEXT:    vcvttpd2qq %xmm0, %xmm0
; AVX512VLDQ-NEXT:    retq
  %cvt = fptosi <2 x double> %a to <2 x i64>
  ret <2 x i64> %cvt
}

define <4 x i32> @fptosi_2f64_to_4i32(<2 x double> %a) {
; SSE-LABEL: fptosi_2f64_to_4i32:
; SSE:       # BB#0:
; SSE-NEXT:    cvttpd2dq %xmm0, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: fptosi_2f64_to_4i32:
; AVX:       # BB#0:
; AVX-NEXT:    vcvttpd2dq %xmm0, %xmm0
; AVX-NEXT:    retq
;
; AVX512-LABEL: fptosi_2f64_to_4i32:
; AVX512:       # BB#0:
; AVX512-NEXT:    vcvttpd2dq %xmm0, %xmm0
; AVX512-NEXT:    retq
  %cvt = fptosi <2 x double> %a to <2 x i32>
  %ext = shufflevector <2 x i32> %cvt, <2 x i32> zeroinitializer, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  ret <4 x i32> %ext
}

define <2 x i32> @fptosi_2f64_to_2i32(<2 x double> %a) {
; SSE-LABEL: fptosi_2f64_to_2i32:
; SSE:       # BB#0:
; SSE-NEXT:    cvttpd2dq %xmm0, %xmm0
; SSE-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,1,1,3]
; SSE-NEXT:    retq
;
; AVX-LABEL: fptosi_2f64_to_2i32:
; AVX:       # BB#0:
; AVX-NEXT:    vcvttpd2dq %xmm0, %xmm0
; AVX-NEXT:    vpmovzxdq {{.*#+}} xmm0 = xmm0[0],zero,xmm0[1],zero
; AVX-NEXT:    retq
;
; AVX512-LABEL: fptosi_2f64_to_2i32:
; AVX512:       # BB#0:
; AVX512-NEXT:    vcvttpd2dq %xmm0, %xmm0
; AVX512-NEXT:    vpmovzxdq {{.*#+}} xmm0 = xmm0[0],zero,xmm0[1],zero
; AVX512-NEXT:    retq
  %cvt = fptosi <2 x double> %a to <2 x i32>
  ret <2 x i32> %cvt
}

define <4 x i32> @fptosi_4f64_to_2i32(<2 x double> %a) {
; SSE-LABEL: fptosi_4f64_to_2i32:
; SSE:       # BB#0:
; SSE-NEXT:    cvttpd2dq %xmm0, %xmm1
; SSE-NEXT:    cvttpd2dq %xmm0, %xmm0
; SSE-NEXT:    punpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; SSE-NEXT:    retq
;
; AVX-LABEL: fptosi_4f64_to_2i32:
; AVX:       # BB#0:
; AVX-NEXT:    # kill: %XMM0<def> %XMM0<kill> %YMM0<def>
; AVX-NEXT:    vcvttpd2dqy %ymm0, %xmm0
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
;
; AVX512F-LABEL: fptosi_4f64_to_2i32:
; AVX512F:       # BB#0:
; AVX512F-NEXT:    # kill: %XMM0<def> %XMM0<kill> %YMM0<def>
; AVX512F-NEXT:    vcvttpd2dqy %ymm0, %xmm0
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: fptosi_4f64_to_2i32:
; AVX512VL:       # BB#0:
; AVX512VL-NEXT:    # kill: %XMM0<def> %XMM0<kill> %YMM0<def>
; AVX512VL-NEXT:    vcvttpd2dq %ymm0, %xmm0
; AVX512VL-NEXT:    retq
;
; AVX512VLDQ-LABEL: fptosi_4f64_to_2i32:
; AVX512VLDQ:       # BB#0:
; AVX512VLDQ-NEXT:    # kill: %XMM0<def> %XMM0<kill> %YMM0<def>
; AVX512VLDQ-NEXT:    vcvttpd2dq %ymm0, %xmm0
; AVX512VLDQ-NEXT:    retq
  %ext = shufflevector <2 x double> %a, <2 x double> undef, <4 x i32> <i32 0, i32 1, i32 undef, i32 undef>
  %cvt = fptosi <4 x double> %ext to <4 x i32>
  ret <4 x i32> %cvt
}

define <4 x i64> @fptosi_4f64_to_4i64(<4 x double> %a) {
; SSE-LABEL: fptosi_4f64_to_4i64:
; SSE:       # BB#0:
; SSE-NEXT:    cvttsd2si %xmm0, %rax
; SSE-NEXT:    movd %rax, %xmm2
; SSE-NEXT:    movhlps {{.*#+}} xmm0 = xmm0[1,1]
; SSE-NEXT:    cvttsd2si %xmm0, %rax
; SSE-NEXT:    movd %rax, %xmm0
; SSE-NEXT:    punpcklqdq {{.*#+}} xmm2 = xmm2[0],xmm0[0]
; SSE-NEXT:    cvttsd2si %xmm1, %rax
; SSE-NEXT:    movd %rax, %xmm3
; SSE-NEXT:    movhlps {{.*#+}} xmm1 = xmm1[1,1]
; SSE-NEXT:    cvttsd2si %xmm1, %rax
; SSE-NEXT:    movd %rax, %xmm0
; SSE-NEXT:    punpcklqdq {{.*#+}} xmm3 = xmm3[0],xmm0[0]
; SSE-NEXT:    movdqa %xmm2, %xmm0
; SSE-NEXT:    movdqa %xmm3, %xmm1
; SSE-NEXT:    retq
;
; AVX1-LABEL: fptosi_4f64_to_4i64:
; AVX1:       # BB#0:
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX1-NEXT:    vcvttsd2si %xmm1, %rax
; AVX1-NEXT:    vmovq %rax, %xmm2
; AVX1-NEXT:    vpermilpd {{.*#+}} xmm1 = xmm1[1,0]
; AVX1-NEXT:    vcvttsd2si %xmm1, %rax
; AVX1-NEXT:    vmovq %rax, %xmm1
; AVX1-NEXT:    vpunpcklqdq {{.*#+}} xmm1 = xmm2[0],xmm1[0]
; AVX1-NEXT:    vcvttsd2si %xmm0, %rax
; AVX1-NEXT:    vmovq %rax, %xmm2
; AVX1-NEXT:    vpermilpd {{.*#+}} xmm0 = xmm0[1,0]
; AVX1-NEXT:    vcvttsd2si %xmm0, %rax
; AVX1-NEXT:    vmovq %rax, %xmm0
; AVX1-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm2[0],xmm0[0]
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: fptosi_4f64_to_4i64:
; AVX2:       # BB#0:
; AVX2-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX2-NEXT:    vcvttsd2si %xmm1, %rax
; AVX2-NEXT:    vmovq %rax, %xmm2
; AVX2-NEXT:    vpermilpd {{.*#+}} xmm1 = xmm1[1,0]
; AVX2-NEXT:    vcvttsd2si %xmm1, %rax
; AVX2-NEXT:    vmovq %rax, %xmm1
; AVX2-NEXT:    vpunpcklqdq {{.*#+}} xmm1 = xmm2[0],xmm1[0]
; AVX2-NEXT:    vcvttsd2si %xmm0, %rax
; AVX2-NEXT:    vmovq %rax, %xmm2
; AVX2-NEXT:    vpermilpd {{.*#+}} xmm0 = xmm0[1,0]
; AVX2-NEXT:    vcvttsd2si %xmm0, %rax
; AVX2-NEXT:    vmovq %rax, %xmm0
; AVX2-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm2[0],xmm0[0]
; AVX2-NEXT:    vinserti128 $1, %xmm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: fptosi_4f64_to_4i64:
; AVX512F:       # BB#0:
; AVX512F-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX512F-NEXT:    vcvttsd2si %xmm1, %rax
; AVX512F-NEXT:    vmovq %rax, %xmm2
; AVX512F-NEXT:    vpermilpd {{.*#+}} xmm1 = xmm1[1,0]
; AVX512F-NEXT:    vcvttsd2si %xmm1, %rax
; AVX512F-NEXT:    vmovq %rax, %xmm1
; AVX512F-NEXT:    vpunpcklqdq {{.*#+}} xmm1 = xmm2[0],xmm1[0]
; AVX512F-NEXT:    vcvttsd2si %xmm0, %rax
; AVX512F-NEXT:    vmovq %rax, %xmm2
; AVX512F-NEXT:    vpermilpd {{.*#+}} xmm0 = xmm0[1,0]
; AVX512F-NEXT:    vcvttsd2si %xmm0, %rax
; AVX512F-NEXT:    vmovq %rax, %xmm0
; AVX512F-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm2[0],xmm0[0]
; AVX512F-NEXT:    vinserti128 $1, %xmm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: fptosi_4f64_to_4i64:
; AVX512VL:       # BB#0:
; AVX512VL-NEXT:    vextractf32x4 $1, %ymm0, %xmm1
; AVX512VL-NEXT:    vcvttsd2si %xmm1, %rax
; AVX512VL-NEXT:    vmovq %rax, %xmm2
; AVX512VL-NEXT:    vpermilpd {{.*#+}} xmm1 = xmm1[1,0]
; AVX512VL-NEXT:    vcvttsd2si %xmm1, %rax
; AVX512VL-NEXT:    vmovq %rax, %xmm1
; AVX512VL-NEXT:    vpunpcklqdq {{.*#+}} xmm1 = xmm2[0],xmm1[0]
; AVX512VL-NEXT:    vcvttsd2si %xmm0, %rax
; AVX512VL-NEXT:    vmovq %rax, %xmm2
; AVX512VL-NEXT:    vpermilpd {{.*#+}} xmm0 = xmm0[1,0]
; AVX512VL-NEXT:    vcvttsd2si %xmm0, %rax
; AVX512VL-NEXT:    vmovq %rax, %xmm0
; AVX512VL-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm2[0],xmm0[0]
; AVX512VL-NEXT:    vinserti32x4 $1, %xmm1, %ymm0, %ymm0
; AVX512VL-NEXT:    retq
;
; AVX512VLDQ-LABEL: fptosi_4f64_to_4i64:
; AVX512VLDQ:       # BB#0:
; AVX512VLDQ-NEXT:    vcvttpd2qq %ymm0, %ymm0
; AVX512VLDQ-NEXT:    retq
  %cvt = fptosi <4 x double> %a to <4 x i64>
  ret <4 x i64> %cvt
}

define <4 x i32> @fptosi_4f64_to_4i32(<4 x double> %a) {
; SSE-LABEL: fptosi_4f64_to_4i32:
; SSE:       # BB#0:
; SSE-NEXT:    cvttpd2dq %xmm1, %xmm1
; SSE-NEXT:    cvttpd2dq %xmm0, %xmm0
; SSE-NEXT:    punpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; SSE-NEXT:    retq
;
; AVX-LABEL: fptosi_4f64_to_4i32:
; AVX:       # BB#0:
; AVX-NEXT:    vcvttpd2dqy %ymm0, %xmm0
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
;
; AVX512F-LABEL: fptosi_4f64_to_4i32:
; AVX512F:       # BB#0:
; AVX512F-NEXT:    vcvttpd2dqy %ymm0, %xmm0
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: fptosi_4f64_to_4i32:
; AVX512VL:       # BB#0:
; AVX512VL-NEXT:    vcvttpd2dq %ymm0, %xmm0
; AVX512VL-NEXT:    retq
;
; AVX512VLDQ-LABEL: fptosi_4f64_to_4i32:
; AVX512VLDQ:       # BB#0:
; AVX512VLDQ-NEXT:    vcvttpd2dq %ymm0, %xmm0
; AVX512VLDQ-NEXT:    retq
  %cvt = fptosi <4 x double> %a to <4 x i32>
  ret <4 x i32> %cvt
}

;
; Double to Unsigned Integer
;

define <2 x i64> @fptoui_2f64_to_2i64(<2 x double> %a) {
; SSE-LABEL: fptoui_2f64_to_2i64:
; SSE:       # BB#0:
; SSE-NEXT:    movsd {{.*#+}} xmm2 = mem[0],zero
; SSE-NEXT:    movapd %xmm0, %xmm1
; SSE-NEXT:    subsd %xmm2, %xmm1
; SSE-NEXT:    cvttsd2si %xmm1, %rax
; SSE-NEXT:    movabsq $-9223372036854775808, %rcx # imm = 0x8000000000000000
; SSE-NEXT:    xorq %rcx, %rax
; SSE-NEXT:    cvttsd2si %xmm0, %rdx
; SSE-NEXT:    ucomisd %xmm2, %xmm0
; SSE-NEXT:    cmovaeq %rax, %rdx
; SSE-NEXT:    movd %rdx, %xmm1
; SSE-NEXT:    movhlps {{.*#+}} xmm0 = xmm0[1,1]
; SSE-NEXT:    movaps %xmm0, %xmm3
; SSE-NEXT:    subsd %xmm2, %xmm3
; SSE-NEXT:    cvttsd2si %xmm3, %rax
; SSE-NEXT:    xorq %rcx, %rax
; SSE-NEXT:    cvttsd2si %xmm0, %rcx
; SSE-NEXT:    ucomisd %xmm2, %xmm0
; SSE-NEXT:    cmovaeq %rax, %rcx
; SSE-NEXT:    movd %rcx, %xmm0
; SSE-NEXT:    punpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm0[0]
; SSE-NEXT:    movdqa %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: fptoui_2f64_to_2i64:
; AVX:       # BB#0:
; AVX-NEXT:    vmovsd {{.*#+}} xmm1 = mem[0],zero
; AVX-NEXT:    vsubsd %xmm1, %xmm0, %xmm2
; AVX-NEXT:    vcvttsd2si %xmm2, %rax
; AVX-NEXT:    movabsq $-9223372036854775808, %rcx # imm = 0x8000000000000000
; AVX-NEXT:    xorq %rcx, %rax
; AVX-NEXT:    vcvttsd2si %xmm0, %rdx
; AVX-NEXT:    vucomisd %xmm1, %xmm0
; AVX-NEXT:    cmovaeq %rax, %rdx
; AVX-NEXT:    vmovq %rdx, %xmm2
; AVX-NEXT:    vpermilpd {{.*#+}} xmm0 = xmm0[1,0]
; AVX-NEXT:    vsubsd %xmm1, %xmm0, %xmm3
; AVX-NEXT:    vcvttsd2si %xmm3, %rax
; AVX-NEXT:    xorq %rcx, %rax
; AVX-NEXT:    vcvttsd2si %xmm0, %rcx
; AVX-NEXT:    vucomisd %xmm1, %xmm0
; AVX-NEXT:    cmovaeq %rax, %rcx
; AVX-NEXT:    vmovq %rcx, %xmm0
; AVX-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm2[0],xmm0[0]
; AVX-NEXT:    retq
;
; AVX512F-LABEL: fptoui_2f64_to_2i64:
; AVX512F:       # BB#0:
; AVX512F-NEXT:    vcvttsd2usi %xmm0, %rax
; AVX512F-NEXT:    vmovq %rax, %xmm1
; AVX512F-NEXT:    vpermilpd {{.*#+}} xmm0 = xmm0[1,0]
; AVX512F-NEXT:    vcvttsd2usi %xmm0, %rax
; AVX512F-NEXT:    vmovq %rax, %xmm0
; AVX512F-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm1[0],xmm0[0]
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: fptoui_2f64_to_2i64:
; AVX512VL:       # BB#0:
; AVX512VL-NEXT:    vcvttsd2usi %xmm0, %rax
; AVX512VL-NEXT:    vmovq %rax, %xmm1
; AVX512VL-NEXT:    vpermilpd {{.*#+}} xmm0 = xmm0[1,0]
; AVX512VL-NEXT:    vcvttsd2usi %xmm0, %rax
; AVX512VL-NEXT:    vmovq %rax, %xmm0
; AVX512VL-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm1[0],xmm0[0]
; AVX512VL-NEXT:    retq
;
; AVX512VLDQ-LABEL: fptoui_2f64_to_2i64:
; AVX512VLDQ:       # BB#0:
; AVX512VLDQ-NEXT:    vcvttpd2uqq %xmm0, %xmm0
; AVX512VLDQ-NEXT:    retq
  %cvt = fptoui <2 x double> %a to <2 x i64>
  ret <2 x i64> %cvt
}

define <4 x i32> @fptoui_2f64_to_4i32(<2 x double> %a) {
; SSE-LABEL: fptoui_2f64_to_4i32:
; SSE:       # BB#0:
; SSE-NEXT:    movsd {{.*#+}} xmm1 = mem[0],zero
; SSE-NEXT:    movapd %xmm0, %xmm2
; SSE-NEXT:    subsd %xmm1, %xmm2
; SSE-NEXT:    cvttsd2si %xmm2, %rax
; SSE-NEXT:    movabsq $-9223372036854775808, %rcx # imm = 0x8000000000000000
; SSE-NEXT:    xorq %rcx, %rax
; SSE-NEXT:    cvttsd2si %xmm0, %rdx
; SSE-NEXT:    ucomisd %xmm1, %xmm0
; SSE-NEXT:    cmovaeq %rax, %rdx
; SSE-NEXT:    movd %rdx, %xmm2
; SSE-NEXT:    movhlps {{.*#+}} xmm0 = xmm0[1,1]
; SSE-NEXT:    movaps %xmm0, %xmm3
; SSE-NEXT:    subsd %xmm1, %xmm3
; SSE-NEXT:    cvttsd2si %xmm3, %rax
; SSE-NEXT:    xorq %rcx, %rax
; SSE-NEXT:    cvttsd2si %xmm0, %rcx
; SSE-NEXT:    ucomisd %xmm1, %xmm0
; SSE-NEXT:    cmovaeq %rax, %rcx
; SSE-NEXT:    movd %rcx, %xmm0
; SSE-NEXT:    punpcklqdq {{.*#+}} xmm2 = xmm2[0],xmm0[0]
; SSE-NEXT:    pshufd {{.*#+}} xmm0 = xmm2[0,1,0,2]
; SSE-NEXT:    psrldq {{.*#+}} xmm0 = xmm0[8,9,10,11,12,13,14,15],zero,zero,zero,zero,zero,zero,zero,zero
; SSE-NEXT:    retq
;
; AVX-LABEL: fptoui_2f64_to_4i32:
; AVX:       # BB#0:
; AVX-NEXT:    vmovsd {{.*#+}} xmm1 = mem[0],zero
; AVX-NEXT:    vsubsd %xmm1, %xmm0, %xmm2
; AVX-NEXT:    vcvttsd2si %xmm2, %rax
; AVX-NEXT:    movabsq $-9223372036854775808, %rcx # imm = 0x8000000000000000
; AVX-NEXT:    xorq %rcx, %rax
; AVX-NEXT:    vcvttsd2si %xmm0, %rdx
; AVX-NEXT:    vucomisd %xmm1, %xmm0
; AVX-NEXT:    cmovaeq %rax, %rdx
; AVX-NEXT:    vmovq %rdx, %xmm2
; AVX-NEXT:    vpermilpd {{.*#+}} xmm0 = xmm0[1,0]
; AVX-NEXT:    vsubsd %xmm1, %xmm0, %xmm3
; AVX-NEXT:    vcvttsd2si %xmm3, %rax
; AVX-NEXT:    xorq %rcx, %rax
; AVX-NEXT:    vcvttsd2si %xmm0, %rcx
; AVX-NEXT:    vucomisd %xmm1, %xmm0
; AVX-NEXT:    cmovaeq %rax, %rcx
; AVX-NEXT:    vmovq %rcx, %xmm0
; AVX-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm2[0],xmm0[0]
; AVX-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[0,2,2,3]
; AVX-NEXT:    vmovq {{.*#+}} xmm0 = xmm0[0],zero
; AVX-NEXT:    retq
;
; AVX512F-LABEL: fptoui_2f64_to_4i32:
; AVX512F:       # BB#0:
; AVX512F-NEXT:    # kill: %XMM0<def> %XMM0<kill> %ZMM0<def>
; AVX512F-NEXT:    vcvttpd2udq %zmm0, %ymm0
; AVX512F-NEXT:    vmovq {{.*#+}} xmm0 = xmm0[0],zero
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: fptoui_2f64_to_4i32:
; AVX512VL:       # BB#0:
; AVX512VL-NEXT:    vcvttpd2udq %xmm0, %xmm0
; AVX512VL-NEXT:    retq
;
; AVX512VLDQ-LABEL: fptoui_2f64_to_4i32:
; AVX512VLDQ:       # BB#0:
; AVX512VLDQ-NEXT:    vcvttpd2udq %xmm0, %xmm0
; AVX512VLDQ-NEXT:    retq
  %cvt = fptoui <2 x double> %a to <2 x i32>
  %ext = shufflevector <2 x i32> %cvt, <2 x i32> zeroinitializer, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  ret <4 x i32> %ext
}

define <4 x i32> @fptoui_2f64_to_2i32(<2 x double> %a) {
; SSE-LABEL: fptoui_2f64_to_2i32:
; SSE:       # BB#0:
; SSE-NEXT:    movsd {{.*#+}} xmm1 = mem[0],zero
; SSE-NEXT:    movapd %xmm0, %xmm2
; SSE-NEXT:    subsd %xmm1, %xmm2
; SSE-NEXT:    cvttsd2si %xmm2, %rax
; SSE-NEXT:    movabsq $-9223372036854775808, %rcx # imm = 0x8000000000000000
; SSE-NEXT:    xorq %rcx, %rax
; SSE-NEXT:    cvttsd2si %xmm0, %rdx
; SSE-NEXT:    ucomisd %xmm1, %xmm0
; SSE-NEXT:    cmovaeq %rax, %rdx
; SSE-NEXT:    movd %rdx, %xmm2
; SSE-NEXT:    movhlps {{.*#+}} xmm0 = xmm0[1,1]
; SSE-NEXT:    movaps %xmm0, %xmm3
; SSE-NEXT:    subsd %xmm1, %xmm3
; SSE-NEXT:    cvttsd2si %xmm3, %rax
; SSE-NEXT:    xorq %rcx, %rax
; SSE-NEXT:    cvttsd2si %xmm0, %rcx
; SSE-NEXT:    ucomisd %xmm1, %xmm0
; SSE-NEXT:    cmovaeq %rax, %rcx
; SSE-NEXT:    movd %rcx, %xmm0
; SSE-NEXT:    punpcklqdq {{.*#+}} xmm2 = xmm2[0],xmm0[0]
; SSE-NEXT:    pshufd {{.*#+}} xmm0 = xmm2[0,2,2,3]
; SSE-NEXT:    retq
;
; AVX-LABEL: fptoui_2f64_to_2i32:
; AVX:       # BB#0:
; AVX-NEXT:    vmovsd {{.*#+}} xmm1 = mem[0],zero
; AVX-NEXT:    vsubsd %xmm1, %xmm0, %xmm2
; AVX-NEXT:    vcvttsd2si %xmm2, %rax
; AVX-NEXT:    movabsq $-9223372036854775808, %rcx # imm = 0x8000000000000000
; AVX-NEXT:    xorq %rcx, %rax
; AVX-NEXT:    vcvttsd2si %xmm0, %rdx
; AVX-NEXT:    vucomisd %xmm1, %xmm0
; AVX-NEXT:    cmovaeq %rax, %rdx
; AVX-NEXT:    vmovq %rdx, %xmm2
; AVX-NEXT:    vpermilpd {{.*#+}} xmm0 = xmm0[1,0]
; AVX-NEXT:    vsubsd %xmm1, %xmm0, %xmm3
; AVX-NEXT:    vcvttsd2si %xmm3, %rax
; AVX-NEXT:    xorq %rcx, %rax
; AVX-NEXT:    vcvttsd2si %xmm0, %rcx
; AVX-NEXT:    vucomisd %xmm1, %xmm0
; AVX-NEXT:    cmovaeq %rax, %rcx
; AVX-NEXT:    vmovq %rcx, %xmm0
; AVX-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm2[0],xmm0[0]
; AVX-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[0,2,2,3]
; AVX-NEXT:    retq
;
; AVX512F-LABEL: fptoui_2f64_to_2i32:
; AVX512F:       # BB#0:
; AVX512F-NEXT:    # kill: %XMM0<def> %XMM0<kill> %ZMM0<def>
; AVX512F-NEXT:    vcvttpd2udq %zmm0, %ymm0
; AVX512F-NEXT:    # kill: %XMM0<def> %XMM0<kill> %YMM0<kill>
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: fptoui_2f64_to_2i32:
; AVX512VL:       # BB#0:
; AVX512VL-NEXT:    vcvttpd2udq %xmm0, %xmm0
; AVX512VL-NEXT:    retq
;
; AVX512VLDQ-LABEL: fptoui_2f64_to_2i32:
; AVX512VLDQ:       # BB#0:
; AVX512VLDQ-NEXT:    vcvttpd2udq %xmm0, %xmm0
; AVX512VLDQ-NEXT:    retq
  %cvt = fptoui <2 x double> %a to <2 x i32>
  %ext = shufflevector <2 x i32> %cvt, <2 x i32> undef, <4 x i32> <i32 0, i32 1, i32 undef, i32 undef>
  ret <4 x i32> %ext
}

define <4 x i32> @fptoui_4f64_to_2i32(<2 x double> %a) {
; SSE-LABEL: fptoui_4f64_to_2i32:
; SSE:       # BB#0:
; SSE-NEXT:    movsd {{.*#+}} xmm1 = mem[0],zero
; SSE-NEXT:    movapd %xmm0, %xmm2
; SSE-NEXT:    subsd %xmm1, %xmm2
; SSE-NEXT:    cvttsd2si %xmm2, %rax
; SSE-NEXT:    movabsq $-9223372036854775808, %rcx # imm = 0x8000000000000000
; SSE-NEXT:    xorq %rcx, %rax
; SSE-NEXT:    cvttsd2si %xmm0, %rdx
; SSE-NEXT:    ucomisd %xmm1, %xmm0
; SSE-NEXT:    cmovaeq %rax, %rdx
; SSE-NEXT:    movd %rdx, %xmm2
; SSE-NEXT:    movhlps {{.*#+}} xmm0 = xmm0[1,1]
; SSE-NEXT:    movaps %xmm0, %xmm3
; SSE-NEXT:    subsd %xmm1, %xmm3
; SSE-NEXT:    cvttsd2si %xmm3, %rax
; SSE-NEXT:    xorq %rcx, %rax
; SSE-NEXT:    cvttsd2si %xmm0, %rdx
; SSE-NEXT:    ucomisd %xmm1, %xmm0
; SSE-NEXT:    cmovaeq %rax, %rdx
; SSE-NEXT:    movd %rdx, %xmm0
; SSE-NEXT:    punpcklqdq {{.*#+}} xmm2 = xmm2[0],xmm0[0]
; SSE-NEXT:    pshufd {{.*#+}} xmm0 = xmm2[0,2,2,3]
; SSE-NEXT:    cvttsd2si %xmm0, %rax
; SSE-NEXT:    xorq %rax, %rcx
; SSE-NEXT:    ucomisd %xmm1, %xmm0
; SSE-NEXT:    cmovbq %rax, %rcx
; SSE-NEXT:    movd %rcx, %xmm1
; SSE-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[0,1,0,1]
; SSE-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[0,2,2,3]
; SSE-NEXT:    punpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; SSE-NEXT:    retq
;
; AVX-LABEL: fptoui_4f64_to_2i32:
; AVX:       # BB#0:
; AVX-NEXT:    vpermilpd {{.*#+}} xmm1 = xmm0[1,0]
; AVX-NEXT:    vcvttsd2si %xmm1, %rax
; AVX-NEXT:    vcvttsd2si %xmm0, %rcx
; AVX-NEXT:    vmovd %ecx, %xmm0
; AVX-NEXT:    vpinsrd $1, %eax, %xmm0, %xmm0
; AVX-NEXT:    vcvttsd2si %xmm0, %rax
; AVX-NEXT:    vpinsrd $2, %eax, %xmm0, %xmm0
; AVX-NEXT:    vpinsrd $3, %eax, %xmm0, %xmm0
; AVX-NEXT:    retq
;
; AVX512F-LABEL: fptoui_4f64_to_2i32:
; AVX512F:       # BB#0:
; AVX512F-NEXT:    # kill: %XMM0<def> %XMM0<kill> %ZMM0<def>
; AVX512F-NEXT:    vcvttpd2udq %zmm0, %ymm0
; AVX512F-NEXT:    # kill: %XMM0<def> %XMM0<kill> %YMM0<kill>
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: fptoui_4f64_to_2i32:
; AVX512VL:       # BB#0:
; AVX512VL-NEXT:    # kill: %XMM0<def> %XMM0<kill> %YMM0<def>
; AVX512VL-NEXT:    vcvttpd2udq %ymm0, %xmm0
; AVX512VL-NEXT:    retq
;
; AVX512VLDQ-LABEL: fptoui_4f64_to_2i32:
; AVX512VLDQ:       # BB#0:
; AVX512VLDQ-NEXT:    # kill: %XMM0<def> %XMM0<kill> %YMM0<def>
; AVX512VLDQ-NEXT:    vcvttpd2udq %ymm0, %xmm0
; AVX512VLDQ-NEXT:    retq
  %ext = shufflevector <2 x double> %a, <2 x double> undef, <4 x i32> <i32 0, i32 1, i32 undef, i32 undef>
  %cvt = fptoui <4 x double> %ext to <4 x i32>
  ret <4 x i32> %cvt
}

define <4 x i64> @fptoui_4f64_to_4i64(<4 x double> %a) {
; SSE-LABEL: fptoui_4f64_to_4i64:
; SSE:       # BB#0:
; SSE-NEXT:    movapd %xmm0, %xmm2
; SSE-NEXT:    movsd {{.*#+}} xmm3 = mem[0],zero
; SSE-NEXT:    subsd %xmm3, %xmm0
; SSE-NEXT:    cvttsd2si %xmm0, %rcx
; SSE-NEXT:    movabsq $-9223372036854775808, %rax # imm = 0x8000000000000000
; SSE-NEXT:    xorq %rax, %rcx
; SSE-NEXT:    cvttsd2si %xmm2, %rdx
; SSE-NEXT:    ucomisd %xmm3, %xmm2
; SSE-NEXT:    cmovaeq %rcx, %rdx
; SSE-NEXT:    movd %rdx, %xmm0
; SSE-NEXT:    movhlps {{.*#+}} xmm2 = xmm2[1,1]
; SSE-NEXT:    movaps %xmm2, %xmm4
; SSE-NEXT:    subsd %xmm3, %xmm4
; SSE-NEXT:    cvttsd2si %xmm4, %rcx
; SSE-NEXT:    xorq %rax, %rcx
; SSE-NEXT:    cvttsd2si %xmm2, %rdx
; SSE-NEXT:    ucomisd %xmm3, %xmm2
; SSE-NEXT:    cmovaeq %rcx, %rdx
; SSE-NEXT:    movd %rdx, %xmm2
; SSE-NEXT:    punpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm2[0]
; SSE-NEXT:    movapd %xmm1, %xmm2
; SSE-NEXT:    subsd %xmm3, %xmm2
; SSE-NEXT:    cvttsd2si %xmm2, %rcx
; SSE-NEXT:    xorq %rax, %rcx
; SSE-NEXT:    cvttsd2si %xmm1, %rdx
; SSE-NEXT:    ucomisd %xmm3, %xmm1
; SSE-NEXT:    cmovaeq %rcx, %rdx
; SSE-NEXT:    movd %rdx, %xmm2
; SSE-NEXT:    movhlps {{.*#+}} xmm1 = xmm1[1,1]
; SSE-NEXT:    movaps %xmm1, %xmm4
; SSE-NEXT:    subsd %xmm3, %xmm4
; SSE-NEXT:    cvttsd2si %xmm4, %rcx
; SSE-NEXT:    xorq %rax, %rcx
; SSE-NEXT:    cvttsd2si %xmm1, %rax
; SSE-NEXT:    ucomisd %xmm3, %xmm1
; SSE-NEXT:    cmovaeq %rcx, %rax
; SSE-NEXT:    movd %rax, %xmm1
; SSE-NEXT:    punpcklqdq {{.*#+}} xmm2 = xmm2[0],xmm1[0]
; SSE-NEXT:    movdqa %xmm2, %xmm1
; SSE-NEXT:    retq
;
; AVX1-LABEL: fptoui_4f64_to_4i64:
; AVX1:       # BB#0:
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm2
; AVX1-NEXT:    vmovsd {{.*#+}} xmm1 = mem[0],zero
; AVX1-NEXT:    vsubsd %xmm1, %xmm2, %xmm3
; AVX1-NEXT:    vcvttsd2si %xmm3, %rax
; AVX1-NEXT:    movabsq $-9223372036854775808, %rcx # imm = 0x8000000000000000
; AVX1-NEXT:    xorq %rcx, %rax
; AVX1-NEXT:    vcvttsd2si %xmm2, %rdx
; AVX1-NEXT:    vucomisd %xmm1, %xmm2
; AVX1-NEXT:    cmovaeq %rax, %rdx
; AVX1-NEXT:    vmovq %rdx, %xmm3
; AVX1-NEXT:    vpermilpd {{.*#+}} xmm2 = xmm2[1,0]
; AVX1-NEXT:    vsubsd %xmm1, %xmm2, %xmm4
; AVX1-NEXT:    vcvttsd2si %xmm4, %rax
; AVX1-NEXT:    xorq %rcx, %rax
; AVX1-NEXT:    vcvttsd2si %xmm2, %rdx
; AVX1-NEXT:    vucomisd %xmm1, %xmm2
; AVX1-NEXT:    cmovaeq %rax, %rdx
; AVX1-NEXT:    vmovq %rdx, %xmm2
; AVX1-NEXT:    vpunpcklqdq {{.*#+}} xmm2 = xmm3[0],xmm2[0]
; AVX1-NEXT:    vsubsd %xmm1, %xmm0, %xmm3
; AVX1-NEXT:    vcvttsd2si %xmm3, %rax
; AVX1-NEXT:    xorq %rcx, %rax
; AVX1-NEXT:    vcvttsd2si %xmm0, %rdx
; AVX1-NEXT:    vucomisd %xmm1, %xmm0
; AVX1-NEXT:    cmovaeq %rax, %rdx
; AVX1-NEXT:    vmovq %rdx, %xmm3
; AVX1-NEXT:    vpermilpd {{.*#+}} xmm0 = xmm0[1,0]
; AVX1-NEXT:    vsubsd %xmm1, %xmm0, %xmm4
; AVX1-NEXT:    vcvttsd2si %xmm4, %rax
; AVX1-NEXT:    xorq %rcx, %rax
; AVX1-NEXT:    vcvttsd2si %xmm0, %rcx
; AVX1-NEXT:    vucomisd %xmm1, %xmm0
; AVX1-NEXT:    cmovaeq %rax, %rcx
; AVX1-NEXT:    vmovq %rcx, %xmm0
; AVX1-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm3[0],xmm0[0]
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: fptoui_4f64_to_4i64:
; AVX2:       # BB#0:
; AVX2-NEXT:    vextractf128 $1, %ymm0, %xmm2
; AVX2-NEXT:    vmovsd {{.*#+}} xmm1 = mem[0],zero
; AVX2-NEXT:    vsubsd %xmm1, %xmm2, %xmm3
; AVX2-NEXT:    vcvttsd2si %xmm3, %rax
; AVX2-NEXT:    movabsq $-9223372036854775808, %rcx # imm = 0x8000000000000000
; AVX2-NEXT:    xorq %rcx, %rax
; AVX2-NEXT:    vcvttsd2si %xmm2, %rdx
; AVX2-NEXT:    vucomisd %xmm1, %xmm2
; AVX2-NEXT:    cmovaeq %rax, %rdx
; AVX2-NEXT:    vmovq %rdx, %xmm3
; AVX2-NEXT:    vpermilpd {{.*#+}} xmm2 = xmm2[1,0]
; AVX2-NEXT:    vsubsd %xmm1, %xmm2, %xmm4
; AVX2-NEXT:    vcvttsd2si %xmm4, %rax
; AVX2-NEXT:    xorq %rcx, %rax
; AVX2-NEXT:    vcvttsd2si %xmm2, %rdx
; AVX2-NEXT:    vucomisd %xmm1, %xmm2
; AVX2-NEXT:    cmovaeq %rax, %rdx
; AVX2-NEXT:    vmovq %rdx, %xmm2
; AVX2-NEXT:    vpunpcklqdq {{.*#+}} xmm2 = xmm3[0],xmm2[0]
; AVX2-NEXT:    vsubsd %xmm1, %xmm0, %xmm3
; AVX2-NEXT:    vcvttsd2si %xmm3, %rax
; AVX2-NEXT:    xorq %rcx, %rax
; AVX2-NEXT:    vcvttsd2si %xmm0, %rdx
; AVX2-NEXT:    vucomisd %xmm1, %xmm0
; AVX2-NEXT:    cmovaeq %rax, %rdx
; AVX2-NEXT:    vmovq %rdx, %xmm3
; AVX2-NEXT:    vpermilpd {{.*#+}} xmm0 = xmm0[1,0]
; AVX2-NEXT:    vsubsd %xmm1, %xmm0, %xmm4
; AVX2-NEXT:    vcvttsd2si %xmm4, %rax
; AVX2-NEXT:    xorq %rcx, %rax
; AVX2-NEXT:    vcvttsd2si %xmm0, %rcx
; AVX2-NEXT:    vucomisd %xmm1, %xmm0
; AVX2-NEXT:    cmovaeq %rax, %rcx
; AVX2-NEXT:    vmovq %rcx, %xmm0
; AVX2-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm3[0],xmm0[0]
; AVX2-NEXT:    vinserti128 $1, %xmm2, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: fptoui_4f64_to_4i64:
; AVX512F:       # BB#0:
; AVX512F-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX512F-NEXT:    vcvttsd2usi %xmm1, %rax
; AVX512F-NEXT:    vmovq %rax, %xmm2
; AVX512F-NEXT:    vpermilpd {{.*#+}} xmm1 = xmm1[1,0]
; AVX512F-NEXT:    vcvttsd2usi %xmm1, %rax
; AVX512F-NEXT:    vmovq %rax, %xmm1
; AVX512F-NEXT:    vpunpcklqdq {{.*#+}} xmm1 = xmm2[0],xmm1[0]
; AVX512F-NEXT:    vcvttsd2usi %xmm0, %rax
; AVX512F-NEXT:    vmovq %rax, %xmm2
; AVX512F-NEXT:    vpermilpd {{.*#+}} xmm0 = xmm0[1,0]
; AVX512F-NEXT:    vcvttsd2usi %xmm0, %rax
; AVX512F-NEXT:    vmovq %rax, %xmm0
; AVX512F-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm2[0],xmm0[0]
; AVX512F-NEXT:    vinserti128 $1, %xmm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: fptoui_4f64_to_4i64:
; AVX512VL:       # BB#0:
; AVX512VL-NEXT:    vextractf32x4 $1, %ymm0, %xmm1
; AVX512VL-NEXT:    vcvttsd2usi %xmm1, %rax
; AVX512VL-NEXT:    vmovq %rax, %xmm2
; AVX512VL-NEXT:    vpermilpd {{.*#+}} xmm1 = xmm1[1,0]
; AVX512VL-NEXT:    vcvttsd2usi %xmm1, %rax
; AVX512VL-NEXT:    vmovq %rax, %xmm1
; AVX512VL-NEXT:    vpunpcklqdq {{.*#+}} xmm1 = xmm2[0],xmm1[0]
; AVX512VL-NEXT:    vcvttsd2usi %xmm0, %rax
; AVX512VL-NEXT:    vmovq %rax, %xmm2
; AVX512VL-NEXT:    vpermilpd {{.*#+}} xmm0 = xmm0[1,0]
; AVX512VL-NEXT:    vcvttsd2usi %xmm0, %rax
; AVX512VL-NEXT:    vmovq %rax, %xmm0
; AVX512VL-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm2[0],xmm0[0]
; AVX512VL-NEXT:    vinserti32x4 $1, %xmm1, %ymm0, %ymm0
; AVX512VL-NEXT:    retq
;
; AVX512VLDQ-LABEL: fptoui_4f64_to_4i64:
; AVX512VLDQ:       # BB#0:
; AVX512VLDQ-NEXT:    vcvttpd2uqq %ymm0, %ymm0
; AVX512VLDQ-NEXT:    retq
  %cvt = fptoui <4 x double> %a to <4 x i64>
  ret <4 x i64> %cvt
}

define <4 x i32> @fptoui_4f64_to_4i32(<4 x double> %a) {
; SSE-LABEL: fptoui_4f64_to_4i32:
; SSE:       # BB#0:
; SSE-NEXT:    movsd {{.*#+}} xmm2 = mem[0],zero
; SSE-NEXT:    movapd %xmm1, %xmm3
; SSE-NEXT:    subsd %xmm2, %xmm3
; SSE-NEXT:    cvttsd2si %xmm3, %rcx
; SSE-NEXT:    movabsq $-9223372036854775808, %rax # imm = 0x8000000000000000
; SSE-NEXT:    xorq %rax, %rcx
; SSE-NEXT:    cvttsd2si %xmm1, %rdx
; SSE-NEXT:    ucomisd %xmm2, %xmm1
; SSE-NEXT:    cmovaeq %rcx, %rdx
; SSE-NEXT:    movd %rdx, %xmm3
; SSE-NEXT:    movhlps {{.*#+}} xmm1 = xmm1[1,1]
; SSE-NEXT:    movaps %xmm1, %xmm4
; SSE-NEXT:    subsd %xmm2, %xmm4
; SSE-NEXT:    cvttsd2si %xmm4, %rcx
; SSE-NEXT:    xorq %rax, %rcx
; SSE-NEXT:    cvttsd2si %xmm1, %rdx
; SSE-NEXT:    ucomisd %xmm2, %xmm1
; SSE-NEXT:    cmovaeq %rcx, %rdx
; SSE-NEXT:    movd %rdx, %xmm1
; SSE-NEXT:    punpcklqdq {{.*#+}} xmm3 = xmm3[0],xmm1[0]
; SSE-NEXT:    pshufd {{.*#+}} xmm1 = xmm3[0,2,2,3]
; SSE-NEXT:    movapd %xmm0, %xmm3
; SSE-NEXT:    subsd %xmm2, %xmm3
; SSE-NEXT:    cvttsd2si %xmm3, %rcx
; SSE-NEXT:    xorq %rax, %rcx
; SSE-NEXT:    cvttsd2si %xmm0, %rdx
; SSE-NEXT:    ucomisd %xmm2, %xmm0
; SSE-NEXT:    cmovaeq %rcx, %rdx
; SSE-NEXT:    movd %rdx, %xmm3
; SSE-NEXT:    movhlps {{.*#+}} xmm0 = xmm0[1,1]
; SSE-NEXT:    movaps %xmm0, %xmm4
; SSE-NEXT:    subsd %xmm2, %xmm4
; SSE-NEXT:    cvttsd2si %xmm4, %rcx
; SSE-NEXT:    xorq %rax, %rcx
; SSE-NEXT:    cvttsd2si %xmm0, %rax
; SSE-NEXT:    ucomisd %xmm2, %xmm0
; SSE-NEXT:    cmovaeq %rcx, %rax
; SSE-NEXT:    movd %rax, %xmm0
; SSE-NEXT:    punpcklqdq {{.*#+}} xmm3 = xmm3[0],xmm0[0]
; SSE-NEXT:    pshufd {{.*#+}} xmm0 = xmm3[0,2,2,3]
; SSE-NEXT:    punpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; SSE-NEXT:    retq
;
; AVX-LABEL: fptoui_4f64_to_4i32:
; AVX:       # BB#0:
; AVX-NEXT:    vpermilpd {{.*#+}} xmm1 = xmm0[1,0]
; AVX-NEXT:    vcvttsd2si %xmm1, %rax
; AVX-NEXT:    vcvttsd2si %xmm0, %rcx
; AVX-NEXT:    vmovd %ecx, %xmm1
; AVX-NEXT:    vpinsrd $1, %eax, %xmm1, %xmm1
; AVX-NEXT:    vextractf128 $1, %ymm0, %xmm0
; AVX-NEXT:    vcvttsd2si %xmm0, %rax
; AVX-NEXT:    vpinsrd $2, %eax, %xmm1, %xmm1
; AVX-NEXT:    vpermilpd {{.*#+}} xmm0 = xmm0[1,0]
; AVX-NEXT:    vcvttsd2si %xmm0, %rax
; AVX-NEXT:    vpinsrd $3, %eax, %xmm1, %xmm0
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
;
; AVX512F-LABEL: fptoui_4f64_to_4i32:
; AVX512F:       # BB#0:
; AVX512F-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<def>
; AVX512F-NEXT:    vcvttpd2udq %zmm0, %ymm0
; AVX512F-NEXT:    # kill: %XMM0<def> %XMM0<kill> %YMM0<kill>
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: fptoui_4f64_to_4i32:
; AVX512VL:       # BB#0:
; AVX512VL-NEXT:    vcvttpd2udq %ymm0, %xmm0
; AVX512VL-NEXT:    retq
;
; AVX512VLDQ-LABEL: fptoui_4f64_to_4i32:
; AVX512VLDQ:       # BB#0:
; AVX512VLDQ-NEXT:    vcvttpd2udq %ymm0, %xmm0
; AVX512VLDQ-NEXT:    retq
  %cvt = fptoui <4 x double> %a to <4 x i32>
  ret <4 x i32> %cvt
}

;
; Float to Signed Integer
;

define <2 x i32> @fptosi_2f32_to_2i32(<2 x float> %a) {
; SSE-LABEL: fptosi_2f32_to_2i32:
; SSE:       # BB#0:
; SSE-NEXT:    cvttps2dq %xmm0, %xmm0
; SSE-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,1,1,3]
; SSE-NEXT:    retq
;
; AVX-LABEL: fptosi_2f32_to_2i32:
; AVX:       # BB#0:
; AVX-NEXT:    vcvttps2dq %xmm0, %xmm0
; AVX-NEXT:    vpmovzxdq {{.*#+}} xmm0 = xmm0[0],zero,xmm0[1],zero
; AVX-NEXT:    retq
;
; AVX512-LABEL: fptosi_2f32_to_2i32:
; AVX512:       # BB#0:
; AVX512-NEXT:    vcvttps2dq %xmm0, %xmm0
; AVX512-NEXT:    vpmovzxdq {{.*#+}} xmm0 = xmm0[0],zero,xmm0[1],zero
; AVX512-NEXT:    retq
  %cvt = fptosi <2 x float> %a to <2 x i32>
  ret <2 x i32> %cvt
}

define <4 x i32> @fptosi_4f32_to_4i32(<4 x float> %a) {
; SSE-LABEL: fptosi_4f32_to_4i32:
; SSE:       # BB#0:
; SSE-NEXT:    cvttps2dq %xmm0, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: fptosi_4f32_to_4i32:
; AVX:       # BB#0:
; AVX-NEXT:    vcvttps2dq %xmm0, %xmm0
; AVX-NEXT:    retq
;
; AVX512-LABEL: fptosi_4f32_to_4i32:
; AVX512:       # BB#0:
; AVX512-NEXT:    vcvttps2dq %xmm0, %xmm0
; AVX512-NEXT:    retq
  %cvt = fptosi <4 x float> %a to <4 x i32>
  ret <4 x i32> %cvt
}

define <2 x i64> @fptosi_2f32_to_2i64(<4 x float> %a) {
; SSE-LABEL: fptosi_2f32_to_2i64:
; SSE:       # BB#0:
; SSE-NEXT:    cvttss2si %xmm0, %rax
; SSE-NEXT:    movd %rax, %xmm1
; SSE-NEXT:    shufps {{.*#+}} xmm0 = xmm0[1,1,2,3]
; SSE-NEXT:    cvttss2si %xmm0, %rax
; SSE-NEXT:    movd %rax, %xmm0
; SSE-NEXT:    punpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm0[0]
; SSE-NEXT:    movdqa %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: fptosi_2f32_to_2i64:
; AVX:       # BB#0:
; AVX-NEXT:    vcvttss2si %xmm0, %rax
; AVX-NEXT:    vmovq %rax, %xmm1
; AVX-NEXT:    vmovshdup {{.*#+}} xmm0 = xmm0[1,1,3,3]
; AVX-NEXT:    vcvttss2si %xmm0, %rax
; AVX-NEXT:    vmovq %rax, %xmm0
; AVX-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm1[0],xmm0[0]
; AVX-NEXT:    retq
;
; AVX512-LABEL: fptosi_2f32_to_2i64:
; AVX512:       # BB#0:
; AVX512-NEXT:    vcvttss2si %xmm0, %rax
; AVX512-NEXT:    vmovq %rax, %xmm1
; AVX512-NEXT:    vmovshdup {{.*#+}} xmm0 = xmm0[1,1,3,3]
; AVX512-NEXT:    vcvttss2si %xmm0, %rax
; AVX512-NEXT:    vmovq %rax, %xmm0
; AVX512-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm1[0],xmm0[0]
; AVX512-NEXT:    retq
  %shuf = shufflevector <4 x float> %a, <4 x float> undef, <2 x i32> <i32 0, i32 1>
  %cvt = fptosi <2 x float> %shuf to <2 x i64>
  ret <2 x i64> %cvt
}

define <2 x i64> @fptosi_4f32_to_2i64(<4 x float> %a) {
; SSE-LABEL: fptosi_4f32_to_2i64:
; SSE:       # BB#0:
; SSE-NEXT:    cvttss2si %xmm0, %rax
; SSE-NEXT:    movd %rax, %xmm1
; SSE-NEXT:    shufps {{.*#+}} xmm0 = xmm0[1,1,2,3]
; SSE-NEXT:    cvttss2si %xmm0, %rax
; SSE-NEXT:    movd %rax, %xmm0
; SSE-NEXT:    punpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm0[0]
; SSE-NEXT:    movdqa %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: fptosi_4f32_to_2i64:
; AVX:       # BB#0:
; AVX-NEXT:    vmovshdup {{.*#+}} xmm1 = xmm0[1,1,3,3]
; AVX-NEXT:    vcvttss2si %xmm1, %rax
; AVX-NEXT:    vcvttss2si %xmm0, %rcx
; AVX-NEXT:    vmovq %rcx, %xmm0
; AVX-NEXT:    vmovq %rax, %xmm1
; AVX-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; AVX-NEXT:    retq
;
; AVX512F-LABEL: fptosi_4f32_to_2i64:
; AVX512F:       # BB#0:
; AVX512F-NEXT:    vmovshdup {{.*#+}} xmm1 = xmm0[1,1,3,3]
; AVX512F-NEXT:    vcvttss2si %xmm1, %rax
; AVX512F-NEXT:    vcvttss2si %xmm0, %rcx
; AVX512F-NEXT:    vmovq %rcx, %xmm0
; AVX512F-NEXT:    vmovq %rax, %xmm1
; AVX512F-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: fptosi_4f32_to_2i64:
; AVX512VL:       # BB#0:
; AVX512VL-NEXT:    vmovshdup {{.*#+}} xmm1 = xmm0[1,1,3,3]
; AVX512VL-NEXT:    vcvttss2si %xmm1, %rax
; AVX512VL-NEXT:    vcvttss2si %xmm0, %rcx
; AVX512VL-NEXT:    vmovq %rcx, %xmm0
; AVX512VL-NEXT:    vmovq %rax, %xmm1
; AVX512VL-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; AVX512VL-NEXT:    retq
;
; AVX512VLDQ-LABEL: fptosi_4f32_to_2i64:
; AVX512VLDQ:       # BB#0:
; AVX512VLDQ-NEXT:    vcvttps2qq %xmm0, %ymm0
; AVX512VLDQ-NEXT:    # kill: %XMM0<def> %XMM0<kill> %YMM0<kill>
; AVX512VLDQ-NEXT:    retq
  %cvt = fptosi <4 x float> %a to <4 x i64>
  %shuf = shufflevector <4 x i64> %cvt, <4 x i64> undef, <2 x i32> <i32 0, i32 1>
  ret <2 x i64> %shuf
}

define <8 x i32> @fptosi_8f32_to_8i32(<8 x float> %a) {
; SSE-LABEL: fptosi_8f32_to_8i32:
; SSE:       # BB#0:
; SSE-NEXT:    cvttps2dq %xmm0, %xmm0
; SSE-NEXT:    cvttps2dq %xmm1, %xmm1
; SSE-NEXT:    retq
;
; AVX-LABEL: fptosi_8f32_to_8i32:
; AVX:       # BB#0:
; AVX-NEXT:    vcvttps2dq %ymm0, %ymm0
; AVX-NEXT:    retq
;
; AVX512-LABEL: fptosi_8f32_to_8i32:
; AVX512:       # BB#0:
; AVX512-NEXT:    vcvttps2dq %ymm0, %ymm0
; AVX512-NEXT:    retq
  %cvt = fptosi <8 x float> %a to <8 x i32>
  ret <8 x i32> %cvt
}

define <4 x i64> @fptosi_4f32_to_4i64(<8 x float> %a) {
; SSE-LABEL: fptosi_4f32_to_4i64:
; SSE:       # BB#0:
; SSE-NEXT:    cvttss2si %xmm0, %rax
; SSE-NEXT:    movd %rax, %xmm2
; SSE-NEXT:    movaps %xmm0, %xmm1
; SSE-NEXT:    shufps {{.*#+}} xmm1 = xmm1[1,1,2,3]
; SSE-NEXT:    cvttss2si %xmm1, %rax
; SSE-NEXT:    movd %rax, %xmm1
; SSE-NEXT:    punpcklqdq {{.*#+}} xmm2 = xmm2[0],xmm1[0]
; SSE-NEXT:    movaps %xmm0, %xmm1
; SSE-NEXT:    shufps {{.*#+}} xmm1 = xmm1[3,1,2,3]
; SSE-NEXT:    cvttss2si %xmm1, %rax
; SSE-NEXT:    movd %rax, %xmm3
; SSE-NEXT:    movhlps {{.*#+}} xmm0 = xmm0[1,1]
; SSE-NEXT:    cvttss2si %xmm0, %rax
; SSE-NEXT:    movd %rax, %xmm1
; SSE-NEXT:    punpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm3[0]
; SSE-NEXT:    movdqa %xmm2, %xmm0
; SSE-NEXT:    retq
;
; AVX1-LABEL: fptosi_4f32_to_4i64:
; AVX1:       # BB#0:
; AVX1-NEXT:    vpermilps {{.*#+}} xmm1 = xmm0[3,1,2,3]
; AVX1-NEXT:    vcvttss2si %xmm1, %rax
; AVX1-NEXT:    vmovq %rax, %xmm1
; AVX1-NEXT:    vpermilpd {{.*#+}} xmm2 = xmm0[1,0]
; AVX1-NEXT:    vcvttss2si %xmm2, %rax
; AVX1-NEXT:    vmovq %rax, %xmm2
; AVX1-NEXT:    vpunpcklqdq {{.*#+}} xmm1 = xmm2[0],xmm1[0]
; AVX1-NEXT:    vcvttss2si %xmm0, %rax
; AVX1-NEXT:    vmovq %rax, %xmm2
; AVX1-NEXT:    vmovshdup {{.*#+}} xmm0 = xmm0[1,1,3,3]
; AVX1-NEXT:    vcvttss2si %xmm0, %rax
; AVX1-NEXT:    vmovq %rax, %xmm0
; AVX1-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm2[0],xmm0[0]
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: fptosi_4f32_to_4i64:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpermilps {{.*#+}} xmm1 = xmm0[3,1,2,3]
; AVX2-NEXT:    vcvttss2si %xmm1, %rax
; AVX2-NEXT:    vmovq %rax, %xmm1
; AVX2-NEXT:    vpermilpd {{.*#+}} xmm2 = xmm0[1,0]
; AVX2-NEXT:    vcvttss2si %xmm2, %rax
; AVX2-NEXT:    vmovq %rax, %xmm2
; AVX2-NEXT:    vpunpcklqdq {{.*#+}} xmm1 = xmm2[0],xmm1[0]
; AVX2-NEXT:    vcvttss2si %xmm0, %rax
; AVX2-NEXT:    vmovq %rax, %xmm2
; AVX2-NEXT:    vmovshdup {{.*#+}} xmm0 = xmm0[1,1,3,3]
; AVX2-NEXT:    vcvttss2si %xmm0, %rax
; AVX2-NEXT:    vmovq %rax, %xmm0
; AVX2-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm2[0],xmm0[0]
; AVX2-NEXT:    vinserti128 $1, %xmm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: fptosi_4f32_to_4i64:
; AVX512F:       # BB#0:
; AVX512F-NEXT:    vpermilps {{.*#+}} xmm1 = xmm0[3,1,2,3]
; AVX512F-NEXT:    vcvttss2si %xmm1, %rax
; AVX512F-NEXT:    vmovq %rax, %xmm1
; AVX512F-NEXT:    vpermilpd {{.*#+}} xmm2 = xmm0[1,0]
; AVX512F-NEXT:    vcvttss2si %xmm2, %rax
; AVX512F-NEXT:    vmovq %rax, %xmm2
; AVX512F-NEXT:    vpunpcklqdq {{.*#+}} xmm1 = xmm2[0],xmm1[0]
; AVX512F-NEXT:    vcvttss2si %xmm0, %rax
; AVX512F-NEXT:    vmovq %rax, %xmm2
; AVX512F-NEXT:    vmovshdup {{.*#+}} xmm0 = xmm0[1,1,3,3]
; AVX512F-NEXT:    vcvttss2si %xmm0, %rax
; AVX512F-NEXT:    vmovq %rax, %xmm0
; AVX512F-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm2[0],xmm0[0]
; AVX512F-NEXT:    vinserti128 $1, %xmm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: fptosi_4f32_to_4i64:
; AVX512VL:       # BB#0:
; AVX512VL-NEXT:    vpermilps {{.*#+}} xmm1 = xmm0[3,1,2,3]
; AVX512VL-NEXT:    vcvttss2si %xmm1, %rax
; AVX512VL-NEXT:    vmovq %rax, %xmm1
; AVX512VL-NEXT:    vpermilpd {{.*#+}} xmm2 = xmm0[1,0]
; AVX512VL-NEXT:    vcvttss2si %xmm2, %rax
; AVX512VL-NEXT:    vmovq %rax, %xmm2
; AVX512VL-NEXT:    vpunpcklqdq {{.*#+}} xmm1 = xmm2[0],xmm1[0]
; AVX512VL-NEXT:    vcvttss2si %xmm0, %rax
; AVX512VL-NEXT:    vmovq %rax, %xmm2
; AVX512VL-NEXT:    vmovshdup {{.*#+}} xmm0 = xmm0[1,1,3,3]
; AVX512VL-NEXT:    vcvttss2si %xmm0, %rax
; AVX512VL-NEXT:    vmovq %rax, %xmm0
; AVX512VL-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm2[0],xmm0[0]
; AVX512VL-NEXT:    vinserti32x4 $1, %xmm1, %ymm0, %ymm0
; AVX512VL-NEXT:    retq
;
; AVX512VLDQ-LABEL: fptosi_4f32_to_4i64:
; AVX512VLDQ:       # BB#0:
; AVX512VLDQ-NEXT:    vcvttps2qq %xmm0, %ymm0
; AVX512VLDQ-NEXT:    retq
  %shuf = shufflevector <8 x float> %a, <8 x float> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %cvt = fptosi <4 x float> %shuf to <4 x i64>
  ret <4 x i64> %cvt
}

define <4 x i64> @fptosi_8f32_to_4i64(<8 x float> %a) {
; SSE-LABEL: fptosi_8f32_to_4i64:
; SSE:       # BB#0:
; SSE-NEXT:    cvttss2si %xmm0, %rax
; SSE-NEXT:    movd %rax, %xmm2
; SSE-NEXT:    movaps %xmm0, %xmm1
; SSE-NEXT:    shufps {{.*#+}} xmm1 = xmm1[1,1,2,3]
; SSE-NEXT:    cvttss2si %xmm1, %rax
; SSE-NEXT:    movd %rax, %xmm1
; SSE-NEXT:    punpcklqdq {{.*#+}} xmm2 = xmm2[0],xmm1[0]
; SSE-NEXT:    movaps %xmm0, %xmm1
; SSE-NEXT:    shufps {{.*#+}} xmm1 = xmm1[3,1,2,3]
; SSE-NEXT:    cvttss2si %xmm1, %rax
; SSE-NEXT:    movd %rax, %xmm3
; SSE-NEXT:    movhlps {{.*#+}} xmm0 = xmm0[1,1]
; SSE-NEXT:    cvttss2si %xmm0, %rax
; SSE-NEXT:    movd %rax, %xmm1
; SSE-NEXT:    punpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm3[0]
; SSE-NEXT:    movdqa %xmm2, %xmm0
; SSE-NEXT:    retq
;
; AVX1-LABEL: fptosi_8f32_to_4i64:
; AVX1:       # BB#0:
; AVX1-NEXT:    vpermilps {{.*#+}} xmm1 = xmm0[3,1,2,3]
; AVX1-NEXT:    vcvttss2si %xmm1, %rax
; AVX1-NEXT:    vmovq %rax, %xmm1
; AVX1-NEXT:    vpermilpd {{.*#+}} xmm2 = xmm0[1,0]
; AVX1-NEXT:    vcvttss2si %xmm2, %rax
; AVX1-NEXT:    vmovq %rax, %xmm2
; AVX1-NEXT:    vpunpcklqdq {{.*#+}} xmm1 = xmm2[0],xmm1[0]
; AVX1-NEXT:    vcvttss2si %xmm0, %rax
; AVX1-NEXT:    vmovq %rax, %xmm2
; AVX1-NEXT:    vmovshdup {{.*#+}} xmm0 = xmm0[1,1,3,3]
; AVX1-NEXT:    vcvttss2si %xmm0, %rax
; AVX1-NEXT:    vmovq %rax, %xmm0
; AVX1-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm2[0],xmm0[0]
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: fptosi_8f32_to_4i64:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpermilps {{.*#+}} xmm1 = xmm0[3,1,2,3]
; AVX2-NEXT:    vcvttss2si %xmm1, %rax
; AVX2-NEXT:    vmovq %rax, %xmm1
; AVX2-NEXT:    vpermilpd {{.*#+}} xmm2 = xmm0[1,0]
; AVX2-NEXT:    vcvttss2si %xmm2, %rax
; AVX2-NEXT:    vmovq %rax, %xmm2
; AVX2-NEXT:    vpunpcklqdq {{.*#+}} xmm1 = xmm2[0],xmm1[0]
; AVX2-NEXT:    vcvttss2si %xmm0, %rax
; AVX2-NEXT:    vmovq %rax, %xmm2
; AVX2-NEXT:    vmovshdup {{.*#+}} xmm0 = xmm0[1,1,3,3]
; AVX2-NEXT:    vcvttss2si %xmm0, %rax
; AVX2-NEXT:    vmovq %rax, %xmm0
; AVX2-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm2[0],xmm0[0]
; AVX2-NEXT:    vinserti128 $1, %xmm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: fptosi_8f32_to_4i64:
; AVX512F:       # BB#0:
; AVX512F-NEXT:    vmovshdup {{.*#+}} xmm1 = xmm0[1,1,3,3]
; AVX512F-NEXT:    vcvttss2si %xmm1, %rax
; AVX512F-NEXT:    vcvttss2si %xmm0, %rcx
; AVX512F-NEXT:    vpermilpd {{.*#+}} xmm1 = xmm0[1,0]
; AVX512F-NEXT:    vcvttss2si %xmm1, %rdx
; AVX512F-NEXT:    vpermilps {{.*#+}} xmm0 = xmm0[3,1,2,3]
; AVX512F-NEXT:    vcvttss2si %xmm0, %rsi
; AVX512F-NEXT:    vmovq %rsi, %xmm0
; AVX512F-NEXT:    vmovq %rdx, %xmm1
; AVX512F-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm1[0],xmm0[0]
; AVX512F-NEXT:    vmovq %rcx, %xmm1
; AVX512F-NEXT:    vmovq %rax, %xmm2
; AVX512F-NEXT:    vpunpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm2[0]
; AVX512F-NEXT:    vinserti128 $1, %xmm0, %ymm1, %ymm0
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: fptosi_8f32_to_4i64:
; AVX512VL:       # BB#0:
; AVX512VL-NEXT:    vmovshdup {{.*#+}} xmm1 = xmm0[1,1,3,3]
; AVX512VL-NEXT:    vcvttss2si %xmm1, %rax
; AVX512VL-NEXT:    vcvttss2si %xmm0, %rcx
; AVX512VL-NEXT:    vpermilpd {{.*#+}} xmm1 = xmm0[1,0]
; AVX512VL-NEXT:    vcvttss2si %xmm1, %rdx
; AVX512VL-NEXT:    vpermilps {{.*#+}} xmm0 = xmm0[3,1,2,3]
; AVX512VL-NEXT:    vcvttss2si %xmm0, %rsi
; AVX512VL-NEXT:    vmovq %rsi, %xmm0
; AVX512VL-NEXT:    vmovq %rdx, %xmm1
; AVX512VL-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm1[0],xmm0[0]
; AVX512VL-NEXT:    vmovq %rcx, %xmm1
; AVX512VL-NEXT:    vmovq %rax, %xmm2
; AVX512VL-NEXT:    vpunpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm2[0]
; AVX512VL-NEXT:    vinserti32x4 $1, %xmm0, %ymm1, %ymm0
; AVX512VL-NEXT:    retq
;
; AVX512VLDQ-LABEL: fptosi_8f32_to_4i64:
; AVX512VLDQ:       # BB#0:
; AVX512VLDQ-NEXT:    vcvttps2qq %ymm0, %zmm0
; AVX512VLDQ-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<kill>
; AVX512VLDQ-NEXT:    retq
  %cvt = fptosi <8 x float> %a to <8 x i64>
  %shuf = shufflevector <8 x i64> %cvt, <8 x i64> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  ret <4 x i64> %shuf
}

;
; Float to Unsigned Integer
;

define <2 x i32> @fptoui_2f32_to_2i32(<2 x float> %a) {
; SSE-LABEL: fptoui_2f32_to_2i32:
; SSE:       # BB#0:
; SSE-NEXT:    movss {{.*#+}} xmm2 = mem[0],zero,zero,zero
; SSE-NEXT:    movaps %xmm0, %xmm1
; SSE-NEXT:    subss %xmm2, %xmm1
; SSE-NEXT:    cvttss2si %xmm1, %rax
; SSE-NEXT:    movabsq $-9223372036854775808, %rcx # imm = 0x8000000000000000
; SSE-NEXT:    xorq %rcx, %rax
; SSE-NEXT:    cvttss2si %xmm0, %rdx
; SSE-NEXT:    ucomiss %xmm2, %xmm0
; SSE-NEXT:    cmovaeq %rax, %rdx
; SSE-NEXT:    movd %rdx, %xmm1
; SSE-NEXT:    shufps {{.*#+}} xmm0 = xmm0[1,1,2,3]
; SSE-NEXT:    movaps %xmm0, %xmm3
; SSE-NEXT:    subss %xmm2, %xmm3
; SSE-NEXT:    cvttss2si %xmm3, %rax
; SSE-NEXT:    xorq %rcx, %rax
; SSE-NEXT:    cvttss2si %xmm0, %rcx
; SSE-NEXT:    ucomiss %xmm2, %xmm0
; SSE-NEXT:    cmovaeq %rax, %rcx
; SSE-NEXT:    movd %rcx, %xmm0
; SSE-NEXT:    punpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm0[0]
; SSE-NEXT:    movdqa %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: fptoui_2f32_to_2i32:
; AVX:       # BB#0:
; AVX-NEXT:    vmovss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; AVX-NEXT:    vsubss %xmm1, %xmm0, %xmm2
; AVX-NEXT:    vcvttss2si %xmm2, %rax
; AVX-NEXT:    movabsq $-9223372036854775808, %rcx # imm = 0x8000000000000000
; AVX-NEXT:    xorq %rcx, %rax
; AVX-NEXT:    vcvttss2si %xmm0, %rdx
; AVX-NEXT:    vucomiss %xmm1, %xmm0
; AVX-NEXT:    cmovaeq %rax, %rdx
; AVX-NEXT:    vmovq %rdx, %xmm2
; AVX-NEXT:    vmovshdup {{.*#+}} xmm0 = xmm0[1,1,3,3]
; AVX-NEXT:    vsubss %xmm1, %xmm0, %xmm3
; AVX-NEXT:    vcvttss2si %xmm3, %rax
; AVX-NEXT:    xorq %rcx, %rax
; AVX-NEXT:    vcvttss2si %xmm0, %rcx
; AVX-NEXT:    vucomiss %xmm1, %xmm0
; AVX-NEXT:    cmovaeq %rax, %rcx
; AVX-NEXT:    vmovq %rcx, %xmm0
; AVX-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm2[0],xmm0[0]
; AVX-NEXT:    retq
;
; AVX512F-LABEL: fptoui_2f32_to_2i32:
; AVX512F:       # BB#0:
; AVX512F-NEXT:    # kill: %XMM0<def> %XMM0<kill> %ZMM0<def>
; AVX512F-NEXT:    vcvttps2udq %zmm0, %zmm0
; AVX512F-NEXT:    vpmovzxdq {{.*#+}} xmm0 = xmm0[0],zero,xmm0[1],zero
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: fptoui_2f32_to_2i32:
; AVX512VL:       # BB#0:
; AVX512VL-NEXT:    vcvttps2udq %xmm0, %xmm0
; AVX512VL-NEXT:    vpmovzxdq {{.*#+}} xmm0 = xmm0[0],zero,xmm0[1],zero
; AVX512VL-NEXT:    retq
;
; AVX512VLDQ-LABEL: fptoui_2f32_to_2i32:
; AVX512VLDQ:       # BB#0:
; AVX512VLDQ-NEXT:    vcvttps2udq %xmm0, %xmm0
; AVX512VLDQ-NEXT:    vpmovzxdq {{.*#+}} xmm0 = xmm0[0],zero,xmm0[1],zero
; AVX512VLDQ-NEXT:    retq
  %cvt = fptoui <2 x float> %a to <2 x i32>
  ret <2 x i32> %cvt
}

define <4 x i32> @fptoui_4f32_to_4i32(<4 x float> %a) {
; SSE-LABEL: fptoui_4f32_to_4i32:
; SSE:       # BB#0:
; SSE-NEXT:    movaps %xmm0, %xmm1
; SSE-NEXT:    shufps {{.*#+}} xmm1 = xmm1[3,1,2,3]
; SSE-NEXT:    cvttss2si %xmm1, %rax
; SSE-NEXT:    movd %eax, %xmm1
; SSE-NEXT:    movaps %xmm0, %xmm2
; SSE-NEXT:    shufps {{.*#+}} xmm2 = xmm2[1,1,2,3]
; SSE-NEXT:    cvttss2si %xmm2, %rax
; SSE-NEXT:    movd %eax, %xmm2
; SSE-NEXT:    punpckldq {{.*#+}} xmm2 = xmm2[0],xmm1[0],xmm2[1],xmm1[1]
; SSE-NEXT:    cvttss2si %xmm0, %rax
; SSE-NEXT:    movd %eax, %xmm1
; SSE-NEXT:    movhlps {{.*#+}} xmm0 = xmm0[1,1]
; SSE-NEXT:    cvttss2si %xmm0, %rax
; SSE-NEXT:    movd %eax, %xmm0
; SSE-NEXT:    punpckldq {{.*#+}} xmm1 = xmm1[0],xmm0[0],xmm1[1],xmm0[1]
; SSE-NEXT:    punpckldq {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1]
; SSE-NEXT:    movdqa %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: fptoui_4f32_to_4i32:
; AVX:       # BB#0:
; AVX-NEXT:    vmovshdup {{.*#+}} xmm1 = xmm0[1,1,3,3]
; AVX-NEXT:    vcvttss2si %xmm1, %rax
; AVX-NEXT:    vcvttss2si %xmm0, %rcx
; AVX-NEXT:    vmovd %ecx, %xmm1
; AVX-NEXT:    vpinsrd $1, %eax, %xmm1, %xmm1
; AVX-NEXT:    vpermilpd {{.*#+}} xmm2 = xmm0[1,0]
; AVX-NEXT:    vcvttss2si %xmm2, %rax
; AVX-NEXT:    vpinsrd $2, %eax, %xmm1, %xmm1
; AVX-NEXT:    vpermilps {{.*#+}} xmm0 = xmm0[3,1,2,3]
; AVX-NEXT:    vcvttss2si %xmm0, %rax
; AVX-NEXT:    vpinsrd $3, %eax, %xmm1, %xmm0
; AVX-NEXT:    retq
;
; AVX512F-LABEL: fptoui_4f32_to_4i32:
; AVX512F:       # BB#0:
; AVX512F-NEXT:    # kill: %XMM0<def> %XMM0<kill> %ZMM0<def>
; AVX512F-NEXT:    vcvttps2udq %zmm0, %zmm0
; AVX512F-NEXT:    # kill: %XMM0<def> %XMM0<kill> %ZMM0<kill>
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: fptoui_4f32_to_4i32:
; AVX512VL:       # BB#0:
; AVX512VL-NEXT:    vcvttps2udq %xmm0, %xmm0
; AVX512VL-NEXT:    retq
;
; AVX512VLDQ-LABEL: fptoui_4f32_to_4i32:
; AVX512VLDQ:       # BB#0:
; AVX512VLDQ-NEXT:    vcvttps2udq %xmm0, %xmm0
; AVX512VLDQ-NEXT:    retq
  %cvt = fptoui <4 x float> %a to <4 x i32>
  ret <4 x i32> %cvt
}

define <2 x i64> @fptoui_2f32_to_2i64(<4 x float> %a) {
; SSE-LABEL: fptoui_2f32_to_2i64:
; SSE:       # BB#0:
; SSE-NEXT:    movss {{.*#+}} xmm2 = mem[0],zero,zero,zero
; SSE-NEXT:    movaps %xmm0, %xmm1
; SSE-NEXT:    subss %xmm2, %xmm1
; SSE-NEXT:    cvttss2si %xmm1, %rax
; SSE-NEXT:    movabsq $-9223372036854775808, %rcx # imm = 0x8000000000000000
; SSE-NEXT:    xorq %rcx, %rax
; SSE-NEXT:    cvttss2si %xmm0, %rdx
; SSE-NEXT:    ucomiss %xmm2, %xmm0
; SSE-NEXT:    cmovaeq %rax, %rdx
; SSE-NEXT:    movd %rdx, %xmm1
; SSE-NEXT:    shufps {{.*#+}} xmm0 = xmm0[1,1,2,3]
; SSE-NEXT:    movaps %xmm0, %xmm3
; SSE-NEXT:    subss %xmm2, %xmm3
; SSE-NEXT:    cvttss2si %xmm3, %rax
; SSE-NEXT:    xorq %rcx, %rax
; SSE-NEXT:    cvttss2si %xmm0, %rcx
; SSE-NEXT:    ucomiss %xmm2, %xmm0
; SSE-NEXT:    cmovaeq %rax, %rcx
; SSE-NEXT:    movd %rcx, %xmm0
; SSE-NEXT:    punpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm0[0]
; SSE-NEXT:    movdqa %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: fptoui_2f32_to_2i64:
; AVX:       # BB#0:
; AVX-NEXT:    vmovss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; AVX-NEXT:    vsubss %xmm1, %xmm0, %xmm2
; AVX-NEXT:    vcvttss2si %xmm2, %rax
; AVX-NEXT:    movabsq $-9223372036854775808, %rcx # imm = 0x8000000000000000
; AVX-NEXT:    xorq %rcx, %rax
; AVX-NEXT:    vcvttss2si %xmm0, %rdx
; AVX-NEXT:    vucomiss %xmm1, %xmm0
; AVX-NEXT:    cmovaeq %rax, %rdx
; AVX-NEXT:    vmovq %rdx, %xmm2
; AVX-NEXT:    vmovshdup {{.*#+}} xmm0 = xmm0[1,1,3,3]
; AVX-NEXT:    vsubss %xmm1, %xmm0, %xmm3
; AVX-NEXT:    vcvttss2si %xmm3, %rax
; AVX-NEXT:    xorq %rcx, %rax
; AVX-NEXT:    vcvttss2si %xmm0, %rcx
; AVX-NEXT:    vucomiss %xmm1, %xmm0
; AVX-NEXT:    cmovaeq %rax, %rcx
; AVX-NEXT:    vmovq %rcx, %xmm0
; AVX-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm2[0],xmm0[0]
; AVX-NEXT:    retq
;
; AVX512-LABEL: fptoui_2f32_to_2i64:
; AVX512:       # BB#0:
; AVX512-NEXT:    vcvttss2usi %xmm0, %rax
; AVX512-NEXT:    vmovq %rax, %xmm1
; AVX512-NEXT:    vmovshdup {{.*#+}} xmm0 = xmm0[1,1,3,3]
; AVX512-NEXT:    vcvttss2usi %xmm0, %rax
; AVX512-NEXT:    vmovq %rax, %xmm0
; AVX512-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm1[0],xmm0[0]
; AVX512-NEXT:    retq
  %shuf = shufflevector <4 x float> %a, <4 x float> undef, <2 x i32> <i32 0, i32 1>
  %cvt = fptoui <2 x float> %shuf to <2 x i64>
  ret <2 x i64> %cvt
}

define <2 x i64> @fptoui_4f32_to_2i64(<4 x float> %a) {
; SSE-LABEL: fptoui_4f32_to_2i64:
; SSE:       # BB#0:
; SSE-NEXT:    movss {{.*#+}} xmm2 = mem[0],zero,zero,zero
; SSE-NEXT:    movaps %xmm0, %xmm1
; SSE-NEXT:    subss %xmm2, %xmm1
; SSE-NEXT:    cvttss2si %xmm1, %rax
; SSE-NEXT:    movabsq $-9223372036854775808, %rcx # imm = 0x8000000000000000
; SSE-NEXT:    xorq %rcx, %rax
; SSE-NEXT:    cvttss2si %xmm0, %rdx
; SSE-NEXT:    ucomiss %xmm2, %xmm0
; SSE-NEXT:    cmovaeq %rax, %rdx
; SSE-NEXT:    movd %rdx, %xmm1
; SSE-NEXT:    shufps {{.*#+}} xmm0 = xmm0[1,1,2,3]
; SSE-NEXT:    movaps %xmm0, %xmm3
; SSE-NEXT:    subss %xmm2, %xmm3
; SSE-NEXT:    cvttss2si %xmm3, %rax
; SSE-NEXT:    xorq %rcx, %rax
; SSE-NEXT:    cvttss2si %xmm0, %rcx
; SSE-NEXT:    ucomiss %xmm2, %xmm0
; SSE-NEXT:    cmovaeq %rax, %rcx
; SSE-NEXT:    movd %rcx, %xmm0
; SSE-NEXT:    punpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm0[0]
; SSE-NEXT:    movdqa %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: fptoui_4f32_to_2i64:
; AVX:       # BB#0:
; AVX-NEXT:    vmovshdup {{.*#+}} xmm1 = xmm0[1,1,3,3]
; AVX-NEXT:    vmovss {{.*#+}} xmm2 = mem[0],zero,zero,zero
; AVX-NEXT:    vsubss %xmm2, %xmm1, %xmm3
; AVX-NEXT:    vcvttss2si %xmm3, %rax
; AVX-NEXT:    movabsq $-9223372036854775808, %rcx # imm = 0x8000000000000000
; AVX-NEXT:    xorq %rcx, %rax
; AVX-NEXT:    vcvttss2si %xmm1, %rdx
; AVX-NEXT:    vucomiss %xmm2, %xmm1
; AVX-NEXT:    cmovaeq %rax, %rdx
; AVX-NEXT:    vsubss %xmm2, %xmm0, %xmm1
; AVX-NEXT:    vcvttss2si %xmm1, %rax
; AVX-NEXT:    xorq %rcx, %rax
; AVX-NEXT:    vcvttss2si %xmm0, %rcx
; AVX-NEXT:    vucomiss %xmm2, %xmm0
; AVX-NEXT:    cmovaeq %rax, %rcx
; AVX-NEXT:    vmovq %rcx, %xmm0
; AVX-NEXT:    vmovq %rdx, %xmm1
; AVX-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; AVX-NEXT:    retq
;
; AVX512F-LABEL: fptoui_4f32_to_2i64:
; AVX512F:       # BB#0:
; AVX512F-NEXT:    vmovshdup {{.*#+}} xmm1 = xmm0[1,1,3,3]
; AVX512F-NEXT:    vcvttss2usi %xmm1, %rax
; AVX512F-NEXT:    vcvttss2usi %xmm0, %rcx
; AVX512F-NEXT:    vmovq %rcx, %xmm0
; AVX512F-NEXT:    vmovq %rax, %xmm1
; AVX512F-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: fptoui_4f32_to_2i64:
; AVX512VL:       # BB#0:
; AVX512VL-NEXT:    vmovshdup {{.*#+}} xmm1 = xmm0[1,1,3,3]
; AVX512VL-NEXT:    vcvttss2usi %xmm1, %rax
; AVX512VL-NEXT:    vcvttss2usi %xmm0, %rcx
; AVX512VL-NEXT:    vmovq %rcx, %xmm0
; AVX512VL-NEXT:    vmovq %rax, %xmm1
; AVX512VL-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; AVX512VL-NEXT:    retq
;
; AVX512VLDQ-LABEL: fptoui_4f32_to_2i64:
; AVX512VLDQ:       # BB#0:
; AVX512VLDQ-NEXT:    vcvttps2uqq %xmm0, %ymm0
; AVX512VLDQ-NEXT:    # kill: %XMM0<def> %XMM0<kill> %YMM0<kill>
; AVX512VLDQ-NEXT:    retq
  %cvt = fptoui <4 x float> %a to <4 x i64>
  %shuf = shufflevector <4 x i64> %cvt, <4 x i64> undef, <2 x i32> <i32 0, i32 1>
  ret <2 x i64> %shuf
}

define <8 x i32> @fptoui_8f32_to_8i32(<8 x float> %a) {
; SSE-LABEL: fptoui_8f32_to_8i32:
; SSE:       # BB#0:
; SSE-NEXT:    movaps %xmm0, %xmm2
; SSE-NEXT:    shufps {{.*#+}} xmm0 = xmm0[3,1,2,3]
; SSE-NEXT:    cvttss2si %xmm0, %rax
; SSE-NEXT:    movd %eax, %xmm0
; SSE-NEXT:    movaps %xmm2, %xmm3
; SSE-NEXT:    shufps {{.*#+}} xmm3 = xmm3[1,1,2,3]
; SSE-NEXT:    cvttss2si %xmm3, %rax
; SSE-NEXT:    movd %eax, %xmm3
; SSE-NEXT:    punpckldq {{.*#+}} xmm3 = xmm3[0],xmm0[0],xmm3[1],xmm0[1]
; SSE-NEXT:    cvttss2si %xmm2, %rax
; SSE-NEXT:    movd %eax, %xmm0
; SSE-NEXT:    movhlps {{.*#+}} xmm2 = xmm2[1,1]
; SSE-NEXT:    cvttss2si %xmm2, %rax
; SSE-NEXT:    movd %eax, %xmm2
; SSE-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1]
; SSE-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm3[0],xmm0[1],xmm3[1]
; SSE-NEXT:    movaps %xmm1, %xmm2
; SSE-NEXT:    shufps {{.*#+}} xmm2 = xmm2[3,1,2,3]
; SSE-NEXT:    cvttss2si %xmm2, %rax
; SSE-NEXT:    movd %eax, %xmm2
; SSE-NEXT:    movaps %xmm1, %xmm3
; SSE-NEXT:    shufps {{.*#+}} xmm3 = xmm3[1,1,2,3]
; SSE-NEXT:    cvttss2si %xmm3, %rax
; SSE-NEXT:    movd %eax, %xmm3
; SSE-NEXT:    punpckldq {{.*#+}} xmm3 = xmm3[0],xmm2[0],xmm3[1],xmm2[1]
; SSE-NEXT:    cvttss2si %xmm1, %rax
; SSE-NEXT:    movd %eax, %xmm2
; SSE-NEXT:    movhlps {{.*#+}} xmm1 = xmm1[1,1]
; SSE-NEXT:    cvttss2si %xmm1, %rax
; SSE-NEXT:    movd %eax, %xmm1
; SSE-NEXT:    punpckldq {{.*#+}} xmm2 = xmm2[0],xmm1[0],xmm2[1],xmm1[1]
; SSE-NEXT:    punpckldq {{.*#+}} xmm2 = xmm2[0],xmm3[0],xmm2[1],xmm3[1]
; SSE-NEXT:    movdqa %xmm2, %xmm1
; SSE-NEXT:    retq
;
; AVX1-LABEL: fptoui_8f32_to_8i32:
; AVX1:       # BB#0:
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX1-NEXT:    vmovshdup {{.*#+}} xmm2 = xmm1[1,1,3,3]
; AVX1-NEXT:    vcvttss2si %xmm2, %rax
; AVX1-NEXT:    vcvttss2si %xmm1, %rcx
; AVX1-NEXT:    vmovd %ecx, %xmm2
; AVX1-NEXT:    vpinsrd $1, %eax, %xmm2, %xmm2
; AVX1-NEXT:    vpermilpd {{.*#+}} xmm3 = xmm1[1,0]
; AVX1-NEXT:    vcvttss2si %xmm3, %rax
; AVX1-NEXT:    vpinsrd $2, %eax, %xmm2, %xmm2
; AVX1-NEXT:    vpermilps {{.*#+}} xmm1 = xmm1[3,1,2,3]
; AVX1-NEXT:    vcvttss2si %xmm1, %rax
; AVX1-NEXT:    vpinsrd $3, %eax, %xmm2, %xmm1
; AVX1-NEXT:    vmovshdup {{.*#+}} xmm2 = xmm0[1,1,3,3]
; AVX1-NEXT:    vcvttss2si %xmm2, %rax
; AVX1-NEXT:    vcvttss2si %xmm0, %rcx
; AVX1-NEXT:    vmovd %ecx, %xmm2
; AVX1-NEXT:    vpinsrd $1, %eax, %xmm2, %xmm2
; AVX1-NEXT:    vpermilpd {{.*#+}} xmm3 = xmm0[1,0]
; AVX1-NEXT:    vcvttss2si %xmm3, %rax
; AVX1-NEXT:    vpinsrd $2, %eax, %xmm2, %xmm2
; AVX1-NEXT:    vpermilps {{.*#+}} xmm0 = xmm0[3,1,2,3]
; AVX1-NEXT:    vcvttss2si %xmm0, %rax
; AVX1-NEXT:    vpinsrd $3, %eax, %xmm2, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: fptoui_8f32_to_8i32:
; AVX2:       # BB#0:
; AVX2-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX2-NEXT:    vmovshdup {{.*#+}} xmm2 = xmm1[1,1,3,3]
; AVX2-NEXT:    vcvttss2si %xmm2, %rax
; AVX2-NEXT:    vcvttss2si %xmm1, %rcx
; AVX2-NEXT:    vmovd %ecx, %xmm2
; AVX2-NEXT:    vpinsrd $1, %eax, %xmm2, %xmm2
; AVX2-NEXT:    vpermilpd {{.*#+}} xmm3 = xmm1[1,0]
; AVX2-NEXT:    vcvttss2si %xmm3, %rax
; AVX2-NEXT:    vpinsrd $2, %eax, %xmm2, %xmm2
; AVX2-NEXT:    vpermilps {{.*#+}} xmm1 = xmm1[3,1,2,3]
; AVX2-NEXT:    vcvttss2si %xmm1, %rax
; AVX2-NEXT:    vpinsrd $3, %eax, %xmm2, %xmm1
; AVX2-NEXT:    vmovshdup {{.*#+}} xmm2 = xmm0[1,1,3,3]
; AVX2-NEXT:    vcvttss2si %xmm2, %rax
; AVX2-NEXT:    vcvttss2si %xmm0, %rcx
; AVX2-NEXT:    vmovd %ecx, %xmm2
; AVX2-NEXT:    vpinsrd $1, %eax, %xmm2, %xmm2
; AVX2-NEXT:    vpermilpd {{.*#+}} xmm3 = xmm0[1,0]
; AVX2-NEXT:    vcvttss2si %xmm3, %rax
; AVX2-NEXT:    vpinsrd $2, %eax, %xmm2, %xmm2
; AVX2-NEXT:    vpermilps {{.*#+}} xmm0 = xmm0[3,1,2,3]
; AVX2-NEXT:    vcvttss2si %xmm0, %rax
; AVX2-NEXT:    vpinsrd $3, %eax, %xmm2, %xmm0
; AVX2-NEXT:    vinserti128 $1, %xmm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: fptoui_8f32_to_8i32:
; AVX512F:       # BB#0:
; AVX512F-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<def>
; AVX512F-NEXT:    vcvttps2udq %zmm0, %zmm0
; AVX512F-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<kill>
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: fptoui_8f32_to_8i32:
; AVX512VL:       # BB#0:
; AVX512VL-NEXT:    vcvttps2udq %ymm0, %ymm0
; AVX512VL-NEXT:    retq
;
; AVX512VLDQ-LABEL: fptoui_8f32_to_8i32:
; AVX512VLDQ:       # BB#0:
; AVX512VLDQ-NEXT:    vcvttps2udq %ymm0, %ymm0
; AVX512VLDQ-NEXT:    retq
  %cvt = fptoui <8 x float> %a to <8 x i32>
  ret <8 x i32> %cvt
}

define <4 x i64> @fptoui_4f32_to_4i64(<8 x float> %a) {
; SSE-LABEL: fptoui_4f32_to_4i64:
; SSE:       # BB#0:
; SSE-NEXT:    movss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; SSE-NEXT:    movaps %xmm0, %xmm2
; SSE-NEXT:    subss %xmm1, %xmm2
; SSE-NEXT:    cvttss2si %xmm2, %rcx
; SSE-NEXT:    movabsq $-9223372036854775808, %rax # imm = 0x8000000000000000
; SSE-NEXT:    xorq %rax, %rcx
; SSE-NEXT:    cvttss2si %xmm0, %rdx
; SSE-NEXT:    ucomiss %xmm1, %xmm0
; SSE-NEXT:    cmovaeq %rcx, %rdx
; SSE-NEXT:    movd %rdx, %xmm2
; SSE-NEXT:    movaps %xmm0, %xmm3
; SSE-NEXT:    shufps {{.*#+}} xmm3 = xmm3[1,1,2,3]
; SSE-NEXT:    movaps %xmm3, %xmm4
; SSE-NEXT:    subss %xmm1, %xmm4
; SSE-NEXT:    cvttss2si %xmm4, %rcx
; SSE-NEXT:    xorq %rax, %rcx
; SSE-NEXT:    cvttss2si %xmm3, %rdx
; SSE-NEXT:    ucomiss %xmm1, %xmm3
; SSE-NEXT:    cmovaeq %rcx, %rdx
; SSE-NEXT:    movd %rdx, %xmm3
; SSE-NEXT:    punpcklqdq {{.*#+}} xmm2 = xmm2[0],xmm3[0]
; SSE-NEXT:    movaps %xmm0, %xmm3
; SSE-NEXT:    shufps {{.*#+}} xmm3 = xmm3[3,1,2,3]
; SSE-NEXT:    movaps %xmm3, %xmm4
; SSE-NEXT:    subss %xmm1, %xmm4
; SSE-NEXT:    cvttss2si %xmm4, %rcx
; SSE-NEXT:    xorq %rax, %rcx
; SSE-NEXT:    cvttss2si %xmm3, %rdx
; SSE-NEXT:    ucomiss %xmm1, %xmm3
; SSE-NEXT:    cmovaeq %rcx, %rdx
; SSE-NEXT:    movd %rdx, %xmm3
; SSE-NEXT:    movhlps {{.*#+}} xmm0 = xmm0[1,1]
; SSE-NEXT:    movaps %xmm0, %xmm4
; SSE-NEXT:    subss %xmm1, %xmm4
; SSE-NEXT:    cvttss2si %xmm4, %rcx
; SSE-NEXT:    xorq %rax, %rcx
; SSE-NEXT:    cvttss2si %xmm0, %rax
; SSE-NEXT:    ucomiss %xmm1, %xmm0
; SSE-NEXT:    cmovaeq %rcx, %rax
; SSE-NEXT:    movd %rax, %xmm1
; SSE-NEXT:    punpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm3[0]
; SSE-NEXT:    movdqa %xmm2, %xmm0
; SSE-NEXT:    retq
;
; AVX1-LABEL: fptoui_4f32_to_4i64:
; AVX1:       # BB#0:
; AVX1-NEXT:    vpermilps {{.*#+}} xmm2 = xmm0[3,1,2,3]
; AVX1-NEXT:    vmovss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; AVX1-NEXT:    vsubss %xmm1, %xmm2, %xmm3
; AVX1-NEXT:    vcvttss2si %xmm3, %rax
; AVX1-NEXT:    movabsq $-9223372036854775808, %rcx # imm = 0x8000000000000000
; AVX1-NEXT:    xorq %rcx, %rax
; AVX1-NEXT:    vcvttss2si %xmm2, %rdx
; AVX1-NEXT:    vucomiss %xmm1, %xmm2
; AVX1-NEXT:    cmovaeq %rax, %rdx
; AVX1-NEXT:    vmovq %rdx, %xmm2
; AVX1-NEXT:    vpermilpd {{.*#+}} xmm3 = xmm0[1,0]
; AVX1-NEXT:    vsubss %xmm1, %xmm3, %xmm4
; AVX1-NEXT:    vcvttss2si %xmm4, %rax
; AVX1-NEXT:    xorq %rcx, %rax
; AVX1-NEXT:    vcvttss2si %xmm3, %rdx
; AVX1-NEXT:    vucomiss %xmm1, %xmm3
; AVX1-NEXT:    cmovaeq %rax, %rdx
; AVX1-NEXT:    vmovq %rdx, %xmm3
; AVX1-NEXT:    vpunpcklqdq {{.*#+}} xmm2 = xmm3[0],xmm2[0]
; AVX1-NEXT:    vsubss %xmm1, %xmm0, %xmm3
; AVX1-NEXT:    vcvttss2si %xmm3, %rax
; AVX1-NEXT:    xorq %rcx, %rax
; AVX1-NEXT:    vcvttss2si %xmm0, %rdx
; AVX1-NEXT:    vucomiss %xmm1, %xmm0
; AVX1-NEXT:    cmovaeq %rax, %rdx
; AVX1-NEXT:    vmovq %rdx, %xmm3
; AVX1-NEXT:    vmovshdup {{.*#+}} xmm0 = xmm0[1,1,3,3]
; AVX1-NEXT:    vsubss %xmm1, %xmm0, %xmm4
; AVX1-NEXT:    vcvttss2si %xmm4, %rax
; AVX1-NEXT:    xorq %rcx, %rax
; AVX1-NEXT:    vcvttss2si %xmm0, %rcx
; AVX1-NEXT:    vucomiss %xmm1, %xmm0
; AVX1-NEXT:    cmovaeq %rax, %rcx
; AVX1-NEXT:    vmovq %rcx, %xmm0
; AVX1-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm3[0],xmm0[0]
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: fptoui_4f32_to_4i64:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpermilps {{.*#+}} xmm2 = xmm0[3,1,2,3]
; AVX2-NEXT:    vmovss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; AVX2-NEXT:    vsubss %xmm1, %xmm2, %xmm3
; AVX2-NEXT:    vcvttss2si %xmm3, %rax
; AVX2-NEXT:    movabsq $-9223372036854775808, %rcx # imm = 0x8000000000000000
; AVX2-NEXT:    xorq %rcx, %rax
; AVX2-NEXT:    vcvttss2si %xmm2, %rdx
; AVX2-NEXT:    vucomiss %xmm1, %xmm2
; AVX2-NEXT:    cmovaeq %rax, %rdx
; AVX2-NEXT:    vmovq %rdx, %xmm2
; AVX2-NEXT:    vpermilpd {{.*#+}} xmm3 = xmm0[1,0]
; AVX2-NEXT:    vsubss %xmm1, %xmm3, %xmm4
; AVX2-NEXT:    vcvttss2si %xmm4, %rax
; AVX2-NEXT:    xorq %rcx, %rax
; AVX2-NEXT:    vcvttss2si %xmm3, %rdx
; AVX2-NEXT:    vucomiss %xmm1, %xmm3
; AVX2-NEXT:    cmovaeq %rax, %rdx
; AVX2-NEXT:    vmovq %rdx, %xmm3
; AVX2-NEXT:    vpunpcklqdq {{.*#+}} xmm2 = xmm3[0],xmm2[0]
; AVX2-NEXT:    vsubss %xmm1, %xmm0, %xmm3
; AVX2-NEXT:    vcvttss2si %xmm3, %rax
; AVX2-NEXT:    xorq %rcx, %rax
; AVX2-NEXT:    vcvttss2si %xmm0, %rdx
; AVX2-NEXT:    vucomiss %xmm1, %xmm0
; AVX2-NEXT:    cmovaeq %rax, %rdx
; AVX2-NEXT:    vmovq %rdx, %xmm3
; AVX2-NEXT:    vmovshdup {{.*#+}} xmm0 = xmm0[1,1,3,3]
; AVX2-NEXT:    vsubss %xmm1, %xmm0, %xmm4
; AVX2-NEXT:    vcvttss2si %xmm4, %rax
; AVX2-NEXT:    xorq %rcx, %rax
; AVX2-NEXT:    vcvttss2si %xmm0, %rcx
; AVX2-NEXT:    vucomiss %xmm1, %xmm0
; AVX2-NEXT:    cmovaeq %rax, %rcx
; AVX2-NEXT:    vmovq %rcx, %xmm0
; AVX2-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm3[0],xmm0[0]
; AVX2-NEXT:    vinserti128 $1, %xmm2, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: fptoui_4f32_to_4i64:
; AVX512F:       # BB#0:
; AVX512F-NEXT:    vpermilps {{.*#+}} xmm1 = xmm0[3,1,2,3]
; AVX512F-NEXT:    vcvttss2usi %xmm1, %rax
; AVX512F-NEXT:    vmovq %rax, %xmm1
; AVX512F-NEXT:    vpermilpd {{.*#+}} xmm2 = xmm0[1,0]
; AVX512F-NEXT:    vcvttss2usi %xmm2, %rax
; AVX512F-NEXT:    vmovq %rax, %xmm2
; AVX512F-NEXT:    vpunpcklqdq {{.*#+}} xmm1 = xmm2[0],xmm1[0]
; AVX512F-NEXT:    vcvttss2usi %xmm0, %rax
; AVX512F-NEXT:    vmovq %rax, %xmm2
; AVX512F-NEXT:    vmovshdup {{.*#+}} xmm0 = xmm0[1,1,3,3]
; AVX512F-NEXT:    vcvttss2usi %xmm0, %rax
; AVX512F-NEXT:    vmovq %rax, %xmm0
; AVX512F-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm2[0],xmm0[0]
; AVX512F-NEXT:    vinserti128 $1, %xmm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: fptoui_4f32_to_4i64:
; AVX512VL:       # BB#0:
; AVX512VL-NEXT:    vpermilps {{.*#+}} xmm1 = xmm0[3,1,2,3]
; AVX512VL-NEXT:    vcvttss2usi %xmm1, %rax
; AVX512VL-NEXT:    vmovq %rax, %xmm1
; AVX512VL-NEXT:    vpermilpd {{.*#+}} xmm2 = xmm0[1,0]
; AVX512VL-NEXT:    vcvttss2usi %xmm2, %rax
; AVX512VL-NEXT:    vmovq %rax, %xmm2
; AVX512VL-NEXT:    vpunpcklqdq {{.*#+}} xmm1 = xmm2[0],xmm1[0]
; AVX512VL-NEXT:    vcvttss2usi %xmm0, %rax
; AVX512VL-NEXT:    vmovq %rax, %xmm2
; AVX512VL-NEXT:    vmovshdup {{.*#+}} xmm0 = xmm0[1,1,3,3]
; AVX512VL-NEXT:    vcvttss2usi %xmm0, %rax
; AVX512VL-NEXT:    vmovq %rax, %xmm0
; AVX512VL-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm2[0],xmm0[0]
; AVX512VL-NEXT:    vinserti32x4 $1, %xmm1, %ymm0, %ymm0
; AVX512VL-NEXT:    retq
;
; AVX512VLDQ-LABEL: fptoui_4f32_to_4i64:
; AVX512VLDQ:       # BB#0:
; AVX512VLDQ-NEXT:    vcvttps2uqq %xmm0, %ymm0
; AVX512VLDQ-NEXT:    retq
  %shuf = shufflevector <8 x float> %a, <8 x float> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %cvt = fptoui <4 x float> %shuf to <4 x i64>
  ret <4 x i64> %cvt
}

define <4 x i64> @fptoui_8f32_to_4i64(<8 x float> %a) {
; SSE-LABEL: fptoui_8f32_to_4i64:
; SSE:       # BB#0:
; SSE-NEXT:    movss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; SSE-NEXT:    movaps %xmm0, %xmm2
; SSE-NEXT:    subss %xmm1, %xmm2
; SSE-NEXT:    cvttss2si %xmm2, %rcx
; SSE-NEXT:    movabsq $-9223372036854775808, %rax # imm = 0x8000000000000000
; SSE-NEXT:    xorq %rax, %rcx
; SSE-NEXT:    cvttss2si %xmm0, %rdx
; SSE-NEXT:    ucomiss %xmm1, %xmm0
; SSE-NEXT:    cmovaeq %rcx, %rdx
; SSE-NEXT:    movd %rdx, %xmm2
; SSE-NEXT:    movaps %xmm0, %xmm3
; SSE-NEXT:    shufps {{.*#+}} xmm3 = xmm3[1,1,2,3]
; SSE-NEXT:    movaps %xmm3, %xmm4
; SSE-NEXT:    subss %xmm1, %xmm4
; SSE-NEXT:    cvttss2si %xmm4, %rcx
; SSE-NEXT:    xorq %rax, %rcx
; SSE-NEXT:    cvttss2si %xmm3, %rdx
; SSE-NEXT:    ucomiss %xmm1, %xmm3
; SSE-NEXT:    cmovaeq %rcx, %rdx
; SSE-NEXT:    movd %rdx, %xmm3
; SSE-NEXT:    punpcklqdq {{.*#+}} xmm2 = xmm2[0],xmm3[0]
; SSE-NEXT:    movaps %xmm0, %xmm3
; SSE-NEXT:    shufps {{.*#+}} xmm3 = xmm3[3,1,2,3]
; SSE-NEXT:    movaps %xmm3, %xmm4
; SSE-NEXT:    subss %xmm1, %xmm4
; SSE-NEXT:    cvttss2si %xmm4, %rcx
; SSE-NEXT:    xorq %rax, %rcx
; SSE-NEXT:    cvttss2si %xmm3, %rdx
; SSE-NEXT:    ucomiss %xmm1, %xmm3
; SSE-NEXT:    cmovaeq %rcx, %rdx
; SSE-NEXT:    movd %rdx, %xmm3
; SSE-NEXT:    movhlps {{.*#+}} xmm0 = xmm0[1,1]
; SSE-NEXT:    movaps %xmm0, %xmm4
; SSE-NEXT:    subss %xmm1, %xmm4
; SSE-NEXT:    cvttss2si %xmm4, %rcx
; SSE-NEXT:    xorq %rax, %rcx
; SSE-NEXT:    cvttss2si %xmm0, %rax
; SSE-NEXT:    ucomiss %xmm1, %xmm0
; SSE-NEXT:    cmovaeq %rcx, %rax
; SSE-NEXT:    movd %rax, %xmm1
; SSE-NEXT:    punpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm3[0]
; SSE-NEXT:    movdqa %xmm2, %xmm0
; SSE-NEXT:    retq
;
; AVX1-LABEL: fptoui_8f32_to_4i64:
; AVX1:       # BB#0:
; AVX1-NEXT:    vpermilps {{.*#+}} xmm2 = xmm0[3,1,2,3]
; AVX1-NEXT:    vmovss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; AVX1-NEXT:    vsubss %xmm1, %xmm2, %xmm3
; AVX1-NEXT:    vcvttss2si %xmm3, %rax
; AVX1-NEXT:    movabsq $-9223372036854775808, %rcx # imm = 0x8000000000000000
; AVX1-NEXT:    xorq %rcx, %rax
; AVX1-NEXT:    vcvttss2si %xmm2, %rdx
; AVX1-NEXT:    vucomiss %xmm1, %xmm2
; AVX1-NEXT:    cmovaeq %rax, %rdx
; AVX1-NEXT:    vmovq %rdx, %xmm2
; AVX1-NEXT:    vpermilpd {{.*#+}} xmm3 = xmm0[1,0]
; AVX1-NEXT:    vsubss %xmm1, %xmm3, %xmm4
; AVX1-NEXT:    vcvttss2si %xmm4, %rax
; AVX1-NEXT:    xorq %rcx, %rax
; AVX1-NEXT:    vcvttss2si %xmm3, %rdx
; AVX1-NEXT:    vucomiss %xmm1, %xmm3
; AVX1-NEXT:    cmovaeq %rax, %rdx
; AVX1-NEXT:    vmovq %rdx, %xmm3
; AVX1-NEXT:    vpunpcklqdq {{.*#+}} xmm2 = xmm3[0],xmm2[0]
; AVX1-NEXT:    vsubss %xmm1, %xmm0, %xmm3
; AVX1-NEXT:    vcvttss2si %xmm3, %rax
; AVX1-NEXT:    xorq %rcx, %rax
; AVX1-NEXT:    vcvttss2si %xmm0, %rdx
; AVX1-NEXT:    vucomiss %xmm1, %xmm0
; AVX1-NEXT:    cmovaeq %rax, %rdx
; AVX1-NEXT:    vmovq %rdx, %xmm3
; AVX1-NEXT:    vmovshdup {{.*#+}} xmm0 = xmm0[1,1,3,3]
; AVX1-NEXT:    vsubss %xmm1, %xmm0, %xmm4
; AVX1-NEXT:    vcvttss2si %xmm4, %rax
; AVX1-NEXT:    xorq %rcx, %rax
; AVX1-NEXT:    vcvttss2si %xmm0, %rcx
; AVX1-NEXT:    vucomiss %xmm1, %xmm0
; AVX1-NEXT:    cmovaeq %rax, %rcx
; AVX1-NEXT:    vmovq %rcx, %xmm0
; AVX1-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm3[0],xmm0[0]
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: fptoui_8f32_to_4i64:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpermilps {{.*#+}} xmm2 = xmm0[3,1,2,3]
; AVX2-NEXT:    vmovss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; AVX2-NEXT:    vsubss %xmm1, %xmm2, %xmm3
; AVX2-NEXT:    vcvttss2si %xmm3, %rax
; AVX2-NEXT:    movabsq $-9223372036854775808, %rcx # imm = 0x8000000000000000
; AVX2-NEXT:    xorq %rcx, %rax
; AVX2-NEXT:    vcvttss2si %xmm2, %rdx
; AVX2-NEXT:    vucomiss %xmm1, %xmm2
; AVX2-NEXT:    cmovaeq %rax, %rdx
; AVX2-NEXT:    vmovq %rdx, %xmm2
; AVX2-NEXT:    vpermilpd {{.*#+}} xmm3 = xmm0[1,0]
; AVX2-NEXT:    vsubss %xmm1, %xmm3, %xmm4
; AVX2-NEXT:    vcvttss2si %xmm4, %rax
; AVX2-NEXT:    xorq %rcx, %rax
; AVX2-NEXT:    vcvttss2si %xmm3, %rdx
; AVX2-NEXT:    vucomiss %xmm1, %xmm3
; AVX2-NEXT:    cmovaeq %rax, %rdx
; AVX2-NEXT:    vmovq %rdx, %xmm3
; AVX2-NEXT:    vpunpcklqdq {{.*#+}} xmm2 = xmm3[0],xmm2[0]
; AVX2-NEXT:    vsubss %xmm1, %xmm0, %xmm3
; AVX2-NEXT:    vcvttss2si %xmm3, %rax
; AVX2-NEXT:    xorq %rcx, %rax
; AVX2-NEXT:    vcvttss2si %xmm0, %rdx
; AVX2-NEXT:    vucomiss %xmm1, %xmm0
; AVX2-NEXT:    cmovaeq %rax, %rdx
; AVX2-NEXT:    vmovq %rdx, %xmm3
; AVX2-NEXT:    vmovshdup {{.*#+}} xmm0 = xmm0[1,1,3,3]
; AVX2-NEXT:    vsubss %xmm1, %xmm0, %xmm4
; AVX2-NEXT:    vcvttss2si %xmm4, %rax
; AVX2-NEXT:    xorq %rcx, %rax
; AVX2-NEXT:    vcvttss2si %xmm0, %rcx
; AVX2-NEXT:    vucomiss %xmm1, %xmm0
; AVX2-NEXT:    cmovaeq %rax, %rcx
; AVX2-NEXT:    vmovq %rcx, %xmm0
; AVX2-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm3[0],xmm0[0]
; AVX2-NEXT:    vinserti128 $1, %xmm2, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: fptoui_8f32_to_4i64:
; AVX512F:       # BB#0:
; AVX512F-NEXT:    vmovshdup {{.*#+}} xmm1 = xmm0[1,1,3,3]
; AVX512F-NEXT:    vcvttss2usi %xmm1, %rax
; AVX512F-NEXT:    vcvttss2usi %xmm0, %rcx
; AVX512F-NEXT:    vpermilpd {{.*#+}} xmm1 = xmm0[1,0]
; AVX512F-NEXT:    vcvttss2usi %xmm1, %rdx
; AVX512F-NEXT:    vpermilps {{.*#+}} xmm0 = xmm0[3,1,2,3]
; AVX512F-NEXT:    vcvttss2usi %xmm0, %rsi
; AVX512F-NEXT:    vmovq %rsi, %xmm0
; AVX512F-NEXT:    vmovq %rdx, %xmm1
; AVX512F-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm1[0],xmm0[0]
; AVX512F-NEXT:    vmovq %rcx, %xmm1
; AVX512F-NEXT:    vmovq %rax, %xmm2
; AVX512F-NEXT:    vpunpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm2[0]
; AVX512F-NEXT:    vinserti128 $1, %xmm0, %ymm1, %ymm0
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: fptoui_8f32_to_4i64:
; AVX512VL:       # BB#0:
; AVX512VL-NEXT:    vmovshdup {{.*#+}} xmm1 = xmm0[1,1,3,3]
; AVX512VL-NEXT:    vcvttss2usi %xmm1, %rax
; AVX512VL-NEXT:    vcvttss2usi %xmm0, %rcx
; AVX512VL-NEXT:    vpermilpd {{.*#+}} xmm1 = xmm0[1,0]
; AVX512VL-NEXT:    vcvttss2usi %xmm1, %rdx
; AVX512VL-NEXT:    vpermilps {{.*#+}} xmm0 = xmm0[3,1,2,3]
; AVX512VL-NEXT:    vcvttss2usi %xmm0, %rsi
; AVX512VL-NEXT:    vmovq %rsi, %xmm0
; AVX512VL-NEXT:    vmovq %rdx, %xmm1
; AVX512VL-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm1[0],xmm0[0]
; AVX512VL-NEXT:    vmovq %rcx, %xmm1
; AVX512VL-NEXT:    vmovq %rax, %xmm2
; AVX512VL-NEXT:    vpunpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm2[0]
; AVX512VL-NEXT:    vinserti32x4 $1, %xmm0, %ymm1, %ymm0
; AVX512VL-NEXT:    retq
;
; AVX512VLDQ-LABEL: fptoui_8f32_to_4i64:
; AVX512VLDQ:       # BB#0:
; AVX512VLDQ-NEXT:    vcvttps2uqq %ymm0, %zmm0
; AVX512VLDQ-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<kill>
; AVX512VLDQ-NEXT:    retq
  %cvt = fptoui <8 x float> %a to <8 x i64>
  %shuf = shufflevector <8 x i64> %cvt, <8 x i64> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  ret <4 x i64> %shuf
}

;
; Constant Folding
;

define <2 x i64> @fptosi_2f64_to_2i64_const() {
; SSE-LABEL: fptosi_2f64_to_2i64_const:
; SSE:       # BB#0:
; SSE-NEXT:    movaps {{.*#+}} xmm0 = [1,18446744073709551615]
; SSE-NEXT:    retq
;
; AVX-LABEL: fptosi_2f64_to_2i64_const:
; AVX:       # BB#0:
; AVX-NEXT:    vmovaps {{.*#+}} xmm0 = [1,18446744073709551615]
; AVX-NEXT:    retq
;
; AVX512-LABEL: fptosi_2f64_to_2i64_const:
; AVX512:       # BB#0:
; AVX512-NEXT:    vmovaps {{.*#+}} xmm0 = [1,18446744073709551615]
; AVX512-NEXT:    retq
  %cvt = fptosi <2 x double> <double 1.0, double -1.0> to <2 x i64>
  ret <2 x i64> %cvt
}

define <4 x i32> @fptosi_2f64_to_2i32_const() {
; SSE-LABEL: fptosi_2f64_to_2i32_const:
; SSE:       # BB#0:
; SSE-NEXT:    movaps {{.*#+}} xmm0 = <4294967295,1,u,u>
; SSE-NEXT:    retq
;
; AVX-LABEL: fptosi_2f64_to_2i32_const:
; AVX:       # BB#0:
; AVX-NEXT:    vmovaps {{.*#+}} xmm0 = <4294967295,1,u,u>
; AVX-NEXT:    retq
;
; AVX512-LABEL: fptosi_2f64_to_2i32_const:
; AVX512:       # BB#0:
; AVX512-NEXT:    vmovaps {{.*#+}} xmm0 = <4294967295,1,u,u>
; AVX512-NEXT:    retq
  %cvt = fptosi <2 x double> <double -1.0, double 1.0> to <2 x i32>
  %ext = shufflevector <2 x i32> %cvt, <2 x i32> undef, <4 x i32> <i32 0, i32 1, i32 undef, i32 undef>
  ret <4 x i32> %ext
}

define <4 x i64> @fptosi_4f64_to_4i64_const() {
; SSE-LABEL: fptosi_4f64_to_4i64_const:
; SSE:       # BB#0:
; SSE-NEXT:    movaps {{.*#+}} xmm0 = [1,18446744073709551615]
; SSE-NEXT:    movaps {{.*#+}} xmm1 = [2,18446744073709551613]
; SSE-NEXT:    retq
;
; AVX-LABEL: fptosi_4f64_to_4i64_const:
; AVX:       # BB#0:
; AVX-NEXT:    vmovaps {{.*#+}} ymm0 = [1,18446744073709551615,2,18446744073709551613]
; AVX-NEXT:    retq
;
; AVX512-LABEL: fptosi_4f64_to_4i64_const:
; AVX512:       # BB#0:
; AVX512-NEXT:    vmovaps {{.*#+}} ymm0 = [1,18446744073709551615,2,18446744073709551613]
; AVX512-NEXT:    retq
  %cvt = fptosi <4 x double> <double 1.0, double -1.0, double 2.0, double -3.0> to <4 x i64>
  ret <4 x i64> %cvt
}

define <4 x i32> @fptosi_4f64_to_4i32_const() {
; SSE-LABEL: fptosi_4f64_to_4i32_const:
; SSE:       # BB#0:
; SSE-NEXT:    movaps {{.*#+}} xmm0 = [4294967295,1,4294967294,3]
; SSE-NEXT:    retq
;
; AVX-LABEL: fptosi_4f64_to_4i32_const:
; AVX:       # BB#0:
; AVX-NEXT:    vmovaps {{.*#+}} xmm0 = [4294967295,1,4294967294,3]
; AVX-NEXT:    retq
;
; AVX512-LABEL: fptosi_4f64_to_4i32_const:
; AVX512:       # BB#0:
; AVX512-NEXT:    vmovaps {{.*#+}} xmm0 = [4294967295,1,4294967294,3]
; AVX512-NEXT:    retq
  %cvt = fptosi <4 x double> <double -1.0, double 1.0, double -2.0, double 3.0> to <4 x i32>
  ret <4 x i32> %cvt
}

define <2 x i64> @fptoui_2f64_to_2i64_const() {
; SSE-LABEL: fptoui_2f64_to_2i64_const:
; SSE:       # BB#0:
; SSE-NEXT:    movaps {{.*#+}} xmm0 = [2,4]
; SSE-NEXT:    retq
;
; AVX-LABEL: fptoui_2f64_to_2i64_const:
; AVX:       # BB#0:
; AVX-NEXT:    vmovaps {{.*#+}} xmm0 = [2,4]
; AVX-NEXT:    retq
;
; AVX512-LABEL: fptoui_2f64_to_2i64_const:
; AVX512:       # BB#0:
; AVX512-NEXT:    vmovaps {{.*#+}} xmm0 = [2,4]
; AVX512-NEXT:    retq
  %cvt = fptoui <2 x double> <double 2.0, double 4.0> to <2 x i64>
  ret <2 x i64> %cvt
}

define <4 x i32> @fptoui_2f64_to_2i32_const(<2 x double> %a) {
; SSE-LABEL: fptoui_2f64_to_2i32_const:
; SSE:       # BB#0:
; SSE-NEXT:    movaps {{.*#+}} xmm0 = <2,4,u,u>
; SSE-NEXT:    retq
;
; AVX-LABEL: fptoui_2f64_to_2i32_const:
; AVX:       # BB#0:
; AVX-NEXT:    vmovaps {{.*#+}} xmm0 = <2,4,u,u>
; AVX-NEXT:    retq
;
; AVX512-LABEL: fptoui_2f64_to_2i32_const:
; AVX512:       # BB#0:
; AVX512-NEXT:    vmovaps {{.*#+}} xmm0 = <2,4,u,u>
; AVX512-NEXT:    retq
  %cvt = fptoui <2 x double> <double 2.0, double 4.0> to <2 x i32>
  %ext = shufflevector <2 x i32> %cvt, <2 x i32> undef, <4 x i32> <i32 0, i32 1, i32 undef, i32 undef>
  ret <4 x i32> %ext
}

define <4 x i64> @fptoui_4f64_to_4i64_const(<4 x double> %a) {
; SSE-LABEL: fptoui_4f64_to_4i64_const:
; SSE:       # BB#0:
; SSE-NEXT:    movaps {{.*#+}} xmm0 = [2,4]
; SSE-NEXT:    movaps {{.*#+}} xmm1 = [6,8]
; SSE-NEXT:    retq
;
; AVX-LABEL: fptoui_4f64_to_4i64_const:
; AVX:       # BB#0:
; AVX-NEXT:    vmovaps {{.*#+}} ymm0 = [2,4,6,8]
; AVX-NEXT:    retq
;
; AVX512-LABEL: fptoui_4f64_to_4i64_const:
; AVX512:       # BB#0:
; AVX512-NEXT:    vmovaps {{.*#+}} ymm0 = [2,4,6,8]
; AVX512-NEXT:    retq
  %cvt = fptoui <4 x double> <double 2.0, double 4.0, double 6.0, double 8.0> to <4 x i64>
  ret <4 x i64> %cvt
}

define <4 x i32> @fptoui_4f64_to_4i32_const(<4 x double> %a) {
; SSE-LABEL: fptoui_4f64_to_4i32_const:
; SSE:       # BB#0:
; SSE-NEXT:    movaps {{.*#+}} xmm0 = [2,4,6,8]
; SSE-NEXT:    retq
;
; AVX-LABEL: fptoui_4f64_to_4i32_const:
; AVX:       # BB#0:
; AVX-NEXT:    vmovaps {{.*#+}} xmm0 = [2,4,6,8]
; AVX-NEXT:    retq
;
; AVX512-LABEL: fptoui_4f64_to_4i32_const:
; AVX512:       # BB#0:
; AVX512-NEXT:    vmovaps {{.*#+}} xmm0 = [2,4,6,8]
; AVX512-NEXT:    retq
  %cvt = fptoui <4 x double> <double 2.0, double 4.0, double 6.0, double 8.0> to <4 x i32>
  ret <4 x i32> %cvt
}

define <4 x i32> @fptosi_4f32_to_4i32_const() {
; SSE-LABEL: fptosi_4f32_to_4i32_const:
; SSE:       # BB#0:
; SSE-NEXT:    movaps {{.*#+}} xmm0 = [1,4294967295,2,3]
; SSE-NEXT:    retq
;
; AVX-LABEL: fptosi_4f32_to_4i32_const:
; AVX:       # BB#0:
; AVX-NEXT:    vmovaps {{.*#+}} xmm0 = [1,4294967295,2,3]
; AVX-NEXT:    retq
;
; AVX512-LABEL: fptosi_4f32_to_4i32_const:
; AVX512:       # BB#0:
; AVX512-NEXT:    vmovaps {{.*#+}} xmm0 = [1,4294967295,2,3]
; AVX512-NEXT:    retq
  %cvt = fptosi <4 x float> <float 1.0, float -1.0, float 2.0, float 3.0> to <4 x i32>
  ret <4 x i32> %cvt
}

define <4 x i64> @fptosi_4f32_to_4i64_const() {
; SSE-LABEL: fptosi_4f32_to_4i64_const:
; SSE:       # BB#0:
; SSE-NEXT:    movaps {{.*#+}} xmm0 = [1,18446744073709551615]
; SSE-NEXT:    movaps {{.*#+}} xmm1 = [2,3]
; SSE-NEXT:    retq
;
; AVX-LABEL: fptosi_4f32_to_4i64_const:
; AVX:       # BB#0:
; AVX-NEXT:    vmovaps {{.*#+}} ymm0 = [1,18446744073709551615,2,3]
; AVX-NEXT:    retq
;
; AVX512-LABEL: fptosi_4f32_to_4i64_const:
; AVX512:       # BB#0:
; AVX512-NEXT:    vmovaps {{.*#+}} ymm0 = [1,18446744073709551615,2,3]
; AVX512-NEXT:    retq
  %cvt = fptosi <4 x float> <float 1.0, float -1.0, float 2.0, float 3.0> to <4 x i64>
  ret <4 x i64> %cvt
}

define <8 x i32> @fptosi_8f32_to_8i32_const(<8 x float> %a) {
; SSE-LABEL: fptosi_8f32_to_8i32_const:
; SSE:       # BB#0:
; SSE-NEXT:    movaps {{.*#+}} xmm0 = [1,4294967295,2,3]
; SSE-NEXT:    movaps {{.*#+}} xmm1 = [6,4294967288,2,4294967295]
; SSE-NEXT:    retq
;
; AVX-LABEL: fptosi_8f32_to_8i32_const:
; AVX:       # BB#0:
; AVX-NEXT:    vmovaps {{.*#+}} ymm0 = [1,4294967295,2,3,6,4294967288,2,4294967295]
; AVX-NEXT:    retq
;
; AVX512-LABEL: fptosi_8f32_to_8i32_const:
; AVX512:       # BB#0:
; AVX512-NEXT:    vmovaps {{.*#+}} ymm0 = [1,4294967295,2,3,6,4294967288,2,4294967295]
; AVX512-NEXT:    retq
  %cvt = fptosi <8 x float> <float 1.0, float -1.0, float 2.0, float 3.0, float 6.0, float -8.0, float 2.0, float -1.0> to <8 x i32>
  ret <8 x i32> %cvt
}

define <4 x i32> @fptoui_4f32_to_4i32_const(<4 x float> %a) {
; SSE-LABEL: fptoui_4f32_to_4i32_const:
; SSE:       # BB#0:
; SSE-NEXT:    movaps {{.*#+}} xmm0 = [1,2,4,6]
; SSE-NEXT:    retq
;
; AVX-LABEL: fptoui_4f32_to_4i32_const:
; AVX:       # BB#0:
; AVX-NEXT:    vmovaps {{.*#+}} xmm0 = [1,2,4,6]
; AVX-NEXT:    retq
;
; AVX512-LABEL: fptoui_4f32_to_4i32_const:
; AVX512:       # BB#0:
; AVX512-NEXT:    vmovaps {{.*#+}} xmm0 = [1,2,4,6]
; AVX512-NEXT:    retq
  %cvt = fptoui <4 x float> <float 1.0, float 2.0, float 4.0, float 6.0> to <4 x i32>
  ret <4 x i32> %cvt
}

define <4 x i64> @fptoui_4f32_to_4i64_const() {
; SSE-LABEL: fptoui_4f32_to_4i64_const:
; SSE:       # BB#0:
; SSE-NEXT:    movaps {{.*#+}} xmm0 = [1,2]
; SSE-NEXT:    movaps {{.*#+}} xmm1 = [4,8]
; SSE-NEXT:    retq
;
; AVX-LABEL: fptoui_4f32_to_4i64_const:
; AVX:       # BB#0:
; AVX-NEXT:    vmovaps {{.*#+}} ymm0 = [1,2,4,8]
; AVX-NEXT:    retq
;
; AVX512-LABEL: fptoui_4f32_to_4i64_const:
; AVX512:       # BB#0:
; AVX512-NEXT:    vmovaps {{.*#+}} ymm0 = [1,2,4,8]
; AVX512-NEXT:    retq
  %cvt = fptoui <4 x float> <float 1.0, float 2.0, float 4.0, float 8.0> to <4 x i64>
  ret <4 x i64> %cvt
}

define <8 x i32> @fptoui_8f32_to_8i32_const(<8 x float> %a) {
; SSE-LABEL: fptoui_8f32_to_8i32_const:
; SSE:       # BB#0:
; SSE-NEXT:    movaps {{.*#+}} xmm0 = [1,2,4,6]
; SSE-NEXT:    movaps {{.*#+}} xmm1 = [8,6,4,1]
; SSE-NEXT:    retq
;
; AVX-LABEL: fptoui_8f32_to_8i32_const:
; AVX:       # BB#0:
; AVX-NEXT:    vmovaps {{.*#+}} ymm0 = [1,2,4,6,8,6,4,1]
; AVX-NEXT:    retq
;
; AVX512-LABEL: fptoui_8f32_to_8i32_const:
; AVX512:       # BB#0:
; AVX512-NEXT:    vmovaps {{.*#+}} ymm0 = [1,2,4,6,8,6,4,1]
; AVX512-NEXT:    retq
  %cvt = fptoui <8 x float> <float 1.0, float 2.0, float 4.0, float 6.0, float 8.0, float 6.0, float 4.0, float 1.0> to <8 x i32>
  ret <8 x i32> %cvt
}

;
; Special Cases
;

define <4 x i32> @fptosi_2f16_to_4i32(<2 x half> %a) nounwind {
; SSE-LABEL: fptosi_2f16_to_4i32:
; SSE:       # BB#0:
; SSE-NEXT:    pushq %rax
; SSE-NEXT:    movss %xmm1, {{[0-9]+}}(%rsp) # 4-byte Spill
; SSE-NEXT:    callq __gnu_f2h_ieee
; SSE-NEXT:    movzwl %ax, %edi
; SSE-NEXT:    callq __gnu_h2f_ieee
; SSE-NEXT:    movss %xmm0, (%rsp) # 4-byte Spill
; SSE-NEXT:    movss {{[0-9]+}}(%rsp), %xmm0 # 4-byte Reload
; SSE-NEXT:    # xmm0 = mem[0],zero,zero,zero
; SSE-NEXT:    callq __gnu_f2h_ieee
; SSE-NEXT:    movzwl %ax, %edi
; SSE-NEXT:    callq __gnu_h2f_ieee
; SSE-NEXT:    cvttss2si %xmm0, %rax
; SSE-NEXT:    movd %rax, %xmm0
; SSE-NEXT:    cvttss2si (%rsp), %rax # 4-byte Folded Reload
; SSE-NEXT:    movd %rax, %xmm1
; SSE-NEXT:    punpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm0[0]
; SSE-NEXT:    pshufd {{.*#+}} xmm0 = xmm1[0,1,0,2]
; SSE-NEXT:    psrldq {{.*#+}} xmm0 = xmm0[8,9,10,11,12,13,14,15],zero,zero,zero,zero,zero,zero,zero,zero
; SSE-NEXT:    popq %rax
; SSE-NEXT:    retq
;
; AVX-LABEL: fptosi_2f16_to_4i32:
; AVX:       # BB#0:
; AVX-NEXT:    pushq %rax
; AVX-NEXT:    vmovss %xmm1, {{[0-9]+}}(%rsp) # 4-byte Spill
; AVX-NEXT:    callq __gnu_f2h_ieee
; AVX-NEXT:    movzwl %ax, %edi
; AVX-NEXT:    callq __gnu_h2f_ieee
; AVX-NEXT:    vmovss %xmm0, (%rsp) # 4-byte Spill
; AVX-NEXT:    vmovss {{[0-9]+}}(%rsp), %xmm0 # 4-byte Reload
; AVX-NEXT:    # xmm0 = mem[0],zero,zero,zero
; AVX-NEXT:    callq __gnu_f2h_ieee
; AVX-NEXT:    movzwl %ax, %edi
; AVX-NEXT:    callq __gnu_h2f_ieee
; AVX-NEXT:    vcvttss2si %xmm0, %rax
; AVX-NEXT:    vmovq %rax, %xmm0
; AVX-NEXT:    vcvttss2si (%rsp), %rax # 4-byte Folded Reload
; AVX-NEXT:    vmovq %rax, %xmm1
; AVX-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm1[0],xmm0[0]
; AVX-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[0,2,2,3]
; AVX-NEXT:    vmovq {{.*#+}} xmm0 = xmm0[0],zero
; AVX-NEXT:    popq %rax
; AVX-NEXT:    retq
;
; AVX512F-LABEL: fptosi_2f16_to_4i32:
; AVX512F:       # BB#0:
; AVX512F-NEXT:    # kill: %XMM1<def> %XMM1<kill> %ZMM1<def>
; AVX512F-NEXT:    # kill: %XMM0<def> %XMM0<kill> %ZMM0<def>
; AVX512F-NEXT:    vcvtps2ph $4, %zmm0, %ymm0
; AVX512F-NEXT:    vcvtph2ps %ymm0, %zmm0
; AVX512F-NEXT:    vcvtps2ph $4, %zmm1, %ymm1
; AVX512F-NEXT:    vcvtph2ps %ymm1, %zmm1
; AVX512F-NEXT:    vcvttss2si %xmm1, %rax
; AVX512F-NEXT:    vmovq %rax, %xmm1
; AVX512F-NEXT:    vcvttss2si %xmm0, %rax
; AVX512F-NEXT:    vmovq %rax, %xmm0
; AVX512F-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; AVX512F-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[0,2,2,3]
; AVX512F-NEXT:    vmovq {{.*#+}} xmm0 = xmm0[0],zero
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: fptosi_2f16_to_4i32:
; AVX512VL:       # BB#0:
; AVX512VL-NEXT:    vcvtps2ph $4, %xmm0, %xmm0
; AVX512VL-NEXT:    vcvtph2ps %xmm0, %xmm0
; AVX512VL-NEXT:    vcvtps2ph $4, %xmm1, %xmm1
; AVX512VL-NEXT:    vcvtph2ps %xmm1, %xmm1
; AVX512VL-NEXT:    vcvttss2si %xmm1, %rax
; AVX512VL-NEXT:    vmovq %rax, %xmm1
; AVX512VL-NEXT:    vcvttss2si %xmm0, %rax
; AVX512VL-NEXT:    vmovq %rax, %xmm0
; AVX512VL-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; AVX512VL-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[0,2,2,3]
; AVX512VL-NEXT:    vmovq {{.*#+}} xmm0 = xmm0[0],zero
; AVX512VL-NEXT:    retq
;
; AVX512VLDQ-LABEL: fptosi_2f16_to_4i32:
; AVX512VLDQ:       # BB#0:
; AVX512VLDQ-NEXT:    vcvtps2ph $4, %xmm0, %xmm0
; AVX512VLDQ-NEXT:    vcvtph2ps %xmm0, %xmm0
; AVX512VLDQ-NEXT:    vcvtps2ph $4, %xmm1, %xmm1
; AVX512VLDQ-NEXT:    vcvtph2ps %xmm1, %xmm1
; AVX512VLDQ-NEXT:    vcvttss2si %xmm1, %rax
; AVX512VLDQ-NEXT:    vmovq %rax, %xmm1
; AVX512VLDQ-NEXT:    vcvttss2si %xmm0, %rax
; AVX512VLDQ-NEXT:    vmovq %rax, %xmm0
; AVX512VLDQ-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; AVX512VLDQ-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[0,2,2,3]
; AVX512VLDQ-NEXT:    vmovq {{.*#+}} xmm0 = xmm0[0],zero
; AVX512VLDQ-NEXT:    retq
  %cvt = fptosi <2 x half> %a to <2 x i32>
  %ext = shufflevector <2 x i32> %cvt, <2 x i32> zeroinitializer, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  ret <4 x i32> %ext
}

define <4 x i32> @fptosi_2f80_to_4i32(<2 x x86_fp80> %a) nounwind {
; SSE-LABEL: fptosi_2f80_to_4i32:
; SSE:       # BB#0:
; SSE-NEXT:    fldt {{[0-9]+}}(%rsp)
; SSE-NEXT:    fldt {{[0-9]+}}(%rsp)
; SSE-NEXT:    fnstcw -{{[0-9]+}}(%rsp)
; SSE-NEXT:    movzwl -{{[0-9]+}}(%rsp), %eax
; SSE-NEXT:    movw $3199, -{{[0-9]+}}(%rsp) # imm = 0xC7F
; SSE-NEXT:    fldcw -{{[0-9]+}}(%rsp)
; SSE-NEXT:    movw %ax, -{{[0-9]+}}(%rsp)
; SSE-NEXT:    fistpll -{{[0-9]+}}(%rsp)
; SSE-NEXT:    fldcw -{{[0-9]+}}(%rsp)
; SSE-NEXT:    fnstcw -{{[0-9]+}}(%rsp)
; SSE-NEXT:    movzwl -{{[0-9]+}}(%rsp), %eax
; SSE-NEXT:    movw $3199, -{{[0-9]+}}(%rsp) # imm = 0xC7F
; SSE-NEXT:    fldcw -{{[0-9]+}}(%rsp)
; SSE-NEXT:    movw %ax, -{{[0-9]+}}(%rsp)
; SSE-NEXT:    fistpll -{{[0-9]+}}(%rsp)
; SSE-NEXT:    fldcw -{{[0-9]+}}(%rsp)
; SSE-NEXT:    movq {{.*#+}} xmm0 = mem[0],zero
; SSE-NEXT:    movq {{.*#+}} xmm1 = mem[0],zero
; SSE-NEXT:    punpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm0[0]
; SSE-NEXT:    pshufd {{.*#+}} xmm0 = xmm1[0,1,0,2]
; SSE-NEXT:    psrldq {{.*#+}} xmm0 = xmm0[8,9,10,11,12,13,14,15],zero,zero,zero,zero,zero,zero,zero,zero
; SSE-NEXT:    retq
;
; AVX-LABEL: fptosi_2f80_to_4i32:
; AVX:       # BB#0:
; AVX-NEXT:    fldt {{[0-9]+}}(%rsp)
; AVX-NEXT:    fldt {{[0-9]+}}(%rsp)
; AVX-NEXT:    fisttpll -{{[0-9]+}}(%rsp)
; AVX-NEXT:    fisttpll -{{[0-9]+}}(%rsp)
; AVX-NEXT:    vmovq {{.*#+}} xmm0 = mem[0],zero
; AVX-NEXT:    vmovq {{.*#+}} xmm1 = mem[0],zero
; AVX-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm1[0],xmm0[0]
; AVX-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[0,2,2,3]
; AVX-NEXT:    vmovq {{.*#+}} xmm0 = xmm0[0],zero
; AVX-NEXT:    retq
;
; AVX512-LABEL: fptosi_2f80_to_4i32:
; AVX512:       # BB#0:
; AVX512-NEXT:    fldt {{[0-9]+}}(%rsp)
; AVX512-NEXT:    fldt {{[0-9]+}}(%rsp)
; AVX512-NEXT:    fisttpll -{{[0-9]+}}(%rsp)
; AVX512-NEXT:    fisttpll -{{[0-9]+}}(%rsp)
; AVX512-NEXT:    vmovq {{.*#+}} xmm0 = mem[0],zero
; AVX512-NEXT:    vmovq {{.*#+}} xmm1 = mem[0],zero
; AVX512-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm1[0],xmm0[0]
; AVX512-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[0,2,2,3]
; AVX512-NEXT:    vmovq {{.*#+}} xmm0 = xmm0[0],zero
; AVX512-NEXT:    retq
  %cvt = fptosi <2 x x86_fp80> %a to <2 x i32>
  %ext = shufflevector <2 x i32> %cvt, <2 x i32> zeroinitializer, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  ret <4 x i32> %ext
}

define <4 x i32> @fptosi_2f128_to_4i32(<2 x fp128> %a) nounwind {
; SSE-LABEL: fptosi_2f128_to_4i32:
; SSE:       # BB#0:
; SSE-NEXT:    pushq %r14
; SSE-NEXT:    pushq %rbx
; SSE-NEXT:    subq $24, %rsp
; SSE-NEXT:    movq %rsi, %r14
; SSE-NEXT:    movq %rdi, %rbx
; SSE-NEXT:    movq %rdx, %rdi
; SSE-NEXT:    movq %rcx, %rsi
; SSE-NEXT:    callq __fixtfdi
; SSE-NEXT:    movd %rax, %xmm0
; SSE-NEXT:    movaps %xmm0, (%rsp) # 16-byte Spill
; SSE-NEXT:    movq %rbx, %rdi
; SSE-NEXT:    movq %r14, %rsi
; SSE-NEXT:    callq __fixtfdi
; SSE-NEXT:    movd %rax, %xmm0
; SSE-NEXT:    punpcklqdq (%rsp), %xmm0 # 16-byte Folded Reload
; SSE-NEXT:    # xmm0 = xmm0[0],mem[0]
; SSE-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,1,0,2]
; SSE-NEXT:    psrldq {{.*#+}} xmm0 = xmm0[8,9,10,11,12,13,14,15],zero,zero,zero,zero,zero,zero,zero,zero
; SSE-NEXT:    addq $24, %rsp
; SSE-NEXT:    popq %rbx
; SSE-NEXT:    popq %r14
; SSE-NEXT:    retq
;
; AVX-LABEL: fptosi_2f128_to_4i32:
; AVX:       # BB#0:
; AVX-NEXT:    pushq %r14
; AVX-NEXT:    pushq %rbx
; AVX-NEXT:    subq $24, %rsp
; AVX-NEXT:    movq %rsi, %r14
; AVX-NEXT:    movq %rdi, %rbx
; AVX-NEXT:    movq %rdx, %rdi
; AVX-NEXT:    movq %rcx, %rsi
; AVX-NEXT:    callq __fixtfdi
; AVX-NEXT:    vmovq %rax, %xmm0
; AVX-NEXT:    vmovaps %xmm0, (%rsp) # 16-byte Spill
; AVX-NEXT:    movq %rbx, %rdi
; AVX-NEXT:    movq %r14, %rsi
; AVX-NEXT:    callq __fixtfdi
; AVX-NEXT:    vmovq %rax, %xmm0
; AVX-NEXT:    vpunpcklqdq (%rsp), %xmm0, %xmm0 # 16-byte Folded Reload
; AVX-NEXT:    # xmm0 = xmm0[0],mem[0]
; AVX-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[0,2,2,3]
; AVX-NEXT:    vmovq {{.*#+}} xmm0 = xmm0[0],zero
; AVX-NEXT:    addq $24, %rsp
; AVX-NEXT:    popq %rbx
; AVX-NEXT:    popq %r14
; AVX-NEXT:    retq
;
; AVX512F-LABEL: fptosi_2f128_to_4i32:
; AVX512F:       # BB#0:
; AVX512F-NEXT:    pushq %r14
; AVX512F-NEXT:    pushq %rbx
; AVX512F-NEXT:    subq $24, %rsp
; AVX512F-NEXT:    movq %rsi, %r14
; AVX512F-NEXT:    movq %rdi, %rbx
; AVX512F-NEXT:    movq %rdx, %rdi
; AVX512F-NEXT:    movq %rcx, %rsi
; AVX512F-NEXT:    callq __fixtfdi
; AVX512F-NEXT:    vmovq %rax, %xmm0
; AVX512F-NEXT:    vmovdqa %xmm0, (%rsp) # 16-byte Spill
; AVX512F-NEXT:    movq %rbx, %rdi
; AVX512F-NEXT:    movq %r14, %rsi
; AVX512F-NEXT:    callq __fixtfdi
; AVX512F-NEXT:    vmovq %rax, %xmm0
; AVX512F-NEXT:    vpunpcklqdq (%rsp), %xmm0, %xmm0 # 16-byte Folded Reload
; AVX512F-NEXT:    # xmm0 = xmm0[0],mem[0]
; AVX512F-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[0,2,2,3]
; AVX512F-NEXT:    vmovq {{.*#+}} xmm0 = xmm0[0],zero
; AVX512F-NEXT:    addq $24, %rsp
; AVX512F-NEXT:    popq %rbx
; AVX512F-NEXT:    popq %r14
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: fptosi_2f128_to_4i32:
; AVX512VL:       # BB#0:
; AVX512VL-NEXT:    pushq %r14
; AVX512VL-NEXT:    pushq %rbx
; AVX512VL-NEXT:    subq $24, %rsp
; AVX512VL-NEXT:    movq %rsi, %r14
; AVX512VL-NEXT:    movq %rdi, %rbx
; AVX512VL-NEXT:    movq %rdx, %rdi
; AVX512VL-NEXT:    movq %rcx, %rsi
; AVX512VL-NEXT:    callq __fixtfdi
; AVX512VL-NEXT:    vmovq %rax, %xmm0
; AVX512VL-NEXT:    vmovdqa64 %xmm0, (%rsp) # 16-byte Spill
; AVX512VL-NEXT:    movq %rbx, %rdi
; AVX512VL-NEXT:    movq %r14, %rsi
; AVX512VL-NEXT:    callq __fixtfdi
; AVX512VL-NEXT:    vmovq %rax, %xmm0
; AVX512VL-NEXT:    vmovdqa64 (%rsp), %xmm1 # 16-byte Reload
; AVX512VL-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; AVX512VL-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[0,2,2,3]
; AVX512VL-NEXT:    vmovq {{.*#+}} xmm0 = xmm0[0],zero
; AVX512VL-NEXT:    addq $24, %rsp
; AVX512VL-NEXT:    popq %rbx
; AVX512VL-NEXT:    popq %r14
; AVX512VL-NEXT:    retq
;
; AVX512VLDQ-LABEL: fptosi_2f128_to_4i32:
; AVX512VLDQ:       # BB#0:
; AVX512VLDQ-NEXT:    pushq %r14
; AVX512VLDQ-NEXT:    pushq %rbx
; AVX512VLDQ-NEXT:    subq $24, %rsp
; AVX512VLDQ-NEXT:    movq %rsi, %r14
; AVX512VLDQ-NEXT:    movq %rdi, %rbx
; AVX512VLDQ-NEXT:    movq %rdx, %rdi
; AVX512VLDQ-NEXT:    movq %rcx, %rsi
; AVX512VLDQ-NEXT:    callq __fixtfdi
; AVX512VLDQ-NEXT:    vmovq %rax, %xmm0
; AVX512VLDQ-NEXT:    vmovdqa64 %xmm0, (%rsp) # 16-byte Spill
; AVX512VLDQ-NEXT:    movq %rbx, %rdi
; AVX512VLDQ-NEXT:    movq %r14, %rsi
; AVX512VLDQ-NEXT:    callq __fixtfdi
; AVX512VLDQ-NEXT:    vmovq %rax, %xmm0
; AVX512VLDQ-NEXT:    vmovdqa64 (%rsp), %xmm1 # 16-byte Reload
; AVX512VLDQ-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; AVX512VLDQ-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[0,2,2,3]
; AVX512VLDQ-NEXT:    vmovq {{.*#+}} xmm0 = xmm0[0],zero
; AVX512VLDQ-NEXT:    addq $24, %rsp
; AVX512VLDQ-NEXT:    popq %rbx
; AVX512VLDQ-NEXT:    popq %r14
; AVX512VLDQ-NEXT:    retq
  %cvt = fptosi <2 x fp128> %a to <2 x i32>
  %ext = shufflevector <2 x i32> %cvt, <2 x i32> zeroinitializer, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  ret <4 x i32> %ext
}
