; xpace-flute; eb, 2012-03-28_22:04:46.


; Csgrouper params:

; intersil:	2
; steps:	1
; cmp. type:	0
; dur. type:	0 (0 = scmp1, 1=rand)

<CsoundSynthesizer>

<CsInstruments>

; Csound params:

sr=44100
ksmps=1
nchnls=2

; Global init:

; global reverbs:

garvbsig init 0 ;
gacmb1 init 0 ;	
gacmb2 init 0 ;	
gacmb3 init 0 ;	
gacmb4 init 0 ;	
gamet1 init 0 ;	
garvb1 init 0 ;


; Instruments:

; i1 (path: ~/Csgrouper/ins/xpace-csg.in)
; note: Sine wave.

instr 1

; parameters names
; 1	2	3	4	5	6	7	8	9	10	11	12	13	14	15	16	17	18	19	20	21	22	23	24	25	26	27	28
; i	st	dur	amp	ft1	aty	atk	rel	hd1	hd2	gl1	gl2	fq1	fq2	fq3	pa1	pa2	del	car	mod	hm1	hm2	cro	buz	rvn	rvs	ft2	pcd

; Csgrouper params.
ipcd = p28 ;  precedence.

;reverb
irvn = p25 ;  fxnmbr.
irvs = p26 ;  fxsend.


; functions
ifn1 = p5 ;	
ifn2 = p27 ;

;enveloppe
iamp	=	ampdb(p4);

idur	= 	p3
iaty	=	p6	; atk type 
iatk	=	p7*idur
irel	=	p8*idur
ista	=	idur-iatk-irel

if (iaty == 0) goto slowat
kenv	linen	iamp,iatk, idur, irel ; 
goto endat

slowat:
kenv	envlpx	iamp, iatk, idur, irel, ifn2, 1, .01 ;
endat:

; frequences 
ifq1	=	p13;
ifq2	=	p14;
ifq3	=	p15;

;; glissandi
ihd1	=	p9*idur  ; during the attack
ihd2	=	p10*idur ; during the release
igl1	=	p11*idur ; from freq1 to freq2
igl2	=	p12*idur ; from freq2 to freq3

itop	=	idur-ihd1-ihd2-igl1-igl2; 

kfrq	linseg	ifq1, ihd1,  ifq1, igl1, ifq2, itop, ifq2, igl2, ifq3, ihd2, ifq3; 

; modulation
kcar	= 	p19
kmod	= 	p20
ihm1	= 	p21
ihm2	= 	p22 

ibuz	=	p24

kfqm	line    ihm1, idur, ihm2

; wave
if (ihm1 < 0)  goto noharm
; buzz choice 1
if (ibuz > 0) goto dobuzz
; Boulanger 114 :
awv1	foscil  kenv, kfrq, kcar, kmod, kfqm, ifn1
goto endbuzz
dobuzz:
awv1	buzz  kenv, kfrq, kfqm, ifn1
endbuzz:
goto endwave

noharm:

kwv1    oscil   1000,   kfrq,  ifn1
awv1    oscil   kenv,   kwv1,   ifn1

endwave:
awv2	=	awv1

; crossover
kfad	=	1
icro	=	p23
if (icro == 0)  goto nofade ; >0<1

if (ihm2 < 0)  goto noharm2

; buzz choice 3:
if (ibuz > 1) goto dobuzz3
awv2	foscil  kenv, kfrq, kcar, kmod, kfqm, ifn2
goto endbuzz3
dobuzz3:
awv2	buzz  kenv, kfrq, kfqm, ifn2
endbuzz3:
goto endtable

noharm2:	; (no h = no buzz)
kwv1    oscil   1000,   kfrq,  ifn1
awv2    oscil   kenv,   kwv1,   ifn2

endtable:
ifd1	= 	idur-(icro*idur)
ifd2	=	idur-ifd1
kfad	linseg	1, ifd1, 0, ifd2, 0; 

nofade:	
afn1 	= 	kfad*(awv1)
afn2	=	(1-kfad)*(awv2)
afun 	= 	afn1 + afn2


; pan : 0 < ipnx < 1 
ipn1	=	abs(p16) ; starting balance: <.5 = R, >.5 = L
ipn2	=	abs(p17) ; target   balance

if (ipn1 < 1)	goto nextpn1
	ipn1 = 1
nextpn1:
if (ipn2 < 1)	igoto nextpn2
	ipn2 = 1
nextpn2:
idel	=	p18*idur ; >0<1
ista	=	idur-idel

kpan	linseg	ipn1, idel, ipn2, ista, ipn2 ;

; REVERB
if (irvn == 0)	goto norev 
if (irvn == 3)	goto rev3 
if (irvn == 2)	goto rev2 
gacmb1	=	gacmb1+(afun*irvs)	;
goto norev 
rev2: 
garvb1	=	garvb1+(afun*irvs)	;
goto norev 
rev3: 
gamet1	=	gamet1+(afun*irvs)	;
norev: 

; OUT

outs     afun*(1-kpan),afun*kpan

;display		kenv,idur

endin

; i2 (path: ~/Csgrouper/ins/xpace-csg.in)
; note: Triangle wave.

instr 2

; parameters names
; 1	2	3	4	5	6	7	8	9	10	11	12	13	14	15	16	17	18	19	20	21	22	23	24	25	26	27	28
; i	st	dur	amp	ft1	aty	atk	rel	hd1	hd2	gl1	gl2	fq1	fq2	fq3	pa1	pa2	del	car	mod	hm1	hm2	cro	buz	rvn	rvs	ft2	pcd

; Csgrouper params.
ipcd = p28 ;  precedence.

;reverb
irvn = p25 ;  fxnmbr.
irvs = p26 ;  fxsend.


; functions
ifn1 = p5 ;	
ifn2 = p27 ;

;enveloppe
iamp	=	ampdb(p4);

idur	= 	p3
iaty	=	p6	; atk type 
iatk	=	p7*idur
irel	=	p8*idur
ista	=	idur-iatk-irel

if (iaty == 0) goto slowat
kenv	linen	iamp,iatk, idur, irel ; 
goto endat

slowat:
kenv	envlpx	iamp, iatk, idur, irel, ifn2, 1, .01 ;
endat:

; frequences 
ifq1	=	p13;
ifq2	=	p14;
ifq3	=	p15;

;; glissandi
ihd1	=	p9*idur  ; during the attack
ihd2	=	p10*idur ; during the release
igl1	=	p11*idur ; from freq1 to freq2
igl2	=	p12*idur ; from freq2 to freq3

itop	=	idur-ihd1-ihd2-igl1-igl2; 

kfrq	linseg	ifq1, ihd1,  ifq1, igl1, ifq2, itop, ifq2, igl2, ifq3, ihd2, ifq3; 

; modulation
kcar	= 	p19
kmod	= 	p20
ihm1	= 	p21
ihm2	= 	p22 

ibuz	=	p24

kfqm	line    ihm1, idur, ihm2

; wave
if (ihm1 < 0)  goto noharm
; buzz choice 1
if (ibuz > 0) goto dobuzz
; Boulanger 114 :
awv1	foscil  kenv, kfrq, kcar, kmod, kfqm, ifn1
goto endbuzz
dobuzz:
awv1	buzz  kenv, kfrq, kfqm, ifn1
endbuzz:
goto endwave

noharm:

kwv1    oscil   1000,   kfrq,  ifn1
awv1    oscil   kenv,   kwv1,   ifn1

endwave:
awv2	=	awv1

; crossover
kfad	=	1
icro	=	p23
if (icro == 0)  goto nofade ; >0<1

if (ihm2 < 0)  goto noharm2

; buzz choice 3:
if (ibuz > 1) goto dobuzz3
awv2	foscil  kenv, kfrq, kcar, kmod, kfqm, ifn2
goto endbuzz3
dobuzz3:
awv2	buzz  kenv, kfrq, kfqm, ifn2
endbuzz3:
goto endtable

noharm2:	; (no h = no buzz)
kwv1    oscil   1000,   kfrq,  ifn1
awv2    oscil   kenv,   kwv1,   ifn2

endtable:
ifd1	= 	idur-(icro*idur)
ifd2	=	idur-ifd1
kfad	linseg	1, ifd1, 0, ifd2, 0; 

nofade:	
afn1 	= 	kfad*(awv1)
afn2	=	(1-kfad)*(awv2)
afun 	= 	afn1 + afn2


; pan : 0 < ipnx < 1 
ipn1	=	abs(p16) ; starting balance: <.5 = R, >.5 = L
ipn2	=	abs(p17) ; target   balance

if (ipn1 < 1)	goto nextpn1
	ipn1 = 1
nextpn1:
if (ipn2 < 1)	igoto nextpn2
	ipn2 = 1
nextpn2:
idel	=	p18*idur ; >0<1
ista	=	idur-idel

kpan	linseg	ipn1, idel, ipn2, ista, ipn2 ;

; REVERB
if (irvn == 0)	goto norev 
if (irvn == 3)	goto rev3 
if (irvn == 2)	goto rev2 
gacmb1	=	gacmb1+(afun*irvs)	;
goto norev 
rev2: 
garvb1	=	garvb1+(afun*irvs)	;
goto norev 
rev3: 
gamet1	=	gamet1+(afun*irvs)	;
norev: 

; OUT

outs     afun*(1-kpan),afun*kpan

;display		kenv,idur

endin

; i3 (path: ~/Csgrouper/ins/xpace-csg.in)
; note: Cosine wave.

instr 3

; parameters names
; 1	2	3	4	5	6	7	8	9	10	11	12	13	14	15	16	17	18	19	20	21	22	23	24	25	26	27	28
; i	st	dur	amp	ft1	aty	atk	rel	hd1	hd2	gl1	gl2	fq1	fq2	fq3	pa1	pa2	del	car	mod	hm1	hm2	cro	buz	rvn	rvs	ft2	pcd

; Csgrouper params.
ipcd = p28 ;  precedence.

;reverb
irvn = p25 ;  fxnmbr.
irvs = p26 ;  fxsend.


; functions
ifn1 = p5 ;	
ifn2 = p27 ;

;enveloppe
iamp	=	ampdb(p4);

idur	= 	p3
iaty	=	p6	; atk type 
iatk	=	p7*idur
irel	=	p8*idur
ista	=	idur-iatk-irel

if (iaty == 0) goto slowat
kenv	linen	iamp,iatk, idur, irel ; 
goto endat

slowat:
kenv	envlpx	iamp, iatk, idur, irel, ifn2, 1, .01 ;
endat:

; frequences 
ifq1	=	p13;
ifq2	=	p14;
ifq3	=	p15;

;; glissandi
ihd1	=	p9*idur  ; during the attack
ihd2	=	p10*idur ; during the release
igl1	=	p11*idur ; from freq1 to freq2
igl2	=	p12*idur ; from freq2 to freq3

itop	=	idur-ihd1-ihd2-igl1-igl2; 

kfrq	linseg	ifq1, ihd1,  ifq1, igl1, ifq2, itop, ifq2, igl2, ifq3, ihd2, ifq3; 

; modulation
kcar	= 	p19
kmod	= 	p20
ihm1	= 	p21
ihm2	= 	p22 

ibuz	=	p24

kfqm	line    ihm1, idur, ihm2

; wave
if (ihm1 < 0)  goto noharm
; buzz choice 1
if (ibuz > 0) goto dobuzz
; Boulanger 114 :
awv1	foscil  kenv, kfrq, kcar, kmod, kfqm, ifn1
goto endbuzz
dobuzz:
awv1	buzz  kenv, kfrq, kfqm, ifn1
endbuzz:
goto endwave

noharm:

kwv1    oscil   1000,   kfrq,  ifn1
awv1    oscil   kenv,   kwv1,   ifn1

endwave:
awv2	=	awv1

; crossover
kfad	=	1
icro	=	p23
if (icro == 0)  goto nofade ; >0<1

if (ihm2 < 0)  goto noharm2

; buzz choice 3:
if (ibuz > 1) goto dobuzz3
awv2	foscil  kenv, kfrq, kcar, kmod, kfqm, ifn2
goto endbuzz3
dobuzz3:
awv2	buzz  kenv, kfrq, kfqm, ifn2
endbuzz3:
goto endtable

noharm2:	; (no h = no buzz)
kwv1    oscil   1000,   kfrq,  ifn1
awv2    oscil   kenv,   kwv1,   ifn2

endtable:
ifd1	= 	idur-(icro*idur)
ifd2	=	idur-ifd1
kfad	linseg	1, ifd1, 0, ifd2, 0; 

nofade:	
afn1 	= 	kfad*(awv1)
afn2	=	(1-kfad)*(awv2)
afun 	= 	afn1 + afn2


; pan : 0 < ipnx < 1 
ipn1	=	abs(p16) ; starting balance: <.5 = R, >.5 = L
ipn2	=	abs(p17) ; target   balance

if (ipn1 < 1)	goto nextpn1
	ipn1 = 1
nextpn1:
if (ipn2 < 1)	igoto nextpn2
	ipn2 = 1
nextpn2:
idel	=	p18*idur ; >0<1
ista	=	idur-idel

kpan	linseg	ipn1, idel, ipn2, ista, ipn2 ;

; REVERB
if (irvn == 0)	goto norev 
if (irvn == 3)	goto rev3 
if (irvn == 2)	goto rev2 
gacmb1	=	gacmb1+(afun*irvs)	;
goto norev 
rev2: 
garvb1	=	garvb1+(afun*irvs)	;
goto norev 
rev3: 
gamet1	=	gamet1+(afun*irvs)	;
norev: 

; OUT

outs     afun*(1-kpan),afun*kpan

;display		kenv,idur

endin

; i4 (path: ~/Csgrouper/ins/xpace-csg.in)
; note: Sine wave support for i1.

instr 4

; parameters names
; 1	2	3	4	5	6	7	8	9	10	11	12	13	14	15	16	17	18	19	20	21	22	23	24	25	26	27	28
; i	st	dur	amp	ft1	aty	atk	rel	hd1	hd2	gl1	gl2	fq1	fq2	fq3	pa1	pa2	del	car	mod	hm1	hm2	cro	buz	rvn	rvs	ft2	pcd

; Csgrouper params.
ipcd = p28 ;  precedence.

;reverb
irvn = p25 ;  fxnmbr.
irvs = p26 ;  fxsend.


; functions
ifn1 = p5 ;	
ifn2 = p27 ;

;enveloppe
iamp	=	ampdb(p4);

idur	= 	p3
iaty	=	p6	; atk type 
iatk	=	p7*idur
irel	=	p8*idur
ista	=	idur-iatk-irel

if (iaty == 0) goto slowat
kenv	linen	iamp,iatk, idur, irel ; 
goto endat

slowat:
kenv	envlpx	iamp, iatk, idur, irel, ifn2, 1, .01 ;
endat:

; frequences 
ifq1	=	p13;
ifq2	=	p14;
ifq3	=	p15;

;; glissandi
ihd1	=	p9*idur  ; during the attack
ihd2	=	p10*idur ; during the release
igl1	=	p11*idur ; from freq1 to freq2
igl2	=	p12*idur ; from freq2 to freq3

itop	=	idur-ihd1-ihd2-igl1-igl2; 

kfrq	linseg	ifq1, ihd1,  ifq1, igl1, ifq2, itop, ifq2, igl2, ifq3, ihd2, ifq3; 

; modulation
kcar	= 	p19
kmod	= 	p20
ihm1	= 	p21
ihm2	= 	p22 

ibuz	=	p24

kfqm	line    ihm1, idur, ihm2

; wave
if (ihm1 < 0)  goto noharm
; buzz choice 1
if (ibuz > 0) goto dobuzz
; Boulanger 114 :
awv1	foscil  kenv, kfrq, kcar, kmod, kfqm, ifn1
goto endbuzz
dobuzz:
awv1	buzz  kenv, kfrq, kfqm, ifn1
endbuzz:
goto endwave

noharm:

kwv1    oscil   1000,   kfrq,  ifn1
awv1    oscil   kenv,   kwv1,   ifn1

endwave:
awv2	=	awv1

; crossover
kfad	=	1
icro	=	p23
if (icro == 0)  goto nofade ; >0<1

if (ihm2 < 0)  goto noharm2

; buzz choice 3:
if (ibuz > 1) goto dobuzz3
awv2	foscil  kenv, kfrq, kcar, kmod, kfqm, ifn2
goto endbuzz3
dobuzz3:
awv2	buzz  kenv, kfrq, kfqm, ifn2
endbuzz3:
goto endtable

noharm2:	; (no h = no buzz)
kwv1    oscil   1000,   kfrq,  ifn1
awv2    oscil   kenv,   kwv1,   ifn2

endtable:
ifd1	= 	idur-(icro*idur)
ifd2	=	idur-ifd1
kfad	linseg	1, ifd1, 0, ifd2, 0; 

nofade:	
afn1 	= 	kfad*(awv1)
afn2	=	(1-kfad)*(awv2)
afun 	= 	afn1 + afn2


; pan : 0 < ipnx < 1 
ipn1	=	abs(p16) ; starting balance: <.5 = R, >.5 = L
ipn2	=	abs(p17) ; target   balance

if (ipn1 < 1)	goto nextpn1
	ipn1 = 1
nextpn1:
if (ipn2 < 1)	igoto nextpn2
	ipn2 = 1
nextpn2:
idel	=	p18*idur ; >0<1
ista	=	idur-idel

kpan	linseg	ipn1, idel, ipn2, ista, ipn2 ;

; REVERB
if (irvn == 0)	goto norev 
if (irvn == 3)	goto rev3 
if (irvn == 2)	goto rev2 
gacmb1	=	gacmb1+(afun*irvs)	;
goto norev 
rev2: 
garvb1	=	garvb1+(afun*irvs)	;
goto norev 
rev3: 
gamet1	=	gamet1+(afun*irvs)	;
norev: 

; OUT

outs     afun*(1-kpan),afun*kpan

;display		kenv,idur

endin

; i5 (path: ~/Csgrouper/ins/xpace-csg.in)
; note: Sine wave support for i2.

instr 5

; parameters names
; 1	2	3	4	5	6	7	8	9	10	11	12	13	14	15	16	17	18	19	20	21	22	23	24	25	26	27	28
; i	st	dur	amp	ft1	aty	atk	rel	hd1	hd2	gl1	gl2	fq1	fq2	fq3	pa1	pa2	del	car	mod	hm1	hm2	cro	buz	rvn	rvs	ft2	pcd


; Csgrouper params.
ipcd = p28 ;  precedence.

;reverb
irvn = p25 ;  fxnmbr.
irvs = p26 ;  fxsend.


; functions
ifn1 = p5 ;	
ifn2 = p27 ;

;enveloppe
iamp	=	ampdb(p4);

idur	= 	p3
iaty	=	p6	; atk type 
iatk	=	p7*idur
irel	=	p8*idur
ista	=	idur-iatk-irel

if (iaty == 0) goto slowat
kenv	linen	iamp,iatk, idur, irel ; 
goto endat

slowat:
kenv	envlpx	iamp, iatk, idur, irel, ifn2, 1, .01 ;
endat:

; frequences 
ifq1	=	p13;
ifq2	=	p14;
ifq3	=	p15;

;; glissandi
ihd1	=	p9*idur  ; during the attack
ihd2	=	p10*idur ; during the release
igl1	=	p11*idur ; from freq1 to freq2
igl2	=	p12*idur ; from freq2 to freq3

itop	=	idur-ihd1-ihd2-igl1-igl2; 

kfrq	linseg	ifq1, ihd1,  ifq1, igl1, ifq2, itop, ifq2, igl2, ifq3, ihd2, ifq3; 

; modulation
kcar	= 	p19
kmod	= 	p20
ihm1	= 	p21
ihm2	= 	p22 

ibuz	=	p24

kfqm	line    ihm1, idur, ihm2

; wave
if (ihm1 < 0)  goto noharm
; buzz choice 1
if (ibuz > 0) goto dobuzz
; Boulanger 114 :
awv1	foscil  kenv, kfrq, kcar, kmod, kfqm, ifn1
goto endbuzz
dobuzz:
awv1	buzz  kenv, kfrq, kfqm, ifn1
endbuzz:
goto endwave

noharm:

kwv1    oscil   1000,   kfrq,  ifn1
awv1    oscil   kenv,   kwv1,   ifn1

endwave:
awv2	=	awv1

; crossover
kfad	=	1
icro	=	p23
if (icro == 0)  goto nofade ; >0<1

if (ihm2 < 0)  goto noharm2

; buzz choice 3:
if (ibuz > 1) goto dobuzz3
awv2	foscil  kenv, kfrq, kcar, kmod, kfqm, ifn2
goto endbuzz3
dobuzz3:
awv2	buzz  kenv, kfrq, kfqm, ifn2
endbuzz3:
goto endtable

noharm2:	; (no h = no buzz)
kwv1    oscil   1000,   kfrq,  ifn1
awv2    oscil   kenv,   kwv1,   ifn2

endtable:
ifd1	= 	idur-(icro*idur)
ifd2	=	idur-ifd1
kfad	linseg	1, ifd1, 0, ifd2, 0; 

nofade:	
afn1 	= 	kfad*(awv1)
afn2	=	(1-kfad)*(awv2)
afun 	= 	afn1 + afn2


; pan : 0 < ipnx < 1 
ipn1	=	abs(p16) ; starting balance: <.5 = R, >.5 = L
ipn2	=	abs(p17) ; target   balance

if (ipn1 < 1)	goto nextpn1
	ipn1 = 1
nextpn1:
if (ipn2 < 1)	igoto nextpn2
	ipn2 = 1
nextpn2:
idel	=	p18*idur ; >0<1
ista	=	idur-idel

kpan	linseg	ipn1, idel, ipn2, ista, ipn2 ;

; REVERB
if (irvn == 0)	goto norev 
if (irvn == 3)	goto rev3 
if (irvn == 2)	goto rev2 
gacmb1	=	gacmb1+(afun*irvs)	;
goto norev 
rev2: 
garvb1	=	garvb1+(afun*irvs)	;
goto norev 
rev3: 
gamet1	=	gamet1+(afun*irvs)	;
norev: 

; OUT

outs     afun*(1-kpan),afun*kpan

;display		kenv,idur

endin

; i6 (path: ~/Csgrouper/ins/xpace-csg.in)
; note: Sine wave support for i3.

instr 6

; parameters names
; 1	2	3	4	5	6	7	8	9	10	11	12	13	14	15	16	17	18	19	20	21	22	23	24	25	26	27	28
; i	st	dur	amp	ft1	aty	atk	rel	hd1	hd2	gl1	gl2	fq1	fq2	fq3	pa1	pa2	del	car	mod	hm1	hm2	cro	buz	rvn	rvs	ft2	pcd


; Csgrouper params.
ipcd = p28 ;  precedence.

;reverb
irvn = p25 ;  fxnmbr.
irvs = p26 ;  fxsend.


; functions
ifn1 = p5 ;	
ifn2 = p27 ;

;enveloppe
iamp	=	ampdb(p4);

idur	= 	p3
iaty	=	p6	; atk type 
iatk	=	p7*idur
irel	=	p8*idur
ista	=	idur-iatk-irel

if (iaty == 0) goto slowat
kenv	linen	iamp,iatk, idur, irel ; 
goto endat

slowat:
kenv	envlpx	iamp, iatk, idur, irel, ifn2, 1, .01 ;
endat:

; frequences 
ifq1	=	p13;
ifq2	=	p14;
ifq3	=	p15;

;; glissandi
ihd1	=	p9*idur  ; during the attack
ihd2	=	p10*idur ; during the release
igl1	=	p11*idur ; from freq1 to freq2
igl2	=	p12*idur ; from freq2 to freq3

itop	=	idur-ihd1-ihd2-igl1-igl2; 

kfrq	linseg	ifq1, ihd1,  ifq1, igl1, ifq2, itop, ifq2, igl2, ifq3, ihd2, ifq3; 

; modulation
kcar	= 	p19
kmod	= 	p20
ihm1	= 	p21
ihm2	= 	p22 

ibuz	=	p24

kfqm	line    ihm1, idur, ihm2

; wave
if (ihm1 < 0)  goto noharm
; buzz choice 1
if (ibuz > 0) goto dobuzz
; Boulanger 114 :
awv1	foscil  kenv, kfrq, kcar, kmod, kfqm, ifn1
goto endbuzz
dobuzz:
awv1	buzz  kenv, kfrq, kfqm, ifn1
endbuzz:
goto endwave

noharm:

kwv1    oscil   1000,   kfrq,  ifn1
awv1    oscil   kenv,   kwv1,   ifn1

endwave:
awv2	=	awv1

; crossover
kfad	=	1
icro	=	p23
if (icro == 0)  goto nofade ; >0<1

if (ihm2 < 0)  goto noharm2

; buzz choice 3:
if (ibuz > 1) goto dobuzz3
awv2	foscil  kenv, kfrq, kcar, kmod, kfqm, ifn2
goto endbuzz3
dobuzz3:
awv2	buzz  kenv, kfrq, kfqm, ifn2
endbuzz3:
goto endtable

noharm2:	; (no h = no buzz)
kwv1    oscil   1000,   kfrq,  ifn1
awv2    oscil   kenv,   kwv1,   ifn2

endtable:
ifd1	= 	idur-(icro*idur)
ifd2	=	idur-ifd1
kfad	linseg	1, ifd1, 0, ifd2, 0; 

nofade:	
afn1 	= 	kfad*(awv1)
afn2	=	(1-kfad)*(awv2)
afun 	= 	afn1 + afn2


; pan : 0 < ipnx < 1 
ipn1	=	abs(p16) ; starting balance: <.5 = R, >.5 = L
ipn2	=	abs(p17) ; target   balance

if (ipn1 < 1)	goto nextpn1
	ipn1 = 1
nextpn1:
if (ipn2 < 1)	igoto nextpn2
	ipn2 = 1
nextpn2:
idel	=	p18*idur ; >0<1
ista	=	idur-idel

kpan	linseg	ipn1, idel, ipn2, ista, ipn2 ;

; REVERB
if (irvn == 0)	goto norev 
if (irvn == 3)	goto rev3 
if (irvn == 2)	goto rev2 
gacmb1	=	gacmb1+(afun*irvs)	;
goto norev 
rev2: 
garvb1	=	garvb1+(afun*irvs)	;
goto norev 
rev3: 
gamet1	=	gamet1+(afun*irvs)	;
norev: 

; OUT

outs     afun*(1-kpan),afun*kpan

;display		kenv,idur

endin

; i7 (path: ~/Csgrouper/ins/flute.in)
; note: Mykelson's flute instrument based on Perry Cook's slide flute.

instr 7


; parameters names
; 1	2	3	4	5	6	7	8	9	10	11	12	
; i	st	dur	amp	fq1	pre	bre	fb1	fb2	pa1	rv2	rvn

aflute1 init  0 ;

idur	= 	p3;
iamp	=	ampdb(p4);
ifq1    =       p5;
ipress  =       p6;
ibreath =       p7;
ifeedbk1 =      p8;
ifeedbk2 =      p9;
ipan	=	p10;
irvs	=	p11;
irvn	=	p12;

; FLOW SETUP
kenv1   linseg  0, .06, 1.1*ipress, .2, ipress, p3-.16, ipress, .02, 0 
kenv2   linseg  0, .01, 1, p3-.02, 1, .01, 0
kenvibr linseg  0, .5, 0, .5, 1, p3-1, 1  ; Vibrato envelope

; THE VALUES MUST BE APPROXIMATELY -1 TO 1 OR THE CUBIC WILL BLOW UP
aflow1  rand    kenv1
kvibr   oscil   .1*kenvibr, 5, 10

; ibreath CAN BE USED TO ADJUST THE NOISE LEVEL
asum1   =       ibreath*aflow1 + kenv1 + kvibr
asum2   =       asum1 + aflute1*ifeedbk1

afqc    =       1/ifq1 - asum1/20000 -9/sr + ifq1/12000000

; EMBOUCHURE DELAY SHOULD BE 1/2 THE BORE DELAY
; ax    delay   asum2, (1/ifq1-10/sr)/2
atemp1  delayr  1/ifq1/2
ax      deltapi afqc/2              ; - asum1/ifq1/10 + 1/1000
        delayw  asum2
                        
apoly   =       ax - ax*ax*ax
asum3   =       apoly + aflute1*ifeedbk2

avalue  tone    asum3, 2000

; BORE, THE BORE LENGTH DETERMINES PITCH.  SHORTER IS HIGHER PITCH
atemp2  delayr  1/ifq1
aflute1 deltapi afqc
        delayw  avalue

aout    =     avalue*iamp*kenv2

;; ECHO:
if (irvn == 0)	goto nocomb 
if (irvn == 1)	goto comb1 
if (irvn == 2)	goto comb2 
if (irvn == 3)	goto comb3 
if (irvn == 4)	goto comb4 

comb1: ; normal reverb:
gacmb1	=	gacmb1+(aout*irvs)	;
goto nocomb 
comb2: 
gacmb2	=	gacmb2+(aout*irvs)	;
goto nocomb 
comb3: 
gacmb3	=	gacmb3+(aout*irvs)	;
goto nocomb 
comb4: 
gacmb4	=	gacmb4+(aout*irvs)	;
nocomb: 

outs	aout*(1-ipan), aout*ipan
     
endin

; i576 (path: internal)
; note: An instrument that is receiving input from a global variable should have a higher number than any instrument that are producing output for that variable.(R. Pinkston)

instr 576
 idur = p3;
 irvbtime = p4 ;
 asig reverb garvbsig,irvbtime ;
 outs asig,asig ;
 garvbsig = 0 ;
endin ;


</CsInstruments>

<CsScore>

; F-tables:

; 	WAVE FORMS: f1,f1*,f1**.
f1   0   4096  10 1 ; Simple sine
f10  0   65536 10 1 ; Sine	
f101 0 513 9 .5 1 0; Half sine
f11 0 8192 9 1 1 90; Cosine

f12 0 513 9 1 1 0 3 .333 180 5 .2 0 7 .143 180 9 .111 0; Triangle 

f13 0   512  7  1  512 -1 ; Saw
f131 0   1024  7  0  124 1 900 0 ; Saw
f132 0 513 10 1 .5 .333 .25 .2 .166 .143 .125 .111 .1 .0909 .0833 .077 ; Sawtooth wave -all harmonics -> 13th.

f14 0   1024  7  1  512 1 0 -1 512 -1; Square
f141 0 513 10 1 0 .333 0 .2 0 .143 0 .111 0 .0909 0 .077 0 .0666 0 .0588; Square (odd harmonics->17th)

f150 0   1024  21 1 ; Noise


; 	END WAVE FORMS
;
;	ENVELOPES  : f2, f2*, f2**
f20  0  1025 5 .01 824 1 200 .75 ; 	Slow attack, peak, fast rel.
f21  0  513 8 0 150 0,5 50 1 113 1 50 0.5 150 0 ; 	Quasi gaussian. fog speed chng
f22  0  1025 5 .01 10 1 1015 .45 ; 	Fast attack, peak, fast rel.
f23  0  1024 19 .5 .5 270 .5 ; 	Grain envelope. [was f60]
f24  0  1025 5  .001 824 1 200 .75 ; space env [was f51]

; 	END ENVELOPES
;	 
;	 FM CARIER : f3, f3*, f3**
f3  0 1025 20 9 1  ; 	
f30 0 1024 6  0 1024 1  ; 	
f31 0 1024 10 .3 0 0 0 .1 .1 .1 .1 .1 .1 ; 	
f32 0 8193 6  0 2048 1 2048 -1 2048 1 2049 0; 	
f33 0 8193 6  0 2048 .25 2048 .5 2048 .75 2049 1 ;
; 	END FM CARIER
;	 
; 	RANDOM SERIES : f4, f4*, f4** 
f9000 0   16 -2  1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 ; 	 test
f9001 0   16 -2  1 2 3 4 5 6 7 8 9 8 7 6 5 4 3 2 1 ; 	 Additive table 1
f9002 0   16 -2  3 1 2 6 4 5 9 8 7 8 6 4 5 3 1 2 1 ; 	 Additive table 2
;	END RANDOM SERIES
;	 
; 	SOUND SAMPLES : f5, f5*, f5** 
;f#  t siz 1 filcod skip frmt chan; 0 = all ch., 0 = head. frmt, 4=16bit, 5=32L, 6=32F.	
;f50 0  524288 1 "female.aif" 0 4 0 ;	
; 	END SOUND SAMPLES
;	 
; 	LOCAL F-TABLES
; LOCAL F-TABLES rev. 080501: f1**** : never use f9*.. (reseved to tables made on the fly).
; 	WAVE FORMS: f10001,f1001*,f101**.
; 	END WAVE FORMS
;
;	ENVELOPES  : f10002, f1002*, f102**
; 	END ENVELOPES
;	 
;	FM CARIER : f10003, f10023*, f103**
; 	END FM CARIER
;	 
; 	RANDOM SERIES : f10004, f1004*, f104**
f10004 0  	8 -2  1 2 3 4 5 6 7 8 9 10 11	; Random series test
f10041 0  	8 -2  10 2 0 6 4 8	 		; space series 1 H0
f10042 0  	8 -2  1 7 9 5 11 3			; Random series 1
f10043 0  	8 -2  6 9 6 1 6 4			; Random series 2
f10044 0  	8 -2  1 6 9 6 1 6 4			; Random series 3
;	END RANDOM SERIES
;	 
; 	SOUND SAMPLES : f10005, f1005*, f105**
;f#  t siz 1 filcod skip frmt chan; 0 = all ch., 0 = head. frmt, 4=16bit, 5=32L, 6=32F.	
;; soundin 100 = Cello.wav, 102 = Violin.aif.
;f10051 0 	65536  1 	"Violin-2.aiff" .3 0 1; 67785 samples, 1.537 sec. 16bit, stereo 
; 	END SOUND SAMPLES
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;	END LOCAL F-TABLES
;****************************************************************


; Score:

s ; Section 0.

; Tempo:

t 0 120

; Seq_1 comments: Gradual of the dodecaphonic reverse (R) for the bass.
;ins	sta	dur	amp	ft1	aty	atk	rel	hd1	hd2	gl1	gl2	fq1	fq2	fq3	pa1	pa2	del	car	mod	hm1	hm2	cro	buz	rvn	rvs	ft2	pcd	
i1	0	0.375	60	10	0	0	1	1	0	0	0	58.2719	58.271	58.271	0.5	0.5	0.3	1	11	2	-1	0	0	0	0	24	1	;Sec:0:Seq_1:0	:0:F:5	ry:0:en:0
i1	0.375	0.375	60	.	.	.	.	.	.	.	.	44.5032	44.503	44.503	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:1	:1:8:5	ry:0:en:0
i1	0.75	0.375	60	.	.	.	.	.	.	.	.	46.2504	39.6479	46.250	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:2	:2:9:5	ry:0:en:0
i1	1.125	1.875	60	.	.	.	.	.	.	.	.	39.6479	35.3222	39.647	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:3	:3:5:5	ry:0:en:0
i1	3	0.75	60	.	.	.	.	.	.	.	.	35.3222	51.9143	35.322	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:4	:4:2:5	ry:0:en:0
i1	3.75	2.25	60	.	.	.	.	.	.	.	.	51.9143	51.914	51.914	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:5	:5:C:5	ry:0:en:0
i1	6	2.25	60	.	.	.	.	.	.	.	.	49.9532	49.953	49.953	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:6	:6:B:5	ry:0:en:0
i1	8.25	4.5	60	.	.	.	.	.	.	.	.	56.0706	56.070	56.070	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:7	:7:E:5	ry:0:en:0
i1	12.75	0.375	0	.	.	.	.	.	.	.	.	62.9371	62.937	62.937	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:8	:8:H:5	ry:0:en:0
i1	13.125	0.375	60	.	.	.	.	.	.	.	.	60.5596	60.559	60.559	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:9	:9:G:5	ry:0:en:0
i1	13.5	0.75	60	.	.	.	.	.	.	.	.	38.1501	38.150	38.150	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:10	:10:4:5	ry:0:en:0
i1	14.25	0.375	60	.	.	.	.	.	.	.	.	33.9879	33.987	33.987	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:11	:11:1:5	ry:0:en:0
i1	14.625	2.25	60	.	.	.	.	.	.	.	.	53.9524	53.952	53.952	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:12	:12:D:5	ry:0:en:0
i1	16.875	3.75	60	.	.	.	.	.	.	.	.	41.2044	41.204	41.204	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:13	:13:6:5	ry:0:en:0
i1	20.625	4.5	60	.	.	.	.	.	.	.	.	42.8221	42.822	42.822	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:14	:14:7:5	ry:0:en:0
i1	25.125	2.625	60	.	.	.	.	.	.	.	.	36.7089	36.708	36.708	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:15	:15:3:5	ry:0:en:0
i1	27.75	0.375	60	.	.	.	.	.	.	.	.	32.704	48.0661	48.0661	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:16	:16:0:5	ry:0:en:0
i1	28.125	0.375	0	.	.	.	.	.	.	.	.	48.0661	48.066	48.066	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:17	:17:A:5	ry:0:en:0
i1	28.5	0.375	60	.	.	.	.	.	.	.	.	58.2719	58.271	58.271	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:18	:0:F:5	ry:0:en:0
i1	28.875	0.375	60	.	.	.	.	.	.	.	.	44.5032	44.503	44.503	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:19	:1:8:5	ry:0:en:0
i1	29.25	0.375	60	.	.	.	.	.	.	.	.	46.2504	39.6479	46.250	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:20	:2:9:5	ry:0:en:0
i1	29.625	1.875	60	.	.	.	.	.	.	.	.	39.6479	35.3222	39.647	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:21	:3:5:5	ry:0:en:0
i1	31.5	0.75	60	.	.	.	.	.	.	.	.	35.3222	51.9143	35.322	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:22	:4:2:5	ry:0:en:0
i1	32.25	2.25	60	.	.	.	.	.	.	.	.	51.9143	51.914	51.914	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:23	:5:C:5	ry:0:en:0
i1	34.5	2.25	60	.	.	.	.	.	.	.	.	49.9532	49.953	49.953	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:24	:6:B:5	ry:0:en:0
i1	36.75	4.5	60	.	.	.	.	.	.	.	.	56.0706	56.070	56.070	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:25	:7:E:5	ry:0:en:0
i1	41.25	0.375	0	.	.	.	.	.	.	.	.	62.9371	62.937	62.937	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:26	:8:H:5	ry:0:en:0
i1	41.625	0.375	60	.	.	.	.	.	.	.	.	60.5596	60.559	60.559	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:27	:9:G:5	ry:0:en:0
i1	42	0.75	60	.	.	.	.	.	.	.	.	38.1501	38.150	38.150	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:28	:10:4:5	ry:0:en:0
i1	42.75	0.375	60	.	.	.	.	.	.	.	.	33.9879	33.987	33.987	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:29	:11:1:5	ry:0:en:0
i1	43.125	2.25	60	.	.	.	.	.	.	.	.	53.9524	53.952	53.952	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:30	:12:D:5	ry:0:en:0
i1	45.375	3.75	60	.	.	.	.	.	.	.	.	41.2044	41.204	41.204	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:31	:13:6:5	ry:0:en:0
i1	49.125	4.5	60	.	.	.	.	.	.	.	.	42.8221	42.822	42.822	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:32	:14:7:5	ry:0:en:0
i1	53.625	2.625	60	.	.	.	.	.	.	.	.	36.7089	36.708	36.708	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:33	:15:3:5	ry:0:en:0
i1	56.25	0.375	60	.	.	.	.	.	.	.	.	32.704	48.0661	48.0661	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:34	:16:0:5	ry:0:en:0
i1	56.625	0.375	0	.	.	.	.	.	.	.	.	48.0661	48.066	48.066	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:35	:17:A:5	ry:0:en:0
i1	57	0.375	60	.	.	.	.	.	.	.	.	36.7089	36.708	36.708	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:36	:0:3:5	ry:0:en:0
i1	57.375	0.375	60	.	.	.	.	.	.	.	.	62.9371	62.937	62.937	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:37	:1:H:5	ry:0:en:0
i1	57.75	0.375	60	.	.	.	.	.	.	.	.	60.5596	60.559	60.559	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:38	:2:G:5	ry:0:en:0
i1	58.125	1.5	60	.	.	.	.	.	.	.	.	51.9143	46.2504	51.914	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:39	:3:C:5	ry:0:en:0
i1	59.625	0.375	0	.	.	.	.	.	.	.	.	46.2504	46.250	46.250	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:40	:4:9:5	ry:0:en:0
i1	60	3	60	.	.	.	.	.	.	.	.	53.9524	33.9879	33.9879	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:41	:5:D:5	ry:0:en:0
i1	63	0.75	60	.	.	.	.	.	.	.	.	33.9879	33.987	33.987	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:42	:6:1:5	ry:0:en:0
i1	63.75	4.5	60	.	.	.	.	.	.	.	.	42.8221	42.822	42.822	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:43	:7:7:5	ry:0:en:0
i1	68.25	0.375	60	.	.	.	.	.	.	.	.	48.0661	32.704	48.066	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:44	:8:A:5	ry:0:en:0
i1	68.625	0.375	60	.	.	.	.	.	.	.	.	32.704	32.704	32.704	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:45	:9:0:5	ry:0:en:0
i1	69	0.375	60	.	.	.	.	.	.	.	.	35.3222	35.322	35.322	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:46	:10:2:5	ry:0:en:0
i1	69.375	0.375	60	.	.	.	.	.	.	.	.	44.5032	41.2044	44.503	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:47	:11:8:5	ry:0:en:0
i1	69.75	3	60	.	.	.	.	.	.	.	.	41.2044	41.204	41.204	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:48	:12:6:5	ry:0:en:0
i1	72.75	1.875	60	.	.	.	.	.	.	.	.	49.9532	49.953	49.953	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:49	:13:B:5	ry:0:en:0
i1	74.625	4.5	60	.	.	.	.	.	.	.	.	56.0706	56.070	56.070	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:50	:14:E:5	ry:0:en:0
i1	79.125	4.125	60	.	.	.	.	.	.	.	.	39.6479	39.647	39.647	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:51	:15:5:5	ry:0:en:0
i1	83.25	0.375	60	.	.	.	.	.	.	.	.	58.2719	58.271	58.271	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:52	:16:F:5	ry:0:en:0
i1	83.625	0.375	0	.	.	.	.	.	.	.	.	38.1501	38.150	38.150	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:53	:17:4:5	ry:0:en:0
i1	84	0.375	60	.	.	.	.	.	.	.	.	39.6479	39.647	39.647	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:54	:0:5:5	ry:0:en:0
i1	84.375	0.375	60	.	.	.	.	.	.	.	.	48.0661	48.066	48.066	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:55	:1:A:5	ry:0:en:0
i1	84.75	0.375	60	.	.	.	.	.	.	.	.	32.704	32.704	32.704	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:56	:2:0:5	ry:0:en:0
i1	85.125	1.875	60	.	.	.	.	.	.	.	.	53.9524	60.5596	53.952	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:57	:3:D:5	ry:0:en:0
i1	87	0.375	60	.	.	.	.	.	.	.	.	60.5596	41.2044	41.2044	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:58	:4:G:5	ry:0:en:0
i1	87.375	3.75	60	.	.	.	.	.	.	.	.	41.2044	41.204	41.204	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:59	:5:6:5	ry:0:en:0
i1	91.125	0.375	60	.	.	.	.	.	.	.	.	44.5032	44.503	44.503	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:60	:6:8:5	ry:0:en:0
i1	91.5	4.5	60	.	.	.	.	.	.	.	.	56.0706	56.070	56.070	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:61	:7:E:5	ry:0:en:0
i1	96	0.375	60	.	.	.	.	.	.	.	.	38.1501	58.2719	38.150	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:62	:8:4:5	ry:0:en:0
i1	96.375	0.75	0	.	.	.	.	.	.	.	.	58.2719	58.271	58.271	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:63	:9:F:5	ry:0:en:0
i1	97.125	0.375	0	.	.	.	.	.	.	.	.	46.2504	62.9371	46.250	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:64	:10:9:5	ry:0:en:0
i1	97.5	0.375	60	.	.	.	.	.	.	.	.	62.9371	62.937	62.937	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:65	:11:H:5	ry:0:en:0
i1	97.875	1.5	60	.	.	.	.	.	.	.	.	49.9532	49.953	49.953	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:66	:12:B:5	ry:0:en:0
i1	99.375	0.375	60	.	.	.	.	.	.	.	.	33.9879	33.987	33.987	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:67	:13:1:5	ry:0:en:0
i1	99.75	4.5	60	.	.	.	.	.	.	.	.	42.8221	51.9143	42.822	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:68	:14:7:5	ry:0:en:0
i1	104.25	3.375	60	.	.	.	.	.	.	.	.	51.9143	36.7089	51.914	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:69	:15:C:5	ry:0:en:0
i1	107.625	0.375	60	.	.	.	.	.	.	.	.	36.7089	36.708	36.708	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:70	:16:3:5	ry:0:en:0
i1	108	0.375	60	.	.	.	.	.	.	.	.	35.3222	35.322	35.322	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:71	:17:2:5	ry:0:en:0
i1	108.375	0.375	0	.	.	.	.	.	.	.	.	51.9143	51.914	51.914	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:72	:0:C:5	ry:0:en:0
i1	108.75	0.375	60	.	.	.	.	.	.	.	.	38.1501	58.2719	38.150	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:73	:1:4:5	ry:0:en:0
i1	109.125	1.5	60	.	.	.	.	.	.	.	.	58.2719	58.271	58.271	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:74	:2:F:5	ry:0:en:0
i1	110.625	2.25	60	.	.	.	.	.	.	.	.	41.2044	41.204	41.204	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:75	:3:6:5	ry:0:en:0
i1	112.875	0.375	0	.	.	.	.	.	.	.	.	32.704	32.704	32.704	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:76	:4:0:5	ry:0:en:0
i1	113.25	1.875	60	.	.	.	.	.	.	.	.	49.9532	62.9371	49.953	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:77	:5:B:5	ry:0:en:0
i1	115.125	0.75	60	.	.	.	.	.	.	.	.	62.9371	42.8221	62.937	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:78	:6:H:5	ry:0:en:0
i1	115.875	4.5	60	.	.	.	.	.	.	.	.	42.8221	42.822	42.822	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:79	:7:7:5	ry:0:en:0
i1	120.375	0.375	60	.	.	.	.	.	.	.	.	35.3222	35.322	35.322	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:80	:8:2:5	ry:0:en:0
i1	120.75	0.375	60	.	.	.	.	.	.	.	.	36.7089	60.5596	36.708	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:81	:9:3:5	ry:0:en:0
i1	121.125	0.375	60	.	.	.	.	.	.	.	.	60.5596	60.559	60.559	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:82	:10:G:5	ry:0:en:0
i1	121.5	0.75	60	.	.	.	.	.	.	.	.	48.0661	48.066	48.066	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:83	:11:A:5	ry:0:en:0
i1	122.25	0.375	60	.	.	.	.	.	.	.	.	33.9879	44.5032	44.5032	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:84	:12:1:5	ry:0:en:0
i1	122.625	0.375	60	.	.	.	.	.	.	.	.	44.5032	56.0706	44.503	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:85	:13:8:5	ry:0:en:0
i1	123	4.5	60	.	.	.	.	.	.	.	.	56.0706	56.070	56.070	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:86	:14:E:5	ry:0:en:0
i1	127.5	4.125	60	.	.	.	.	.	.	.	.	53.9524	39.6479	39.6479	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:87	:15:D:5	ry:0:en:0
i1	131.625	0.375	60	.	.	.	.	.	.	.	.	39.6479	39.647	39.647	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:88	:16:5:5	ry:0:en:0
i1	132	0.375	60	.	.	.	.	.	.	.	.	46.2504	46.250	46.250	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:89	:17:9:5	ry:0:en:0
i1	132.375	0.375	60	.	.	.	.	.	.	.	.	53.9524	53.952	53.952	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:90	:0:D:5	ry:0:en:0
i1	132.75	0.375	60	.	.	.	.	.	.	.	.	35.3222	35.322	35.322	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:91	:1:2:5	ry:0:en:0
i1	133.125	0.75	0	.	.	.	.	.	.	.	.	36.7089	49.9532	36.708	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:92	:2:3:5	ry:0:en:0
i1	133.875	1.125	0	.	.	.	.	.	.	.	.	49.9532	49.953	49.953	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:93	:3:B:5	ry:0:en:0
i1	135	3.375	60	.	.	.	.	.	.	.	.	58.2719	58.271	58.271	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:94	:4:F:5	ry:0:en:0
i1	138.375	0.375	60	.	.	.	.	.	.	.	.	33.9879	48.0661	33.987	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:95	:5:1:5	ry:0:en:0
i1	138.75	1.5	60	.	.	.	.	.	.	.	.	48.0661	56.0706	56.0706	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:96	:6:A:5	ry:0:en:0
i1	140.25	4.5	60	.	.	.	.	.	.	.	.	56.0706	46.2504	46.2504	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:97	:7:E:5	ry:0:en:0
i1	144.75	0.375	60	.	.	.	.	.	.	.	.	46.2504	46.250	46.250	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:98	:8:9:5	ry:0:en:0
i1	145.125	0.375	60	.	.	.	.	.	.	.	.	39.6479	39.647	39.647	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:99	:9:5:5	ry:0:en:0
i1	145.5	0.375	60	.	.	.	.	.	.	.	.	32.704	32.704	32.704	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:100	:10:0:5	ry:0:en:0
i1	145.875	1.5	60	.	.	.	.	.	.	.	.	38.1501	44.5032	44.5032	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:101	:11:4:5	ry:0:en:0
i1	147.375	0.375	60	.	.	.	.	.	.	.	.	44.5032	62.9371	62.9371	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:102	:12:8:5	ry:0:en:0
i1	147.75	0.375	60	.	.	.	.	.	.	.	.	62.9371	62.937	62.937	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:103	:13:H:5	ry:0:en:0
i1	148.125	4.5	60	.	.	.	.	.	.	.	.	42.8221	42.822	42.822	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:104	:14:7:5	ry:0:en:0
i1	152.625	4.5	60	.	.	.	.	.	.	.	.	41.2044	41.204	41.204	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:105	:15:6:5	ry:0:en:0
i1	157.125	0.375	60	.	.	.	.	.	.	.	.	51.9143	60.5596	60.5596	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:106	:16:C:5	ry:0:en:0
i1	157.5	0.375	60	.	.	.	.	.	.	.	.	60.5596	60.559	60.559	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:107	:17:G:5	ry:0:en:0
i1	157.875	0.375	60	.	.	.	.	.	.	.	.	41.2044	41.204	41.204	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:108	:0:6:5	ry:0:en:0
i1	158.25	0.375	60	.	.	.	.	.	.	.	.	46.2504	46.250	46.250	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:109	:1:9:5	ry:0:en:0
i1	158.625	1.125	60	.	.	.	.	.	.	.	.	39.6479	39.647	39.647	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:110	:2:5:5	ry:0:en:0
i1	159.75	0.375	60	.	.	.	.	.	.	.	.	33.9879	33.987	33.987	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:111	:3:1:5	ry:0:en:0
i1	160.125	1.5	60	.	.	.	.	.	.	.	.	36.7089	44.5032	44.5032	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:112	:4:3:5	ry:0:en:0
i1	161.625	0.375	60	.	.	.	.	.	.	.	.	44.5032	44.503	44.503	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:113	:5:8:5	ry:0:en:0
i1	162	3	60	.	.	.	.	.	.	.	.	38.1501	38.150	38.150	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:114	:6:4:5	ry:0:en:0
i1	165	4.5	60	.	.	.	.	.	.	.	.	42.8221	42.822	42.822	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:115	:7:7:5	ry:0:en:0
i1	169.5	0.375	60	.	.	.	.	.	.	.	.	60.5596	51.9143	60.559	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:116	:8:G:5	ry:0:en:0
i1	169.875	0.375	0	.	.	.	.	.	.	.	.	51.9143	51.914	51.914	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:117	:9:C:5	ry:0:en:0
i1	170.25	1.5	60	.	.	.	.	.	.	.	.	58.2719	58.271	58.271	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:118	:10:F:5	ry:0:en:0
i1	171.75	0.75	60	.	.	.	.	.	.	.	.	35.3222	35.322	35.322	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:119	:11:2:5	ry:0:en:0
i1	172.5	0.375	0	.	.	.	.	.	.	.	.	62.9371	62.937	62.937	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:120	:12:H:5	ry:0:en:0
i1	172.875	1.125	60	.	.	.	.	.	.	.	.	48.0661	48.066	48.066	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:121	:13:A:5	ry:0:en:0
i1	174	4.5	60	.	.	.	.	.	.	.	.	56.0706	56.070	56.070	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:122	:14:E:5	ry:0:en:0
i1	178.5	2.625	60	.	.	.	.	.	.	.	.	49.9532	49.953	49.953	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:123	:15:B:5	ry:0:en:0
i1	181.125	0.375	60	.	.	.	.	.	.	.	.	53.9524	53.952	53.952	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:124	:16:D:5	ry:0:en:0
i1	181.5	0.375	60	.	.	.	.	.	.	.	.	32.704	32.704	32.704	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:125	:17:0:5	ry:0:en:0
i1	181.875	0.375	60	.	.	.	.	.	.	.	.	49.9532	49.953	49.953	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:126	:0:B:5	ry:0:en:0
i1	182.25	0.375	60	.	.	.	.	.	.	.	.	60.5596	60.559	60.559	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:127	:1:G:5	ry:0:en:0
i1	182.625	0.75	60	.	.	.	.	.	.	.	.	51.9143	44.5032	51.914	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:128	:2:C:5	ry:0:en:0
i1	183.375	0.375	60	.	.	.	.	.	.	.	.	44.5032	44.503	44.503	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:129	:3:8:5	ry:0:en:0
i1	183.75	2.25	60	.	.	.	.	.	.	.	.	39.6479	39.647	39.647	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:130	:4:5:5	ry:0:en:0
i1	186	0.375	60	.	.	.	.	.	.	.	.	62.9371	62.937	62.937	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:131	:5:H:5	ry:0:en:0
i1	186.375	1.5	0	.	.	.	.	.	.	.	.	35.3222	35.322	35.322	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:132	:6:2:5	ry:0:en:0
i1	187.875	4.5	60	.	.	.	.	.	.	.	.	56.0706	56.070	56.070	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:133	:7:E:5	ry:0:en:0
i1	192.375	0.375	60	.	.	.	.	.	.	.	.	32.704	53.9524	53.9524	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:134	:8:0:5	ry:0:en:0
i1	192.75	0.375	60	.	.	.	.	.	.	.	.	53.9524	53.952	53.952	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:135	:9:D:5	ry:0:en:0
i1	193.125	0.75	60	.	.	.	.	.	.	.	.	36.7089	36.708	36.708	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:136	:10:3:5	ry:0:en:0
i1	193.875	0.375	60	.	.	.	.	.	.	.	.	46.2504	48.0661	48.0661	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:137	:11:9:5	ry:0:en:0
i1	194.25	0.75	60	.	.	.	.	.	.	.	.	48.0661	48.066	48.066	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:138	:12:A:5	ry:0:en:0
i1	195	2.25	60	.	.	.	.	.	.	.	.	38.1501	38.150	38.150	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:139	:13:4:5	ry:0:en:0
i1	197.25	4.5	60	.	.	.	.	.	.	.	.	42.8221	33.9879	42.822	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:140	:14:7:5	ry:0:en:0
i1	201.75	0.75	60	.	.	.	.	.	.	.	.	33.9879	33.987	33.987	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:141	:15:1:5	ry:0:en:0
i1	202.5	0.375	0	.	.	.	.	.	.	.	.	41.2044	41.204	41.204	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:142	:16:6:5	ry:0:en:0
i1	202.875	0.75	60	.	.	.	.	.	.	.	.	58.2719	58.271	58.271	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:143	:17:F:5	ry:0:en:0
i1	203.625	0.375	0	.	.	.	.	.	.	.	.	33.9879	33.987	33.987	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:144	:0:1:5	ry:0:en:0
i1	204	0.375	0	.	.	.	.	.	.	.	.	32.704	53.9524	53.9524	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:145	:1:0:5	ry:0:en:0
i1	204.375	1.125	60	.	.	.	.	.	.	.	.	53.9524	53.952	53.952	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:146	:2:D:5	ry:0:en:0
i1	205.5	0.375	60	.	.	.	.	.	.	.	.	62.9371	62.937	62.937	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:147	:3:H:5	ry:0:en:0
i1	205.875	1.875	60	.	.	.	.	.	.	.	.	51.9143	51.914	51.914	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:148	:4:C:5	ry:0:en:0
i1	207.75	1.125	60	.	.	.	.	.	.	.	.	48.0661	48.066	48.066	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:149	:5:A:5	ry:0:en:0
i1	208.875	0.75	60	.	.	.	.	.	.	.	.	46.2504	46.250	46.250	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:150	:6:9:5	ry:0:en:0
i1	209.625	4.5	60	.	.	.	.	.	.	.	.	42.8221	42.822	42.822	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:151	:7:7:5	ry:0:en:0
i1	214.125	0.375	60	.	.	.	.	.	.	.	.	58.2719	41.2044	41.2044	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:152	:8:F:5	ry:0:en:0
i1	214.5	0.75	60	.	.	.	.	.	.	.	.	41.2044	41.204	41.204	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:153	:9:6:5	ry:0:en:0
i1	215.25	1.125	60	.	.	.	.	.	.	.	.	39.6479	39.647	39.647	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:154	:10:5:5	ry:0:en:0
i1	216.375	0.375	60	.	.	.	.	.	.	.	.	60.5596	38.1501	60.559	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:155	:11:G:5	ry:0:en:0
i1	216.75	1.875	60	.	.	.	.	.	.	.	.	38.1501	38.150	38.150	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:156	:12:4:5	ry:0:en:0
i1	218.625	1.125	60	.	.	.	.	.	.	.	.	35.3222	56.0706	35.322	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:157	:13:2:5	ry:0:en:0
i1	219.75	4.5	60	.	.	.	.	.	.	.	.	56.0706	56.070	56.070	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:158	:14:E:5	ry:0:en:0
i1	224.25	0.375	60	.	.	.	.	.	.	.	.	44.5032	44.503	44.503	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:159	:15:8:5	ry:0:en:0
i1	224.625	0.375	60	.	.	.	.	.	.	.	.	49.9532	49.953	49.953	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:160	:16:B:5	ry:0:en:0
i1	225	0.375	60	.	.	.	.	.	.	.	.	36.7089	36.708	36.708	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:161	:17:3:5	ry:0:en:0
i1	225.375	0.375	60	.	.	.	.	.	.	.	.	44.5032	58.2719	44.503	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:162	:0:8:5	ry:0:en:0
i1	225.75	0.75	60	.	.	.	.	.	.	.	.	58.2719	58.271	58.271	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:163	:1:F:5	ry:0:en:0
i1	226.5	1.5	60	.	.	.	.	.	.	.	.	41.2044	48.0661	48.0661	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:164	:2:6:5	ry:0:en:0
i1	228	0.75	60	.	.	.	.	.	.	.	.	48.0661	48.066	48.066	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:165	:3:A:5	ry:0:en:0
i1	228.75	2.25	60	.	.	.	.	.	.	.	.	53.9524	53.952	53.952	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:166	:4:D:5	ry:0:en:0
i1	231	2.25	60	.	.	.	.	.	.	.	.	38.1501	38.150	38.150	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:167	:5:4:5	ry:0:en:0
i1	233.25	0.375	60	.	.	.	.	.	.	.	.	60.5596	60.559	60.559	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:168	:6:G:5	ry:0:en:0
i1	233.625	4.5	60	.	.	.	.	.	.	.	.	56.0706	56.070	56.070	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:169	:7:E:5	ry:0:en:0
i1	238.125	0.375	60	.	.	.	.	.	.	.	.	36.7089	36.708	36.708	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:170	:8:3:5	ry:0:en:0
i1	238.5	0.375	60	.	.	.	.	.	.	.	.	49.9532	49.953	49.953	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:171	:9:B:5	ry:0:en:0
i1	238.875	0.75	60	.	.	.	.	.	.	.	.	51.9143	51.914	51.914	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:172	:10:C:5	ry:0:en:0
i1	239.625	0.375	60	.	.	.	.	.	.	.	.	32.704	35.3222	32.704	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:173	:11:0:5	ry:0:en:0
i1	240	0.75	60	.	.	.	.	.	.	.	.	35.3222	46.2504	35.322	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:174	:12:2:5	ry:0:en:0
i1	240.75	0.375	60	.	.	.	.	.	.	.	.	46.2504	46.250	46.250	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:175	:13:9:5	ry:0:en:0
i1	241.125	4.5	60	.	.	.	.	.	.	.	.	42.8221	42.822	42.822	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:176	:14:7:5	ry:0:en:0
i1	245.625	0.75	0	.	.	.	.	.	.	.	.	62.9371	62.937	62.937	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:177	:15:H:5	ry:0:en:0
i1	246.375	0.375	60	.	.	.	.	.	.	.	.	33.9879	33.987	33.987	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:178	:16:1:5	ry:0:en:0
i1	246.75	0.375	0	.	.	.	.	.	.	.	.	39.6479	39.647	39.647	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:179	:17:5:5	ry:0:en:0
i1	247.125	0.375	60	.	.	.	.	.	.	.	.	62.9371	62.937	62.937	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:180	:0:H:5	ry:0:en:0
i1	247.5	0.375	60	.	.	.	.	.	.	.	.	36.7089	36.708	36.708	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:181	:1:3:5	ry:0:en:0
i1	247.875	0.75	60	.	.	.	.	.	.	.	.	49.9532	49.953	49.953	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:182	:2:B:5	ry:0:en:0
i1	248.625	1.5	0	.	.	.	.	.	.	.	.	38.1501	38.150	38.150	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:183	:3:4:5	ry:0:en:0
i1	250.125	3	0	.	.	.	.	.	.	.	.	41.2044	41.204	41.204	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:184	:4:6:5	ry:0:en:0
i1	253.125	1.125	60	.	.	.	.	.	.	.	.	35.3222	35.322	35.322	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:185	:5:2:5	ry:0:en:0
i1	254.25	0.375	60	.	.	.	.	.	.	.	.	32.704	32.704	32.704	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:186	:6:0:5	ry:0:en:0
i1	254.625	4.5	60	.	.	.	.	.	.	.	.	42.8221	42.822	42.822	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:187	:7:7:5	ry:0:en:0
i1	259.125	0.375	60	.	.	.	.	.	.	.	.	39.6479	39.647	39.647	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:188	:8:5:5	ry:0:en:0
i1	259.5	0.375	60	.	.	.	.	.	.	.	.	33.9879	53.9524	33.987	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:189	:9:1:5	ry:0:en:0
i1	259.875	1.125	60	.	.	.	.	.	.	.	.	53.9524	58.2719	53.952	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:190	:10:D:5	ry:0:en:0
i1	261	2.625	60	.	.	.	.	.	.	.	.	58.2719	58.271	58.271	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:191	:11:F:5	ry:0:en:0
i1	263.625	0.375	60	.	.	.	.	.	.	.	.	46.2504	60.5596	46.250	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:192	:12:9:5	ry:0:en:0
i1	264	0.375	60	.	.	.	.	.	.	.	.	60.5596	56.0706	56.0706	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:193	:13:G:5	ry:0:en:0
i1	264.375	4.5	60	.	.	.	.	.	.	.	.	56.0706	48.0661	56.070	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:194	:14:E:5	ry:0:en:0
i1	268.875	1.5	60	.	.	.	.	.	.	.	.	48.0661	48.066	48.066	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:195	:15:A:5	ry:0:en:0
i1	270.375	0.375	60	.	.	.	.	.	.	.	.	44.5032	44.503	44.503	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:196	:16:8:5	ry:0:en:0
i1	270.75	0.375	60	.	.	.	.	.	.	.	.	51.9143	48.0661	51.914	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:197	:17:C:5	ry:0:en:0
i1	271.125	0.375	60	.	.	.	.	.	.	.	.	48.0661	48.066	48.066	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:198	:0:A:5	ry:0:en:0
i1	271.5	0.375	60	.	.	.	.	.	.	.	.	39.6479	33.9879	39.647	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:199	:1:5:5	ry:0:en:0
i1	271.875	0.375	60	.	.	.	.	.	.	.	.	33.9879	33.987	33.987	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:200	:2:1:5	ry:0:en:0
i1	272.25	0.75	60	.	.	.	.	.	.	.	.	35.3222	35.322	35.322	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:201	:3:2:5	ry:0:en:0
i1	273	1.5	60	.	.	.	.	.	.	.	.	49.9532	49.953	49.953	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:202	:4:B:5	ry:0:en:0
i1	274.5	0.375	0	.	.	.	.	.	.	.	.	46.2504	58.2719	58.2719	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:203	:5:9:5	ry:0:en:0
i1	274.875	4.5	60	.	.	.	.	.	.	.	.	58.2719	56.0706	58.271	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:204	:6:F:5	ry:0:en:0
i1	279.375	4.5	60	.	.	.	.	.	.	.	.	56.0706	51.9143	56.070	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:205	:7:E:5	ry:0:en:0
i1	283.875	0.375	60	.	.	.	.	.	.	.	.	51.9143	51.914	51.914	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:206	:8:C:5	ry:0:en:0
i1	284.25	0.375	0	.	.	.	.	.	.	.	.	44.5032	44.503	44.503	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:207	:9:8:5	ry:0:en:0
i1	284.625	1.5	60	.	.	.	.	.	.	.	.	41.2044	41.204	41.204	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:208	:10:6:5	ry:0:en:0
i1	286.125	1.125	60	.	.	.	.	.	.	.	.	36.7089	36.708	36.708	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:209	:11:3:5	ry:0:en:0
i1	287.25	0.375	60	.	.	.	.	.	.	.	.	60.5596	60.559	60.559	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:210	:12:G:5	ry:0:en:0
i1	287.625	0.375	60	.	.	.	.	.	.	.	.	32.704	32.704	32.704	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:211	:13:0:5	ry:0:en:0
i1	288	4.5	60	.	.	.	.	.	.	.	.	42.8221	42.822	42.822	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:212	:14:7:5	ry:0:en:0
i1	292.5	3.375	60	.	.	.	.	.	.	.	.	38.1501	38.150	38.150	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:213	:15:4:5	ry:0:en:0
i1	295.875	0.375	60	.	.	.	.	.	.	.	.	62.9371	62.937	62.937	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:214	:16:H:5	ry:0:en:0
i1	296.25	0.375	60	.	.	.	.	.	.	.	.	53.9524	53.952	53.952	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:215	:17:D:5	ry:0:en:0
i1	296.625	0.375	0	.	.	.	.	.	.	.	.	38.1501	38.150	38.150	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:216	:0:4:5	ry:0:en:0
i1	297	0.375	60	.	.	.	.	.	.	.	.	51.9143	44.5032	51.914	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:217	:1:C:5	ry:0:en:0
i1	297.375	0.375	60	.	.	.	.	.	.	.	.	44.5032	46.2504	46.2504	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:218	:2:8:5	ry:0:en:0
i1	297.75	0.375	60	.	.	.	.	.	.	.	.	46.2504	46.250	46.250	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:219	:3:9:5	ry:0:en:0
i1	298.125	0.375	60	.	.	.	.	.	.	.	.	33.9879	60.5596	60.5596	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:220	:4:1:5	ry:0:en:0
i1	298.5	0.375	60	.	.	.	.	.	.	.	.	60.5596	60.559	60.559	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:221	:5:G:5	ry:0:en:0
i1	298.875	2.25	60	.	.	.	.	.	.	.	.	36.7089	36.708	36.708	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:222	:6:3:5	ry:0:en:0
i1	301.125	4.5	60	.	.	.	.	.	.	.	.	42.8221	42.822	42.822	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:223	:7:7:5	ry:0:en:0
i1	305.625	0.375	60	.	.	.	.	.	.	.	.	53.9524	53.952	53.952	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:224	:8:D:5	ry:0:en:0
i1	306	0.375	60	.	.	.	.	.	.	.	.	62.9371	62.937	62.937	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:225	:9:H:5	ry:0:en:0
i1	306.375	0.75	60	.	.	.	.	.	.	.	.	49.9532	49.953	49.953	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:226	:10:B:5	ry:0:en:0
i1	307.125	1.875	60	.	.	.	.	.	.	.	.	39.6479	39.647	39.647	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:227	:11:5:5	ry:0:en:0
i1	309	0.375	0	.	.	.	.	.	.	.	.	32.704	32.704	32.704	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:228	:12:0:5	ry:0:en:0
i1	309.375	4.125	60	.	.	.	.	.	.	.	.	58.2719	58.271	58.271	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:229	:13:F:5	ry:0:en:0
i1	313.5	4.5	60	.	.	.	.	.	.	.	.	56.0706	56.070	56.070	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:230	:14:E:5	ry:0:en:0
i1	318	1.5	60	.	.	.	.	.	.	.	.	35.3222	35.322	35.322	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:231	:15:2:5	ry:0:en:0
i1	319.5	0.375	60	.	.	.	.	.	.	.	.	48.0661	48.066	48.066	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:232	:16:A:5	ry:0:en:0
i1	319.875	0.75	60	.	.	.	.	.	.	.	.	41.2044	35.3222	41.204	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:233	:17:6:5	ry:0:en:0
i1	320.625	0.375	60	.	.	.	.	.	.	.	.	35.3222	35.322	35.322	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:234	:0:2:5	ry:0:en:0
i1	321	0.375	60	.	.	.	.	.	.	.	.	53.9524	53.952	53.952	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:235	:1:D:5	ry:0:en:0
i1	321.375	0.375	60	.	.	.	.	.	.	.	.	62.9371	60.5596	62.937	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:236	:2:H:5	ry:0:en:0
i1	321.75	0.375	0	.	.	.	.	.	.	.	.	60.5596	60.559	60.559	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:237	:3:G:5	ry:0:en:0
i1	322.125	0.375	60	.	.	.	.	.	.	.	.	44.5032	44.503	44.503	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:238	:4:8:5	ry:0:en:0
i1	322.5	0.375	60	.	.	.	.	.	.	.	.	32.704	32.704	32.704	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:239	:5:0:5	ry:0:en:0
i1	322.875	3.75	60	.	.	.	.	.	.	.	.	39.6479	56.0706	56.0706	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:240	:6:5:5	ry:0:en:0
i1	326.625	4.5	60	.	.	.	.	.	.	.	.	56.0706	56.070	56.070	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:241	:7:E:5	ry:0:en:0
i1	331.125	0.375	60	.	.	.	.	.	.	.	.	41.2044	41.204	41.204	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:242	:8:6:5	ry:0:en:0
i1	331.5	0.375	60	.	.	.	.	.	.	.	.	48.0661	48.066	48.066	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:243	:9:A:5	ry:0:en:0
i1	331.875	0.375	60	.	.	.	.	.	.	.	.	33.9879	33.987	33.987	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:244	:10:1:5	ry:0:en:0
i1	332.25	1.5	60	.	.	.	.	.	.	.	.	51.9143	51.914	51.914	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:245	:11:C:5	ry:0:en:0
i1	333.75	3.375	60	.	.	.	.	.	.	.	.	58.2719	58.271	58.271	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:246	:12:F:5	ry:0:en:0
i1	337.125	1.875	0	.	.	.	.	.	.	.	.	36.7089	36.708	36.708	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:247	:13:3:5	ry:0:en:0
i1	339	4.5	60	.	.	.	.	.	.	.	.	42.8221	42.822	42.822	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:248	:14:7:5	ry:0:en:0
i1	343.5	0.75	60	.	.	.	.	.	.	.	.	46.2504	46.250	46.250	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:249	:15:9:5	ry:0:en:0
i1	344.25	0.375	60	.	.	.	.	.	.	.	.	38.1501	38.150	38.150	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:250	:16:4:5	ry:0:en:0
i1	344.625	0.375	60	.	.	.	.	.	.	.	.	49.9532	46.2504	49.953	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:251	:17:B:5	ry:0:en:0
i1	345	0.375	60	.	.	.	.	.	.	.	.	46.2504	46.250	46.250	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:252	:0:9:5	ry:0:en:0
i1	345.375	0.75	60	.	.	.	.	.	.	.	.	41.2044	41.204	41.204	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:253	:1:6:5	ry:0:en:0
i1	346.125	0.375	60	.	.	.	.	.	.	.	.	48.0661	32.704	48.066	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:254	:2:A:5	ry:0:en:0
i1	346.5	0.375	60	.	.	.	.	.	.	.	.	32.704	62.9371	32.704	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:255	:3:0:5	ry:0:en:0
i1	346.875	0.375	60	.	.	.	.	.	.	.	.	62.9371	62.937	62.937	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:256	:4:H:5	ry:0:en:0
i1	347.25	4.125	60	.	.	.	.	.	.	.	.	58.2719	58.271	58.271	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:257	:5:F:5	ry:0:en:0
i1	351.375	3	0	.	.	.	.	.	.	.	.	51.9143	42.8221	51.914	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:258	:6:C:5	ry:0:en:0
i1	354.375	4.5	60	.	.	.	.	.	.	.	.	42.8221	42.822	42.822	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:259	:7:7:5	ry:0:en:0
i1	358.875	0.375	60	.	.	.	.	.	.	.	.	49.9532	49.953	49.953	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:260	:8:B:5	ry:0:en:0
i1	359.25	0.375	60	.	.	.	.	.	.	.	.	38.1501	44.5032	38.150	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:261	:9:4:5	ry:0:en:0
i1	359.625	0.375	60	.	.	.	.	.	.	.	.	44.5032	44.503	44.503	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:262	:10:8:5	ry:0:en:0
i1	360	1.875	60	.	.	.	.	.	.	.	.	53.9524	53.952	53.952	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:263	:11:D:5	ry:0:en:0
i1	361.875	1.5	0	.	.	.	.	.	.	.	.	36.7089	36.708	36.708	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:264	:12:3:5	ry:0:en:0
i1	363.375	3	60	.	.	.	.	.	.	.	.	39.6479	39.647	39.647	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:265	:13:5:5	ry:0:en:0
i1	366.375	4.5	60	.	.	.	.	.	.	.	.	56.0706	56.070	56.070	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:266	:14:E:5	ry:0:en:0
i1	370.875	0.375	60	.	.	.	.	.	.	.	.	60.5596	60.559	60.559	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:267	:15:G:5	ry:0:en:0
i1	371.25	0.375	60	.	.	.	.	.	.	.	.	35.3222	35.322	35.322	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:268	:16:2:5	ry:0:en:0
i1	371.625	0.375	60	.	.	.	.	.	.	.	.	33.9879	60.5596	60.5596	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:269	:17:1:5	ry:0:en:0
i1	372	0.375	60	.	.	.	.	.	.	.	.	60.5596	49.9532	49.9532	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:270	:0:G:5	ry:0:en:0
i1	372.375	0.375	60	.	.	.	.	.	.	.	.	49.9532	38.1501	38.1501	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:271	:1:B:5	ry:0:en:0
i1	372.75	0.75	60	.	.	.	.	.	.	.	.	38.1501	38.150	38.150	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:272	:2:4:5	ry:0:en:0
i1	373.5	2.625	60	.	.	.	.	.	.	.	.	58.2719	48.0661	58.271	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:273	:3:F:5	ry:0:en:0
i1	376.125	0.75	60	.	.	.	.	.	.	.	.	48.0661	48.066	48.066	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:274	:4:A:5	ry:0:en:0
i1	376.875	1.875	60	.	.	.	.	.	.	.	.	36.7089	36.708	36.708	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:275	:5:3:5	ry:0:en:0
i1	378.75	3.75	0	.	.	.	.	.	.	.	.	53.9524	56.0706	53.952	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:276	:6:D:5	ry:0:en:0
i1	382.5	4.5	60	.	.	.	.	.	.	.	.	56.0706	56.070	56.070	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:277	:7:E:5	ry:0:en:0
i1	387	0.375	60	.	.	.	.	.	.	.	.	33.9879	33.987	33.987	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:278	:8:1:5	ry:0:en:0
i1	387.375	0.375	60	.	.	.	.	.	.	.	.	35.3222	35.322	35.322	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:279	:9:2:5	ry:0:en:0
i1	387.75	0.375	60	.	.	.	.	.	.	.	.	62.9371	62.937	62.937	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:280	:10:H:5	ry:0:en:0
i1	388.125	2.25	0	.	.	.	.	.	.	.	.	41.2044	41.204	41.204	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:281	:11:6:5	ry:0:en:0
i1	390.375	2.25	60	.	.	.	.	.	.	.	.	39.6479	39.647	39.647	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:282	:12:5:5	ry:0:en:0
i1	392.625	2.25	60	.	.	.	.	.	.	.	.	51.9143	51.914	51.914	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:283	:13:C:5	ry:0:en:0
i1	394.875	4.5	60	.	.	.	.	.	.	.	.	42.8221	42.822	42.822	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:284	:14:7:5	ry:0:en:0
i1	399.375	0.375	60	.	.	.	.	.	.	.	.	32.704	32.704	32.704	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:285	:15:0:5	ry:0:en:0
i1	399.75	0.375	60	.	.	.	.	.	.	.	.	46.2504	44.5032	44.5032	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:286	:16:9:5	ry:0:en:0
i1	400.125	0.375	60	.	.	.	.	.	.	.	.	44.5032	44.503	44.503	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_1:287	:17:8:5	ry:0:en:0

; Seq_2 comments: Gradual of the dodecaphonic inverse (I) for an alto voice.
;ins	sta	dur	amp	ft1	aty	atk	rel	hd1	hd2	gl1	gl2	fq1	fq2	fq3	pa1	pa2	del	car	mod	hm1	hm2	cro	buz	rvn	rvs	ft2	pcd	
i2	0	0.375	70	12	0	0	1	1	0	0	0	96.1323	96.132	96.132	0.3	0.7	0.3	1	1	0	0	0	0	0	0	24	1	;Sec:0:Seq_2:0	:0:A:6	ry:0:en:0
i2	0.375	0.375	70	.	.	.	.	.	.	.	.	70.6445	70.644	70.644	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:1	:1:2:6	ry:0:en:0
i2	0.75	0.375	0	.	.	.	.	.	.	.	.	125.8742	125.874	125.874	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:2	:2:H:6	ry:0:en:0
i2	1.125	1.875	70	.	.	.	.	.	.	.	.	107.9049	112.1412	107.904	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:3	:3:D:6	ry:0:en:0
i2	3	3	70	.	.	.	.	.	.	.	.	112.1412	85.6442	85.6442	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:4	:4:E:6	ry:0:en:0
i2	6	4.125	70	.	.	.	.	.	.	.	.	85.6442	85.644	85.644	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:5	:5:7:6	ry:0:en:0
i2	10.125	0.75	70	.	.	.	.	.	.	.	.	67.9758	121.1192	121.1192	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:6	:6:1:6	ry:0:en:0
i2	10.875	0.375	70	.	.	.	.	.	.	.	.	121.1192	121.119	121.119	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:7	:7:G:6	ry:0:en:0
i2	11.25	0.375	70	.	.	.	.	.	.	.	.	76.3003	76.300	76.300	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:8	:8:4:6	ry:0:en:0
i2	11.625	0.375	70	.	.	.	.	.	.	.	.	73.4179	73.417	73.417	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:9	:9:3:6	ry:0:en:0
i2	12	1.5	70	.	.	.	.	.	.	.	.	82.4089	82.408	82.408	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:10	:10:6:6	ry:0:en:0
i2	13.5	0.375	70	.	.	.	.	.	.	.	.	92.5008	92.500	92.500	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:11	:11:9:6	ry:0:en:0
i2	13.875	0.375	70	.	.	.	.	.	.	.	.	89.0065	89.006	89.006	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:12	:12:8:6	ry:0:en:0
i2	14.25	0.375	70	.	.	.	.	.	.	.	.	65.408	65.408	65.408	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:13	:13:0:6	ry:0:en:0
i2	14.625	4.5	70	.	.	.	.	.	.	.	.	116.5438	116.543	116.543	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:14	:14:F:6	ry:0:en:0
i2	19.125	2.625	70	.	.	.	.	.	.	.	.	99.9064	103.8287	103.8287	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:15	:15:B:6	ry:0:en:0
i2	21.75	0.375	70	.	.	.	.	.	.	.	.	103.8287	103.828	103.828	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:16	:16:C:6	ry:0:en:0
i2	22.125	0.375	0	.	.	.	.	.	.	.	.	79.2958	79.295	79.295	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:17	:17:5:6	ry:0:en:0
i2	22.5	0.375	70	.	.	.	.	.	.	.	.	96.1323	96.132	96.132	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:18	:0:A:6	ry:0:en:0
i2	22.875	0.375	70	.	.	.	.	.	.	.	.	70.6445	70.644	70.644	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:19	:1:2:6	ry:0:en:0
i2	23.25	0.375	0	.	.	.	.	.	.	.	.	125.8742	125.874	125.874	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:20	:2:H:6	ry:0:en:0
i2	23.625	1.875	70	.	.	.	.	.	.	.	.	107.9049	112.1412	107.904	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:21	:3:D:6	ry:0:en:0
i2	25.5	3	70	.	.	.	.	.	.	.	.	112.1412	85.6442	85.6442	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:22	:4:E:6	ry:0:en:0
i2	28.5	4.125	70	.	.	.	.	.	.	.	.	85.6442	85.644	85.644	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:23	:5:7:6	ry:0:en:0
i2	32.625	0.75	70	.	.	.	.	.	.	.	.	67.9758	121.1192	121.1192	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:24	:6:1:6	ry:0:en:0
i2	33.375	0.375	70	.	.	.	.	.	.	.	.	121.1192	121.119	121.119	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:25	:7:G:6	ry:0:en:0
i2	33.75	0.375	70	.	.	.	.	.	.	.	.	76.3003	76.300	76.300	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:26	:8:4:6	ry:0:en:0
i2	34.125	0.375	70	.	.	.	.	.	.	.	.	73.4179	73.417	73.417	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:27	:9:3:6	ry:0:en:0
i2	34.5	1.5	70	.	.	.	.	.	.	.	.	82.4089	82.408	82.408	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:28	:10:6:6	ry:0:en:0
i2	36	0.375	70	.	.	.	.	.	.	.	.	92.5008	92.500	92.500	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:29	:11:9:6	ry:0:en:0
i2	36.375	0.375	70	.	.	.	.	.	.	.	.	89.0065	89.006	89.006	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:30	:12:8:6	ry:0:en:0
i2	36.75	0.375	70	.	.	.	.	.	.	.	.	65.408	65.408	65.408	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:31	:13:0:6	ry:0:en:0
i2	37.125	4.5	70	.	.	.	.	.	.	.	.	116.5438	116.543	116.543	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:32	:14:F:6	ry:0:en:0
i2	41.625	2.625	70	.	.	.	.	.	.	.	.	99.9064	103.8287	103.8287	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:33	:15:B:6	ry:0:en:0
i2	44.25	0.375	70	.	.	.	.	.	.	.	.	103.8287	103.828	103.828	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:34	:16:C:6	ry:0:en:0
i2	44.625	0.375	0	.	.	.	.	.	.	.	.	79.2958	79.295	79.295	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:35	:17:5:6	ry:0:en:0
i2	45	0.375	70	.	.	.	.	.	.	.	.	82.4089	125.8742	125.8742	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:36	:0:6:6	ry:0:en:0
i2	45.375	0.375	70	.	.	.	.	.	.	.	.	125.8742	125.874	125.874	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:37	:1:H:6	ry:0:en:0
i2	45.75	1.125	70	.	.	.	.	.	.	.	.	79.2958	79.295	79.295	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:38	:2:5:6	ry:0:en:0
i2	46.875	0.375	70	.	.	.	.	.	.	.	.	65.408	65.408	65.408	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:39	:3:0:6	ry:0:en:0
i2	47.25	3.375	70	.	.	.	.	.	.	.	.	116.5438	116.543	116.543	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:40	:4:F:6	ry:0:en:0
i2	50.625	0.375	70	.	.	.	.	.	.	.	.	121.1192	70.6445	121.119	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:41	:5:G:6	ry:0:en:0
i2	51	1.5	70	.	.	.	.	.	.	.	.	70.6445	70.644	70.644	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:42	:6:2:6	ry:0:en:0
i2	52.5	3.375	0	.	.	.	.	.	.	.	.	103.8287	112.1412	103.828	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:43	:7:C:6	ry:0:en:0
i2	55.875	0.375	70	.	.	.	.	.	.	.	.	112.1412	112.141	112.141	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:44	:8:E:6	ry:0:en:0
i2	56.25	0.375	70	.	.	.	.	.	.	.	.	107.9049	107.904	107.904	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:45	:9:D:6	ry:0:en:0
i2	56.625	0.375	70	.	.	.	.	.	.	.	.	67.9758	67.975	67.975	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:46	:10:1:6	ry:0:en:0
i2	57	1.125	70	.	.	.	.	.	.	.	.	73.4179	73.417	73.417	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:47	:11:3:6	ry:0:en:0
i2	58.125	1.875	70	.	.	.	.	.	.	.	.	76.3003	96.1323	76.300	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:48	:12:4:6	ry:0:en:0
i2	60	1.125	70	.	.	.	.	.	.	.	.	96.1323	96.132	96.132	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:49	:13:A:6	ry:0:en:0
i2	61.125	2.25	70	.	.	.	.	.	.	.	.	99.9064	92.5008	99.906	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:50	:14:B:6	ry:0:en:0
i2	63.375	0.75	70	.	.	.	.	.	.	.	.	92.5008	89.0065	92.500	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:51	:15:9:6	ry:0:en:0
i2	64.125	0.375	70	.	.	.	.	.	.	.	.	89.0065	89.006	89.006	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:52	:16:8:6	ry:0:en:0
i2	64.5	0.75	0	.	.	.	.	.	.	.	.	85.6442	85.644	85.644	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:53	:17:7:6	ry:0:en:0
i2	65.25	0.375	70	.	.	.	.	.	.	.	.	67.9758	67.975	67.975	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:54	:0:1:6	ry:0:en:0
i2	65.625	0.375	70	.	.	.	.	.	.	.	.	79.2958	79.295	79.295	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:55	:1:5:6	ry:0:en:0
i2	66	1.5	70	.	.	.	.	.	.	.	.	85.6442	85.644	85.644	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:56	:2:7:6	ry:0:en:0
i2	67.5	0.75	70	.	.	.	.	.	.	.	.	96.1323	96.132	96.132	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:57	:3:A:6	ry:0:en:0
i2	68.25	1.5	70	.	.	.	.	.	.	.	.	99.9064	99.906	99.906	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:58	:4:B:6	ry:0:en:0
i2	69.75	2.25	0	.	.	.	.	.	.	.	.	103.8287	103.828	103.828	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:59	:5:C:6	ry:0:en:0
i2	72	0.75	70	.	.	.	.	.	.	.	.	125.8742	125.874	125.874	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:60	:6:H:6	ry:0:en:0
i2	72.75	0.375	70	.	.	.	.	.	.	.	.	89.0065	89.006	89.006	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:61	:7:8:6	ry:0:en:0
i2	73.125	0.375	70	.	.	.	.	.	.	.	.	116.5438	65.408	116.543	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:62	:8:F:6	ry:0:en:0
i2	73.5	0.375	70	.	.	.	.	.	.	.	.	65.408	70.6445	70.6445	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:63	:9:0:6	ry:0:en:0
i2	73.875	0.375	70	.	.	.	.	.	.	.	.	70.6445	70.644	70.644	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:64	:10:2:6	ry:0:en:0
i2	74.25	1.875	70	.	.	.	.	.	.	.	.	107.9049	107.904	107.904	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:65	:11:D:6	ry:0:en:0
i2	76.125	3	0	.	.	.	.	.	.	.	.	112.1412	82.4089	82.4089	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:66	:12:E:6	ry:0:en:0
i2	79.125	3.75	70	.	.	.	.	.	.	.	.	82.4089	92.5008	92.5008	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:67	:13:6:6	ry:0:en:0
i2	82.875	0.75	70	.	.	.	.	.	.	.	.	92.5008	92.500	92.500	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:68	:14:9:6	ry:0:en:0
i2	83.625	2.625	70	.	.	.	.	.	.	.	.	73.4179	73.417	73.417	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:69	:15:3:6	ry:0:en:0
i2	86.25	0.375	70	.	.	.	.	.	.	.	.	76.3003	76.300	76.300	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:70	:16:4:6	ry:0:en:0
i2	86.625	0.375	70	.	.	.	.	.	.	.	.	121.1192	121.119	121.119	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:71	:17:G:6	ry:0:en:0
i2	87	0.375	70	.	.	.	.	.	.	.	.	70.6445	85.6442	70.644	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:72	:0:2:6	ry:0:en:0
i2	87.375	0.75	70	.	.	.	.	.	.	.	.	85.6442	85.644	85.644	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:73	:1:7:6	ry:0:en:0
i2	88.125	0.375	70	.	.	.	.	.	.	.	.	121.1192	82.4089	121.119	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:74	:2:G:6	ry:0:en:0
i2	88.5	2.25	70	.	.	.	.	.	.	.	.	82.4089	82.408	82.408	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:75	:3:6:6	ry:0:en:0
i2	90.75	0.375	0	.	.	.	.	.	.	.	.	92.5008	92.500	92.500	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:76	:4:9:6	ry:0:en:0
i2	91.125	0.375	70	.	.	.	.	.	.	.	.	89.0065	89.006	89.006	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:77	:5:8:6	ry:0:en:0
i2	91.5	3.75	70	.	.	.	.	.	.	.	.	79.2958	76.3003	76.3003	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:78	:6:5:6	ry:0:en:0
i2	95.25	3.375	0	.	.	.	.	.	.	.	.	76.3003	76.300	76.300	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:79	:7:4:6	ry:0:en:0
i2	98.625	0.375	70	.	.	.	.	.	.	.	.	99.9064	99.906	99.906	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:80	:8:B:6	ry:0:en:0
i2	99	0.375	70	.	.	.	.	.	.	.	.	96.1323	96.132	96.132	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:81	:9:A:6	ry:0:en:0
i2	99.375	0.375	70	.	.	.	.	.	.	.	.	125.8742	65.408	125.874	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:82	:10:H:6	ry:0:en:0
i2	99.75	0.375	70	.	.	.	.	.	.	.	.	65.408	65.408	65.408	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:83	:11:0:6	ry:0:en:0
i2	100.125	3.375	70	.	.	.	.	.	.	.	.	116.5438	116.543	116.543	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:84	:12:F:6	ry:0:en:0
i2	103.5	0.375	70	.	.	.	.	.	.	.	.	67.9758	73.4179	67.975	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:85	:13:1:6	ry:0:en:0
i2	103.875	2.25	70	.	.	.	.	.	.	.	.	73.4179	73.417	73.417	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:86	:14:3:6	ry:0:en:0
i2	106.125	4.125	70	.	.	.	.	.	.	.	.	107.9049	112.1412	112.1412	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:87	:15:D:6	ry:0:en:0
i2	110.25	0.375	70	.	.	.	.	.	.	.	.	112.1412	103.8287	103.8287	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:88	:16:E:6	ry:0:en:0
i2	110.625	0.375	70	.	.	.	.	.	.	.	.	103.8287	103.828	103.828	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:89	:17:C:6	ry:0:en:0
i2	111	0.375	70	.	.	.	.	.	.	.	.	125.8742	125.874	125.874	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:90	:0:H:6	ry:0:en:0
i2	111.375	0.375	70	.	.	.	.	.	.	.	.	121.1192	103.8287	121.119	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:91	:1:G:6	ry:0:en:0
i2	111.75	0.75	70	.	.	.	.	.	.	.	.	103.8287	103.828	103.828	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:92	:2:C:6	ry:0:en:0
i2	112.5	0.375	70	.	.	.	.	.	.	.	.	67.9758	73.4179	67.975	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:93	:3:1:6	ry:0:en:0
i2	112.875	1.5	70	.	.	.	.	.	.	.	.	73.4179	76.3003	73.417	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:94	:4:3:6	ry:0:en:0
i2	114.375	2.25	70	.	.	.	.	.	.	.	.	76.3003	85.6442	76.300	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:95	:5:4:6	ry:0:en:0
i2	116.625	4.5	70	.	.	.	.	.	.	.	.	85.6442	112.1412	85.644	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:96	:6:7:6	ry:0:en:0
i2	121.125	4.5	70	.	.	.	.	.	.	.	.	112.1412	112.141	112.141	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:97	:7:E:6	ry:0:en:0
i2	125.625	0.375	70	.	.	.	.	.	.	.	.	92.5008	82.4089	82.4089	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:98	:8:9:6	ry:0:en:0
i2	126	0.75	70	.	.	.	.	.	.	.	.	82.4089	82.408	82.408	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:99	:9:6:6	ry:0:en:0
i2	126.75	1.125	70	.	.	.	.	.	.	.	.	79.2958	79.295	79.295	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:100	:10:5:6	ry:0:en:0
i2	127.875	0.75	70	.	.	.	.	.	.	.	.	96.1323	96.132	96.132	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:101	:11:A:6	ry:0:en:0
i2	128.625	1.5	70	.	.	.	.	.	.	.	.	99.9064	70.6445	99.906	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:102	:12:B:6	ry:0:en:0
i2	130.125	1.125	70	.	.	.	.	.	.	.	.	70.6445	107.9049	70.644	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:103	:13:2:6	ry:0:en:0
i2	131.25	3.75	70	.	.	.	.	.	.	.	.	107.9049	107.904	107.904	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:104	:14:D:6	ry:0:en:0
i2	135	0.375	0	.	.	.	.	.	.	.	.	65.408	65.408	65.408	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:105	:15:0:6	ry:0:en:0
i2	135.375	0.375	0	.	.	.	.	.	.	.	.	116.5438	116.543	116.543	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:106	:16:F:6	ry:0:en:0
i2	135.75	0.375	70	.	.	.	.	.	.	.	.	89.0065	79.2958	89.006	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:107	:17:8:6	ry:0:en:0
i2	136.125	0.375	70	.	.	.	.	.	.	.	.	79.2958	79.295	79.295	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:108	:0:5:6	ry:0:en:0
i2	136.5	0.375	70	.	.	.	.	.	.	.	.	103.8287	103.828	103.828	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:109	:1:C:6	ry:0:en:0
i2	136.875	0.375	70	.	.	.	.	.	.	.	.	89.0065	70.6445	70.6445	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:110	:2:8:6	ry:0:en:0
i2	137.25	0.75	70	.	.	.	.	.	.	.	.	70.6445	70.644	70.644	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:111	:3:2:6	ry:0:en:0
i2	138	2.25	70	.	.	.	.	.	.	.	.	107.9049	107.904	107.904	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:112	:4:D:6	ry:0:en:0
i2	140.25	3.75	70	.	.	.	.	.	.	.	.	112.1412	112.141	112.141	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:113	:5:E:6	ry:0:en:0
i2	144	0.375	70	.	.	.	.	.	.	.	.	121.1192	121.119	121.119	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:114	:6:G:6	ry:0:en:0
i2	144.375	4.5	70	.	.	.	.	.	.	.	.	116.5438	116.543	116.543	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:115	:7:F:6	ry:0:en:0
i2	148.875	0.375	70	.	.	.	.	.	.	.	.	73.4179	67.9758	67.9758	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:116	:8:3:6	ry:0:en:0
i2	149.25	0.375	0	.	.	.	.	.	.	.	.	67.9758	67.975	67.975	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:117	:9:1:6	ry:0:en:0
i2	149.625	1.5	70	.	.	.	.	.	.	.	.	85.6442	85.644	85.644	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:118	:10:7:6	ry:0:en:0
i2	151.125	2.25	70	.	.	.	.	.	.	.	.	82.4089	82.408	82.408	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:119	:11:6:6	ry:0:en:0
i2	153.375	0.375	0	.	.	.	.	.	.	.	.	92.5008	92.500	92.500	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:120	:12:9:6	ry:0:en:0
i2	153.75	0.375	70	.	.	.	.	.	.	.	.	125.8742	125.874	125.874	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:121	:13:H:6	ry:0:en:0
i2	154.125	0.375	70	.	.	.	.	.	.	.	.	65.408	96.1323	96.1323	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:122	:14:0:6	ry:0:en:0
i2	154.5	1.5	70	.	.	.	.	.	.	.	.	96.1323	99.9064	96.132	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:123	:15:A:6	ry:0:en:0
i2	156	0.375	70	.	.	.	.	.	.	.	.	99.9064	76.3003	99.906	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:124	:16:B:6	ry:0:en:0
i2	156.375	0.375	70	.	.	.	.	.	.	.	.	76.3003	76.300	76.300	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:125	:17:4:6	ry:0:en:0
i2	156.75	0.375	70	.	.	.	.	.	.	.	.	85.6442	89.0065	85.644	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:126	:0:7:6	ry:0:en:0
i2	157.125	0.375	70	.	.	.	.	.	.	.	.	89.0065	89.006	89.006	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:127	:1:8:6	ry:0:en:0
i2	157.5	0.75	70	.	.	.	.	.	.	.	.	76.3003	76.300	76.300	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:128	:2:4:6	ry:0:en:0
i2	158.25	0.375	70	.	.	.	.	.	.	.	.	125.8742	65.408	65.408	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:129	:3:H:6	ry:0:en:0
i2	158.625	0.375	70	.	.	.	.	.	.	.	.	65.408	65.408	65.408	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:130	:4:0:6	ry:0:en:0
i2	159	4.125	70	.	.	.	.	.	.	.	.	116.5438	116.543	116.543	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:131	:5:F:6	ry:0:en:0
i2	163.125	3	70	.	.	.	.	.	.	.	.	103.8287	103.828	103.828	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:132	:6:C:6	ry:0:en:0
i2	166.125	2.625	70	.	.	.	.	.	.	.	.	99.9064	107.9049	107.9049	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:133	:7:B:6	ry:0:en:0
i2	168.75	0.375	0	.	.	.	.	.	.	.	.	107.9049	107.904	107.904	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:134	:8:D:6	ry:0:en:0
i2	169.125	0.375	70	.	.	.	.	.	.	.	.	70.6445	70.644	70.644	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:135	:9:2:6	ry:0:en:0
i2	169.5	0.375	70	.	.	.	.	.	.	.	.	121.1192	67.9758	67.9758	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:136	:10:G:6	ry:0:en:0
i2	169.875	0.375	70	.	.	.	.	.	.	.	.	67.9758	67.975	67.975	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:137	:11:1:6	ry:0:en:0
i2	170.25	1.5	70	.	.	.	.	.	.	.	.	73.4179	73.417	73.417	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:138	:12:3:6	ry:0:en:0
i2	171.75	3	0	.	.	.	.	.	.	.	.	79.2958	79.295	79.295	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:139	:13:5:6	ry:0:en:0
i2	174.75	1.5	70	.	.	.	.	.	.	.	.	96.1323	96.132	96.132	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:140	:14:A:6	ry:0:en:0
i2	176.25	4.5	70	.	.	.	.	.	.	.	.	82.4089	92.5008	92.5008	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:141	:15:6:6	ry:0:en:0
i2	180.75	0.375	70	.	.	.	.	.	.	.	.	92.5008	92.500	92.500	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:142	:16:9:6	ry:0:en:0
i2	181.125	0.75	70	.	.	.	.	.	.	.	.	112.1412	112.141	112.141	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:143	:17:E:6	ry:0:en:0
i2	181.875	0.375	70	.	.	.	.	.	.	.	.	121.1192	121.119	121.119	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:144	:0:G:6	ry:0:en:0
i2	182.25	0.375	70	.	.	.	.	.	.	.	.	76.3003	76.300	76.300	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:145	:1:4:6	ry:0:en:0
i2	182.625	1.5	70	.	.	.	.	.	.	.	.	112.1412	112.141	112.141	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:146	:2:E:6	ry:0:en:0
i2	184.125	1.875	70	.	.	.	.	.	.	.	.	79.2958	79.295	79.295	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:147	:3:5:6	ry:0:en:0
i2	186	0.75	0	.	.	.	.	.	.	.	.	96.1323	96.132	96.132	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:148	:4:A:6	ry:0:en:0
i2	186.75	1.875	70	.	.	.	.	.	.	.	.	99.9064	89.0065	99.906	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:149	:5:B:6	ry:0:en:0
i2	188.625	0.375	70	.	.	.	.	.	.	.	.	89.0065	89.006	89.006	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:150	:6:8:6	ry:0:en:0
i2	189	0.75	70	.	.	.	.	.	.	.	.	92.5008	92.500	92.500	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:151	:7:9:6	ry:0:en:0
i2	189.75	0.375	70	.	.	.	.	.	.	.	.	65.408	65.408	65.408	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:152	:8:0:6	ry:0:en:0
i2	190.125	0.375	70	.	.	.	.	.	.	.	.	125.8742	125.874	125.874	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:153	:9:H:6	ry:0:en:0
i2	190.5	0.75	0	.	.	.	.	.	.	.	.	103.8287	70.6445	70.6445	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:154	:10:C:6	ry:0:en:0
i2	191.25	0.75	70	.	.	.	.	.	.	.	.	70.6445	70.644	70.644	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:155	:11:2:6	ry:0:en:0
i2	192	2.25	70	.	.	.	.	.	.	.	.	107.9049	107.904	107.904	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:156	:12:D:6	ry:0:en:0
i2	194.25	4.125	70	.	.	.	.	.	.	.	.	85.6442	85.644	85.644	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:157	:13:7:6	ry:0:en:0
i2	198.375	4.5	70	.	.	.	.	.	.	.	.	82.4089	82.408	82.408	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:158	:14:6:6	ry:0:en:0
i2	202.875	0.75	70	.	.	.	.	.	.	.	.	67.9758	67.975	67.975	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:159	:15:1:6	ry:0:en:0
i2	203.625	0.375	70	.	.	.	.	.	.	.	.	73.4179	116.5438	116.5438	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:160	:16:3:6	ry:0:en:0
i2	204	0.75	70	.	.	.	.	.	.	.	.	116.5438	103.8287	116.543	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:161	:17:F:6	ry:0:en:0
i2	204.75	0.375	70	.	.	.	.	.	.	.	.	103.8287	112.1412	103.828	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:162	:0:C:6	ry:0:en:0
i2	205.125	0.75	0	.	.	.	.	.	.	.	.	112.1412	112.141	112.141	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:163	:1:E:6	ry:0:en:0
i2	205.875	1.5	70	.	.	.	.	.	.	.	.	116.5438	116.543	116.543	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:164	:2:F:6	ry:0:en:0
i2	207.375	2.625	70	.	.	.	.	.	.	.	.	85.6442	82.4089	82.4089	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:165	:3:7:6	ry:0:en:0
i2	210	3	70	.	.	.	.	.	.	.	.	82.4089	82.408	82.408	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:166	:4:6:6	ry:0:en:0
i2	213	0.375	70	.	.	.	.	.	.	.	.	92.5008	92.500	92.500	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:167	:5:9:6	ry:0:en:0
i2	213.375	3	70	.	.	.	.	.	.	.	.	76.3003	76.300	76.300	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:168	:6:4:6	ry:0:en:0
i2	216.375	2.625	70	.	.	.	.	.	.	.	.	73.4179	73.417	73.417	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:169	:7:3:6	ry:0:en:0
i2	219	0.375	70	.	.	.	.	.	.	.	.	96.1323	96.132	96.132	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:170	:8:A:6	ry:0:en:0
i2	219.375	0.375	70	.	.	.	.	.	.	.	.	79.2958	89.0065	79.295	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:171	:9:5:6	ry:0:en:0
i2	219.75	0.375	70	.	.	.	.	.	.	.	.	89.0065	89.006	89.006	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:172	:10:8:6	ry:0:en:0
i2	220.125	0.375	70	.	.	.	.	.	.	.	.	125.8742	125.874	125.874	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:173	:11:H:6	ry:0:en:0
i2	220.5	0.375	70	.	.	.	.	.	.	.	.	65.408	121.1192	121.1192	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:174	:12:0:6	ry:0:en:0
i2	220.875	0.375	70	.	.	.	.	.	.	.	.	121.1192	67.9758	121.119	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:175	:13:G:6	ry:0:en:0
i2	221.25	0.75	0	.	.	.	.	.	.	.	.	67.9758	67.975	67.975	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:176	:14:1:6	ry:0:en:0
i2	222	1.5	70	.	.	.	.	.	.	.	.	70.6445	107.9049	70.644	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:177	:15:2:6	ry:0:en:0
i2	223.5	0.375	70	.	.	.	.	.	.	.	.	107.9049	107.904	107.904	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:178	:16:D:6	ry:0:en:0
i2	223.875	0.375	70	.	.	.	.	.	.	.	.	99.9064	99.906	99.906	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:179	:17:B:6	ry:0:en:0
i2	224.25	0.375	70	.	.	.	.	.	.	.	.	89.0065	89.006	89.006	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:180	:0:8:6	ry:0:en:0
i2	224.625	0.75	70	.	.	.	.	.	.	.	.	116.5438	116.543	116.543	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:181	:1:F:6	ry:0:en:0
i2	225.375	0.75	70	.	.	.	.	.	.	.	.	99.9064	99.906	99.906	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:182	:2:B:6	ry:0:en:0
i2	226.125	0.375	70	.	.	.	.	.	.	.	.	121.1192	121.119	121.119	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:183	:3:G:6	ry:0:en:0
i2	226.5	0.375	70	.	.	.	.	.	.	.	.	67.9758	73.4179	67.975	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:184	:4:1:6	ry:0:en:0
i2	226.875	1.875	70	.	.	.	.	.	.	.	.	73.4179	112.1412	73.417	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:185	:5:3:6	ry:0:en:0
i2	228.75	4.5	70	.	.	.	.	.	.	.	.	112.1412	112.141	112.141	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:186	:6:E:6	ry:0:en:0
i2	233.25	4.125	70	.	.	.	.	.	.	.	.	107.9049	82.4089	107.904	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:187	:7:D:6	ry:0:en:0
i2	237.375	0.375	70	.	.	.	.	.	.	.	.	82.4089	82.408	82.408	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:188	:8:6:6	ry:0:en:0
i2	237.75	0.75	70	.	.	.	.	.	.	.	.	85.6442	85.644	85.644	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:189	:9:7:6	ry:0:en:0
i2	238.5	0.75	70	.	.	.	.	.	.	.	.	76.3003	76.300	76.300	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:190	:10:4:6	ry:0:en:0
i2	239.25	1.875	70	.	.	.	.	.	.	.	.	79.2958	79.295	79.295	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:191	:11:5:6	ry:0:en:0
i2	241.125	0.75	70	.	.	.	.	.	.	.	.	96.1323	96.132	96.132	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:192	:12:A:6	ry:0:en:0
i2	241.875	2.25	70	.	.	.	.	.	.	.	.	103.8287	103.828	103.828	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:193	:13:C:6	ry:0:en:0
i2	244.125	1.5	70	.	.	.	.	.	.	.	.	70.6445	70.644	70.644	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:194	:14:2:6	ry:0:en:0
i2	245.625	0.75	0	.	.	.	.	.	.	.	.	125.8742	65.408	65.408	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:195	:15:H:6	ry:0:en:0
i2	246.375	0.375	70	.	.	.	.	.	.	.	.	65.408	65.408	65.408	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:196	:16:0:6	ry:0:en:0
i2	246.75	0.375	0	.	.	.	.	.	.	.	.	92.5008	92.500	92.500	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:197	:17:9:6	ry:0:en:0
i2	247.125	0.375	70	.	.	.	.	.	.	.	.	76.3003	76.300	76.300	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:198	:0:4:6	ry:0:en:0
i2	247.5	0.375	70	.	.	.	.	.	.	.	.	99.9064	99.906	99.906	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:199	:1:B:6	ry:0:en:0
i2	247.875	0.375	70	.	.	.	.	.	.	.	.	92.5008	92.500	92.500	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:200	:2:9:6	ry:0:en:0
i2	248.25	1.5	70	.	.	.	.	.	.	.	.	103.8287	103.828	103.828	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:201	:3:C:6	ry:0:en:0
i2	249.75	0.75	70	.	.	.	.	.	.	.	.	70.6445	107.9049	107.9049	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:202	:4:2:6	ry:0:en:0
i2	250.5	3	70	.	.	.	.	.	.	.	.	107.9049	107.904	107.904	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:203	:5:D:6	ry:0:en:0
i2	253.5	4.5	70	.	.	.	.	.	.	.	.	116.5438	65.408	116.543	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:204	:6:F:6	ry:0:en:0
i2	258	0.375	0	.	.	.	.	.	.	.	.	65.408	65.408	65.408	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:205	:7:0:6	ry:0:en:0
i2	258.375	0.375	70	.	.	.	.	.	.	.	.	67.9758	67.975	67.975	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:206	:8:1:6	ry:0:en:0
i2	258.75	0.375	70	.	.	.	.	.	.	.	.	121.1192	121.119	121.119	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:207	:9:G:6	ry:0:en:0
i2	259.125	1.5	70	.	.	.	.	.	.	.	.	112.1412	112.141	112.141	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:208	:10:E:6	ry:0:en:0
i2	260.625	2.625	0	.	.	.	.	.	.	.	.	85.6442	82.4089	85.644	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:209	:11:7:6	ry:0:en:0
i2	263.25	3	70	.	.	.	.	.	.	.	.	82.4089	82.408	82.408	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:210	:12:6:6	ry:0:en:0
i2	266.25	0.375	70	.	.	.	.	.	.	.	.	89.0065	89.006	89.006	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:211	:13:8:6	ry:0:en:0
i2	266.625	0.75	70	.	.	.	.	.	.	.	.	125.8742	79.2958	125.874	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:212	:14:H:6	ry:0:en:0
i2	267.375	4.125	70	.	.	.	.	.	.	.	.	79.2958	79.295	79.295	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:213	:15:5:6	ry:0:en:0
i2	271.5	0.375	70	.	.	.	.	.	.	.	.	96.1323	96.132	96.132	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:214	:16:A:6	ry:0:en:0
i2	271.875	0.375	70	.	.	.	.	.	.	.	.	73.4179	112.1412	73.417	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:215	:17:3:6	ry:0:en:0
i2	272.25	0.375	70	.	.	.	.	.	.	.	.	112.1412	92.5008	92.5008	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:216	:0:E:6	ry:0:en:0
i2	272.625	0.375	70	.	.	.	.	.	.	.	.	92.5008	92.500	92.500	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:217	:1:9:6	ry:0:en:0
i2	273	0.75	70	.	.	.	.	.	.	.	.	73.4179	89.0065	89.0065	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:218	:2:3:6	ry:0:en:0
i2	273.75	0.375	70	.	.	.	.	.	.	.	.	89.0065	89.006	89.006	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:219	:3:8:6	ry:0:en:0
i2	274.125	0.375	70	.	.	.	.	.	.	.	.	125.8742	125.874	125.874	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:220	:4:H:6	ry:0:en:0
i2	274.5	0.375	70	.	.	.	.	.	.	.	.	65.408	65.408	65.408	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:221	:5:0:6	ry:0:en:0
i2	274.875	2.25	70	.	.	.	.	.	.	.	.	99.9064	99.906	99.906	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:222	:6:B:6	ry:0:en:0
i2	277.125	1.5	70	.	.	.	.	.	.	.	.	96.1323	70.6445	96.132	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:223	:7:A:6	ry:0:en:0
i2	278.625	0.375	70	.	.	.	.	.	.	.	.	70.6445	70.644	70.644	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:224	:8:2:6	ry:0:en:0
i2	279	0.375	0	.	.	.	.	.	.	.	.	103.8287	103.828	103.828	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:225	:9:C:6	ry:0:en:0
i2	279.375	1.5	70	.	.	.	.	.	.	.	.	116.5438	116.543	116.543	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:226	:10:F:6	ry:0:en:0
i2	280.875	0.375	70	.	.	.	.	.	.	.	.	121.1192	121.119	121.119	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:227	:11:G:6	ry:0:en:0
i2	281.25	0.375	0	.	.	.	.	.	.	.	.	67.9758	67.975	67.975	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:228	:12:1:6	ry:0:en:0
i2	281.625	2.25	70	.	.	.	.	.	.	.	.	76.3003	76.300	76.300	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:229	:13:4:6	ry:0:en:0
i2	283.875	3.75	70	.	.	.	.	.	.	.	.	79.2958	85.6442	85.6442	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:230	:14:5:6	ry:0:en:0
i2	287.625	4.5	70	.	.	.	.	.	.	.	.	85.6442	82.4089	85.644	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:231	:15:7:6	ry:0:en:0
i2	292.125	0.375	70	.	.	.	.	.	.	.	.	82.4089	82.408	82.408	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:232	:16:6:6	ry:0:en:0
i2	292.5	0.375	70	.	.	.	.	.	.	.	.	107.9049	116.5438	116.5438	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:233	:17:D:6	ry:0:en:0
i2	292.875	0.375	70	.	.	.	.	.	.	.	.	116.5438	116.543	116.543	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:234	:0:F:6	ry:0:en:0
i2	293.25	0.375	70	.	.	.	.	.	.	.	.	73.4179	73.417	73.417	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:235	:1:3:6	ry:0:en:0
i2	293.625	1.125	70	.	.	.	.	.	.	.	.	107.9049	76.3003	76.3003	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:236	:2:D:6	ry:0:en:0
i2	294.75	1.5	0	.	.	.	.	.	.	.	.	76.3003	76.300	76.300	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:237	:3:4:6	ry:0:en:0
i2	296.25	2.25	0	.	.	.	.	.	.	.	.	79.2958	79.295	79.295	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:238	:4:5:6	ry:0:en:0
i2	298.5	1.125	70	.	.	.	.	.	.	.	.	96.1323	96.132	96.132	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:239	:5:A:6	ry:0:en:0
i2	299.625	0.75	70	.	.	.	.	.	.	.	.	92.5008	92.500	92.500	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:240	:6:9:6	ry:0:en:0
i2	300.375	4.5	70	.	.	.	.	.	.	.	.	82.4089	82.408	82.408	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:241	:7:6:6	ry:0:en:0
i2	304.875	0.375	70	.	.	.	.	.	.	.	.	125.8742	125.874	125.874	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:242	:8:H:6	ry:0:en:0
i2	305.25	0.375	70	.	.	.	.	.	.	.	.	89.0065	89.006	89.006	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:243	:9:8:6	ry:0:en:0
i2	305.625	0.75	70	.	.	.	.	.	.	.	.	99.9064	99.906	99.906	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:244	:10:B:6	ry:0:en:0
i2	306.375	1.5	70	.	.	.	.	.	.	.	.	103.8287	103.828	103.828	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:245	:11:C:6	ry:0:en:0
i2	307.875	0.75	70	.	.	.	.	.	.	.	.	70.6445	70.644	70.644	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:246	:12:2:6	ry:0:en:0
i2	308.625	3.75	70	.	.	.	.	.	.	.	.	112.1412	112.141	112.141	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:247	:13:E:6	ry:0:en:0
i2	312.375	4.5	70	.	.	.	.	.	.	.	.	85.6442	85.644	85.644	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:248	:14:7:6	ry:0:en:0
i2	316.875	0.375	70	.	.	.	.	.	.	.	.	121.1192	67.9758	121.119	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:249	:15:G:6	ry:0:en:0
i2	317.25	0.375	70	.	.	.	.	.	.	.	.	67.9758	67.975	67.975	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:250	:16:1:6	ry:0:en:0
i2	317.625	0.375	70	.	.	.	.	.	.	.	.	65.408	99.9064	65.408	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:251	:17:0:6	ry:0:en:0
i2	318	0.375	70	.	.	.	.	.	.	.	.	99.9064	99.906	99.906	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:252	:0:B:6	ry:0:en:0
i2	318.375	0.375	70	.	.	.	.	.	.	.	.	107.9049	65.408	107.904	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:253	:1:D:6	ry:0:en:0
i2	318.75	0.375	70	.	.	.	.	.	.	.	.	65.408	65.408	65.408	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:254	:2:0:6	ry:0:en:0
i2	319.125	2.25	70	.	.	.	.	.	.	.	.	112.1412	112.141	112.141	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:255	:3:E:6	ry:0:en:0
i2	321.375	3.375	70	.	.	.	.	.	.	.	.	85.6442	82.4089	85.644	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:256	:4:7:6	ry:0:en:0
i2	324.75	3.75	70	.	.	.	.	.	.	.	.	82.4089	73.4179	82.408	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:257	:5:6:6	ry:0:en:0
i2	328.5	2.25	70	.	.	.	.	.	.	.	.	73.4179	73.417	73.417	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:258	:6:3:6	ry:0:en:0
i2	330.75	0.75	70	.	.	.	.	.	.	.	.	67.9758	67.975	67.975	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:259	:7:1:6	ry:0:en:0
i2	331.5	0.375	70	.	.	.	.	.	.	.	.	79.2958	79.295	79.295	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:260	:8:5:6	ry:0:en:0
i2	331.875	0.375	70	.	.	.	.	.	.	.	.	76.3003	92.5008	76.300	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:261	:9:4:6	ry:0:en:0
i2	332.25	0.375	70	.	.	.	.	.	.	.	.	92.5008	92.500	92.500	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:262	:10:9:6	ry:0:en:0
i2	332.625	0.375	70	.	.	.	.	.	.	.	.	89.0065	89.006	89.006	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:263	:11:8:6	ry:0:en:0
i2	333	0.375	70	.	.	.	.	.	.	.	.	125.8742	125.874	125.874	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:264	:12:H:6	ry:0:en:0
i2	333.375	4.125	0	.	.	.	.	.	.	.	.	116.5438	116.543	116.543	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:265	:13:F:6	ry:0:en:0
i2	337.5	0.375	70	.	.	.	.	.	.	.	.	121.1192	121.119	121.119	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:266	:14:G:6	ry:0:en:0
i2	337.875	3.375	0	.	.	.	.	.	.	.	.	103.8287	103.828	103.828	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:267	:15:C:6	ry:0:en:0
i2	341.25	0.375	70	.	.	.	.	.	.	.	.	70.6445	96.1323	70.644	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:268	:16:2:6	ry:0:en:0
i2	341.625	0.375	70	.	.	.	.	.	.	.	.	96.1323	96.132	96.132	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:269	:17:A:6	ry:0:en:0
i2	342	0.375	0	.	.	.	.	.	.	.	.	92.5008	65.408	92.500	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:270	:0:9:6	ry:0:en:0
i2	342.375	0.375	70	.	.	.	.	.	.	.	.	65.408	96.1323	65.408	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:271	:1:0:6	ry:0:en:0
i2	342.75	0.375	70	.	.	.	.	.	.	.	.	96.1323	96.132	96.132	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:272	:2:A:6	ry:0:en:0
i2	343.125	2.625	70	.	.	.	.	.	.	.	.	116.5438	116.543	116.543	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:273	:3:F:6	ry:0:en:0
i2	345.75	0.375	70	.	.	.	.	.	.	.	.	121.1192	121.119	121.119	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:274	:4:G:6	ry:0:en:0
i2	346.125	0.375	70	.	.	.	.	.	.	.	.	67.9758	67.975	67.975	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:275	:5:1:6	ry:0:en:0
i2	346.5	3.75	70	.	.	.	.	.	.	.	.	107.9049	107.904	107.904	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:276	:6:D:6	ry:0:en:0
i2	350.25	1.5	70	.	.	.	.	.	.	.	.	70.6445	70.644	70.644	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:277	:7:2:6	ry:0:en:0
i2	351.75	0.375	70	.	.	.	.	.	.	.	.	85.6442	85.644	85.644	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:278	:8:7:6	ry:0:en:0
i2	352.125	0.75	0	.	.	.	.	.	.	.	.	112.1412	73.4179	73.4179	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:279	:9:E:6	ry:0:en:0
i2	352.875	0.75	70	.	.	.	.	.	.	.	.	73.4179	73.417	73.417	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:280	:10:3:6	ry:0:en:0
i2	353.625	1.5	70	.	.	.	.	.	.	.	.	76.3003	76.300	76.300	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:281	:11:4:6	ry:0:en:0
i2	355.125	2.25	70	.	.	.	.	.	.	.	.	79.2958	99.9064	99.9064	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:282	:12:5:6	ry:0:en:0
i2	357.375	1.875	70	.	.	.	.	.	.	.	.	99.9064	99.906	99.906	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:283	:13:B:6	ry:0:en:0
i2	359.25	3	70	.	.	.	.	.	.	.	.	103.8287	103.828	103.828	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:284	:14:C:6	ry:0:en:0
i2	362.25	0.375	70	.	.	.	.	.	.	.	.	89.0065	89.006	89.006	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:285	:15:8:6	ry:0:en:0
i2	362.625	0.375	70	.	.	.	.	.	.	.	.	125.8742	125.874	125.874	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:286	:16:H:6	ry:0:en:0
i2	363	0.75	70	.	.	.	.	.	.	.	.	82.4089	73.4179	82.408	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:287	:17:6:6	ry:0:en:0
i2	363.75	0.375	70	.	.	.	.	.	.	.	.	73.4179	73.417	73.417	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:288	:0:3:6	ry:0:en:0
i2	364.125	0.375	70	.	.	.	.	.	.	.	.	96.1323	82.4089	96.132	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:289	:1:A:6	ry:0:en:0
i2	364.5	1.5	70	.	.	.	.	.	.	.	.	82.4089	99.9064	82.408	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:290	:2:6:6	ry:0:en:0
i2	366	1.125	70	.	.	.	.	.	.	.	.	99.9064	99.906	99.906	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:291	:3:B:6	ry:0:en:0
i2	367.125	1.875	70	.	.	.	.	.	.	.	.	103.8287	70.6445	103.828	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:292	:4:C:6	ry:0:en:0
i2	369	1.125	70	.	.	.	.	.	.	.	.	70.6445	65.408	65.408	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:293	:5:2:6	ry:0:en:0
i2	370.125	0.375	70	.	.	.	.	.	.	.	.	65.408	65.408	65.408	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:294	:6:0:6	ry:0:en:0
i2	370.5	0.75	70	.	.	.	.	.	.	.	.	125.8742	125.874	125.874	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:295	:7:H:6	ry:0:en:0
i2	371.25	0.375	70	.	.	.	.	.	.	.	.	121.1192	121.119	121.119	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:296	:8:G:6	ry:0:en:0
i2	371.625	0.75	70	.	.	.	.	.	.	.	.	116.5438	116.543	116.543	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:297	:9:F:6	ry:0:en:0
i2	372.375	1.125	0	.	.	.	.	.	.	.	.	107.9049	107.904	107.904	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:298	:10:D:6	ry:0:en:0
i2	373.5	2.25	70	.	.	.	.	.	.	.	.	112.1412	112.141	112.141	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:299	:11:E:6	ry:0:en:0
i2	375.75	3.375	70	.	.	.	.	.	.	.	.	85.6442	92.5008	85.644	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:300	:12:7:6	ry:0:en:0
i2	379.125	0.375	0	.	.	.	.	.	.	.	.	92.5008	89.0065	89.0065	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:301	:13:9:6	ry:0:en:0
i2	379.5	0.375	70	.	.	.	.	.	.	.	.	89.0065	89.006	89.006	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:302	:14:8:6	ry:0:en:0
i2	379.875	3.375	70	.	.	.	.	.	.	.	.	76.3003	76.300	76.300	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:303	:15:4:6	ry:0:en:0
i2	383.25	0.375	70	.	.	.	.	.	.	.	.	79.2958	79.295	79.295	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:304	:16:5:6	ry:0:en:0
i2	383.625	0.375	70	.	.	.	.	.	.	.	.	67.9758	67.975	67.975	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:305	:17:1:6	ry:0:en:0
i2	384	0.375	70	.	.	.	.	.	.	.	.	107.9049	82.4089	107.904	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:306	:0:D:6	ry:0:en:0
i2	384.375	0.75	70	.	.	.	.	.	.	.	.	82.4089	67.9758	82.408	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:307	:1:6:6	ry:0:en:0
i2	385.125	0.375	70	.	.	.	.	.	.	.	.	67.9758	92.5008	92.5008	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:308	:2:1:6	ry:0:en:0
i2	385.5	0.375	70	.	.	.	.	.	.	.	.	92.5008	92.500	92.500	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:309	:3:9:6	ry:0:en:0
i2	385.875	0.375	70	.	.	.	.	.	.	.	.	89.0065	89.006	89.006	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:310	:4:8:6	ry:0:en:0
i2	386.25	0.375	70	.	.	.	.	.	.	.	.	125.8742	125.874	125.874	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:311	:5:H:6	ry:0:en:0
i2	386.625	1.5	0	.	.	.	.	.	.	.	.	96.1323	79.2958	96.132	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:312	:6:A:6	ry:0:en:0
i2	388.125	4.125	70	.	.	.	.	.	.	.	.	79.2958	79.295	79.295	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:313	:7:5:6	ry:0:en:0
i2	392.25	0.375	70	.	.	.	.	.	.	.	.	103.8287	103.828	103.828	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:314	:8:C:6	ry:0:en:0
i2	392.625	0.375	70	.	.	.	.	.	.	.	.	99.9064	99.906	99.906	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:315	:9:B:6	ry:0:en:0
i2	393	0.375	0	.	.	.	.	.	.	.	.	65.408	65.408	65.408	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:316	:10:0:6	ry:0:en:0
i2	393.375	2.625	70	.	.	.	.	.	.	.	.	116.5438	116.543	116.543	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:317	:11:F:6	ry:0:en:0
i2	396	0.375	70	.	.	.	.	.	.	.	.	121.1192	121.119	121.119	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:318	:12:G:6	ry:0:en:0
i2	396.375	1.875	70	.	.	.	.	.	.	.	.	73.4179	76.3003	76.3003	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:319	:13:3:6	ry:0:en:0
i2	398.25	3	70	.	.	.	.	.	.	.	.	76.3003	76.300	76.300	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:320	:14:4:6	ry:0:en:0
i2	401.25	4.5	70	.	.	.	.	.	.	.	.	112.1412	112.141	112.141	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:321	:15:E:6	ry:0:en:0
i2	405.75	0.375	70	.	.	.	.	.	.	.	.	85.6442	85.644	85.644	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:322	:16:7:6	ry:0:en:0
i2	406.125	0.375	70	.	.	.	.	.	.	.	.	70.6445	70.644	70.644	0.3	0.7	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_2:323	:17:2:6	ry:0:en:0

; Seq_3 comments: Gradual of the opposite (O) for a soprano.
;ins	sta	dur	amp	ft1	aty	atk	rel	hd1	hd2	gl1	gl2	fq1	fq2	fq3	pa1	pa2	del	car	mod	hm1	hm2	cro	buz	rvn	rvs	ft2	pcd	
i3	0	0.375	70	11	0	0.2	0.9	0.25	0.25	0.25	0.25	158.5916	207.6574	158.591	0.7	0.3	0.3	1	1	4	0	0	0	0	0	24	1	;Sec:0:Seq_3:0	:0:5:7	ry:0:en:0
i3	0.375	0.375	70	.	.	.	.	.	.	.	.	207.6574	207.657	207.657	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:1	:1:C:7	ry:0:en:0
i3	0.75	0.75	70	.	.	.	.	.	.	.	.	199.8129	199.812	199.812	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:2	:2:B:7	ry:0:en:0
i3	1.5	2.625	70	.	.	.	.	.	.	.	.	233.0876	233.087	233.087	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:3	:3:F:7	ry:0:en:0
i3	4.125	0.375	70	.	.	.	.	.	.	.	.	130.816	178.0131	130.816	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:4	:4:0:7	ry:0:en:0
i3	4.5	0.375	70	.	.	.	.	.	.	.	.	178.0131	185.0017	178.013	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:5	:5:8:7	ry:0:en:0
i3	4.875	0.75	70	.	.	.	.	.	.	.	.	185.0017	185.001	185.001	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:6	:6:9:7	ry:0:en:0
i3	5.625	4.5	0	.	.	.	.	.	.	.	.	164.8178	164.817	164.817	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:7	:7:6:7	ry:0:en:0
i3	10.125	0.375	70	.	.	.	.	.	.	.	.	146.8359	146.835	146.835	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:8	:8:3:7	ry:0:en:0
i3	10.5	0.375	70	.	.	.	.	.	.	.	.	152.6006	152.600	152.600	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:9	:9:4:7	ry:0:en:0
i3	10.875	0.375	70	.	.	.	.	.	.	.	.	242.2384	135.9517	242.238	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:10	:10:G:7	ry:0:en:0
i3	11.25	0.375	70	.	.	.	.	.	.	.	.	135.9517	135.951	135.951	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:11	:11:1:7	ry:0:en:0
i3	11.625	3.375	0	.	.	.	.	.	.	.	.	171.2884	171.288	171.288	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:12	:12:7:7	ry:0:en:0
i3	15	3.75	70	.	.	.	.	.	.	.	.	224.2824	224.282	224.282	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:13	:13:E:7	ry:0:en:0
i3	18.75	3.75	70	.	.	.	.	.	.	.	.	215.8099	215.809	215.809	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:14	:14:D:7	ry:0:en:0
i3	22.5	0.75	70	.	.	.	.	.	.	.	.	251.7485	251.748	251.748	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:15	:15:H:7	ry:0:en:0
i3	23.25	0.375	70	.	.	.	.	.	.	.	.	141.2890	192.2647	141.289	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:16	:16:2:7	ry:0:en:0
i3	23.625	0.375	70	.	.	.	.	.	.	.	.	192.2647	192.264	192.264	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:17	:17:A:7	ry:0:en:0
i3	24	0.375	70	.	.	.	.	.	.	.	.	158.5916	207.6574	158.591	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:18	:0:5:7	ry:0:en:0
i3	24.375	0.375	70	.	.	.	.	.	.	.	.	207.6574	207.657	207.657	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:19	:1:C:7	ry:0:en:0
i3	24.75	0.75	70	.	.	.	.	.	.	.	.	199.8129	199.812	199.812	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:20	:2:B:7	ry:0:en:0
i3	25.5	2.625	70	.	.	.	.	.	.	.	.	233.0876	233.087	233.087	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:21	:3:F:7	ry:0:en:0
i3	28.125	0.375	70	.	.	.	.	.	.	.	.	130.816	178.0131	130.816	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:22	:4:0:7	ry:0:en:0
i3	28.5	0.375	70	.	.	.	.	.	.	.	.	178.0131	185.0017	178.013	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:23	:5:8:7	ry:0:en:0
i3	28.875	0.75	70	.	.	.	.	.	.	.	.	185.0017	185.001	185.001	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:24	:6:9:7	ry:0:en:0
i3	29.625	4.5	0	.	.	.	.	.	.	.	.	164.8178	164.817	164.817	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:25	:7:6:7	ry:0:en:0
i3	34.125	0.375	70	.	.	.	.	.	.	.	.	146.8359	146.835	146.835	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:26	:8:3:7	ry:0:en:0
i3	34.5	0.375	70	.	.	.	.	.	.	.	.	152.6006	152.600	152.600	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:27	:9:4:7	ry:0:en:0
i3	34.875	0.375	70	.	.	.	.	.	.	.	.	242.2384	135.9517	242.238	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:28	:10:G:7	ry:0:en:0
i3	35.25	0.375	70	.	.	.	.	.	.	.	.	135.9517	135.951	135.951	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:29	:11:1:7	ry:0:en:0
i3	35.625	3.375	0	.	.	.	.	.	.	.	.	171.2884	171.288	171.288	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:30	:12:7:7	ry:0:en:0
i3	39	3.75	70	.	.	.	.	.	.	.	.	224.2824	224.282	224.282	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:31	:13:E:7	ry:0:en:0
i3	42.75	3.75	70	.	.	.	.	.	.	.	.	215.8099	215.809	215.809	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:32	:14:D:7	ry:0:en:0
i3	46.5	0.75	70	.	.	.	.	.	.	.	.	251.7485	251.748	251.748	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:33	:15:H:7	ry:0:en:0
i3	47.25	0.375	70	.	.	.	.	.	.	.	.	141.2890	192.2647	141.289	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:34	:16:2:7	ry:0:en:0
i3	47.625	0.375	70	.	.	.	.	.	.	.	.	192.2647	192.264	192.264	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:35	:17:A:7	ry:0:en:0
i3	48	0.375	70	.	.	.	.	.	.	.	.	178.0131	171.2884	178.013	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:36	:0:8:7	ry:0:en:0
i3	48.375	0.75	70	.	.	.	.	.	.	.	.	171.2884	171.288	171.288	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:37	:1:7:7	ry:0:en:0
i3	49.125	0.375	70	.	.	.	.	.	.	.	.	135.9517	135.951	135.951	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:38	:2:1:7	ry:0:en:0
i3	49.5	0.375	70	.	.	.	.	.	.	.	.	251.7485	251.748	251.748	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:39	:3:H:7	ry:0:en:0
i3	49.875	2.25	70	.	.	.	.	.	.	.	.	158.5916	158.591	158.591	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:40	:4:5:7	ry:0:en:0
i3	52.125	1.875	70	.	.	.	.	.	.	.	.	146.8359	146.835	146.835	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:41	:5:3:7	ry:0:en:0
i3	54	3	70	.	.	.	.	.	.	.	.	152.6006	152.600	152.600	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:42	:6:4:7	ry:0:en:0
i3	57	0.75	0	.	.	.	.	.	.	.	.	185.0017	185.001	185.001	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:43	:7:9:7	ry:0:en:0
i3	57.75	0.375	70	.	.	.	.	.	.	.	.	233.0876	130.816	130.816	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:44	:8:F:7	ry:0:en:0
i3	58.125	0.375	0	.	.	.	.	.	.	.	.	130.816	130.816	130.816	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:45	:9:0:7	ry:0:en:0
i3	58.5	0.375	70	.	.	.	.	.	.	.	.	141.2890	141.289	141.289	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:46	:10:2:7	ry:0:en:0
i3	58.875	1.5	70	.	.	.	.	.	.	.	.	207.6574	164.8178	207.657	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:47	:11:C:7	ry:0:en:0
i3	60.375	3	70	.	.	.	.	.	.	.	.	164.8178	215.8099	164.817	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:48	:12:6:7	ry:0:en:0
i3	63.375	3	70	.	.	.	.	.	.	.	.	215.8099	224.2824	215.809	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:49	:13:D:7	ry:0:en:0
i3	66.375	4.5	70	.	.	.	.	.	.	.	.	224.2824	224.282	224.282	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:50	:14:E:7	ry:0:en:0
i3	70.875	1.5	70	.	.	.	.	.	.	.	.	192.2647	199.8129	192.264	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:51	:15:A:7	ry:0:en:0
i3	72.375	0.375	70	.	.	.	.	.	.	.	.	199.8129	199.812	199.812	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:52	:16:B:7	ry:0:en:0
i3	72.75	0.375	70	.	.	.	.	.	.	.	.	242.2384	242.238	242.238	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:53	:17:G:7	ry:0:en:0
i3	73.125	0.375	0	.	.	.	.	.	.	.	.	146.8359	164.8178	146.835	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:54	:0:3:7	ry:0:en:0
i3	73.5	0.75	70	.	.	.	.	.	.	.	.	164.8178	164.817	164.817	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:55	:1:6:7	ry:0:en:0
i3	74.25	0.75	70	.	.	.	.	.	.	.	.	207.6574	207.657	207.657	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:56	:2:C:7	ry:0:en:0
i3	75	0.75	70	.	.	.	.	.	.	.	.	192.2647	192.264	192.264	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:57	:3:A:7	ry:0:en:0
i3	75.75	0.375	70	.	.	.	.	.	.	.	.	178.0131	233.0876	233.0876	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:58	:4:8:7	ry:0:en:0
i3	76.125	4.125	70	.	.	.	.	.	.	.	.	233.0876	233.087	233.087	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:59	:5:F:7	ry:0:en:0
i3	80.25	0.375	0	.	.	.	.	.	.	.	.	130.816	130.816	130.816	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:60	:6:0:7	ry:0:en:0
i3	80.625	3.375	70	.	.	.	.	.	.	.	.	152.6006	152.600	152.600	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:61	:7:4:7	ry:0:en:0
i3	84	0.375	70	.	.	.	.	.	.	.	.	251.7485	251.748	251.748	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:62	:8:H:7	ry:0:en:0
i3	84.375	0.375	70	.	.	.	.	.	.	.	.	158.5916	199.8129	158.591	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:63	:9:5:7	ry:0:en:0
i3	84.75	0.75	70	.	.	.	.	.	.	.	.	199.8129	199.812	199.812	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:64	:10:B:7	ry:0:en:0
i3	85.5	2.625	70	.	.	.	.	.	.	.	.	171.2884	171.288	171.288	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:65	:11:7:7	ry:0:en:0
i3	88.125	0.375	70	.	.	.	.	.	.	.	.	185.0017	185.001	185.001	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:66	:12:9:7	ry:0:en:0
i3	88.5	3.75	70	.	.	.	.	.	.	.	.	224.2824	224.282	224.282	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:67	:13:E:7	ry:0:en:0
i3	92.25	3.75	70	.	.	.	.	.	.	.	.	215.8099	242.2384	215.809	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:68	:14:D:7	ry:0:en:0
i3	96	0.375	70	.	.	.	.	.	.	.	.	242.2384	242.238	242.238	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:69	:15:G:7	ry:0:en:0
i3	96.375	0.375	70	.	.	.	.	.	.	.	.	135.9517	135.951	135.951	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:70	:16:1:7	ry:0:en:0
i3	96.75	0.375	70	.	.	.	.	.	.	.	.	141.2890	141.289	141.289	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:71	:17:2:7	ry:0:en:0
i3	97.125	0.375	70	.	.	.	.	.	.	.	.	233.0876	233.087	233.087	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:72	:0:F:7	ry:0:en:0
i3	97.5	0.375	70	.	.	.	.	.	.	.	.	185.0017	185.001	185.001	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:73	:1:9:7	ry:0:en:0
i3	97.875	1.5	70	.	.	.	.	.	.	.	.	171.2884	171.288	171.288	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:74	:2:7:7	ry:0:en:0
i3	99.375	0.375	70	.	.	.	.	.	.	.	.	242.2384	242.238	242.238	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:75	:3:G:7	ry:0:en:0
i3	99.75	1.5	70	.	.	.	.	.	.	.	.	146.8359	146.835	146.835	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:76	:4:3:7	ry:0:en:0
i3	101.25	0.375	70	.	.	.	.	.	.	.	.	251.7485	158.5916	158.5916	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:77	:5:H:7	ry:0:en:0
i3	101.625	3.75	70	.	.	.	.	.	.	.	.	158.5916	130.816	158.591	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:78	:6:5:7	ry:0:en:0
i3	105.375	0.375	70	.	.	.	.	.	.	.	.	130.816	130.816	130.816	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:79	:7:0:7	ry:0:en:0
i3	105.75	0.375	0	.	.	.	.	.	.	.	.	192.2647	192.264	192.264	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:80	:8:A:7	ry:0:en:0
i3	106.125	0.375	0	.	.	.	.	.	.	.	.	178.0131	135.9517	178.013	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:81	:9:8:7	ry:0:en:0
i3	106.5	0.375	70	.	.	.	.	.	.	.	.	135.9517	135.951	135.951	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:82	:10:1:7	ry:0:en:0
i3	106.875	2.25	70	.	.	.	.	.	.	.	.	164.8178	164.817	164.817	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:83	:11:6:7	ry:0:en:0
i3	109.125	1.875	70	.	.	.	.	.	.	.	.	152.6006	152.600	152.600	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:84	:12:4:7	ry:0:en:0
i3	111	3	70	.	.	.	.	.	.	.	.	215.8099	224.2824	224.2824	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:85	:13:D:7	ry:0:en:0
i3	114	4.5	70	.	.	.	.	.	.	.	.	224.2824	141.2890	224.282	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:86	:14:E:7	ry:0:en:0
i3	118.5	1.5	70	.	.	.	.	.	.	.	.	141.2890	141.289	141.289	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:87	:15:2:7	ry:0:en:0
i3	120	0.375	70	.	.	.	.	.	.	.	.	207.6574	207.657	207.657	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:88	:16:C:7	ry:0:en:0
i3	120.375	0.375	70	.	.	.	.	.	.	.	.	199.8129	199.812	199.812	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:89	:17:B:7	ry:0:en:0
i3	120.75	0.375	70	.	.	.	.	.	.	.	.	251.7485	251.748	251.748	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:90	:0:H:7	ry:0:en:0
i3	121.125	0.375	70	.	.	.	.	.	.	.	.	152.6006	152.600	152.600	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:91	:1:4:7	ry:0:en:0
i3	121.5	1.5	70	.	.	.	.	.	.	.	.	164.8178	164.817	164.817	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:92	:2:6:7	ry:0:en:0
i3	123	0.75	70	.	.	.	.	.	.	.	.	141.2890	233.0876	141.289	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:93	:3:2:7	ry:0:en:0
i3	123.75	3.375	0	.	.	.	.	.	.	.	.	233.0876	233.087	233.087	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:94	:4:F:7	ry:0:en:0
i3	127.125	1.125	70	.	.	.	.	.	.	.	.	192.2647	192.264	192.264	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:95	:5:A:7	ry:0:en:0
i3	128.25	0.375	70	.	.	.	.	.	.	.	.	178.0131	158.5916	158.5916	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:96	:6:8:7	ry:0:en:0
i3	128.625	4.125	70	.	.	.	.	.	.	.	.	158.5916	158.591	158.591	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:97	:7:5:7	ry:0:en:0
i3	132.75	0.375	70	.	.	.	.	.	.	.	.	242.2384	146.8359	146.8359	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:98	:8:G:7	ry:0:en:0
i3	133.125	0.375	70	.	.	.	.	.	.	.	.	146.8359	146.835	146.835	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:99	:9:3:7	ry:0:en:0
i3	133.5	0.75	70	.	.	.	.	.	.	.	.	207.6574	185.0017	185.0017	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:100	:10:C:7	ry:0:en:0
i3	134.25	0.375	70	.	.	.	.	.	.	.	.	185.0017	130.816	185.001	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:101	:11:9:7	ry:0:en:0
i3	134.625	0.375	70	.	.	.	.	.	.	.	.	130.816	130.816	130.816	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:102	:12:0:7	ry:0:en:0
i3	135	3.75	70	.	.	.	.	.	.	.	.	224.2824	224.282	224.282	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:103	:13:E:7	ry:0:en:0
i3	138.75	3.75	70	.	.	.	.	.	.	.	.	215.8099	199.8129	215.809	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:104	:14:D:7	ry:0:en:0
i3	142.5	2.625	0	.	.	.	.	.	.	.	.	199.8129	199.812	199.812	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:105	:15:B:7	ry:0:en:0
i3	145.125	0.375	70	.	.	.	.	.	.	.	.	171.2884	171.288	171.288	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:106	:16:7:7	ry:0:en:0
i3	145.5	0.375	70	.	.	.	.	.	.	.	.	135.9517	192.2647	135.951	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:107	:17:1:7	ry:0:en:0
i3	145.875	0.375	0	.	.	.	.	.	.	.	.	192.2647	192.264	192.264	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:108	:0:A:7	ry:0:en:0
i3	146.25	0.375	70	.	.	.	.	.	.	.	.	130.816	130.816	130.816	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:109	:1:0:7	ry:0:en:0
i3	146.625	0.375	70	.	.	.	.	.	.	.	.	185.0017	185.001	185.001	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:110	:2:9:7	ry:0:en:0
i3	147	1.125	70	.	.	.	.	.	.	.	.	199.8129	199.812	199.812	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:111	:3:B:7	ry:0:en:0
i3	148.125	0.375	70	.	.	.	.	.	.	.	.	251.7485	242.2384	251.748	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:112	:4:H:7	ry:0:en:0
i3	148.5	0.375	70	.	.	.	.	.	.	.	.	242.2384	242.238	242.238	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:113	:5:G:7	ry:0:en:0
i3	148.875	2.25	70	.	.	.	.	.	.	.	.	146.8359	146.835	146.835	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:114	:6:3:7	ry:0:en:0
i3	151.125	0.375	70	.	.	.	.	.	.	.	.	178.0131	178.013	178.013	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:115	:7:8:7	ry:0:en:0
i3	151.5	0.375	70	.	.	.	.	.	.	.	.	141.2890	141.289	141.289	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:116	:8:2:7	ry:0:en:0
i3	151.875	0.75	70	.	.	.	.	.	.	.	.	233.0876	233.087	233.087	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:117	:9:F:7	ry:0:en:0
i3	152.625	1.5	0	.	.	.	.	.	.	.	.	171.2884	152.6006	152.6006	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:118	:10:7:7	ry:0:en:0
i3	154.125	1.5	70	.	.	.	.	.	.	.	.	152.6006	152.600	152.600	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:119	:11:4:7	ry:0:en:0
i3	155.625	2.25	70	.	.	.	.	.	.	.	.	158.5916	215.8099	215.8099	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:120	:12:5:7	ry:0:en:0
i3	157.875	3	70	.	.	.	.	.	.	.	.	215.8099	215.809	215.809	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:121	:13:D:7	ry:0:en:0
i3	160.875	4.5	70	.	.	.	.	.	.	.	.	224.2824	224.282	224.282	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:122	:14:E:7	ry:0:en:0
i3	165.375	0.75	70	.	.	.	.	.	.	.	.	135.9517	135.951	135.951	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:123	:15:1:7	ry:0:en:0
i3	166.125	0.375	70	.	.	.	.	.	.	.	.	164.8178	164.817	164.817	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:124	:16:6:7	ry:0:en:0
i3	166.5	0.375	70	.	.	.	.	.	.	.	.	207.6574	242.2384	207.657	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:125	:17:C:7	ry:0:en:0
i3	166.875	0.375	70	.	.	.	.	.	.	.	.	242.2384	242.238	242.238	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:126	:0:G:7	ry:0:en:0
i3	167.25	0.375	70	.	.	.	.	.	.	.	.	158.5916	158.591	158.591	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:127	:1:5:7	ry:0:en:0
i3	167.625	0.75	0	.	.	.	.	.	.	.	.	152.6006	135.9517	152.600	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:128	:2:4:7	ry:0:en:0
i3	168.375	0.375	70	.	.	.	.	.	.	.	.	135.9517	135.951	135.951	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:129	:3:1:7	ry:0:en:0
i3	168.75	0.75	70	.	.	.	.	.	.	.	.	192.2647	141.2890	141.2890	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:130	:4:A:7	ry:0:en:0
i3	169.5	1.125	0	.	.	.	.	.	.	.	.	141.2890	141.289	141.289	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:131	:5:2:7	ry:0:en:0
i3	170.625	4.5	70	.	.	.	.	.	.	.	.	233.0876	233.087	233.087	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:132	:6:F:7	ry:0:en:0
i3	175.125	2.625	70	.	.	.	.	.	.	.	.	146.8359	146.835	146.835	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:133	:7:3:7	ry:0:en:0
i3	177.75	0.375	70	.	.	.	.	.	.	.	.	199.8129	199.812	199.812	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:134	:8:B:7	ry:0:en:0
i3	178.125	0.375	70	.	.	.	.	.	.	.	.	251.7485	164.8178	164.8178	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:135	:9:H:7	ry:0:en:0
i3	178.5	1.5	70	.	.	.	.	.	.	.	.	164.8178	164.817	164.817	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:136	:10:6:7	ry:0:en:0
i3	180	0.375	70	.	.	.	.	.	.	.	.	130.816	178.0131	130.816	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:137	:11:0:7	ry:0:en:0
i3	180.375	0.375	70	.	.	.	.	.	.	.	.	178.0131	224.2824	178.013	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:138	:12:8:7	ry:0:en:0
i3	180.75	3.75	70	.	.	.	.	.	.	.	.	224.2824	224.282	224.282	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:139	:13:E:7	ry:0:en:0
i3	184.5	3.75	70	.	.	.	.	.	.	.	.	215.8099	215.809	215.809	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:140	:14:D:7	ry:0:en:0
i3	188.25	3.375	70	.	.	.	.	.	.	.	.	207.6574	207.657	207.657	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:141	:15:C:7	ry:0:en:0
i3	191.625	0.375	70	.	.	.	.	.	.	.	.	185.0017	171.2884	171.2884	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:142	:16:9:7	ry:0:en:0
i3	192	0.75	70	.	.	.	.	.	.	.	.	171.2884	141.2890	141.2890	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:143	:17:7:7	ry:0:en:0
i3	192.75	0.375	70	.	.	.	.	.	.	.	.	141.2890	141.289	141.289	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:144	:0:2:7	ry:0:en:0
i3	193.125	0.375	0	.	.	.	.	.	.	.	.	178.0131	178.013	178.013	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:145	:1:8:7	ry:0:en:0
i3	193.5	0.375	70	.	.	.	.	.	.	.	.	130.816	130.816	130.816	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:146	:2:0:7	ry:0:en:0
i3	193.875	1.5	70	.	.	.	.	.	.	.	.	207.6574	207.657	207.657	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:147	:3:C:7	ry:0:en:0
i3	195.375	0.375	70	.	.	.	.	.	.	.	.	242.2384	242.238	242.238	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:148	:4:G:7	ry:0:en:0
i3	195.75	1.875	70	.	.	.	.	.	.	.	.	199.8129	251.7485	199.812	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:149	:5:B:7	ry:0:en:0
i3	197.625	0.75	70	.	.	.	.	.	.	.	.	251.7485	251.748	251.748	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:150	:6:H:7	ry:0:en:0
i3	198.375	4.5	70	.	.	.	.	.	.	.	.	233.0876	135.9517	135.9517	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:151	:7:F:7	ry:0:en:0
i3	202.875	0.375	0	.	.	.	.	.	.	.	.	135.9517	135.951	135.951	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:152	:8:1:7	ry:0:en:0
i3	203.25	0.375	70	.	.	.	.	.	.	.	.	192.2647	192.264	192.264	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:153	:9:A:7	ry:0:en:0
i3	203.625	0.375	70	.	.	.	.	.	.	.	.	185.0017	158.5916	185.001	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:154	:10:9:7	ry:0:en:0
i3	204	1.875	70	.	.	.	.	.	.	.	.	158.5916	158.591	158.591	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:155	:11:5:7	ry:0:en:0
i3	205.875	1.5	70	.	.	.	.	.	.	.	.	146.8359	146.835	146.835	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:156	:12:3:7	ry:0:en:0
i3	207.375	3	70	.	.	.	.	.	.	.	.	215.8099	215.809	215.809	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:157	:13:D:7	ry:0:en:0
i3	210.375	4.5	70	.	.	.	.	.	.	.	.	224.2824	171.2884	171.2884	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:158	:14:E:7	ry:0:en:0
i3	214.875	4.5	70	.	.	.	.	.	.	.	.	171.2884	171.288	171.288	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:159	:15:7:7	ry:0:en:0
i3	219.375	0.375	70	.	.	.	.	.	.	.	.	152.6006	152.600	152.600	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:160	:16:4:7	ry:0:en:0
i3	219.75	0.75	70	.	.	.	.	.	.	.	.	164.8178	164.817	164.817	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:161	:17:6:7	ry:0:en:0
i3	220.5	0.375	70	.	.	.	.	.	.	.	.	199.8129	199.812	199.812	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:162	:0:B:7	ry:0:en:0
i3	220.875	0.375	70	.	.	.	.	.	.	.	.	146.8359	146.835	146.835	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:163	:1:3:7	ry:0:en:0
i3	221.25	1.125	70	.	.	.	.	.	.	.	.	158.5916	171.2884	171.2884	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:164	:2:5:7	ry:0:en:0
i3	222.375	2.625	0	.	.	.	.	.	.	.	.	171.2884	141.2890	171.288	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:165	:3:7:7	ry:0:en:0
i3	225	0.75	70	.	.	.	.	.	.	.	.	141.2890	141.289	141.289	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:166	:4:2:7	ry:0:en:0
i3	225.75	0.375	70	.	.	.	.	.	.	.	.	135.9517	135.951	135.951	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:167	:5:1:7	ry:0:en:0
i3	226.125	1.5	70	.	.	.	.	.	.	.	.	192.2647	192.264	192.264	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:168	:6:A:7	ry:0:en:0
i3	227.625	0.75	0	.	.	.	.	.	.	.	.	251.7485	251.748	251.748	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:169	:7:H:7	ry:0:en:0
i3	228.375	0.375	70	.	.	.	.	.	.	.	.	207.6574	207.657	207.657	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:170	:8:C:7	ry:0:en:0
i3	228.75	0.375	70	.	.	.	.	.	.	.	.	242.2384	242.238	242.238	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:171	:9:G:7	ry:0:en:0
i3	229.125	0.75	70	.	.	.	.	.	.	.	.	152.6006	152.600	152.600	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:172	:10:4:7	ry:0:en:0
i3	229.875	0.375	70	.	.	.	.	.	.	.	.	178.0131	233.0876	233.0876	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:173	:11:8:7	ry:0:en:0
i3	230.25	3.375	70	.	.	.	.	.	.	.	.	233.0876	224.2824	224.2824	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:174	:12:F:7	ry:0:en:0
i3	233.625	3.75	70	.	.	.	.	.	.	.	.	224.2824	224.282	224.282	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:175	:13:E:7	ry:0:en:0
i3	237.375	3.75	70	.	.	.	.	.	.	.	.	215.8099	215.809	215.809	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:176	:14:D:7	ry:0:en:0
i3	241.125	4.5	70	.	.	.	.	.	.	.	.	164.8178	164.817	164.817	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:177	:15:6:7	ry:0:en:0
i3	245.625	0.375	70	.	.	.	.	.	.	.	.	130.816	130.816	130.816	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:178	:16:0:7	ry:0:en:0
i3	246	0.375	70	.	.	.	.	.	.	.	.	185.0017	135.9517	185.001	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:179	:17:9:7	ry:0:en:0
i3	246.375	0.375	70	.	.	.	.	.	.	.	.	135.9517	135.951	135.951	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:180	:0:1:7	ry:0:en:0
i3	246.75	0.75	70	.	.	.	.	.	.	.	.	233.0876	233.087	233.087	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:181	:1:F:7	ry:0:en:0
i3	247.5	0.375	70	.	.	.	.	.	.	.	.	178.0131	178.013	178.013	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:182	:2:8:7	ry:0:en:0
i3	247.875	2.25	70	.	.	.	.	.	.	.	.	164.8178	164.817	164.817	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:183	:3:6:7	ry:0:en:0
i3	250.125	1.5	70	.	.	.	.	.	.	.	.	199.8129	199.812	199.812	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:184	:4:B:7	ry:0:en:0
i3	251.625	2.25	70	.	.	.	.	.	.	.	.	207.6574	242.2384	242.2384	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:185	:5:C:7	ry:0:en:0
i3	253.875	0.375	70	.	.	.	.	.	.	.	.	242.2384	242.238	242.238	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:186	:6:G:7	ry:0:en:0
i3	254.25	1.5	70	.	.	.	.	.	.	.	.	192.2647	192.264	192.264	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:187	:7:A:7	ry:0:en:0
i3	255.75	0.375	70	.	.	.	.	.	.	.	.	171.2884	141.2890	171.288	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:188	:8:7:7	ry:0:en:0
i3	256.125	0.375	0	.	.	.	.	.	.	.	.	141.2890	141.289	141.289	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:189	:9:2:7	ry:0:en:0
i3	256.5	0.375	70	.	.	.	.	.	.	.	.	130.816	146.8359	130.816	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:190	:10:0:7	ry:0:en:0
i3	256.875	1.125	70	.	.	.	.	.	.	.	.	146.8359	146.835	146.835	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:191	:11:3:7	ry:0:en:0
i3	258	0.375	70	.	.	.	.	.	.	.	.	251.7485	251.748	251.748	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:192	:12:H:7	ry:0:en:0
i3	258.375	3	70	.	.	.	.	.	.	.	.	215.8099	215.809	215.809	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:193	:13:D:7	ry:0:en:0
i3	261.375	4.5	70	.	.	.	.	.	.	.	.	224.2824	185.0017	224.282	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:194	:14:E:7	ry:0:en:0
i3	265.875	0.75	0	.	.	.	.	.	.	.	.	185.0017	185.001	185.001	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:195	:15:9:7	ry:0:en:0
i3	266.625	0.375	70	.	.	.	.	.	.	.	.	158.5916	158.591	158.591	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:196	:16:5:7	ry:0:en:0
i3	267	0.375	70	.	.	.	.	.	.	.	.	152.6006	152.600	152.600	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:197	:17:4:7	ry:0:en:0
i3	267.375	0.375	0	.	.	.	.	.	.	.	.	207.6574	207.657	207.657	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:198	:0:C:7	ry:0:en:0
i3	267.75	0.375	70	.	.	.	.	.	.	.	.	251.7485	251.748	251.748	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:199	:1:H:7	ry:0:en:0
i3	268.125	0.75	70	.	.	.	.	.	.	.	.	146.8359	185.0017	146.835	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:200	:2:3:7	ry:0:en:0
i3	268.875	0.375	70	.	.	.	.	.	.	.	.	185.0017	135.9517	135.9517	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:201	:3:9:7	ry:0:en:0
i3	269.25	0.375	70	.	.	.	.	.	.	.	.	135.9517	135.951	135.951	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:202	:4:1:7	ry:0:en:0
i3	269.625	4.125	70	.	.	.	.	.	.	.	.	171.2884	171.288	171.288	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:203	:5:7:7	ry:0:en:0
i3	273.75	1.5	70	.	.	.	.	.	.	.	.	141.2890	141.289	141.289	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:204	:6:2:7	ry:0:en:0
i3	275.25	0.375	70	.	.	.	.	.	.	.	.	242.2384	242.238	242.238	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:205	:7:G:7	ry:0:en:0
i3	275.625	0.375	70	.	.	.	.	.	.	.	.	164.8178	164.817	164.817	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:206	:8:6:7	ry:0:en:0
i3	276	0.375	70	.	.	.	.	.	.	.	.	199.8129	199.812	199.812	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:207	:9:B:7	ry:0:en:0
i3	276.375	1.125	70	.	.	.	.	.	.	.	.	158.5916	158.591	158.591	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:208	:10:5:7	ry:0:en:0
i3	277.5	2.625	70	.	.	.	.	.	.	.	.	233.0876	233.087	233.087	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:209	:11:F:7	ry:0:en:0
i3	280.125	0.75	70	.	.	.	.	.	.	.	.	192.2647	224.2824	192.264	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:210	:12:A:7	ry:0:en:0
i3	280.875	3.75	70	.	.	.	.	.	.	.	.	224.2824	224.282	224.282	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:211	:13:E:7	ry:0:en:0
i3	284.625	3.75	70	.	.	.	.	.	.	.	.	215.8099	215.809	215.809	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:212	:14:D:7	ry:0:en:0
i3	288.375	3.375	70	.	.	.	.	.	.	.	.	152.6006	152.600	152.600	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:213	:15:4:7	ry:0:en:0
i3	291.75	0.375	70	.	.	.	.	.	.	.	.	178.0131	178.013	178.013	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:214	:16:8:7	ry:0:en:0
i3	292.125	0.375	0	.	.	.	.	.	.	.	.	130.816	171.2884	130.816	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:215	:17:0:7	ry:0:en:0
i3	292.5	0.375	70	.	.	.	.	.	.	.	.	171.2884	171.288	171.288	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:216	:0:7:7	ry:0:en:0
i3	292.875	0.375	70	.	.	.	.	.	.	.	.	192.2647	192.264	192.264	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:217	:1:A:7	ry:0:en:0
i3	293.25	1.5	70	.	.	.	.	.	.	.	.	233.0876	233.087	233.087	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:218	:2:F:7	ry:0:en:0
i3	294.75	1.5	70	.	.	.	.	.	.	.	.	152.6006	152.600	152.600	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:219	:3:4:7	ry:0:en:0
i3	296.25	1.875	70	.	.	.	.	.	.	.	.	207.6574	207.657	207.657	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:220	:4:C:7	ry:0:en:0
i3	298.125	3.75	70	.	.	.	.	.	.	.	.	164.8178	164.817	164.817	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:221	:5:6:7	ry:0:en:0
i3	301.875	2.25	70	.	.	.	.	.	.	.	.	199.8129	199.812	199.812	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:222	:6:B:7	ry:0:en:0
i3	304.125	1.5	70	.	.	.	.	.	.	.	.	141.2890	185.0017	141.289	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:223	:7:2:7	ry:0:en:0
i3	305.625	0.375	0	.	.	.	.	.	.	.	.	185.0017	135.9517	135.9517	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:224	:8:9:7	ry:0:en:0
i3	306	0.375	70	.	.	.	.	.	.	.	.	135.9517	135.951	135.951	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:225	:9:1:7	ry:0:en:0
i3	306.375	0.375	0	.	.	.	.	.	.	.	.	178.0131	178.013	178.013	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:226	:10:8:7	ry:0:en:0
i3	306.75	0.375	70	.	.	.	.	.	.	.	.	251.7485	251.748	251.748	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:227	:11:H:7	ry:0:en:0
i3	307.125	0.375	70	.	.	.	.	.	.	.	.	242.2384	215.8099	242.238	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:228	:12:G:7	ry:0:en:0
i3	307.5	3	70	.	.	.	.	.	.	.	.	215.8099	215.809	215.809	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:229	:13:D:7	ry:0:en:0
i3	310.5	4.5	70	.	.	.	.	.	.	.	.	224.2824	224.282	224.282	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:230	:14:E:7	ry:0:en:0
i3	315	0.375	70	.	.	.	.	.	.	.	.	130.816	130.816	130.816	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:231	:15:0:7	ry:0:en:0
i3	315.375	0.375	70	.	.	.	.	.	.	.	.	146.8359	146.835	146.835	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:232	:16:3:7	ry:0:en:0
i3	315.75	0.375	70	.	.	.	.	.	.	.	.	158.5916	158.591	158.591	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:233	:17:5:7	ry:0:en:0
i3	316.125	0.375	70	.	.	.	.	.	.	.	.	164.8178	164.817	164.817	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:234	:0:6:7	ry:0:en:0
i3	316.5	0.375	70	.	.	.	.	.	.	.	.	242.2384	242.238	242.238	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:235	:1:G:7	ry:0:en:0
i3	316.875	0.375	70	.	.	.	.	.	.	.	.	251.7485	251.748	251.748	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:236	:2:H:7	ry:0:en:0
i3	317.25	0.375	70	.	.	.	.	.	.	.	.	130.816	171.2884	171.2884	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:237	:3:0:7	ry:0:en:0
i3	317.625	3.375	70	.	.	.	.	.	.	.	.	171.2884	171.288	171.288	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:238	:4:7:7	ry:0:en:0
i3	321	0.375	70	.	.	.	.	.	.	.	.	185.0017	135.9517	135.9517	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:239	:5:9:7	ry:0:en:0
i3	321.375	0.75	70	.	.	.	.	.	.	.	.	135.9517	135.951	135.951	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:240	:6:1:7	ry:0:en:0
i3	322.125	2.625	70	.	.	.	.	.	.	.	.	199.8129	199.812	199.812	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:241	:7:B:7	ry:0:en:0
i3	324.75	0.375	70	.	.	.	.	.	.	.	.	152.6006	152.600	152.600	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:242	:8:4:7	ry:0:en:0
i3	325.125	0.375	70	.	.	.	.	.	.	.	.	207.6574	207.657	207.657	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:243	:9:C:7	ry:0:en:0
i3	325.5	0.75	70	.	.	.	.	.	.	.	.	146.8359	146.835	146.835	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:244	:10:3:7	ry:0:en:0
i3	326.25	0.75	70	.	.	.	.	.	.	.	.	192.2647	141.2890	192.264	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:245	:11:A:7	ry:0:en:0
i3	327	0.75	70	.	.	.	.	.	.	.	.	141.2890	224.2824	141.289	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:246	:12:2:7	ry:0:en:0
i3	327.75	3.75	70	.	.	.	.	.	.	.	.	224.2824	224.282	224.282	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:247	:13:E:7	ry:0:en:0
i3	331.5	3.75	70	.	.	.	.	.	.	.	.	215.8099	215.809	215.809	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:248	:14:D:7	ry:0:en:0
i3	335.25	4.125	0	.	.	.	.	.	.	.	.	158.5916	158.591	158.591	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:249	:15:5:7	ry:0:en:0
i3	339.375	0.375	0	.	.	.	.	.	.	.	.	233.0876	233.087	233.087	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:250	:16:F:7	ry:0:en:0
i3	339.75	0.375	70	.	.	.	.	.	.	.	.	178.0131	178.013	178.013	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:251	:17:8:7	ry:0:en:0
i3	340.125	0.375	70	.	.	.	.	.	.	.	.	185.0017	185.001	185.001	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:252	:0:9:7	ry:0:en:0
i3	340.5	0.375	70	.	.	.	.	.	.	.	.	141.2890	192.2647	141.289	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:253	:1:2:7	ry:0:en:0
i3	340.875	0.375	0	.	.	.	.	.	.	.	.	192.2647	192.264	192.264	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:254	:2:A:7	ry:0:en:0
i3	341.25	1.875	70	.	.	.	.	.	.	.	.	158.5916	158.591	158.591	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:255	:3:5:7	ry:0:en:0
i3	343.125	3	70	.	.	.	.	.	.	.	.	164.8178	164.817	164.817	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:256	:4:6:7	ry:0:en:0
i3	346.125	2.25	70	.	.	.	.	.	.	.	.	152.6006	152.600	152.600	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:257	:5:4:7	ry:0:en:0
i3	348.375	3	70	.	.	.	.	.	.	.	.	207.6574	207.657	207.657	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:258	:6:C:7	ry:0:en:0
i3	351.375	0.75	70	.	.	.	.	.	.	.	.	135.9517	135.951	135.951	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:259	:7:1:7	ry:0:en:0
i3	352.125	0.375	70	.	.	.	.	.	.	.	.	130.816	171.2884	171.2884	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:260	:8:0:7	ry:0:en:0
i3	352.5	0.75	70	.	.	.	.	.	.	.	.	171.2884	233.0876	171.288	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:261	:9:7:7	ry:0:en:0
i3	353.25	1.5	0	.	.	.	.	.	.	.	.	233.0876	233.087	233.087	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:262	:10:F:7	ry:0:en:0
i3	354.75	0.375	70	.	.	.	.	.	.	.	.	242.2384	242.238	242.238	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:263	:11:G:7	ry:0:en:0
i3	355.125	1.5	70	.	.	.	.	.	.	.	.	199.8129	215.8099	199.812	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:264	:12:B:7	ry:0:en:0
i3	356.625	3	70	.	.	.	.	.	.	.	.	215.8099	224.2824	215.809	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:265	:13:D:7	ry:0:en:0
i3	359.625	4.5	70	.	.	.	.	.	.	.	.	224.2824	178.0131	224.282	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:266	:14:E:7	ry:0:en:0
i3	364.125	0.375	70	.	.	.	.	.	.	.	.	178.0131	178.013	178.013	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:267	:15:8:7	ry:0:en:0
i3	364.5	0.375	70	.	.	.	.	.	.	.	.	251.7485	146.8359	251.748	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:268	:16:H:7	ry:0:en:0
i3	364.875	0.375	70	.	.	.	.	.	.	.	.	146.8359	146.835	146.835	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:269	:17:3:7	ry:0:en:0
i3	365.25	0.375	70	.	.	.	.	.	.	.	.	152.6006	199.8129	199.8129	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:270	:0:4:7	ry:0:en:0
i3	365.625	0.375	70	.	.	.	.	.	.	.	.	199.8129	242.2384	199.812	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:271	:1:B:7	ry:0:en:0
i3	366	0.375	0	.	.	.	.	.	.	.	.	242.2384	242.238	242.238	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:272	:2:G:7	ry:0:en:0
i3	366.375	0.375	70	.	.	.	.	.	.	.	.	178.0131	178.013	178.013	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:273	:3:8:7	ry:0:en:0
i3	366.75	0.375	70	.	.	.	.	.	.	.	.	185.0017	130.816	130.816	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:274	:4:9:7	ry:0:en:0
i3	367.125	0.375	70	.	.	.	.	.	.	.	.	130.816	130.816	130.816	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:275	:5:0:7	ry:0:en:0
i3	367.5	4.5	70	.	.	.	.	.	.	.	.	171.2884	207.6574	171.288	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:276	:6:7:7	ry:0:en:0
i3	372	3.375	70	.	.	.	.	.	.	.	.	207.6574	207.657	207.657	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:277	:7:C:7	ry:0:en:0
i3	375.375	0.375	70	.	.	.	.	.	.	.	.	158.5916	158.591	158.591	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:278	:8:5:7	ry:0:en:0
i3	375.75	0.75	70	.	.	.	.	.	.	.	.	164.8178	164.817	164.817	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:279	:9:6:7	ry:0:en:0
i3	376.5	0.375	70	.	.	.	.	.	.	.	.	251.7485	141.2890	251.748	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:280	:10:H:7	ry:0:en:0
i3	376.875	0.75	0	.	.	.	.	.	.	.	.	141.2890	135.9517	141.289	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:281	:11:2:7	ry:0:en:0
i3	377.625	0.375	70	.	.	.	.	.	.	.	.	135.9517	135.951	135.951	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:282	:12:1:7	ry:0:en:0
i3	378	3.75	70	.	.	.	.	.	.	.	.	224.2824	224.282	224.282	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:283	:13:E:7	ry:0:en:0
i3	381.75	3.75	70	.	.	.	.	.	.	.	.	215.8099	146.8359	215.809	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:284	:14:D:7	ry:0:en:0
i3	385.5	2.625	70	.	.	.	.	.	.	.	.	146.8359	146.835	146.835	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:285	:15:3:7	ry:0:en:0
i3	388.125	0.375	70	.	.	.	.	.	.	.	.	192.2647	192.264	192.264	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:286	:16:A:7	ry:0:en:0
i3	388.5	0.75	70	.	.	.	.	.	.	.	.	233.0876	233.087	233.087	0.7	0.3	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_3:287	:17:F:7	ry:0:en:0

; Seq_4 comments: Oppgrad of the root series (S) - not the same as gradual of the opposite - for the solo flute in section 1.
;ins	sta	dur	amp	fq1	prs	bre	fb1	fb2	pa1	rvs	rvn	
i7	16	0.375	70	317.1832	0.8	0.07	0.4	0.5	0.5	0.1	1	;Sec:0:Seq_4:0	:0:5:8	ry:0:en:0
i7	16.375	0.375	70	103.8287	.	.	.	.	.	.	.	;Sec:0:Seq_4:1	:1:C:6	ry:0:en:0
i7	16.75	0.75	70	399.6259	.	.	.	.	.	.	.	;Sec:0:Seq_4:2	:2:B:8	ry:0:en:0
i7	17.5	2.625	70	466.1752	.	.	.	.	.	.	.	;Sec:0:Seq_4:3	:3:F:8	ry:0:en:0
i7	20.125	0.375	70	523.264	.	.	.	.	.	.	.	;Sec:0:Seq_4:4	:4:0:9	ry:0:en:0
i7	20.5	0.375	70	356.0262	.	.	.	.	.	.	.	;Sec:0:Seq_4:5	:5:8:8	ry:0:en:0
i7	20.875	0.75	70	46.2504	.	.	.	.	.	.	.	;Sec:0:Seq_4:6	:6:9:5	ry:0:en:0
i7	21.625	4.5	0	82.4089	.	.	.	.	.	.	.	;Sec:0:Seq_4:7	:7:6:6	ry:0:en:0
i7	26.125	0.375	70	73.4179	.	.	.	.	.	.	.	;Sec:0:Seq_4:8	:8:3:6	ry:0:en:0
i7	26.5	0.375	70	76.3003	.	.	.	.	.	.	.	;Sec:0:Seq_4:9	:9:4:6	ry:0:en:0
i7	26.875	0.375	70	968.9538	.	.	.	.	.	.	.	;Sec:0:Seq_4:10	:10:G:9	ry:0:en:0
i7	27.25	0.375	70	271.9034	.	.	.	.	.	.	.	;Sec:0:Seq_4:11	:11:1:8	ry:0:en:0
i7	27.625	3.375	0	342.5769	.	.	.	.	.	.	.	;Sec:0:Seq_4:12	:12:7:8	ry:0:en:0
i7	31	3.75	70	897.1298	.	.	.	.	.	.	.	;Sec:0:Seq_4:13	:13:E:9	ry:0:en:0
i7	34.75	3.75	70	431.6198	.	.	.	.	.	.	.	;Sec:0:Seq_4:14	:14:D:8	ry:0:en:0
i7	38.5	0.75	70	251.7485	.	.	.	.	.	.	.	;Sec:0:Seq_4:15	:15:H:7	ry:0:en:0
i7	39.25	0.375	70	565.1563	.	.	.	.	.	.	.	;Sec:0:Seq_4:16	:16:2:9	ry:0:en:0
i7	39.625	0.375	70	769.0591	.	.	.	.	.	.	.	;Sec:0:Seq_4:17	:17:A:9	ry:0:en:0
i7	40	0.375	70	130.816	.	.	.	.	.	.	.	;Sec:0:Seq_4:18	:0:0:7	ry:0:en:0
i7	40.375	0.375	70	356.0262	.	.	.	.	.	.	.	;Sec:0:Seq_4:19	:1:8:8	ry:0:en:0
i7	40.75	0.75	70	799.2518	.	.	.	.	.	.	.	;Sec:0:Seq_4:20	:2:B:9	ry:0:en:0
i7	41.5	2.625	70	932.3504	.	.	.	.	.	.	.	;Sec:0:Seq_4:21	:3:F:9	ry:0:en:0
i7	44.125	3	70	448.5649	.	.	.	.	.	.	.	;Sec:0:Seq_4:22	:4:E:8	ry:0:en:0
i7	47.125	1.875	70	146.8359	.	.	.	.	.	.	.	;Sec:0:Seq_4:23	:5:3:7	ry:0:en:0
i7	49	0.75	0	23.1252	.	.	.	.	.	.	.	;Sec:0:Seq_4:24	:6:9:4	ry:0:en:0
i7	49.75	3.375	70	415.3149	.	.	.	.	.	.	.	;Sec:0:Seq_4:25	:7:C:8	ry:0:en:0
i7	53.125	0.375	0	329.6356	.	.	.	.	.	.	.	;Sec:0:Seq_4:26	:8:6:8	ry:0:en:0
i7	53.5	0.75	70	85.6442	.	.	.	.	.	.	.	;Sec:0:Seq_4:27	:9:7:6	ry:0:en:0
i7	54.25	0.75	70	152.6006	.	.	.	.	.	.	.	;Sec:0:Seq_4:28	:10:4:7	ry:0:en:0
i7	55	0.375	70	16.9939	.	.	.	.	.	.	.	;Sec:0:Seq_4:29	:11:1:4	ry:0:en:0
i7	55.375	0.75	70	141.2890	.	.	.	.	.	.	.	;Sec:0:Seq_4:30	:12:2:7	ry:0:en:0
i7	56.125	1.125	70	769.0591	.	.	.	.	.	.	.	;Sec:0:Seq_4:31	:13:A:9	ry:0:en:0
i7	57.25	3.75	70	107.9049	.	.	.	.	.	.	.	;Sec:0:Seq_4:32	:14:D:6	ry:0:en:0
i7	61	0.75	70	251.7485	.	.	.	.	.	.	.	;Sec:0:Seq_4:33	:15:H:7	ry:0:en:0
i7	61.75	0.375	70	484.4769	.	.	.	.	.	.	.	;Sec:0:Seq_4:34	:16:G:8	ry:0:en:0
i7	62.125	0.375	70	634.3665	.	.	.	.	.	.	.	;Sec:0:Seq_4:35	:17:5:9	ry:0:en:0
i7	62.5	0.375	70	431.6198	.	.	.	.	.	.	.	;Sec:0:Seq_4:36	:0:D:8	ry:0:en:0
i7	62.875	0.375	0	70.6445	.	.	.	.	.	.	.	;Sec:0:Seq_4:37	:1:2:6	ry:0:en:0
i7	63.25	0.375	0	135.9517	.	.	.	.	.	.	.	;Sec:0:Seq_4:38	:2:1:7	ry:0:en:0
i7	63.625	1.875	70	317.1832	.	.	.	.	.	.	.	;Sec:0:Seq_4:39	:3:5:8	ry:0:en:0
i7	65.5	0.375	70	178.0131	.	.	.	.	.	.	.	;Sec:0:Seq_4:40	:4:8:7	ry:0:en:0
i7	65.875	0.375	70	484.4769	.	.	.	.	.	.	.	;Sec:0:Seq_4:41	:5:G:8	ry:0:en:0
i7	66.25	0.75	70	251.7485	.	.	.	.	.	.	.	;Sec:0:Seq_4:42	:6:H:7	ry:0:en:0
i7	67	4.5	70	448.5649	.	.	.	.	.	.	.	;Sec:0:Seq_4:43	:7:E:8	ry:0:en:0
i7	71.5	0.375	70	199.8129	.	.	.	.	.	.	.	;Sec:0:Seq_4:44	:8:B:7	ry:0:en:0
i7	71.875	0.375	70	207.6574	.	.	.	.	.	.	.	;Sec:0:Seq_4:45	:9:C:7	ry:0:en:0
i7	72.25	1.5	70	329.6356	.	.	.	.	.	.	.	;Sec:0:Seq_4:46	:10:6:8	ry:0:en:0
i7	73.75	0.375	70	92.5008	.	.	.	.	.	.	.	;Sec:0:Seq_4:47	:11:9:6	ry:0:en:0
i7	74.125	3.375	70	233.0876	.	.	.	.	.	.	.	;Sec:0:Seq_4:48	:12:F:7	ry:0:en:0
i7	77.5	2.25	70	305.2013	.	.	.	.	.	.	.	;Sec:0:Seq_4:49	:13:4:8	ry:0:en:0
i7	79.75	2.25	70	73.4179	.	.	.	.	.	.	.	;Sec:0:Seq_4:50	:14:3:6	ry:0:en:0
i7	82	4.5	70	21.4110	.	.	.	.	.	.	.	;Sec:0:Seq_4:51	:15:7:4	ry:0:en:0
i7	86.5	0.375	70	48.0661	.	.	.	.	.	.	.	;Sec:0:Seq_4:52	:16:A:5	ry:0:en:0
i7	86.875	0.375	70	16.352	.	.	.	.	.	.	.	;Sec:0:Seq_4:53	:17:0:4	ry:0:en:0
i7	87.25	0.375	70	356.0262	.	.	.	.	.	.	.	;Sec:0:Seq_4:54	:0:8:8	ry:0:en:0
i7	87.625	0.375	70	121.1192	.	.	.	.	.	.	.	;Sec:0:Seq_4:55	:1:G:6	ry:0:en:0
i7	88	0.375	70	271.9034	.	.	.	.	.	.	.	;Sec:0:Seq_4:56	:2:1:8	ry:0:en:0
i7	88.375	1.875	70	317.1832	.	.	.	.	.	.	.	;Sec:0:Seq_4:57	:3:5:8	ry:0:en:0
i7	90.25	1.875	70	76.3003	.	.	.	.	.	.	.	;Sec:0:Seq_4:58	:4:4:6	ry:0:en:0
i7	92.125	1.875	70	399.6259	.	.	.	.	.	.	.	;Sec:0:Seq_4:59	:5:B:8	ry:0:en:0
i7	94	0.75	0	31.4685	.	.	.	.	.	.	.	;Sec:0:Seq_4:60	:6:H:4	ry:0:en:0
i7	94.75	1.5	70	35.3222	.	.	.	.	.	.	.	;Sec:0:Seq_4:61	:7:2:5	ry:0:en:0
i7	96.25	0.375	70	28.0353	.	.	.	.	.	.	.	;Sec:0:Seq_4:62	:8:E:4	ry:0:en:0
i7	96.625	0.75	70	58.2719	.	.	.	.	.	.	.	;Sec:0:Seq_4:63	:9:F:5	ry:0:en:0
i7	97.375	0.75	70	415.3149	.	.	.	.	.	.	.	;Sec:0:Seq_4:64	:10:C:8	ry:0:en:0
i7	98.125	0.375	70	370.0035	.	.	.	.	.	.	.	;Sec:0:Seq_4:65	:11:9:8	ry:0:en:0
i7	98.5	0.75	70	192.2647	.	.	.	.	.	.	.	;Sec:0:Seq_4:66	:12:A:7	ry:0:en:0
i7	99.25	0.375	70	65.408	.	.	.	.	.	.	.	;Sec:0:Seq_4:67	:13:0:6	ry:0:en:0
i7	99.625	2.25	70	73.4179	.	.	.	.	.	.	.	;Sec:0:Seq_4:68	:14:3:6	ry:0:en:0
i7	101.875	4.5	70	342.5769	.	.	.	.	.	.	.	;Sec:0:Seq_4:69	:15:7:8	ry:0:en:0
i7	106.375	0.375	0	329.6356	.	.	.	.	.	.	.	;Sec:0:Seq_4:70	:16:6:8	ry:0:en:0
i7	106.75	0.375	70	431.6198	.	.	.	.	.	.	.	;Sec:0:Seq_4:71	:17:D:8	ry:0:en:0
i7	107.125	0.375	70	146.8359	.	.	.	.	.	.	.	;Sec:0:Seq_4:72	:0:3:7	ry:0:en:0
i7	107.5	0.375	70	192.2647	.	.	.	.	.	.	.	;Sec:0:Seq_4:73	:1:A:7	ry:0:en:0
i7	107.875	0.375	70	23.1252	.	.	.	.	.	.	.	;Sec:0:Seq_4:74	:2:9:4	ry:0:en:0
i7	108.25	1.875	70	431.6198	.	.	.	.	.	.	.	;Sec:0:Seq_4:75	:3:D:8	ry:0:en:0
i7	110.125	0.375	70	242.2384	.	.	.	.	.	.	.	;Sec:0:Seq_4:76	:4:G:7	ry:0:en:0
i7	110.5	3.75	70	659.2713	.	.	.	.	.	.	.	;Sec:0:Seq_4:77	:5:6:9	ry:0:en:0
i7	114.25	4.5	70	21.4110	.	.	.	.	.	.	.	;Sec:0:Seq_4:78	:6:7:4	ry:0:en:0
i7	118.75	3.375	70	76.3003	.	.	.	.	.	.	.	;Sec:0:Seq_4:79	:7:4:6	ry:0:en:0
i7	122.125	0.375	70	135.9517	.	.	.	.	.	.	.	;Sec:0:Seq_4:80	:8:1:7	ry:0:en:0
i7	122.5	0.375	70	35.3222	.	.	.	.	.	.	.	;Sec:0:Seq_4:81	:9:2:5	ry:0:en:0
i7	122.875	1.5	0	112.1412	.	.	.	.	.	.	.	;Sec:0:Seq_4:82	:10:E:6	ry:0:en:0
i7	124.375	0.375	70	503.4970	.	.	.	.	.	.	.	;Sec:0:Seq_4:83	:11:H:8	ry:0:en:0
i7	124.75	2.25	70	317.1832	.	.	.	.	.	.	.	;Sec:0:Seq_4:84	:12:5:8	ry:0:en:0
i7	127	2.25	70	207.6574	.	.	.	.	.	.	.	;Sec:0:Seq_4:85	:13:C:7	ry:0:en:0
i7	129.25	2.25	0	49.9532	.	.	.	.	.	.	.	;Sec:0:Seq_4:86	:14:B:5	ry:0:en:0
i7	131.5	4.5	70	116.5438	.	.	.	.	.	.	.	;Sec:0:Seq_4:87	:15:F:6	ry:0:en:0
i7	136	0.375	70	130.816	.	.	.	.	.	.	.	;Sec:0:Seq_4:88	:16:0:7	ry:0:en:0
i7	136.375	0.375	70	89.0065	.	.	.	.	.	.	.	;Sec:0:Seq_4:89	:17:8:6	ry:0:en:0
i7	136.75	0.375	70	484.4769	.	.	.	.	.	.	.	;Sec:0:Seq_4:90	:0:G:8	ry:0:en:0
i7	137.125	0.75	70	82.4089	.	.	.	.	.	.	.	;Sec:0:Seq_4:91	:1:6:6	ry:0:en:0
i7	137.875	0.375	70	370.0035	.	.	.	.	.	.	.	;Sec:0:Seq_4:92	:2:9:8	ry:0:en:0
i7	138.25	1.875	70	431.6198	.	.	.	.	.	.	.	;Sec:0:Seq_4:93	:3:D:8	ry:0:en:0
i7	140.125	1.875	70	415.3149	.	.	.	.	.	.	.	;Sec:0:Seq_4:94	:4:C:8	ry:0:en:0
i7	142	0.375	70	271.9034	.	.	.	.	.	.	.	;Sec:0:Seq_4:95	:5:1:8	ry:0:en:0
i7	142.375	4.5	0	21.4110	.	.	.	.	.	.	.	;Sec:0:Seq_4:96	:6:7:4	ry:0:en:0
i7	146.875	1.5	0	384.5295	.	.	.	.	.	.	.	;Sec:0:Seq_4:97	:7:A:8	ry:0:en:0
i7	148.375	0.375	70	38.1501	.	.	.	.	.	.	.	;Sec:0:Seq_4:98	:8:4:5	ry:0:en:0
i7	148.75	0.375	70	317.1832	.	.	.	.	.	.	.	;Sec:0:Seq_4:99	:9:5:8	ry:0:en:0
i7	149.125	0.375	70	141.2890	.	.	.	.	.	.	.	;Sec:0:Seq_4:100	:10:2:7	ry:0:en:0
i7	149.5	0.375	70	503.4970	.	.	.	.	.	.	.	;Sec:0:Seq_4:101	:11:H:8	ry:0:en:0
i7	149.875	0.375	70	261.632	.	.	.	.	.	.	.	;Sec:0:Seq_4:102	:12:0:8	ry:0:en:0
i7	150.25	0.375	70	712.0524	.	.	.	.	.	.	.	;Sec:0:Seq_4:103	:13:8:9	ry:0:en:0
i7	150.625	2.25	70	24.9766	.	.	.	.	.	.	.	;Sec:0:Seq_4:104	:14:B:4	ry:0:en:0
i7	152.875	4.5	70	116.5438	.	.	.	.	.	.	.	;Sec:0:Seq_4:105	:15:F:6	ry:0:en:0
i7	157.375	0.375	70	28.0353	.	.	.	.	.	.	.	;Sec:0:Seq_4:106	:16:E:4	ry:0:en:0
i7	157.75	0.375	70	293.6719	.	.	.	.	.	.	.	;Sec:0:Seq_4:107	:17:3:8	ry:0:en:0
i7	158.125	0.375	0	199.8129	.	.	.	.	.	.	.	;Sec:0:Seq_4:108	:0:B:7	ry:0:en:0
i7	158.5	0.375	70	130.816	.	.	.	.	.	.	.	;Sec:0:Seq_4:109	:1:0:7	ry:0:en:0
i7	158.875	0.375	70	125.8742	.	.	.	.	.	.	.	;Sec:0:Seq_4:110	:2:H:6	ry:0:en:0
i7	159.25	1.125	70	293.6719	.	.	.	.	.	.	.	;Sec:0:Seq_4:111	:3:3:8	ry:0:en:0
i7	160.375	3	70	329.6356	.	.	.	.	.	.	.	;Sec:0:Seq_4:112	:4:6:8	ry:0:en:0
i7	163.375	3.75	70	448.5649	.	.	.	.	.	.	.	;Sec:0:Seq_4:113	:5:E:8	ry:0:en:0
i7	167.125	4.5	70	116.5438	.	.	.	.	.	.	.	;Sec:0:Seq_4:114	:6:F:6	ry:0:en:0
i7	171.625	3.375	70	25.9571	.	.	.	.	.	.	.	;Sec:0:Seq_4:115	:7:C:4	ry:0:en:0
i7	175	0.375	70	185.0017	.	.	.	.	.	.	.	;Sec:0:Seq_4:116	:8:9:7	ry:0:en:0
i7	175.375	0.375	70	96.1323	.	.	.	.	.	.	.	;Sec:0:Seq_4:117	:9:A:6	ry:0:en:0
i7	175.75	0.75	70	305.2013	.	.	.	.	.	.	.	;Sec:0:Seq_4:118	:10:4:8	ry:0:en:0
i7	176.5	2.625	0	21.4110	.	.	.	.	.	.	.	;Sec:0:Seq_4:119	:11:7:4	ry:0:en:0
i7	179.125	2.25	70	431.6198	.	.	.	.	.	.	.	;Sec:0:Seq_4:120	:12:D:8	ry:0:en:0
i7	181.375	1.125	70	282.5781	.	.	.	.	.	.	.	;Sec:0:Seq_4:121	:13:2:8	ry:0:en:0
i7	182.5	0.75	70	135.9517	.	.	.	.	.	.	.	;Sec:0:Seq_4:122	:14:1:7	ry:0:en:0
i7	183.25	4.125	70	317.1832	.	.	.	.	.	.	.	;Sec:0:Seq_4:123	:15:5:8	ry:0:en:0
i7	187.375	0.375	70	712.0524	.	.	.	.	.	.	.	;Sec:0:Seq_4:124	:16:8:9	ry:0:en:0
i7	187.75	0.375	70	242.2384	.	.	.	.	.	.	.	;Sec:0:Seq_4:125	:17:G:7	ry:0:en:0
i7	188.125	0.375	70	329.6356	.	.	.	.	.	.	.	;Sec:0:Seq_4:126	:0:6:8	ry:0:en:0
i7	188.5	0.75	0	224.2824	.	.	.	.	.	.	.	;Sec:0:Seq_4:127	:1:E:7	ry:0:en:0
i7	189.25	0.375	70	31.4685	.	.	.	.	.	.	.	;Sec:0:Seq_4:128	:2:H:4	ry:0:en:0
i7	189.625	1.125	70	587.3439	.	.	.	.	.	.	.	;Sec:0:Seq_4:129	:3:3:9	ry:0:en:0
i7	190.75	0.75	70	17.6611	.	.	.	.	.	.	.	;Sec:0:Seq_4:130	:4:2:4	ry:0:en:0
i7	191.5	0.375	70	370.0035	.	.	.	.	.	.	.	;Sec:0:Seq_4:131	:5:9:8	ry:0:en:0
i7	191.875	4.5	70	466.1752	.	.	.	.	.	.	.	;Sec:0:Seq_4:132	:6:F:8	ry:0:en:0
i7	196.375	0.375	70	261.632	.	.	.	.	.	.	.	;Sec:0:Seq_4:133	:7:0:8	ry:0:en:0
i7	196.75	0.375	70	25.9571	.	.	.	.	.	.	.	;Sec:0:Seq_4:134	:8:C:4	ry:0:en:0
i7	197.125	0.375	70	53.9524	.	.	.	.	.	.	.	;Sec:0:Seq_4:135	:9:D:5	ry:0:en:0
i7	197.5	0.375	70	769.0591	.	.	.	.	.	.	.	;Sec:0:Seq_4:136	:10:A:9	ry:0:en:0
i7	197.875	2.625	70	342.5769	.	.	.	.	.	.	.	;Sec:0:Seq_4:137	:11:7:8	ry:0:en:0
i7	200.5	0.375	70	178.0131	.	.	.	.	.	.	.	;Sec:0:Seq_4:138	:12:8:7	ry:0:en:0
i7	200.875	0.375	70	484.4769	.	.	.	.	.	.	.	;Sec:0:Seq_4:139	:13:G:8	ry:0:en:0
i7	201.25	0.75	0	271.9034	.	.	.	.	.	.	.	;Sec:0:Seq_4:140	:14:1:8	ry:0:en:0
i7	202	4.125	70	79.2958	.	.	.	.	.	.	.	;Sec:0:Seq_4:141	:15:5:6	ry:0:en:0
i7	206.125	0.375	70	76.3003	.	.	.	.	.	.	.	;Sec:0:Seq_4:142	:16:4:6	ry:0:en:0
i7	206.5	0.375	70	199.8129	.	.	.	.	.	.	.	;Sec:0:Seq_4:143	:17:B:7	ry:0:en:0
i7	206.875	0.375	70	135.9517	.	.	.	.	.	.	.	;Sec:0:Seq_4:144	:0:1:7	ry:0:en:0
i7	207.25	0.375	70	356.0262	.	.	.	.	.	.	.	;Sec:0:Seq_4:145	:1:8:8	ry:0:en:0
i7	207.625	1.5	70	171.2884	.	.	.	.	.	.	.	;Sec:0:Seq_4:146	:2:7:7	ry:0:en:0
i7	209.125	1.125	70	199.8129	.	.	.	.	.	.	.	;Sec:0:Seq_4:147	:3:B:7	ry:0:en:0
i7	210.25	3	70	224.2824	.	.	.	.	.	.	.	;Sec:0:Seq_4:148	:4:E:7	ry:0:en:0
i7	213.25	2.25	70	610.4026	.	.	.	.	.	.	.	;Sec:0:Seq_4:149	:5:4:9	ry:0:en:0
i7	215.5	3.75	70	158.5916	.	.	.	.	.	.	.	;Sec:0:Seq_4:150	:6:5:7	ry:0:en:0
i7	219.25	1.5	70	282.5781	.	.	.	.	.	.	.	;Sec:0:Seq_4:151	:7:2:8	ry:0:en:0
i7	220.75	0.375	0	503.4970	.	.	.	.	.	.	.	;Sec:0:Seq_4:152	:8:H:8	ry:0:en:0
i7	221.125	0.375	70	523.264	.	.	.	.	.	.	.	;Sec:0:Seq_4:153	:9:0:9	ry:0:en:0
i7	221.5	0.75	70	415.3149	.	.	.	.	.	.	.	;Sec:0:Seq_4:154	:10:C:8	ry:0:en:0
i7	222.25	2.625	70	466.1752	.	.	.	.	.	.	.	;Sec:0:Seq_4:155	:11:F:8	ry:0:en:0
i7	224.875	1.5	70	146.8359	.	.	.	.	.	.	.	;Sec:0:Seq_4:156	:12:3:7	ry:0:en:0
i7	226.375	1.125	70	96.1323	.	.	.	.	.	.	.	;Sec:0:Seq_4:157	:13:A:6	ry:0:en:0
i7	227.5	0.75	70	185.0017	.	.	.	.	.	.	.	;Sec:0:Seq_4:158	:14:9:7	ry:0:en:0
i7	228.25	4.125	70	431.6198	.	.	.	.	.	.	.	;Sec:0:Seq_4:159	:15:D:8	ry:0:en:0
i7	232.375	0.375	70	242.2384	.	.	.	.	.	.	.	;Sec:0:Seq_4:160	:16:G:7	ry:0:en:0
i7	232.75	0.75	0	82.4089	.	.	.	.	.	.	.	;Sec:0:Seq_4:161	:17:6:6	ry:0:en:0
i7	233.5	0.375	70	897.1298	.	.	.	.	.	.	.	;Sec:0:Seq_4:162	:0:E:9	ry:0:en:0
i7	233.875	0.375	70	305.2013	.	.	.	.	.	.	.	;Sec:0:Seq_4:163	:1:4:8	ry:0:en:0
i7	234.25	1.5	70	342.5769	.	.	.	.	.	.	.	;Sec:0:Seq_4:164	:2:7:8	ry:0:en:0
i7	235.75	1.125	70	99.9064	.	.	.	.	.	.	.	;Sec:0:Seq_4:165	:3:B:6	ry:0:en:0
i7	236.875	0.75	0	192.2647	.	.	.	.	.	.	.	;Sec:0:Seq_4:166	:4:A:7	ry:0:en:0
i7	237.625	0.375	70	503.4970	.	.	.	.	.	.	.	;Sec:0:Seq_4:167	:5:H:8	ry:0:en:0
i7	238	3.75	70	158.5916	.	.	.	.	.	.	.	;Sec:0:Seq_4:168	:6:5:7	ry:0:en:0
i7	241.75	0.375	70	44.5032	.	.	.	.	.	.	.	;Sec:0:Seq_4:169	:7:8:5	ry:0:en:0
i7	242.125	0.375	70	35.3222	.	.	.	.	.	.	.	;Sec:0:Seq_4:170	:8:2:5	ry:0:en:0
i7	242.5	0.375	70	73.4179	.	.	.	.	.	.	.	;Sec:0:Seq_4:171	:9:3:6	ry:0:en:0
i7	242.875	0.375	0	261.632	.	.	.	.	.	.	.	;Sec:0:Seq_4:172	:10:0:8	ry:0:en:0
i7	243.25	2.625	70	466.1752	.	.	.	.	.	.	.	;Sec:0:Seq_4:173	:11:F:8	ry:0:en:0
i7	245.875	0.375	70	484.4769	.	.	.	.	.	.	.	;Sec:0:Seq_4:174	:12:G:8	ry:0:en:0
i7	246.25	3.75	70	329.6356	.	.	.	.	.	.	.	;Sec:0:Seq_4:175	:13:6:8	ry:0:en:0
i7	250	0.75	70	370.0035	.	.	.	.	.	.	.	;Sec:0:Seq_4:176	:14:9:8	ry:0:en:0
i7	250.75	4.125	70	431.6198	.	.	.	.	.	.	.	;Sec:0:Seq_4:177	:15:D:8	ry:0:en:0
i7	254.875	0.375	70	207.6574	.	.	.	.	.	.	.	;Sec:0:Seq_4:178	:16:C:7	ry:0:en:0
i7	255.25	0.375	70	543.8069	.	.	.	.	.	.	.	;Sec:0:Seq_4:179	:17:1:9	ry:0:en:0
i7	255.625	0.375	70	185.0017	.	.	.	.	.	.	.	;Sec:0:Seq_4:180	:0:9:7	ry:0:en:0
i7	256	0.375	70	30.2798	.	.	.	.	.	.	.	;Sec:0:Seq_4:181	:1:G:4	ry:0:en:0
i7	256.375	1.5	70	29.1359	.	.	.	.	.	.	.	;Sec:0:Seq_4:182	:2:F:4	ry:0:en:0
i7	257.875	0.375	70	135.9517	.	.	.	.	.	.	.	;Sec:0:Seq_4:183	:3:1:7	ry:0:en:0
i7	258.25	1.875	70	610.4026	.	.	.	.	.	.	.	;Sec:0:Seq_4:184	:4:4:9	ry:0:en:0
i7	260.125	2.25	70	207.6574	.	.	.	.	.	.	.	;Sec:0:Seq_4:185	:5:C:7	ry:0:en:0
i7	262.375	3.75	0	431.6198	.	.	.	.	.	.	.	;Sec:0:Seq_4:186	:6:D:8	ry:0:en:0
i7	266.125	1.5	70	384.5295	.	.	.	.	.	.	.	;Sec:0:Seq_4:187	:7:A:8	ry:0:en:0
i7	267.625	0.375	70	342.5769	.	.	.	.	.	.	.	;Sec:0:Seq_4:188	:8:7:8	ry:0:en:0
i7	268	0.375	70	22.2516	.	.	.	.	.	.	.	;Sec:0:Seq_4:189	:9:8:4	ry:0:en:0
i7	268.375	0.375	70	282.5781	.	.	.	.	.	.	.	;Sec:0:Seq_4:190	:10:2:8	ry:0:en:0
i7	268.75	1.875	70	158.5916	.	.	.	.	.	.	.	;Sec:0:Seq_4:191	:11:5:7	ry:0:en:0
i7	270.625	1.5	70	399.6259	.	.	.	.	.	.	.	;Sec:0:Seq_4:192	:12:B:8	ry:0:en:0
i7	272.125	0.375	70	130.816	.	.	.	.	.	.	.	;Sec:0:Seq_4:193	:13:0:7	ry:0:en:0
i7	272.5	0.75	70	125.8742	.	.	.	.	.	.	.	;Sec:0:Seq_4:194	:14:H:6	ry:0:en:0
i7	273.25	2.625	70	73.4179	.	.	.	.	.	.	.	;Sec:0:Seq_4:195	:15:3:6	ry:0:en:0
i7	275.875	0.375	0	329.6356	.	.	.	.	.	.	.	;Sec:0:Seq_4:196	:16:6:8	ry:0:en:0
i7	276.25	0.75	70	224.2824	.	.	.	.	.	.	.	;Sec:0:Seq_4:197	:17:E:7	ry:0:en:0
i7	277	0.375	70	76.3003	.	.	.	.	.	.	.	;Sec:0:Seq_4:198	:0:4:6	ry:0:en:0
i7	277.375	0.375	70	207.6574	.	.	.	.	.	.	.	;Sec:0:Seq_4:199	:1:C:7	ry:0:en:0
i7	277.75	1.5	70	233.0876	.	.	.	.	.	.	.	;Sec:0:Seq_4:200	:2:F:7	ry:0:en:0
i7	279.25	0.375	70	16.9939	.	.	.	.	.	.	.	;Sec:0:Seq_4:201	:3:1:4	ry:0:en:0
i7	279.625	0.375	70	130.816	.	.	.	.	.	.	.	;Sec:0:Seq_4:202	:4:0:7	ry:0:en:0
i7	280	4.125	70	171.2884	.	.	.	.	.	.	.	;Sec:0:Seq_4:203	:5:7:7	ry:0:en:0
i7	284.125	3.75	0	107.9049	.	.	.	.	.	.	.	;Sec:0:Seq_4:204	:6:D:6	ry:0:en:0
i7	287.875	0.375	70	968.9538	.	.	.	.	.	.	.	;Sec:0:Seq_4:205	:7:G:9	ry:0:en:0
i7	288.25	0.375	70	384.5295	.	.	.	.	.	.	.	;Sec:0:Seq_4:206	:8:A:8	ry:0:en:0
i7	288.625	0.375	70	49.9532	.	.	.	.	.	.	.	;Sec:0:Seq_4:207	:9:B:5	ry:0:en:0
i7	289	0.375	70	89.0065	.	.	.	.	.	.	.	;Sec:0:Seq_4:208	:10:8:6	ry:0:en:0
i7	289.375	1.875	70	317.1832	.	.	.	.	.	.	.	;Sec:0:Seq_4:209	:11:5:8	ry:0:en:0
i7	291.25	3	0	41.2044	.	.	.	.	.	.	.	;Sec:0:Seq_4:210	:12:6:5	ry:0:en:0
i7	294.25	3.75	70	897.1298	.	.	.	.	.	.	.	;Sec:0:Seq_4:211	:13:E:9	ry:0:en:0
i7	298	0.75	70	31.4685	.	.	.	.	.	.	.	;Sec:0:Seq_4:212	:14:H:4	ry:0:en:0
i7	298.75	2.625	70	146.8359	.	.	.	.	.	.	.	;Sec:0:Seq_4:213	:15:3:7	ry:0:en:0
i7	301.375	0.375	70	282.5781	.	.	.	.	.	.	.	;Sec:0:Seq_4:214	:16:2:8	ry:0:en:0
i7	301.75	0.375	70	185.0017	.	.	.	.	.	.	.	;Sec:0:Seq_4:215	:17:9:7	ry:0:en:0
i7	302.125	0.375	70	251.7485	.	.	.	.	.	.	.	;Sec:0:Seq_4:216	:0:H:7	ry:0:en:0
i7	302.5	0.75	70	20.6022	.	.	.	.	.	.	.	;Sec:0:Seq_4:217	:1:6:4	ry:0:en:0
i7	303.25	1.125	70	158.5916	.	.	.	.	.	.	.	;Sec:0:Seq_4:218	:2:5:7	ry:0:en:0
i7	304.375	0.375	0	185.0017	.	.	.	.	.	.	.	;Sec:0:Seq_4:219	:3:9:7	ry:0:en:0
i7	304.75	1.875	70	830.6298	.	.	.	.	.	.	.	;Sec:0:Seq_4:220	:4:C:9	ry:0:en:0
i7	306.625	1.125	70	565.1563	.	.	.	.	.	.	.	;Sec:0:Seq_4:221	:5:2:9	ry:0:en:0
i7	307.75	2.25	0	293.6719	.	.	.	.	.	.	.	;Sec:0:Seq_4:222	:6:3:8	ry:0:en:0
i7	310	0.375	70	130.816	.	.	.	.	.	.	.	;Sec:0:Seq_4:223	:7:0:7	ry:0:en:0
i7	310.375	0.375	70	466.1752	.	.	.	.	.	.	.	;Sec:0:Seq_4:224	:8:F:8	ry:0:en:0
i7	310.75	0.375	70	484.4769	.	.	.	.	.	.	.	;Sec:0:Seq_4:225	:9:G:8	ry:0:en:0
i7	311.125	0.375	70	769.0591	.	.	.	.	.	.	.	;Sec:0:Seq_4:226	:10:A:9	ry:0:en:0
i7	311.5	1.875	70	863.2397	.	.	.	.	.	.	.	;Sec:0:Seq_4:227	:11:D:9	ry:0:en:0
i7	313.375	0.375	70	16.9939	.	.	.	.	.	.	.	;Sec:0:Seq_4:228	:12:1:4	ry:0:en:0
i7	313.75	0.375	70	712.0524	.	.	.	.	.	.	.	;Sec:0:Seq_4:229	:13:8:9	ry:0:en:0
i7	314.125	4.5	70	171.2884	.	.	.	.	.	.	.	;Sec:0:Seq_4:230	:14:7:7	ry:0:en:0
i7	318.625	2.625	70	199.8129	.	.	.	.	.	.	.	;Sec:0:Seq_4:231	:15:B:7	ry:0:en:0
i7	321.25	0.375	70	448.5649	.	.	.	.	.	.	.	;Sec:0:Seq_4:232	:16:E:8	ry:0:en:0
i7	321.625	0.375	70	19.0750	.	.	.	.	.	.	.	;Sec:0:Seq_4:233	:17:4:4	ry:0:en:0
i7	322	0.375	70	415.3149	.	.	.	.	.	.	.	;Sec:0:Seq_4:234	:0:C:8	ry:0:en:0
i7	322.375	0.375	70	565.1563	.	.	.	.	.	.	.	;Sec:0:Seq_4:235	:1:2:9	ry:0:en:0
i7	322.75	1.125	0	158.5916	.	.	.	.	.	.	.	;Sec:0:Seq_4:236	:2:5:7	ry:0:en:0
i7	323.875	0.375	70	370.0035	.	.	.	.	.	.	.	;Sec:0:Seq_4:237	:3:9:8	ry:0:en:0
i7	324.25	0.375	70	712.0524	.	.	.	.	.	.	.	;Sec:0:Seq_4:238	:4:8:9	ry:0:en:0
i7	324.625	4.125	0	466.1752	.	.	.	.	.	.	.	;Sec:0:Seq_4:239	:5:F:8	ry:0:en:0
i7	328.75	2.25	70	146.8359	.	.	.	.	.	.	.	;Sec:0:Seq_4:240	:6:3:7	ry:0:en:0
i7	331	4.5	70	659.2713	.	.	.	.	.	.	.	;Sec:0:Seq_4:241	:7:6:9	ry:0:en:0
i7	335.5	0.375	70	261.632	.	.	.	.	.	.	.	;Sec:0:Seq_4:242	:8:0:8	ry:0:en:0
i7	335.875	0.375	70	33.9879	.	.	.	.	.	.	.	;Sec:0:Seq_4:243	:9:1:5	ry:0:en:0
i7	336.25	0.375	70	242.2384	.	.	.	.	.	.	.	;Sec:0:Seq_4:244	:10:G:7	ry:0:en:0
i7	336.625	1.875	70	431.6198	.	.	.	.	.	.	.	;Sec:0:Seq_4:245	:11:D:8	ry:0:en:0
i7	338.5	3	70	56.0706	.	.	.	.	.	.	.	;Sec:0:Seq_4:246	:12:E:5	ry:0:en:0
i7	341.5	2.25	70	305.2013	.	.	.	.	.	.	.	;Sec:0:Seq_4:247	:13:4:8	ry:0:en:0
i7	343.75	4.5	70	685.1538	.	.	.	.	.	.	.	;Sec:0:Seq_4:248	:14:7:9	ry:0:en:0
i7	348.25	2.625	70	399.6259	.	.	.	.	.	.	.	;Sec:0:Seq_4:249	:15:B:8	ry:0:en:0
i7	350.875	0.375	70	48.0661	.	.	.	.	.	.	.	;Sec:0:Seq_4:250	:16:A:5	ry:0:en:0
i7	351.25	0.375	70	503.4970	.	.	.	.	.	.	.	;Sec:0:Seq_4:251	:17:H:8	ry:0:en:0
i7	351.625	0.375	70	171.2884	.	.	.	.	.	.	.	;Sec:0:Seq_4:252	:0:7:7	ry:0:en:0
i7	352	0.75	70	448.5649	.	.	.	.	.	.	.	;Sec:0:Seq_4:253	:1:E:8	ry:0:en:0
i7	352.75	1.125	70	431.6198	.	.	.	.	.	.	.	;Sec:0:Seq_4:254	:2:D:8	ry:0:en:0
i7	353.875	0.375	70	503.4970	.	.	.	.	.	.	.	;Sec:0:Seq_4:255	:3:H:8	ry:0:en:0
i7	354.25	0.75	70	282.5781	.	.	.	.	.	.	.	;Sec:0:Seq_4:256	:4:2:8	ry:0:en:0
i7	355	1.125	70	384.5295	.	.	.	.	.	.	.	;Sec:0:Seq_4:257	:5:A:8	ry:0:en:0
i7	356.125	2.25	70	799.2518	.	.	.	.	.	.	.	;Sec:0:Seq_4:258	:6:B:9	ry:0:en:0
i7	358.375	0.375	70	356.0262	.	.	.	.	.	.	.	;Sec:0:Seq_4:259	:7:8:8	ry:0:en:0
i7	358.75	0.375	70	317.1832	.	.	.	.	.	.	.	;Sec:0:Seq_4:260	:8:5:8	ry:0:en:0
i7	359.125	0.75	70	164.8178	.	.	.	.	.	.	.	;Sec:0:Seq_4:261	:9:6:7	ry:0:en:0
i7	359.875	0.375	70	130.816	.	.	.	.	.	.	.	;Sec:0:Seq_4:262	:10:0:7	ry:0:en:0
i7	360.25	1.125	70	18.3544	.	.	.	.	.	.	.	;Sec:0:Seq_4:263	:11:3:4	ry:0:en:0
i7	361.375	0.375	70	23.1252	.	.	.	.	.	.	.	;Sec:0:Seq_4:264	:12:9:4	ry:0:en:0
i7	361.75	0.375	70	242.2384	.	.	.	.	.	.	.	;Sec:0:Seq_4:265	:13:G:7	ry:0:en:0
i7	362.125	4.5	0	466.1752	.	.	.	.	.	.	.	;Sec:0:Seq_4:266	:14:F:8	ry:0:en:0
i7	366.625	0.75	0	135.9517	.	.	.	.	.	.	.	;Sec:0:Seq_4:267	:15:1:7	ry:0:en:0
i7	367.375	0.375	70	76.3003	.	.	.	.	.	.	.	;Sec:0:Seq_4:268	:16:4:6	ry:0:en:0
i7	367.75	0.375	70	103.8287	.	.	.	.	.	.	.	;Sec:0:Seq_4:269	:17:C:6	ry:0:en:0
i7	368.125	0.375	70	282.5781	.	.	.	.	.	.	.	;Sec:0:Seq_4:270	:0:2:8	ry:0:en:0
i7	368.5	0.375	70	48.0661	.	.	.	.	.	.	.	;Sec:0:Seq_4:271	:1:A:5	ry:0:en:0
i7	368.875	1.125	70	107.9049	.	.	.	.	.	.	.	;Sec:0:Seq_4:272	:2:D:6	ry:0:en:0
i7	370	0.375	70	1006.9941	.	.	.	.	.	.	.	;Sec:0:Seq_4:273	:3:H:9	ry:0:en:0
i7	370.375	0.375	70	484.4769	.	.	.	.	.	.	.	;Sec:0:Seq_4:274	:4:G:8	ry:0:en:0
i7	370.75	3	70	79.2958	.	.	.	.	.	.	.	;Sec:0:Seq_4:275	:5:5:6	ry:0:en:0
i7	373.75	2.25	0	99.9064	.	.	.	.	.	.	.	;Sec:0:Seq_4:276	:6:B:6	ry:0:en:0
i7	376	4.5	70	448.5649	.	.	.	.	.	.	.	;Sec:0:Seq_4:277	:7:E:8	ry:0:en:0
i7	380.5	0.375	70	356.0262	.	.	.	.	.	.	.	;Sec:0:Seq_4:278	:8:8:8	ry:0:en:0
i7	380.875	0.375	70	185.0017	.	.	.	.	.	.	.	;Sec:0:Seq_4:279	:9:9:7	ry:0:en:0
i7	381.25	1.5	0	82.4089	.	.	.	.	.	.	.	;Sec:0:Seq_4:280	:10:6:6	ry:0:en:0
i7	382.75	1.125	70	36.7089	.	.	.	.	.	.	.	;Sec:0:Seq_4:281	:11:3:5	ry:0:en:0
i7	383.875	1.875	70	152.6006	.	.	.	.	.	.	.	;Sec:0:Seq_4:282	:12:4:7	ry:0:en:0
i7	385.75	2.25	70	415.3149	.	.	.	.	.	.	.	;Sec:0:Seq_4:283	:13:C:8	ry:0:en:0
i7	388	4.5	70	233.0876	.	.	.	.	.	.	.	;Sec:0:Seq_4:284	:14:F:7	ry:0:en:0
i7	392.5	0.75	70	16.9939	.	.	.	.	.	.	.	;Sec:0:Seq_4:285	:15:1:4	ry:0:en:0
i7	393.25	0.375	70	261.632	.	.	.	.	.	.	.	;Sec:0:Seq_4:286	:16:0:8	ry:0:en:0
i7	393.625	0.75	70	21.4110	.	.	.	.	.	.	.	;Sec:0:Seq_4:287	:17:7:4	ry:0:en:0
i7	394.375	0.375	70	466.1752	.	.	.	.	.	.	.	;Sec:0:Seq_4:288	:0:F:8	ry:0:en:0
i7	394.75	0.375	70	305.2013	.	.	.	.	.	.	.	;Sec:0:Seq_4:289	:1:4:8	ry:0:en:0
i7	395.125	0.75	70	293.6719	.	.	.	.	.	.	.	;Sec:0:Seq_4:290	:2:3:8	ry:0:en:0
i7	395.875	2.625	70	42.8221	.	.	.	.	.	.	.	;Sec:0:Seq_4:291	:3:7:5	ry:0:en:0
i7	398.5	0.75	0	769.0591	.	.	.	.	.	.	.	;Sec:0:Seq_4:292	:4:A:9	ry:0:en:0
i7	399.25	0.375	70	130.816	.	.	.	.	.	.	.	;Sec:0:Seq_4:293	:5:0:7	ry:0:en:0
i7	399.625	0.75	70	135.9517	.	.	.	.	.	.	.	;Sec:0:Seq_4:294	:6:1:7	ry:0:en:0
i7	400.375	0.375	70	242.2384	.	.	.	.	.	.	.	;Sec:0:Seq_4:295	:7:G:7	ry:0:en:0
i7	400.75	0.375	70	215.8099	.	.	.	.	.	.	.	;Sec:0:Seq_4:296	:8:D:7	ry:0:en:0
i7	401.125	0.75	70	448.5649	.	.	.	.	.	.	.	;Sec:0:Seq_4:297	:9:E:8	ry:0:en:0
i7	401.875	0.375	0	178.0131	.	.	.	.	.	.	.	;Sec:0:Seq_4:298	:10:8:7	ry:0:en:0
i7	402.25	1.125	70	99.9064	.	.	.	.	.	.	.	;Sec:0:Seq_4:299	:11:B:6	ry:0:en:0
i7	403.375	0.375	70	31.4685	.	.	.	.	.	.	.	;Sec:0:Seq_4:300	:12:H:4	ry:0:en:0
i7	403.75	3.75	70	82.4089	.	.	.	.	.	.	.	;Sec:0:Seq_4:301	:13:6:6	ry:0:en:0
i7	407.5	3.75	70	317.1832	.	.	.	.	.	.	.	;Sec:0:Seq_4:302	:14:5:8	ry:0:en:0
i7	411.25	0.75	70	185.0017	.	.	.	.	.	.	.	;Sec:0:Seq_4:303	:15:9:7	ry:0:en:0
i7	412	0.375	70	415.3149	.	.	.	.	.	.	.	;Sec:0:Seq_4:304	:16:C:8	ry:0:en:0
i7	412.375	0.375	70	282.5781	.	.	.	.	.	.	.	;Sec:0:Seq_4:305	:17:2:8	ry:0:en:0
i7	412.75	0.375	0	96.1323	.	.	.	.	.	.	.	;Sec:0:Seq_4:306	:0:A:6	ry:0:en:0
i7	413.125	0.375	70	261.632	.	.	.	.	.	.	.	;Sec:0:Seq_4:307	:1:0:8	ry:0:en:0
i7	413.5	0.75	70	36.7089	.	.	.	.	.	.	.	;Sec:0:Seq_4:308	:2:3:5	ry:0:en:0
i7	414.25	2.625	70	342.5769	.	.	.	.	.	.	.	;Sec:0:Seq_4:309	:3:7:8	ry:0:en:0
i7	416.875	3	70	329.6356	.	.	.	.	.	.	.	;Sec:0:Seq_4:310	:4:6:8	ry:0:en:0
i7	419.875	3	70	107.9049	.	.	.	.	.	.	.	;Sec:0:Seq_4:311	:5:D:6	ry:0:en:0
i7	422.875	0.75	70	67.9758	.	.	.	.	.	.	.	;Sec:0:Seq_4:312	:6:1:6	ry:0:en:0
i7	423.625	3.375	70	76.3003	.	.	.	.	.	.	.	;Sec:0:Seq_4:313	:7:4:6	ry:0:en:0
i7	427	0.375	70	968.9538	.	.	.	.	.	.	.	;Sec:0:Seq_4:314	:8:G:9	ry:0:en:0
i7	427.375	0.375	70	1006.9941	.	.	.	.	.	.	.	;Sec:0:Seq_4:315	:9:H:9	ry:0:en:0
i7	427.75	1.5	0	112.1412	.	.	.	.	.	.	.	;Sec:0:Seq_4:316	:10:E:6	ry:0:en:0
i7	429.25	1.125	70	199.8129	.	.	.	.	.	.	.	;Sec:0:Seq_4:317	:11:B:7	ry:0:en:0
i7	430.375	1.875	70	415.3149	.	.	.	.	.	.	.	;Sec:0:Seq_4:318	:12:C:8	ry:0:en:0
i7	432.25	1.125	70	282.5781	.	.	.	.	.	.	.	;Sec:0:Seq_4:319	:13:2:8	ry:0:en:0
i7	433.375	3.75	70	39.6479	.	.	.	.	.	.	.	;Sec:0:Seq_4:320	:14:5:5	ry:0:en:0
i7	437.125	0.75	70	370.0035	.	.	.	.	.	.	.	;Sec:0:Seq_4:321	:15:9:8	ry:0:en:0
i7	437.875	0.375	70	178.0131	.	.	.	.	.	.	.	;Sec:0:Seq_4:322	:16:8:7	ry:0:en:0
i7	438.25	0.75	70	116.5438	.	.	.	.	.	.	.	;Sec:0:Seq_4:323	:17:F:6	ry:0:en:0

; Seq_5 comments: Bass (R) oppgrad support with randocts.
;ins	sta	dur	amp	ft1	aty	atk	rel	hd1	hd2	gl1	gl2	fq1	fq2	fq3	pa1	pa2	del	car	mod	hm1	hm2	cro	buz	rvn	rvs	ft2	pcd	
i4	0	0.375	0	10	0	0	1	1	0	0	0	35.3222	35.322	35.322	0.5	0.5	0.3	1	1	0	0	0	0	0	0	24	2	;Sec:0:Seq_5:0	:0:2:5	ry:0:en:0
i4	0.375	0.375	70	.	.	.	.	.	.	.	.	207.6574	207.657	207.657	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:1	:1:C:7	ry:0:en:0
i4	0.75	0.375	70	.	.	.	.	.	.	.	.	370.0035	317.1832	370.003	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:2	:2:9:8	ry:0:en:0
i4	1.125	1.875	70	.	.	.	.	.	.	.	.	317.1832	317.183	317.183	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:3	:3:5:8	ry:0:en:0
i4	3	3	70	.	.	.	.	.	.	.	.	41.2044	41.204	41.204	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:4	:4:6:5	ry:0:en:0
i4	6	0.375	70	.	.	.	.	.	.	.	.	503.4970	503.497	503.497	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:5	:5:H:8	ry:0:en:0
i4	6.375	2.25	70	.	.	.	.	.	.	.	.	99.9064	99.906	99.906	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:6	:6:B:6	ry:0:en:0
i4	8.625	0.375	70	.	.	.	.	.	.	.	.	44.5032	44.503	44.503	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:7	:7:8:5	ry:0:en:0
i4	9	0.375	70	.	.	.	.	.	.	.	.	224.2824	224.282	224.282	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:8	:8:E:7	ry:0:en:0
i4	9.375	0.375	70	.	.	.	.	.	.	.	.	215.8099	215.809	215.809	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:9	:9:D:7	ry:0:en:0
i4	9.75	0.375	70	.	.	.	.	.	.	.	.	484.4769	271.9034	484.476	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:10	:10:G:8	ry:0:en:0
i4	10.125	0.375	70	.	.	.	.	.	.	.	.	271.9034	261.632	271.903	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:11	:11:1:8	ry:0:en:0
i4	10.5	0.375	0	.	.	.	.	.	.	.	.	261.632	261.632	261.632	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:12	:12:0:8	ry:0:en:0
i4	10.875	1.125	70	.	.	.	.	.	.	.	.	769.0591	769.059	769.059	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:13	:13:A:9	ry:0:en:0
i4	12	4.5	70	.	.	.	.	.	.	.	.	21.4110	293.6719	293.6719	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:14	:14:7:4	ry:0:en:0
i4	16.5	2.625	70	.	.	.	.	.	.	.	.	293.6719	293.671	293.671	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:15	:15:3:8	ry:0:en:0
i4	19.125	0.375	70	.	.	.	.	.	.	.	.	76.3003	116.5438	76.300	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:16	:16:4:6	ry:0:en:0
i4	19.5	0.75	70	.	.	.	.	.	.	.	.	116.5438	171.2884	171.2884	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:17	:17:F:6	ry:0:en:0
i4	20.25	0.375	0	.	.	.	.	.	.	.	.	171.2884	171.288	171.288	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:18	:0:7:7	ry:0:en:0
i4	20.625	0.375	70	.	.	.	.	.	.	.	.	261.632	261.632	261.632	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:19	:1:0:8	ry:0:en:0
i4	21	0.375	70	.	.	.	.	.	.	.	.	16.9939	233.0876	233.0876	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:20	:2:1:4	ry:0:en:0
i4	21.375	2.625	70	.	.	.	.	.	.	.	.	233.0876	233.087	233.087	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:21	:3:F:7	ry:0:en:0
i4	24	1.875	70	.	.	.	.	.	.	.	.	415.3149	415.314	415.314	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:22	:4:C:8	ry:0:en:0
i4	25.875	2.25	70	.	.	.	.	.	.	.	.	152.6006	152.600	152.600	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:23	:5:4:7	ry:0:en:0
i4	28.125	2.25	70	.	.	.	.	.	.	.	.	293.6719	293.671	293.671	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:24	:6:3:8	ry:0:en:0
i4	30.375	4.5	0	.	.	.	.	.	.	.	.	82.4089	185.0017	82.408	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:25	:7:6:6	ry:0:en:0
i4	34.875	0.375	70	.	.	.	.	.	.	.	.	185.0017	356.0262	356.0262	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:26	:8:9:7	ry:0:en:0
i4	35.25	0.375	70	.	.	.	.	.	.	.	.	356.0262	356.026	356.026	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:27	:9:8:8	ry:0:en:0
i4	35.625	1.5	70	.	.	.	.	.	.	.	.	224.2824	49.9532	49.9532	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:28	:10:E:7	ry:0:en:0
i4	37.125	1.125	70	.	.	.	.	.	.	.	.	49.9532	19.8239	49.953	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:29	:11:B:5	ry:0:en:0
i4	38.25	2.25	70	.	.	.	.	.	.	.	.	19.8239	19.823	19.823	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:30	:12:5:4	ry:0:en:0
i4	40.5	0.375	70	.	.	.	.	.	.	.	.	121.1192	121.119	121.119	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:31	:13:G:6	ry:0:en:0
i4	40.875	0.75	70	.	.	.	.	.	.	.	.	503.4970	503.497	503.497	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:32	:14:H:8	ry:0:en:0
i4	41.625	4.125	70	.	.	.	.	.	.	.	.	215.8099	215.809	215.809	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:33	:15:D:7	ry:0:en:0
i4	45.75	0.375	70	.	.	.	.	.	.	.	.	96.1323	96.132	96.132	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:34	:16:A:6	ry:0:en:0
i4	46.125	0.375	70	.	.	.	.	.	.	.	.	70.6445	207.6574	70.644	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:35	:17:2:6	ry:0:en:0
i4	46.5	0.375	70	.	.	.	.	.	.	.	.	207.6574	207.657	207.657	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:36	:0:C:7	ry:0:en:0
i4	46.875	0.375	70	.	.	.	.	.	.	.	.	152.6006	152.600	152.600	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:37	:1:4:7	ry:0:en:0
i4	47.25	0.375	70	.	.	.	.	.	.	.	.	135.9517	135.951	135.951	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:38	:2:1:7	ry:0:en:0
i4	47.625	2.625	70	.	.	.	.	.	.	.	.	58.2719	58.271	58.271	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:39	:3:F:5	ry:0:en:0
i4	50.25	0.375	0	.	.	.	.	.	.	.	.	484.4769	92.5008	484.476	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:40	:4:G:8	ry:0:en:0
i4	50.625	0.375	70	.	.	.	.	.	.	.	.	92.5008	293.6719	293.6719	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:41	:5:9:6	ry:0:en:0
i4	51	2.25	70	.	.	.	.	.	.	.	.	293.6719	293.671	293.671	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:42	:6:3:8	ry:0:en:0
i4	53.25	0.375	70	.	.	.	.	.	.	.	.	523.264	523.264	523.264	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:43	:7:0:9	ry:0:en:0
i4	53.625	0.375	70	.	.	.	.	.	.	.	.	164.8178	164.817	164.817	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:44	:8:6:7	ry:0:en:0
i4	54	0.375	70	.	.	.	.	.	.	.	.	634.3665	634.366	634.366	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:45	:9:5:9	ry:0:en:0
i4	54.375	0.375	70	.	.	.	.	.	.	.	.	89.0065	89.006	89.006	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:46	:10:8:6	ry:0:en:0
i4	54.75	1.125	70	.	.	.	.	.	.	.	.	399.6259	399.625	399.625	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:47	:11:B:8	ry:0:en:0
i4	55.875	0.75	70	.	.	.	.	.	.	.	.	192.2647	141.2890	141.2890	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:48	:12:A:7	ry:0:en:0
i4	56.625	1.125	70	.	.	.	.	.	.	.	.	141.2890	141.289	141.289	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:49	:13:2:7	ry:0:en:0
i4	57.75	0.75	70	.	.	.	.	.	.	.	.	1006.9941	1006.994	1006.994	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:50	:14:H:9	ry:0:en:0
i4	58.5	4.125	70	.	.	.	.	.	.	.	.	53.9524	112.1412	53.952	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:51	:15:D:5	ry:0:en:0
i4	62.625	0.375	0	.	.	.	.	.	.	.	.	112.1412	112.141	112.141	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:52	:16:E:6	ry:0:en:0
i4	63	0.75	70	.	.	.	.	.	.	.	.	342.5769	342.576	342.576	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:53	:17:7:8	ry:0:en:0
i4	63.75	0.375	70	.	.	.	.	.	.	.	.	1006.9941	1006.994	1006.994	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:54	:0:H:9	ry:0:en:0
i4	64.125	0.375	70	.	.	.	.	.	.	.	.	384.5295	384.529	384.529	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:55	:1:A:8	ry:0:en:0
i4	64.5	0.75	70	.	.	.	.	.	.	.	.	399.6259	342.5769	342.5769	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:56	:2:B:8	ry:0:en:0
i4	65.25	2.625	70	.	.	.	.	.	.	.	.	342.5769	342.576	342.576	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:57	:3:7:8	ry:0:en:0
i4	67.875	1.875	70	.	.	.	.	.	.	.	.	152.6006	448.5649	152.600	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:58	:4:4:7	ry:0:en:0
i4	69.75	3.75	70	.	.	.	.	.	.	.	.	448.5649	448.564	448.564	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:59	:5:E:8	ry:0:en:0
i4	73.5	3.75	0	.	.	.	.	.	.	.	.	863.2397	863.239	863.239	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:60	:6:D:9	ry:0:en:0
i4	77.25	0.375	70	.	.	.	.	.	.	.	.	484.4769	484.476	484.476	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:61	:7:G:8	ry:0:en:0
i4	77.625	0.375	70	.	.	.	.	.	.	.	.	543.8069	543.806	543.806	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:62	:8:1:9	ry:0:en:0
i4	78	0.375	70	.	.	.	.	.	.	.	.	65.408	65.408	65.408	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:63	:9:0:6	ry:0:en:0
i4	78.375	1.5	0	.	.	.	.	.	.	.	.	329.6356	329.635	329.635	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:64	:10:6:8	ry:0:en:0
i4	79.875	1.125	70	.	.	.	.	.	.	.	.	146.8359	146.835	146.835	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:65	:11:3:7	ry:0:en:0
i4	81	3.375	70	.	.	.	.	.	.	.	.	233.0876	233.087	233.087	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:66	:12:F:7	ry:0:en:0
i4	84.375	0.375	70	.	.	.	.	.	.	.	.	356.0262	356.026	356.026	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:67	:13:8:8	ry:0:en:0
i4	84.75	0.75	70	.	.	.	.	.	.	.	.	740.0070	740.007	740.007	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:68	:14:9:9	ry:0:en:0
i4	85.5	4.125	70	.	.	.	.	.	.	.	.	158.5916	158.591	158.591	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:69	:15:5:7	ry:0:en:0
i4	89.625	0.375	70	.	.	.	.	.	.	.	.	282.5781	282.578	282.578	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:70	:16:2:8	ry:0:en:0
i4	90	0.375	70	.	.	.	.	.	.	.	.	207.6574	610.4026	207.657	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:71	:17:C:7	ry:0:en:0
i4	90.375	0.375	70	.	.	.	.	.	.	.	.	610.4026	28.0353	610.402	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:72	:0:4:9	ry:0:en:0
i4	90.75	0.75	70	.	.	.	.	.	.	.	.	28.0353	28.035	28.035	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:73	:1:E:4	ry:0:en:0
i4	91.5	0.75	70	.	.	.	.	.	.	.	.	99.9064	99.906	99.906	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:74	:2:B:6	ry:0:en:0
i4	92.25	2.625	70	.	.	.	.	.	.	.	.	85.6442	85.644	85.644	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:75	:3:7:6	ry:0:en:0
i4	94.875	0.375	70	.	.	.	.	.	.	.	.	89.0065	89.006	89.006	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:76	:4:8:6	ry:0:en:0
i4	95.25	0.375	70	.	.	.	.	.	.	.	.	271.9034	271.903	271.903	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:77	:5:1:8	ry:0:en:0
i4	95.625	3.75	70	.	.	.	.	.	.	.	.	26.9762	26.976	26.976	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:78	:6:D:4	ry:0:en:0
i4	99.375	1.5	70	.	.	.	.	.	.	.	.	192.2647	484.4769	192.264	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:79	:7:A:7	ry:0:en:0
i4	100.875	0.375	70	.	.	.	.	.	.	.	.	484.4769	484.476	484.476	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:80	:8:G:8	ry:0:en:0
i4	101.25	0.75	0	.	.	.	.	.	.	.	.	233.0876	261.632	233.087	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:81	:9:F:7	ry:0:en:0
i4	102	0.375	70	.	.	.	.	.	.	.	.	261.632	261.632	261.632	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:82	:10:0:8	ry:0:en:0
i4	102.375	1.125	70	.	.	.	.	.	.	.	.	146.8359	146.835	146.835	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:83	:11:3:7	ry:0:en:0
i4	103.5	0.75	70	.	.	.	.	.	.	.	.	141.2890	415.3149	415.3149	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:84	:12:2:7	ry:0:en:0
i4	104.25	2.25	70	.	.	.	.	.	.	.	.	415.3149	415.314	415.314	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:85	:13:C:8	ry:0:en:0
i4	106.5	0.75	0	.	.	.	.	.	.	.	.	370.0035	370.003	370.003	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:86	:14:9:8	ry:0:en:0
i4	107.25	4.125	70	.	.	.	.	.	.	.	.	19.8239	164.8178	19.823	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:87	:15:5:4	ry:0:en:0
i4	111.375	0.375	70	.	.	.	.	.	.	.	.	164.8178	164.817	164.817	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:88	:16:6:7	ry:0:en:0
i4	111.75	0.375	70	.	.	.	.	.	.	.	.	503.4970	503.497	503.497	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:89	:17:H:8	ry:0:en:0
i4	112.125	0.375	70	.	.	.	.	.	.	.	.	92.5008	92.500	92.500	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:90	:0:9:6	ry:0:en:0
i4	112.5	0.375	70	.	.	.	.	.	.	.	.	70.6445	73.4179	73.4179	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:91	:1:2:6	ry:0:en:0
i4	112.875	0.75	0	.	.	.	.	.	.	.	.	73.4179	73.417	73.417	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:92	:2:3:6	ry:0:en:0
i4	113.625	0.375	0	.	.	.	.	.	.	.	.	251.7485	251.748	251.748	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:93	:3:H:7	ry:0:en:0
i4	114	3	70	.	.	.	.	.	.	.	.	448.5649	164.8178	448.564	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:94	:4:E:8	ry:0:en:0
i4	117	3.75	70	.	.	.	.	.	.	.	.	164.8178	164.817	164.817	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:95	:5:6:7	ry:0:en:0
i4	120.75	3.75	70	.	.	.	.	.	.	.	.	317.1832	317.183	317.183	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:96	:6:5:8	ry:0:en:0
i4	124.5	0.375	70	.	.	.	.	.	.	.	.	178.0131	178.013	178.013	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:97	:7:8:7	ry:0:en:0
i4	124.875	0.375	70	.	.	.	.	.	.	.	.	24.9766	96.1323	24.976	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:98	:8:B:4	ry:0:en:0
i4	125.25	0.375	70	.	.	.	.	.	.	.	.	96.1323	96.132	96.132	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:99	:9:A:6	ry:0:en:0
i4	125.625	0.375	70	.	.	.	.	.	.	.	.	484.4769	431.6198	484.476	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:100	:10:G:8	ry:0:en:0
i4	126	1.875	70	.	.	.	.	.	.	.	.	431.6198	431.619	431.619	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:101	:11:D:8	ry:0:en:0
i4	127.875	3.375	70	.	.	.	.	.	.	.	.	85.6442	523.264	85.644	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:102	:12:7:6	ry:0:en:0
i4	131.25	0.375	70	.	.	.	.	.	.	.	.	523.264	523.264	523.264	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:103	:13:0:9	ry:0:en:0
i4	131.625	0.75	70	.	.	.	.	.	.	.	.	135.9517	135.951	135.951	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:104	:14:1:7	ry:0:en:0
i4	132.375	4.5	70	.	.	.	.	.	.	.	.	233.0876	103.8287	233.087	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:105	:15:F:7	ry:0:en:0
i4	136.875	0.375	70	.	.	.	.	.	.	.	.	103.8287	305.2013	103.828	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:106	:16:C:6	ry:0:en:0
i4	137.25	0.375	70	.	.	.	.	.	.	.	.	305.2013	305.201	305.201	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:107	:17:4:8	ry:0:en:0
i4	137.625	0.375	70	.	.	.	.	.	.	.	.	224.2824	224.282	224.282	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:108	:0:E:7	ry:0:en:0
i4	138	0.75	70	.	.	.	.	.	.	.	.	329.6356	329.635	329.635	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:109	:1:6:8	ry:0:en:0
i4	138.75	0.75	70	.	.	.	.	.	.	.	.	293.6719	293.671	293.671	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:110	:2:3:8	ry:0:en:0
i4	139.5	0.375	70	.	.	.	.	.	.	.	.	1006.9941	1006.994	1006.994	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:111	:3:H:9	ry:0:en:0
i4	139.875	0.375	70	.	.	.	.	.	.	.	.	16.352	16.352	16.352	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:112	:4:0:4	ry:0:en:0
i4	140.25	1.875	0	.	.	.	.	.	.	.	.	99.9064	317.1832	317.1832	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:113	:5:B:6	ry:0:en:0
i4	142.125	3.75	0	.	.	.	.	.	.	.	.	317.1832	317.183	317.183	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:114	:6:5:8	ry:0:en:0
i4	145.875	1.5	70	.	.	.	.	.	.	.	.	282.5781	282.578	282.578	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:115	:7:2:8	ry:0:en:0
i4	147.375	0.375	70	.	.	.	.	.	.	.	.	356.0262	85.6442	85.6442	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:116	:8:8:8	ry:0:en:0
i4	147.75	0.75	70	.	.	.	.	.	.	.	.	85.6442	85.644	85.644	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:117	:9:7:6	ry:0:en:0
i4	148.5	0.375	70	.	.	.	.	.	.	.	.	192.2647	192.264	192.264	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:118	:10:A:7	ry:0:en:0
i4	148.875	1.875	70	.	.	.	.	.	.	.	.	431.6198	415.3149	431.619	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:119	:11:D:8	ry:0:en:0
i4	150.75	1.875	70	.	.	.	.	.	.	.	.	415.3149	415.314	415.314	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:120	:12:C:8	ry:0:en:0
i4	152.625	2.25	70	.	.	.	.	.	.	.	.	610.4026	610.402	610.402	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:121	:13:4:9	ry:0:en:0
i4	154.875	0.75	70	.	.	.	.	.	.	.	.	543.8069	116.5438	116.5438	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:122	:14:1:9	ry:0:en:0
i4	155.625	4.5	70	.	.	.	.	.	.	.	.	116.5438	116.543	116.543	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:123	:15:F:6	ry:0:en:0
i4	160.125	0.375	70	.	.	.	.	.	.	.	.	121.1192	121.119	121.119	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:124	:16:G:6	ry:0:en:0
i4	160.5	0.375	70	.	.	.	.	.	.	.	.	185.0017	185.001	185.001	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:125	:17:9:7	ry:0:en:0
i4	160.875	0.375	70	.	.	.	.	.	.	.	.	16.9939	16.993	16.993	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:126	:0:1:4	ry:0:en:0
i4	161.25	0.375	70	.	.	.	.	.	.	.	.	25.9571	25.957	25.957	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:127	:1:C:4	ry:0:en:0
i4	161.625	1.125	70	.	.	.	.	.	.	.	.	431.6198	431.619	431.619	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:128	:2:D:8	ry:0:en:0
i4	162.75	0.375	70	.	.	.	.	.	.	.	.	185.0017	185.001	185.001	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:129	:3:9:7	ry:0:en:0
i4	163.125	3	70	.	.	.	.	.	.	.	.	164.8178	164.817	164.817	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:130	:4:6:7	ry:0:en:0
i4	166.125	0.375	70	.	.	.	.	.	.	.	.	484.4769	58.2719	58.2719	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:131	:5:G:8	ry:0:en:0
i4	166.5	4.5	70	.	.	.	.	.	.	.	.	58.2719	58.271	58.271	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:132	:6:F:5	ry:0:en:0
i4	171	0.375	70	.	.	.	.	.	.	.	.	65.408	65.408	65.408	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:133	:7:0:6	ry:0:en:0
i4	171.375	0.375	70	.	.	.	.	.	.	.	.	146.8359	146.835	146.835	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:134	:8:3:7	ry:0:en:0
i4	171.75	0.375	70	.	.	.	.	.	.	.	.	35.3222	35.322	35.322	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:135	:9:2:5	ry:0:en:0
i4	172.125	0.375	70	.	.	.	.	.	.	.	.	356.0262	356.026	356.026	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:136	:10:8:8	ry:0:en:0
i4	172.5	1.875	70	.	.	.	.	.	.	.	.	634.3665	62.9371	62.9371	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:137	:11:5:9	ry:0:en:0
i4	174.375	0.375	0	.	.	.	.	.	.	.	.	62.9371	62.937	62.937	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:138	:12:H:5	ry:0:en:0
i4	174.75	1.125	70	.	.	.	.	.	.	.	.	96.1323	96.132	96.132	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:139	:13:A:6	ry:0:en:0
i4	175.875	2.25	70	.	.	.	.	.	.	.	.	199.8129	199.812	199.812	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:140	:14:B:7	ry:0:en:0
i4	178.125	4.5	70	.	.	.	.	.	.	.	.	21.4110	21.411	21.411	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:141	:15:7:4	ry:0:en:0
i4	182.625	0.375	70	.	.	.	.	.	.	.	.	152.6006	152.600	152.600	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:142	:16:4:7	ry:0:en:0
i4	183	0.75	0	.	.	.	.	.	.	.	.	448.5649	448.564	448.564	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:143	:17:E:8	ry:0:en:0
i4	183.75	0.375	70	.	.	.	.	.	.	.	.	82.4089	82.408	82.408	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:144	:0:6:6	ry:0:en:0
i4	184.125	0.375	70	.	.	.	.	.	.	.	.	121.1192	121.119	121.119	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:145	:1:G:6	ry:0:en:0
i4	184.5	1.125	70	.	.	.	.	.	.	.	.	431.6198	431.619	431.619	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:146	:2:D:8	ry:0:en:0
i4	185.625	0.375	70	.	.	.	.	.	.	.	.	370.0035	384.5295	384.5295	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:147	:3:9:8	ry:0:en:0
i4	186	0.75	70	.	.	.	.	.	.	.	.	384.5295	384.529	384.529	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:148	:4:A:8	ry:0:en:0
i4	186.75	1.875	70	.	.	.	.	.	.	.	.	146.8359	146.835	146.835	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:149	:5:3:7	ry:0:en:0
i4	188.625	4.5	70	.	.	.	.	.	.	.	.	466.1752	25.9571	466.175	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:150	:6:F:8	ry:0:en:0
i4	193.125	3.375	70	.	.	.	.	.	.	.	.	25.9571	25.957	25.957	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:151	:7:C:4	ry:0:en:0
i4	196.5	0.375	0	.	.	.	.	.	.	.	.	130.816	130.816	130.816	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:152	:8:0:7	ry:0:en:0
i4	196.875	0.375	70	.	.	.	.	.	.	.	.	503.4970	503.497	503.497	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:153	:9:H:8	ry:0:en:0
i4	197.25	0.375	70	.	.	.	.	.	.	.	.	70.6445	70.644	70.644	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:154	:10:2:6	ry:0:en:0
i4	197.625	1.875	70	.	.	.	.	.	.	.	.	317.1832	610.4026	317.183	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:155	:11:5:8	ry:0:en:0
i4	199.5	1.875	70	.	.	.	.	.	.	.	.	610.4026	610.402	610.402	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:156	:12:4:9	ry:0:en:0
i4	201.375	3.75	70	.	.	.	.	.	.	.	.	112.1412	112.141	112.141	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:157	:13:E:6	ry:0:en:0
i4	205.125	2.25	70	.	.	.	.	.	.	.	.	399.6259	399.625	399.625	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:158	:14:B:8	ry:0:en:0
i4	207.375	4.5	70	.	.	.	.	.	.	.	.	171.2884	89.0065	89.0065	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:159	:15:7:7	ry:0:en:0
i4	211.875	0.375	0	.	.	.	.	.	.	.	.	89.0065	89.006	89.006	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:160	:16:8:6	ry:0:en:0
i4	212.25	0.375	70	.	.	.	.	.	.	.	.	135.9517	24.9766	24.9766	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:161	:17:1:7	ry:0:en:0
i4	212.625	0.375	70	.	.	.	.	.	.	.	.	24.9766	305.2013	24.976	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:162	:0:B:4	ry:0:en:0
i4	213	0.375	70	.	.	.	.	.	.	.	.	305.2013	305.201	305.201	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:163	:1:4:8	ry:0:en:0
i4	213.375	1.125	70	.	.	.	.	.	.	.	.	317.1832	317.183	317.183	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:164	:2:5:8	ry:0:en:0
i4	214.5	0.375	70	.	.	.	.	.	.	.	.	16.9939	242.2384	242.2384	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:165	:3:1:4	ry:0:en:0
i4	214.875	0.375	0	.	.	.	.	.	.	.	.	242.2384	242.238	242.238	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:166	:4:G:7	ry:0:en:0
i4	215.25	0.375	70	.	.	.	.	.	.	.	.	178.0131	178.013	178.013	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:167	:5:8:7	ry:0:en:0
i4	215.625	4.5	70	.	.	.	.	.	.	.	.	342.5769	342.576	342.576	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:168	:6:7:8	ry:0:en:0
i4	220.125	1.5	70	.	.	.	.	.	.	.	.	96.1323	96.132	96.132	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:169	:7:A:6	ry:0:en:0
i4	221.625	0.375	70	.	.	.	.	.	.	.	.	215.8099	215.809	215.809	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:170	:8:D:7	ry:0:en:0
i4	222	0.375	70	.	.	.	.	.	.	.	.	830.6298	261.632	830.629	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:171	:9:C:9	ry:0:en:0
i4	222.375	0.375	70	.	.	.	.	.	.	.	.	261.632	261.632	261.632	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:172	:10:0:8	ry:0:en:0
i4	222.75	2.625	70	.	.	.	.	.	.	.	.	116.5438	185.0017	116.543	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:173	:11:F:6	ry:0:en:0
i4	225.375	0.375	70	.	.	.	.	.	.	.	.	185.0017	185.001	185.001	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:174	:12:9:7	ry:0:en:0
i4	225.75	1.125	70	.	.	.	.	.	.	.	.	70.6445	70.644	70.644	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:175	:13:2:6	ry:0:en:0
i4	226.875	2.25	70	.	.	.	.	.	.	.	.	146.8359	1006.9941	1006.9941	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:176	:14:3:7	ry:0:en:0
i4	229.125	0.75	70	.	.	.	.	.	.	.	.	1006.9941	224.2824	1006.994	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:177	:15:H:9	ry:0:en:0
i4	229.875	0.375	0	.	.	.	.	.	.	.	.	224.2824	41.2044	224.282	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:178	:16:E:7	ry:0:en:0
i4	230.25	0.75	70	.	.	.	.	.	.	.	.	41.2044	242.2384	41.204	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:179	:17:6:5	ry:0:en:0
i4	231	0.375	70	.	.	.	.	.	.	.	.	242.2384	242.238	242.238	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:180	:0:G:7	ry:0:en:0
i4	231.375	0.375	70	.	.	.	.	.	.	.	.	89.0065	19.8239	89.006	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:181	:1:8:6	ry:0:en:0
i4	231.75	1.125	70	.	.	.	.	.	.	.	.	19.8239	19.823	19.823	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:182	:2:5:4	ry:0:en:0
i4	232.875	0.375	70	.	.	.	.	.	.	.	.	543.8069	543.806	543.806	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:183	:3:1:9	ry:0:en:0
i4	233.25	0.75	70	.	.	.	.	.	.	.	.	70.6445	70.644	70.644	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:184	:4:2:6	ry:0:en:0
i4	234	3	70	.	.	.	.	.	.	.	.	215.8099	215.809	215.809	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:185	:5:D:7	ry:0:en:0
i4	237	4.5	70	.	.	.	.	.	.	.	.	171.2884	19.0750	171.288	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:186	:6:7:7	ry:0:en:0
i4	241.5	3.375	70	.	.	.	.	.	.	.	.	19.0750	19.075	19.075	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:187	:7:4:4	ry:0:en:0
i4	244.875	0.375	0	.	.	.	.	.	.	.	.	769.0591	769.059	769.059	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:188	:8:A:9	ry:0:en:0
i4	245.25	0.375	70	.	.	.	.	.	.	.	.	370.0035	370.003	370.003	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:189	:9:9:8	ry:0:en:0
i4	245.625	0.75	0	.	.	.	.	.	.	.	.	830.6298	233.0876	830.629	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:190	:10:C:9	ry:0:en:0
i4	246.375	2.625	70	.	.	.	.	.	.	.	.	233.0876	233.087	233.087	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:191	:11:F:7	ry:0:en:0
i4	249	3	70	.	.	.	.	.	.	.	.	448.5649	82.4089	448.564	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:192	:12:E:8	ry:0:en:0
i4	252	3.75	70	.	.	.	.	.	.	.	.	82.4089	82.408	82.408	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:193	:13:6:6	ry:0:en:0
i4	255.75	2.25	70	.	.	.	.	.	.	.	.	146.8359	146.835	146.835	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:194	:14:3:7	ry:0:en:0
i4	258	0.75	70	.	.	.	.	.	.	.	.	251.7485	251.748	251.748	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:195	:15:H:7	ry:0:en:0
i4	258.75	0.375	70	.	.	.	.	.	.	.	.	261.632	261.632	261.632	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:196	:16:0:8	ry:0:en:0
i4	259.125	0.375	70	.	.	.	.	.	.	.	.	799.2518	799.251	799.251	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:197	:17:B:9	ry:0:en:0
i4	259.5	0.375	70	.	.	.	.	.	.	.	.	293.6719	293.671	293.671	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:198	:0:3:8	ry:0:en:0
i4	259.875	0.75	70	.	.	.	.	.	.	.	.	224.2824	224.282	224.282	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:199	:1:E:7	ry:0:en:0
i4	260.625	1.5	70	.	.	.	.	.	.	.	.	466.1752	466.175	466.175	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:200	:2:F:8	ry:0:en:0
i4	262.125	1.125	70	.	.	.	.	.	.	.	.	199.8129	199.812	199.812	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:201	:3:B:7	ry:0:en:0
i4	263.25	0.375	70	.	.	.	.	.	.	.	.	178.0131	130.816	130.816	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:202	:4:8:7	ry:0:en:0
i4	263.625	0.375	70	.	.	.	.	.	.	.	.	130.816	1006.9941	130.816	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:203	:5:0:7	ry:0:en:0
i4	264	0.75	70	.	.	.	.	.	.	.	.	1006.9941	1006.994	1006.994	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:204	:6:H:9	ry:0:en:0
i4	264.75	1.5	70	.	.	.	.	.	.	.	.	565.1563	565.156	565.156	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:205	:7:2:9	ry:0:en:0
i4	266.25	0.375	70	.	.	.	.	.	.	.	.	634.3665	634.366	634.366	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:206	:8:5:9	ry:0:en:0
i4	266.625	0.375	70	.	.	.	.	.	.	.	.	610.4026	610.402	610.402	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:207	:9:4:9	ry:0:en:0
i4	267	0.375	70	.	.	.	.	.	.	.	.	192.2647	171.2884	192.264	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:208	:10:A:7	ry:0:en:0
i4	267.375	2.625	70	.	.	.	.	.	.	.	.	171.2884	171.288	171.288	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:209	:11:7:7	ry:0:en:0
i4	270	0.375	70	.	.	.	.	.	.	.	.	135.9517	135.951	135.951	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:210	:12:1:7	ry:0:en:0
i4	270.375	2.25	0	.	.	.	.	.	.	.	.	51.9143	51.914	51.914	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:211	:13:C:5	ry:0:en:0
i4	272.625	3.75	0	.	.	.	.	.	.	.	.	107.9049	107.904	107.904	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:212	:14:D:6	ry:0:en:0
i4	276.375	0.75	70	.	.	.	.	.	.	.	.	92.5008	92.500	92.500	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:213	:15:9:6	ry:0:en:0
i4	277.125	0.375	70	.	.	.	.	.	.	.	.	82.4089	60.5596	60.5596	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:214	:16:6:6	ry:0:en:0
i4	277.5	0.375	70	.	.	.	.	.	.	.	.	60.5596	60.559	60.559	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:215	:17:G:5	ry:0:en:0
i4	277.875	0.375	0	.	.	.	.	.	.	.	.	178.0131	178.013	178.013	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:216	:0:8:7	ry:0:en:0
i4	278.25	0.375	70	.	.	.	.	.	.	.	.	261.632	261.632	261.632	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:217	:1:0:8	ry:0:en:0
i4	278.625	1.5	70	.	.	.	.	.	.	.	.	233.0876	233.087	233.087	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:218	:2:F:7	ry:0:en:0
i4	280.125	1.125	70	.	.	.	.	.	.	.	.	199.8129	415.3149	199.812	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:219	:3:B:7	ry:0:en:0
i4	281.25	1.875	70	.	.	.	.	.	.	.	.	415.3149	39.6479	415.314	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:220	:4:C:8	ry:0:en:0
i4	283.125	3	70	.	.	.	.	.	.	.	.	39.6479	39.647	39.647	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:221	:5:5:5	ry:0:en:0
i4	286.125	0.75	70	.	.	.	.	.	.	.	.	503.4970	503.497	503.497	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:222	:6:H:8	ry:0:en:0
i4	286.875	4.5	70	.	.	.	.	.	.	.	.	112.1412	112.141	112.141	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:223	:7:E:6	ry:0:en:0
i4	291.375	0.375	0	.	.	.	.	.	.	.	.	282.5781	543.8069	543.8069	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:224	:8:2:8	ry:0:en:0
i4	291.75	0.375	70	.	.	.	.	.	.	.	.	543.8069	543.806	543.806	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:225	:9:1:9	ry:0:en:0
i4	292.125	0.75	70	.	.	.	.	.	.	.	.	610.4026	610.402	610.402	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:226	:10:4:9	ry:0:en:0
i4	292.875	2.625	70	.	.	.	.	.	.	.	.	42.8221	42.822	42.822	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:227	:11:7:5	ry:0:en:0
i4	295.5	3	70	.	.	.	.	.	.	.	.	164.8178	164.817	164.817	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:228	:12:6:7	ry:0:en:0
i4	298.5	0.375	70	.	.	.	.	.	.	.	.	30.2798	30.279	30.279	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:229	:13:G:4	ry:0:en:0
i4	298.875	3.75	70	.	.	.	.	.	.	.	.	431.6198	431.619	431.619	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:230	:14:D:8	ry:0:en:0
i4	302.625	0.75	70	.	.	.	.	.	.	.	.	185.0017	185.001	185.001	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:231	:15:9:7	ry:0:en:0
i4	303.375	0.375	70	.	.	.	.	.	.	.	.	192.2647	587.3439	192.264	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:232	:16:A:7	ry:0:en:0
i4	303.75	0.375	70	.	.	.	.	.	.	.	.	587.3439	107.9049	587.343	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:233	:17:3:9	ry:0:en:0
i4	304.125	0.375	70	.	.	.	.	.	.	.	.	107.9049	164.8178	107.904	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:234	:0:D:6	ry:0:en:0
i4	304.5	0.75	70	.	.	.	.	.	.	.	.	164.8178	164.817	164.817	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:235	:1:6:7	ry:0:en:0
i4	305.25	1.5	70	.	.	.	.	.	.	.	.	171.2884	293.6719	293.6719	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:236	:2:7:7	ry:0:en:0
i4	306.75	1.125	70	.	.	.	.	.	.	.	.	293.6719	261.632	293.671	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:237	:3:3:8	ry:0:en:0
i4	307.875	0.375	70	.	.	.	.	.	.	.	.	261.632	96.1323	261.632	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:238	:4:0:8	ry:0:en:0
i4	308.25	1.125	70	.	.	.	.	.	.	.	.	96.1323	185.0017	185.0017	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:239	:5:A:6	ry:0:en:0
i4	309.375	0.75	0	.	.	.	.	.	.	.	.	185.0017	185.001	185.001	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:240	:6:9:7	ry:0:en:0
i4	310.125	3.375	70	.	.	.	.	.	.	.	.	207.6574	207.657	207.657	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:241	:7:C:7	ry:0:en:0
i4	313.5	0.375	70	.	.	.	.	.	.	.	.	932.3504	112.1412	932.350	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:242	:8:F:9	ry:0:en:0
i4	313.875	0.75	0	.	.	.	.	.	.	.	.	112.1412	112.141	112.141	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:243	:9:E:6	ry:0:en:0
i4	314.625	0.375	70	.	.	.	.	.	.	.	.	70.6445	70.644	70.644	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:244	:10:2:6	ry:0:en:0
i4	315	0.375	70	.	.	.	.	.	.	.	.	62.9371	62.937	62.937	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:245	:11:H:5	ry:0:en:0
i4	315.375	1.5	70	.	.	.	.	.	.	.	.	99.9064	99.906	99.906	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:246	:12:B:6	ry:0:en:0
i4	316.875	2.25	70	.	.	.	.	.	.	.	.	305.2013	317.1832	305.201	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:247	:13:4:8	ry:0:en:0
i4	319.125	3.75	70	.	.	.	.	.	.	.	.	317.1832	317.183	317.183	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:248	:14:5:8	ry:0:en:0
i4	322.875	0.75	70	.	.	.	.	.	.	.	.	135.9517	135.951	135.951	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:249	:15:1:7	ry:0:en:0
i4	323.625	0.375	70	.	.	.	.	.	.	.	.	242.2384	242.238	242.238	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:250	:16:G:7	ry:0:en:0
i4	324	0.375	70	.	.	.	.	.	.	.	.	356.0262	356.026	356.026	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:251	:17:8:8	ry:0:en:0
i4	324.375	0.375	70	.	.	.	.	.	.	.	.	261.632	261.632	261.632	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:252	:0:0:8	ry:0:en:0
i4	324.75	0.375	70	.	.	.	.	.	.	.	.	384.5295	384.529	384.529	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:253	:1:A:8	ry:0:en:0
i4	325.125	1.5	70	.	.	.	.	.	.	.	.	85.6442	85.644	85.644	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:254	:2:7:6	ry:0:en:0
i4	326.625	1.125	70	.	.	.	.	.	.	.	.	146.8359	152.6006	146.835	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:255	:3:3:7	ry:0:en:0
i4	327.75	1.875	70	.	.	.	.	.	.	.	.	152.6006	152.600	152.600	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:256	:4:4:7	ry:0:en:0
i4	329.625	4.125	70	.	.	.	.	.	.	.	.	116.5438	370.0035	116.543	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:257	:5:F:6	ry:0:en:0
i4	333.75	0.75	70	.	.	.	.	.	.	.	.	370.0035	370.003	370.003	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:258	:6:9:8	ry:0:en:0
i4	334.5	4.5	70	.	.	.	.	.	.	.	.	659.2713	659.271	659.271	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:259	:7:6:9	ry:0:en:0
i4	339	0.375	70	.	.	.	.	.	.	.	.	51.9143	51.914	51.914	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:260	:8:C:5	ry:0:en:0
i4	339.375	0.375	70	.	.	.	.	.	.	.	.	399.6259	224.2824	224.2824	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:261	:9:B:8	ry:0:en:0
i4	339.75	1.5	0	.	.	.	.	.	.	.	.	224.2824	224.282	224.282	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:262	:10:E:7	ry:0:en:0
i4	341.25	0.375	70	.	.	.	.	.	.	.	.	125.8742	484.4769	484.4769	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:263	:11:H:6	ry:0:en:0
i4	341.625	0.375	70	.	.	.	.	.	.	.	.	484.4769	484.476	484.476	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:264	:12:G:8	ry:0:en:0
i4	342	0.375	70	.	.	.	.	.	.	.	.	44.5032	44.503	44.503	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:265	:13:8:5	ry:0:en:0
i4	342.375	3.75	0	.	.	.	.	.	.	.	.	317.1832	317.183	317.183	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:266	:14:5:8	ry:0:en:0
i4	346.125	0.75	70	.	.	.	.	.	.	.	.	271.9034	141.2890	141.2890	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:267	:15:1:8	ry:0:en:0
i4	346.875	0.375	70	.	.	.	.	.	.	.	.	141.2890	141.289	141.289	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:268	:16:2:7	ry:0:en:0
i4	347.25	0.375	70	.	.	.	.	.	.	.	.	26.9762	26.976	26.976	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:269	:17:D:4	ry:0:en:0
i4	347.625	0.375	70	.	.	.	.	.	.	.	.	158.5916	158.591	158.591	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:270	:0:5:7	ry:0:en:0
i4	348	0.375	70	.	.	.	.	.	.	.	.	484.4769	484.476	484.476	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:271	:1:G:8	ry:0:en:0
i4	348.375	0.375	70	.	.	.	.	.	.	.	.	62.9371	62.937	62.937	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:272	:2:H:5	ry:0:en:0
i4	348.75	1.875	70	.	.	.	.	.	.	.	.	107.9049	107.904	107.904	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:273	:3:D:6	ry:0:en:0
i4	350.625	0.75	70	.	.	.	.	.	.	.	.	384.5295	384.529	384.529	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:274	:4:A:8	ry:0:en:0
i4	351.375	1.125	70	.	.	.	.	.	.	.	.	141.2890	141.289	141.289	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:275	:5:2:7	ry:0:en:0
i4	352.5	0.75	70	.	.	.	.	.	.	.	.	135.9517	305.2013	305.2013	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:276	:6:1:7	ry:0:en:0
i4	353.25	3.375	70	.	.	.	.	.	.	.	.	305.2013	305.201	305.201	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:277	:7:4:8	ry:0:en:0
i4	356.625	0.375	0	.	.	.	.	.	.	.	.	342.5769	329.6356	342.576	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:278	:8:7:8	ry:0:en:0
i4	357	0.75	70	.	.	.	.	.	.	.	.	329.6356	415.3149	329.635	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:279	:9:6:8	ry:0:en:0
i4	357.75	0.75	70	.	.	.	.	.	.	.	.	415.3149	92.5008	92.5008	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:280	:10:C:8	ry:0:en:0
i4	358.5	0.375	70	.	.	.	.	.	.	.	.	92.5008	293.6719	293.6719	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:281	:11:9:6	ry:0:en:0
i4	358.875	1.5	70	.	.	.	.	.	.	.	.	293.6719	293.671	293.671	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:282	:12:3:8	ry:0:en:0
i4	360.375	3.75	70	.	.	.	.	.	.	.	.	56.0706	56.070	56.070	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:283	:13:E:5	ry:0:en:0
i4	364.125	4.5	70	.	.	.	.	.	.	.	.	466.1752	466.175	466.175	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:284	:14:F:8	ry:0:en:0
i4	368.625	2.625	70	.	.	.	.	.	.	.	.	199.8129	199.812	199.812	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:285	:15:B:7	ry:0:en:0
i4	371.25	0.375	0	.	.	.	.	.	.	.	.	89.0065	89.006	89.006	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:286	:16:8:6	ry:0:en:0
i4	371.625	0.375	70	.	.	.	.	.	.	.	.	523.264	523.264	523.264	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:287	:17:0:9	ry:0:en:0
i4	372	0.375	70	.	.	.	.	.	.	.	.	384.5295	384.529	384.529	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:288	:0:A:8	ry:0:en:0
i4	372.375	0.375	70	.	.	.	.	.	.	.	.	282.5781	282.578	282.578	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:289	:1:2:8	ry:0:en:0
i4	372.75	0.375	0	.	.	.	.	.	.	.	.	125.8742	125.874	125.874	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:290	:2:H:6	ry:0:en:0
i4	373.125	1.875	70	.	.	.	.	.	.	.	.	863.2397	448.5649	863.239	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:291	:3:D:9	ry:0:en:0
i4	375	3	70	.	.	.	.	.	.	.	.	448.5649	342.5769	342.5769	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:292	:4:E:8	ry:0:en:0
i4	378	4.125	70	.	.	.	.	.	.	.	.	342.5769	342.576	342.576	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:293	:5:7:8	ry:0:en:0
i4	382.125	0.75	70	.	.	.	.	.	.	.	.	543.8069	30.2798	30.2798	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:294	:6:1:9	ry:0:en:0
i4	382.875	0.375	70	.	.	.	.	.	.	.	.	30.2798	30.279	30.279	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:295	:7:G:4	ry:0:en:0
i4	383.25	0.375	70	.	.	.	.	.	.	.	.	305.2013	305.201	305.201	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:296	:8:4:8	ry:0:en:0
i4	383.625	0.375	70	.	.	.	.	.	.	.	.	146.8359	146.835	146.835	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:297	:9:3:7	ry:0:en:0
i4	384	1.5	70	.	.	.	.	.	.	.	.	164.8178	164.817	164.817	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:298	:10:6:7	ry:0:en:0
i4	385.5	0.375	70	.	.	.	.	.	.	.	.	92.5008	92.500	92.500	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:299	:11:9:6	ry:0:en:0
i4	385.875	0.375	70	.	.	.	.	.	.	.	.	712.0524	712.052	712.052	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:300	:12:8:9	ry:0:en:0
i4	386.25	0.375	70	.	.	.	.	.	.	.	.	65.408	65.408	65.408	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:301	:13:0:6	ry:0:en:0
i4	386.625	4.5	70	.	.	.	.	.	.	.	.	932.3504	932.350	932.350	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:302	:14:F:9	ry:0:en:0
i4	391.125	2.625	70	.	.	.	.	.	.	.	.	99.9064	207.6574	207.6574	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:303	:15:B:6	ry:0:en:0
i4	393.75	0.375	70	.	.	.	.	.	.	.	.	207.6574	207.657	207.657	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:304	:16:C:7	ry:0:en:0
i4	394.125	0.375	0	.	.	.	.	.	.	.	.	79.2958	79.295	79.295	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:305	:17:5:6	ry:0:en:0
i4	394.5	0.375	70	.	.	.	.	.	.	.	.	116.5438	116.543	116.543	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:306	:0:F:6	ry:0:en:0
i4	394.875	0.375	70	.	.	.	.	.	.	.	.	356.0262	356.026	356.026	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:307	:1:8:8	ry:0:en:0
i4	395.25	0.375	70	.	.	.	.	.	.	.	.	370.0035	79.2958	370.003	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:308	:2:9:8	ry:0:en:0
i4	395.625	1.875	70	.	.	.	.	.	.	.	.	79.2958	17.6611	79.295	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:309	:3:5:6	ry:0:en:0
i4	397.5	0.75	70	.	.	.	.	.	.	.	.	17.6611	415.3149	17.661	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:310	:4:2:4	ry:0:en:0
i4	398.25	2.25	70	.	.	.	.	.	.	.	.	415.3149	415.314	415.314	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:311	:5:C:8	ry:0:en:0
i4	400.5	2.25	70	.	.	.	.	.	.	.	.	799.2518	799.251	799.251	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:312	:6:B:9	ry:0:en:0
i4	402.75	4.5	70	.	.	.	.	.	.	.	.	224.2824	224.282	224.282	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:313	:7:E:7	ry:0:en:0
i4	407.25	0.375	0	.	.	.	.	.	.	.	.	503.4970	503.497	503.497	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:314	:8:H:8	ry:0:en:0
i4	407.625	0.375	70	.	.	.	.	.	.	.	.	484.4769	484.476	484.476	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:315	:9:G:8	ry:0:en:0
i4	408	0.75	70	.	.	.	.	.	.	.	.	305.2013	305.201	305.201	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:316	:10:4:8	ry:0:en:0
i4	408.75	0.375	70	.	.	.	.	.	.	.	.	135.9517	135.951	135.951	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:317	:11:1:7	ry:0:en:0
i4	409.125	2.25	70	.	.	.	.	.	.	.	.	107.9049	107.904	107.904	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:318	:12:D:6	ry:0:en:0
i4	411.375	3.75	70	.	.	.	.	.	.	.	.	82.4089	82.408	82.408	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:319	:13:6:6	ry:0:en:0
i4	415.125	4.5	70	.	.	.	.	.	.	.	.	342.5769	342.576	342.576	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:320	:14:7:8	ry:0:en:0
i4	419.625	2.625	70	.	.	.	.	.	.	.	.	293.6719	293.671	293.671	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:321	:15:3:8	ry:0:en:0
i4	422.25	0.375	70	.	.	.	.	.	.	.	.	261.632	384.5295	384.5295	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:322	:16:0:8	ry:0:en:0
i4	422.625	0.375	0	.	.	.	.	.	.	.	.	384.5295	384.529	384.529	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_5:323	:17:A:8	ry:0:en:0

; Seq_6 comments: Alto (I) oppgrad support with randocts.
;ins	sta	dur	amp	ft1	aty	atk	rel	hd1	hd2	gl1	gl2	fq1	fq2	fq3	pa1	pa2	del	car	mod	hm1	hm2	cro	buz	rvn	rvs	ft2	pcd	
i5	0	0.375	70	10	0	0	1	1	0	0	0	233.0876	233.087	233.087	0.5	0.5	0.3	1	1	0	0	0	0	0	0	24	2	;Sec:0:Seq_6:0	:0:F:7	ry:0:en:0
i5	0.375	0.375	70	10	0	0	1	1	0	0	0	178.0131	178.013	178.013	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:1	:1:8:7	ry:0:en:0
i5	0.75	0.375	70	10	0	0	1	1	0	0	0	92.5008	92.500	92.500	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:2	:2:9:6	ry:5.0:en:0
i5	1.125	1.875	70	10	0	0	1	1	0	0	0	39.6479	39.647	39.647	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:3	:3:5:5	ry:0:en:0
i5	3	0.75	70	10	0	0	1	1	0	0	0	282.5781	282.578	282.578	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:4	:4:2:8	ry:0:en:0
i5	3.75	1.875	70	10	0	0	1	1	0	0	0	415.3149	415.314	415.314	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:5	:5:C:8	ry:5.3:en:0
i5	5.625	2.25	70	10	0	0	1	1	0	0	0	199.8129	199.812	199.812	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:6	:6:B:7	ry:0:en:0
i5	7.875	4.5	70	10	0	0	1	1	0	0	0	897.1298	897.129	897.129	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:7	:7:E:9	ry:0:en:0
i5	12.375	0.375	0	10	0	0	1	1	0	0	0	503.4970	503.497	503.497	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:8	:8:H:8	ry:0:en:0
i5	12.75	0.375	70	10	0	0	1	1	0	0	0	60.5596	60.559	60.559	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:9	:9:G:5	ry:5.7:en:0
i5	13.125	0.375	70	10	0	0	1	1	0	0	0	305.2013	305.201	305.201	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:10	:10:4:8	ry:5.8:en:0
i5	13.5	0.375	70	10	0	0	1	1	0	0	0	135.9517	135.951	135.951	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:11	:11:1:7	ry:5.9:en:0
i5	13.875	0.375	70	10	0	0	1	1	0	0	0	863.2397	863.239	863.239	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:12	:12:D:9	ry:5.10:en:0
i5	14.25	3.75	70	10	0	0	1	1	0	0	0	164.8178	164.817	164.817	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:13	:13:6:7	ry:0:en:0
i5	18	4.5	70	10	0	0	1	1	0	0	0	42.8221	42.822	42.822	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:14	:14:7:5	ry:0:en:0
i5	22.5	1.125	70	10	0	0	1	1	0	0	0	18.3544	18.354	18.354	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:15	:15:3:4	ry:5.13:en:0
i5	23.625	4.5	70	10	0	0	1	1	0	0	0	261.632	261.632	261.632	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:16	:16:0:8	ry:5.14:en:0
i5	28.125	2.625	0	10	0	0	1	1	0	0	0	384.5295	384.529	384.529	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:17	:17:A:8	ry:5.15:en:0
i5	30.75	0.375	0	10	0	0	1	1	0	0	0	565.1563	565.156	565.156	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:18	:0:2:9	ry:5.16:en:0
i5	31.125	0.75	70	10	0	0	1	1	0	0	0	415.3149	415.314	415.314	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:19	:1:C:8	ry:5.17:en:0
i5	31.875	0.375	70	10	0	0	1	1	0	0	0	185.0017	185.001	185.001	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:20	:2:9:7	ry:0:en:0
i5	32.25	0.375	70	10	0	0	1	1	0	0	0	158.5916	158.591	158.591	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:21	:3:5:7	ry:5.19:en:0
i5	32.625	0.375	70	10	0	0	1	1	0	0	0	659.2713	659.271	659.271	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:22	:4:6:9	ry:5.20:en:0
i5	33	0.375	70	10	0	0	1	1	0	0	0	125.8742	125.874	125.874	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:23	:5:H:6	ry:0:en:0
i5	33.375	2.25	70	10	0	0	1	1	0	0	0	399.6259	399.625	399.625	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:24	:6:B:8	ry:0:en:0
i5	35.625	0.375	70	10	0	0	1	1	0	0	0	89.0065	89.006	89.006	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:25	:7:8:6	ry:0:en:0
i5	36	0.375	70	10	0	0	1	1	0	0	0	224.2824	224.282	224.282	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:26	:8:E:7	ry:0:en:0
i5	36.375	0.375	70	10	0	0	1	1	0	0	0	53.9524	53.952	53.952	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:27	:9:D:5	ry:0:en:0
i5	36.75	0.375	70	10	0	0	1	1	0	0	0	242.2384	242.238	242.238	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:28	:10:G:7	ry:0:en:0
i5	37.125	0.375	70	10	0	0	1	1	0	0	0	135.9517	135.951	135.951	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:29	:11:1:7	ry:5.27:en:0
i5	37.5	1.5	0	10	0	0	1	1	0	0	0	130.816	130.816	130.816	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:30	:12:0:7	ry:5.28:en:0
i5	39	1.125	70	10	0	0	1	1	0	0	0	192.2647	192.264	192.264	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:31	:13:A:7	ry:0:en:0
i5	40.125	4.5	70	10	0	0	1	1	0	0	0	342.5769	342.576	342.576	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:32	:14:7:8	ry:0:en:0
i5	44.625	2.625	70	10	0	0	1	1	0	0	0	293.6719	293.671	293.671	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:33	:15:3:8	ry:0:en:0
i5	47.25	0.375	70	10	0	0	1	1	0	0	0	610.4026	610.402	610.402	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:34	:16:4:9	ry:0:en:0
i5	47.625	0.75	70	10	0	0	1	1	0	0	0	58.2719	58.271	58.271	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:35	:17:F:5	ry:0:en:0
i5	48.375	0.375	0	10	0	0	1	1	0	0	0	685.1538	685.153	685.153	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:36	:0:7:9	ry:0:en:0
i5	48.75	0.375	70	10	0	0	1	1	0	0	0	261.632	261.632	261.632	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:37	:1:0:8	ry:0:en:0
i5	49.125	0.375	70	10	0	0	1	1	0	0	0	135.9517	135.951	135.951	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:38	:2:1:7	ry:0:en:0
i5	49.5	0.375	70	10	0	0	1	1	0	0	0	233.0876	233.087	233.087	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:39	:3:F:7	ry:5.37:en:0
i5	49.875	0.375	70	10	0	0	1	1	0	0	0	830.6298	830.629	830.629	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:40	:4:C:9	ry:5.38:en:0
i5	50.25	2.625	70	10	0	0	1	1	0	0	0	305.2013	305.201	305.201	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:41	:5:4:8	ry:5.39:en:0
i5	52.875	2.25	70	10	0	0	1	1	0	0	0	146.8359	146.835	146.835	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:42	:6:3:7	ry:0:en:0
i5	55.125	4.5	0	10	0	0	1	1	0	0	0	164.8178	164.817	164.817	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:43	:7:6:7	ry:0:en:0
i5	59.625	0.375	70	10	0	0	1	1	0	0	0	185.0017	185.001	185.001	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:44	:8:9:7	ry:0:en:0
i5	60	0.375	70	10	0	0	1	1	0	0	0	356.0262	356.026	356.026	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:45	:9:8:8	ry:5.43:en:0
i5	60.375	0.375	70	10	0	0	1	1	0	0	0	112.1412	112.141	112.141	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:46	:10:E:6	ry:5.44:en:0
i5	60.75	1.125	70	10	0	0	1	1	0	0	0	199.8129	199.812	199.812	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:47	:11:B:7	ry:0:en:0
i5	61.875	2.25	70	10	0	0	1	1	0	0	0	158.5916	158.591	158.591	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:48	:12:5:7	ry:0:en:0
i5	64.125	0.375	70	10	0	0	1	1	0	0	0	242.2384	242.238	242.238	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:49	:13:G:7	ry:0:en:0
i5	64.5	0.75	70	10	0	0	1	1	0	0	0	251.7485	251.748	251.748	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:50	:14:H:7	ry:0:en:0
i5	65.25	4.125	70	10	0	0	1	1	0	0	0	863.2397	863.239	863.239	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:51	:15:D:9	ry:0:en:0
i5	69.375	0.75	70	10	0	0	1	1	0	0	0	96.1323	96.132	96.132	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:52	:16:A:6	ry:5.50:en:0
i5	70.125	4.125	70	10	0	0	1	1	0	0	0	35.3222	35.322	35.322	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:53	:17:2:5	ry:5.51:en:0
i5	74.25	0.375	70	10	0	0	1	1	0	0	0	830.6298	830.629	830.629	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:54	:0:C:9	ry:0:en:0
i5	74.625	0.375	70	10	0	0	1	1	0	0	0	305.2013	305.201	305.201	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:55	:1:4:8	ry:0:en:0
i5	75	0.375	70	10	0	0	1	1	0	0	0	271.9034	271.903	271.903	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:56	:2:1:8	ry:0:en:0
i5	75.375	0.375	70	10	0	0	1	1	0	0	0	116.5438	116.543	116.543	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:57	:3:F:6	ry:5.55:en:0
i5	75.75	0.75	0	10	0	0	1	1	0	0	0	968.9538	968.953	968.953	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:58	:4:G:9	ry:5.56:en:0
i5	76.5	2.625	70	10	0	0	1	1	0	0	0	92.5008	92.500	92.500	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:59	:5:9:6	ry:5.57:en:0
i5	79.125	1.875	70	10	0	0	1	1	0	0	0	18.3544	18.354	18.354	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:60	:6:3:4	ry:5.58:en:0
i5	81	3.75	70	10	0	0	1	1	0	0	0	261.632	261.632	261.632	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:61	:7:0:8	ry:5.59:en:0
i5	84.75	3.75	70	10	0	0	1	1	0	0	0	329.6356	329.635	329.635	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:62	:8:6:8	ry:5.60:en:0
i5	88.5	0.375	70	10	0	0	1	1	0	0	0	317.1832	317.183	317.183	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:63	:9:5:8	ry:5.61:en:0
i5	88.875	0.375	70	10	0	0	1	1	0	0	0	178.0131	178.013	178.013	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:64	:10:8:7	ry:5.62:en:0
i5	89.25	0.375	70	10	0	0	1	1	0	0	0	199.8129	199.812	199.812	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:65	:11:B:7	ry:5.63:en:0
i5	89.625	1.5	70	10	0	0	1	1	0	0	0	384.5295	384.529	384.529	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:66	:12:A:8	ry:5.64:en:0
i5	91.125	1.125	70	10	0	0	1	1	0	0	0	70.6445	70.644	70.644	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:67	:13:2:6	ry:0:en:0
i5	92.25	0.75	70	10	0	0	1	1	0	0	0	125.8742	125.874	125.874	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:68	:14:H:6	ry:0:en:0
i5	93	4.125	70	10	0	0	1	1	0	0	0	863.2397	863.239	863.239	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:69	:15:D:9	ry:0:en:0
i5	97.125	0.75	0	10	0	0	1	1	0	0	0	224.2824	224.282	224.282	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:70	:16:E:7	ry:5.68:en:0
i5	97.875	0.75	70	10	0	0	1	1	0	0	0	42.8221	42.822	42.822	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:71	:17:7:5	ry:0:en:0
i5	98.625	0.375	70	10	0	0	1	1	0	0	0	31.4685	31.468	31.468	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:72	:0:H:4	ry:0:en:0
i5	99	0.375	70	10	0	0	1	1	0	0	0	24.0330	24.033	24.033	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:73	:1:A:4	ry:0:en:0
i5	99.375	0.375	70	10	0	0	1	1	0	0	0	399.6259	399.625	399.625	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:74	:2:B:8	ry:5.72:en:0
i5	99.75	2.625	70	10	0	0	1	1	0	0	0	342.5769	342.576	342.576	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:75	:3:7:8	ry:0:en:0
i5	102.375	1.875	70	10	0	0	1	1	0	0	0	610.4026	610.402	610.402	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:76	:4:4:9	ry:0:en:0
i5	104.25	3.75	70	10	0	0	1	1	0	0	0	112.1412	112.141	112.141	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:77	:5:E:6	ry:0:en:0
i5	108	3.75	0	10	0	0	1	1	0	0	0	431.6198	431.619	431.619	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:78	:6:D:8	ry:0:en:0
i5	111.75	0.375	70	10	0	0	1	1	0	0	0	242.2384	242.238	242.238	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:79	:7:G:7	ry:0:en:0
i5	112.125	0.375	70	10	0	0	1	1	0	0	0	16.9939	16.993	16.993	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:80	:8:1:4	ry:0:en:0
i5	112.5	0.375	70	10	0	0	1	1	0	0	0	130.816	130.816	130.816	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:81	:9:0:7	ry:0:en:0
i5	112.875	1.5	0	10	0	0	1	1	0	0	0	329.6356	329.635	329.635	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:82	:10:6:8	ry:0:en:0
i5	114.375	0.75	70	10	0	0	1	1	0	0	0	73.4179	73.417	73.417	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:83	:11:3:6	ry:5.81:en:0
i5	115.125	0.375	70	10	0	0	1	1	0	0	0	466.1752	466.175	466.175	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:84	:12:F:8	ry:5.82:en:0
i5	115.5	1.125	70	10	0	0	1	1	0	0	0	89.0065	89.006	89.006	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:85	:13:8:6	ry:5.83:en:0
i5	116.625	0.75	70	10	0	0	1	1	0	0	0	370.0035	370.003	370.003	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:86	:14:9:8	ry:0:en:0
i5	117.375	4.125	70	10	0	0	1	1	0	0	0	39.6479	39.647	39.647	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:87	:15:5:5	ry:0:en:0
i5	121.5	0.75	70	10	0	0	1	1	0	0	0	565.1563	565.156	565.156	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:88	:16:2:9	ry:5.86:en:0
i5	122.25	0.375	70	10	0	0	1	1	0	0	0	103.8287	103.828	103.828	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:89	:17:C:6	ry:0:en:0
i5	122.625	0.375	70	10	0	0	1	1	0	0	0	38.1501	38.150	38.150	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:90	:0:4:5	ry:0:en:0
i5	123	0.75	70	10	0	0	1	1	0	0	0	56.0706	56.070	56.070	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:91	:1:E:5	ry:0:en:0
i5	123.75	0.75	70	10	0	0	1	1	0	0	0	399.6259	399.625	399.625	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:92	:2:B:8	ry:0:en:0
i5	124.5	2.625	70	10	0	0	1	1	0	0	0	85.6442	85.644	85.644	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:93	:3:7:6	ry:0:en:0
i5	127.125	0.375	70	10	0	0	1	1	0	0	0	22.2516	22.251	22.251	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:94	:4:8:4	ry:0:en:0
i5	127.5	0.375	70	10	0	0	1	1	0	0	0	271.9034	271.903	271.903	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:95	:5:1:8	ry:0:en:0
i5	127.875	3.75	70	10	0	0	1	1	0	0	0	431.6198	431.619	431.619	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:96	:6:D:8	ry:0:en:0
i5	131.625	3.75	70	10	0	0	1	1	0	0	0	384.5295	384.529	384.529	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:97	:7:A:8	ry:5.95:en:0
i5	135.375	3.75	70	10	0	0	1	1	0	0	0	484.4769	484.476	484.476	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:98	:8:G:8	ry:5.96:en:0
i5	139.125	0.375	0	10	0	0	1	1	0	0	0	932.3504	932.350	932.350	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:99	:9:F:9	ry:5.97:en:0
i5	139.5	0.375	70	10	0	0	1	1	0	0	0	261.632	261.632	261.632	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:100	:10:0:8	ry:5.98:en:0
i5	139.875	0.375	70	10	0	0	1	1	0	0	0	293.6719	293.671	293.671	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:101	:11:3:8	ry:5.99:en:0
i5	140.25	0.375	70	10	0	0	1	1	0	0	0	70.6445	70.644	70.644	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:102	:12:2:6	ry:5.100:en:0
i5	140.625	1.875	70	10	0	0	1	1	0	0	0	415.3149	415.314	415.314	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:103	:13:C:8	ry:5.101:en:0
i5	142.5	3.375	0	10	0	0	1	1	0	0	0	370.0035	370.003	370.003	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:104	:14:9:8	ry:5.102:en:0
i5	145.875	0.375	70	10	0	0	1	1	0	0	0	634.3665	634.366	634.366	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:105	:15:5:9	ry:5.103:en:0
i5	146.25	0.75	70	10	0	0	1	1	0	0	0	164.8178	164.817	164.817	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:106	:16:6:7	ry:5.104:en:0
i5	147	0.375	70	10	0	0	1	1	0	0	0	125.8742	125.874	125.874	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:107	:17:H:6	ry:0:en:0
i5	147.375	0.375	70	10	0	0	1	1	0	0	0	185.0017	185.001	185.001	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:108	:0:9:7	ry:0:en:0
i5	147.75	0.375	70	10	0	0	1	1	0	0	0	565.1563	565.156	565.156	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:109	:1:2:9	ry:0:en:0
i5	148.125	0.375	0	10	0	0	1	1	0	0	0	73.4179	73.417	73.417	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:110	:2:3:6	ry:5.108:en:0
i5	148.5	0.75	0	10	0	0	1	1	0	0	0	125.8742	125.874	125.874	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:111	:3:H:6	ry:5.109:en:0
i5	149.25	0.75	70	10	0	0	1	1	0	0	0	28.0353	28.035	28.035	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:112	:4:E:4	ry:5.110:en:0
i5	150	0.375	70	10	0	0	1	1	0	0	0	164.8178	164.817	164.817	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:113	:5:6:7	ry:5.111:en:0
i5	150.375	0.375	70	10	0	0	1	1	0	0	0	79.2958	79.295	79.295	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:114	:6:5:6	ry:5.112:en:0
i5	150.75	1.875	70	10	0	0	1	1	0	0	0	712.0524	712.052	712.052	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:115	:7:8:9	ry:5.113:en:0
i5	152.625	3.75	70	10	0	0	1	1	0	0	0	399.6259	399.625	399.625	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:116	:8:B:8	ry:5.114:en:0
i5	156.375	1.5	70	10	0	0	1	1	0	0	0	769.0591	769.059	769.059	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:117	:9:A:9	ry:5.115:en:0
i5	157.875	0.375	70	10	0	0	1	1	0	0	0	968.9538	968.953	968.953	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:118	:10:G:9	ry:0:en:0
i5	158.25	1.875	70	10	0	0	1	1	0	0	0	215.8099	215.809	215.809	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:119	:11:D:7	ry:0:en:0
i5	160.125	3.375	70	10	0	0	1	1	0	0	0	171.2884	171.288	171.288	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:120	:12:7:7	ry:0:en:0
i5	163.5	0.375	70	10	0	0	1	1	0	0	0	65.408	65.408	65.408	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:121	:13:0:6	ry:0:en:0
i5	163.875	0.75	70	10	0	0	1	1	0	0	0	271.9034	271.903	271.903	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:122	:14:1:8	ry:0:en:0
i5	164.625	2.25	70	10	0	0	1	1	0	0	0	466.1752	466.175	466.175	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:123	:15:F:8	ry:5.121:en:0
i5	166.875	0.75	70	10	0	0	1	1	0	0	0	51.9143	51.914	51.914	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:124	:16:C:5	ry:5.122:en:0
i5	167.625	4.5	70	10	0	0	1	1	0	0	0	152.6006	152.600	152.600	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:125	:17:4:7	ry:5.123:en:0
i5	172.125	0.375	70	10	0	0	1	1	0	0	0	897.1298	897.129	897.129	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:126	:0:E:9	ry:5.124:en:0
i5	172.5	0.375	70	10	0	0	1	1	0	0	0	329.6356	329.635	329.635	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:127	:1:6:8	ry:5.125:en:0
i5	172.875	0.75	70	10	0	0	1	1	0	0	0	293.6719	293.671	293.671	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:128	:2:3:8	ry:0:en:0
i5	173.625	0.375	70	10	0	0	1	1	0	0	0	1006.9941	1006.994	1006.994	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:129	:3:H:9	ry:0:en:0
i5	174	1.125	70	10	0	0	1	1	0	0	0	261.632	261.632	261.632	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:130	:4:0:8	ry:5.128:en:0
i5	175.125	0.375	0	10	0	0	1	1	0	0	0	399.6259	399.625	399.625	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:131	:5:B:8	ry:5.129:en:0
i5	175.5	3	0	10	0	0	1	1	0	0	0	317.1832	317.183	317.183	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:132	:6:5:8	ry:5.130:en:0
i5	178.5	0.375	70	10	0	0	1	1	0	0	0	70.6445	70.644	70.644	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:133	:7:2:6	ry:5.131:en:0
i5	178.875	4.5	70	10	0	0	1	1	0	0	0	356.0262	356.026	356.026	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:134	:8:8:8	ry:5.132:en:0
i5	183.375	0.375	70	10	0	0	1	1	0	0	0	171.2884	171.288	171.288	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:135	:9:7:7	ry:5.133:en:0
i5	183.75	0.375	70	10	0	0	1	1	0	0	0	192.2647	192.264	192.264	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:136	:10:A:7	ry:5.134:en:0
i5	184.125	0.375	70	10	0	0	1	1	0	0	0	215.8099	215.809	215.809	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:137	:11:D:7	ry:5.135:en:0
i5	184.5	1.875	70	10	0	0	1	1	0	0	0	103.8287	103.828	103.828	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:138	:12:C:6	ry:0:en:0
i5	186.375	2.25	70	10	0	0	1	1	0	0	0	19.0750	19.075	19.075	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:139	:13:4:4	ry:0:en:0
i5	188.625	0.75	70	10	0	0	1	1	0	0	0	271.9034	271.903	271.903	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:140	:14:1:8	ry:0:en:0
i5	189.375	1.125	70	10	0	0	1	1	0	0	0	932.3504	932.350	932.350	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:141	:15:F:9	ry:5.139:en:0
i5	190.5	2.25	70	10	0	0	1	1	0	0	0	484.4769	484.476	484.476	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:142	:16:G:8	ry:5.140:en:0
i5	192.75	4.5	70	10	0	0	1	1	0	0	0	92.5008	92.500	92.500	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:143	:17:9:6	ry:5.141:en:0
i5	197.25	0.375	70	10	0	0	1	1	0	0	0	135.9517	135.951	135.951	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:144	:0:1:7	ry:0:en:0
i5	197.625	0.375	70	10	0	0	1	1	0	0	0	207.6574	207.657	207.657	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:145	:1:C:7	ry:0:en:0
i5	198	0.375	70	10	0	0	1	1	0	0	0	215.8099	215.809	215.809	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:146	:2:D:7	ry:5.144:en:0
i5	198.375	0.375	70	10	0	0	1	1	0	0	0	370.0035	370.003	370.003	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:147	:3:9:8	ry:5.145:en:0
i5	198.75	1.125	70	10	0	0	1	1	0	0	0	329.6356	329.635	329.635	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:148	:4:6:8	ry:5.146:en:0
i5	199.875	0.375	70	10	0	0	1	1	0	0	0	242.2384	242.238	242.238	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:149	:5:G:7	ry:5.147:en:0
i5	200.25	4.5	70	10	0	0	1	1	0	0	0	233.0876	233.087	233.087	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:150	:6:F:7	ry:0:en:0
i5	204.75	0.375	70	10	0	0	1	1	0	0	0	261.632	261.632	261.632	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:151	:7:0:8	ry:0:en:0
i5	205.125	0.375	70	10	0	0	1	1	0	0	0	293.6719	293.671	293.671	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:152	:8:3:8	ry:0:en:0
i5	205.5	0.375	70	10	0	0	1	1	0	0	0	141.2890	141.289	141.289	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:153	:9:2:7	ry:0:en:0
i5	205.875	0.375	70	10	0	0	1	1	0	0	0	178.0131	178.013	178.013	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:154	:10:8:7	ry:0:en:0
i5	206.25	1.875	70	10	0	0	1	1	0	0	0	317.1832	317.183	317.183	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:155	:11:5:8	ry:0:en:0
i5	208.125	0.375	0	10	0	0	1	1	0	0	0	62.9371	62.937	62.937	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:156	:12:H:5	ry:5.154:en:0
i5	208.5	1.875	70	10	0	0	1	1	0	0	0	384.5295	384.529	384.529	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:157	:13:A:8	ry:5.155:en:0
i5	210.375	2.25	70	10	0	0	1	1	0	0	0	99.9064	99.906	99.906	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:158	:14:B:6	ry:0:en:0
i5	212.625	3.75	70	10	0	0	1	1	0	0	0	85.6442	85.644	85.644	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:159	:15:7:6	ry:5.157:en:0
i5	216.375	2.25	70	10	0	0	1	1	0	0	0	610.4026	610.402	610.402	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:160	:16:4:9	ry:5.158:en:0
i5	218.625	0.75	0	10	0	0	1	1	0	0	0	28.0353	28.035	28.035	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:161	:17:E:4	ry:0:en:0
i5	219.375	0.375	70	10	0	0	1	1	0	0	0	329.6356	329.635	329.635	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:162	:0:6:8	ry:5.160:en:0
i5	219.75	0.375	70	10	0	0	1	1	0	0	0	242.2384	242.238	242.238	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:163	:1:G:7	ry:5.161:en:0
i5	220.125	0.375	70	10	0	0	1	1	0	0	0	107.9049	107.904	107.904	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:164	:2:D:6	ry:5.162:en:0
i5	220.5	0.375	70	10	0	0	1	1	0	0	0	740.0070	740.007	740.007	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:165	:3:9:9	ry:5.163:en:0
i5	220.875	1.125	70	10	0	0	1	1	0	0	0	769.0591	769.059	769.059	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:166	:4:A:9	ry:5.164:en:0
i5	222	0.375	70	10	0	0	1	1	0	0	0	293.6719	293.671	293.671	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:167	:5:3:8	ry:5.165:en:0
i5	222.375	0.375	70	10	0	0	1	1	0	0	0	116.5438	116.543	116.543	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:168	:6:F:6	ry:5.166:en:0
i5	222.75	0.375	70	10	0	0	1	1	0	0	0	415.3149	415.314	415.314	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:169	:7:C:8	ry:5.167:en:0
i5	223.125	4.5	0	10	0	0	1	1	0	0	0	261.632	261.632	261.632	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:170	:8:0:8	ry:5.168:en:0
i5	227.625	1.5	70	10	0	0	1	1	0	0	0	251.7485	251.748	251.748	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:171	:9:H:7	ry:5.169:en:0
i5	229.125	0.375	70	10	0	0	1	1	0	0	0	141.2890	141.289	141.289	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:172	:10:2:7	ry:0:en:0
i5	229.5	1.875	70	10	0	0	1	1	0	0	0	158.5916	158.591	158.591	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:173	:11:5:7	ry:0:en:0
i5	231.375	0.375	70	10	0	0	1	1	0	0	0	76.3003	76.300	76.300	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:174	:12:4:6	ry:5.172:en:0
i5	231.75	2.625	70	10	0	0	1	1	0	0	0	56.0706	56.070	56.070	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:175	:13:E:5	ry:5.173:en:0
i5	234.375	0.375	70	10	0	0	1	1	0	0	0	99.9064	99.906	99.906	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:176	:14:B:6	ry:5.174:en:0
i5	234.75	1.125	70	10	0	0	1	1	0	0	0	342.5769	342.576	342.576	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:177	:15:7:8	ry:5.175:en:0
i5	235.875	2.25	0	10	0	0	1	1	0	0	0	356.0262	356.026	356.026	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:178	:16:8:8	ry:5.176:en:0
i5	238.125	0.75	70	10	0	0	1	1	0	0	0	16.9939	16.993	16.993	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:179	:17:1:4	ry:5.177:en:0
i5	238.875	0.375	70	10	0	0	1	1	0	0	0	399.6259	399.625	399.625	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:180	:0:B:8	ry:0:en:0
i5	239.25	0.75	70	10	0	0	1	1	0	0	0	19.0750	19.075	19.075	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:181	:1:4:4	ry:5.179:en:0
i5	240	0.375	70	10	0	0	1	1	0	0	0	317.1832	317.183	317.183	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:182	:2:5:8	ry:5.180:en:0
i5	240.375	0.375	70	10	0	0	1	1	0	0	0	543.8069	543.806	543.806	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:183	:3:1:9	ry:5.181:en:0
i5	240.75	1.125	0	10	0	0	1	1	0	0	0	242.2384	242.238	242.238	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:184	:4:G:7	ry:5.182:en:0
i5	241.875	0.375	70	10	0	0	1	1	0	0	0	89.0065	89.006	89.006	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:185	:5:8:6	ry:5.183:en:0
i5	242.25	0.75	70	10	0	0	1	1	0	0	0	171.2884	171.288	171.288	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:186	:6:7:7	ry:5.184:en:0
i5	243	3	70	10	0	0	1	1	0	0	0	384.5295	384.529	384.529	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:187	:7:A:8	ry:5.185:en:0
i5	246	4.5	70	10	0	0	1	1	0	0	0	215.8099	215.809	215.809	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:188	:8:D:7	ry:5.186:en:0
i5	250.5	0.375	70	10	0	0	1	1	0	0	0	830.6298	830.629	830.629	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:189	:9:C:9	ry:0:en:0
i5	250.875	0.375	70	10	0	0	1	1	0	0	0	130.816	130.816	130.816	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:190	:10:0:7	ry:5.188:en:0
i5	251.25	2.625	70	10	0	0	1	1	0	0	0	29.1359	29.135	29.135	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:191	:11:F:4	ry:0:en:0
i5	253.875	0.375	70	10	0	0	1	1	0	0	0	370.0035	370.003	370.003	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:192	:12:9:8	ry:0:en:0
i5	254.25	1.125	70	10	0	0	1	1	0	0	0	141.2890	141.289	141.289	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:193	:13:2:7	ry:0:en:0
i5	255.375	3	70	10	0	0	1	1	0	0	0	293.6719	293.671	293.671	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:194	:14:3:8	ry:5.192:en:0
i5	258.375	3.75	70	10	0	0	1	1	0	0	0	251.7485	251.748	251.748	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:195	:15:H:7	ry:5.193:en:0
i5	262.125	2.25	0	10	0	0	1	1	0	0	0	897.1298	897.129	897.129	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:196	:16:E:9	ry:5.194:en:0
i5	264.375	0.75	70	10	0	0	1	1	0	0	0	20.6022	20.602	20.602	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:197	:17:6:4	ry:5.195:en:0
i5	265.125	0.375	70	10	0	0	1	1	0	0	0	484.4769	484.476	484.476	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:198	:0:G:8	ry:0:en:0
i5	265.5	0.375	70	10	0	0	1	1	0	0	0	178.0131	178.013	178.013	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:199	:1:8:7	ry:5.197:en:0
i5	265.875	0.375	70	10	0	0	1	1	0	0	0	634.3665	634.366	634.366	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:200	:2:5:9	ry:5.198:en:0
i5	266.25	0.75	70	10	0	0	1	1	0	0	0	135.9517	135.951	135.951	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:201	:3:1:7	ry:5.199:en:0
i5	267	0.75	70	10	0	0	1	1	0	0	0	17.6611	17.661	17.661	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:202	:4:2:4	ry:0:en:0
i5	267.75	3	70	10	0	0	1	1	0	0	0	431.6198	431.619	431.619	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:203	:5:D:8	ry:0:en:0
i5	270.75	4.5	70	10	0	0	1	1	0	0	0	171.2884	171.288	171.288	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:204	:6:7:7	ry:0:en:0
i5	275.25	3.375	70	10	0	0	1	1	0	0	0	610.4026	610.402	610.402	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:205	:7:4:9	ry:0:en:0
i5	278.625	0.75	0	10	0	0	1	1	0	0	0	384.5295	384.529	384.529	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:206	:8:A:8	ry:5.204:en:0
i5	279.375	1.5	70	10	0	0	1	1	0	0	0	370.0035	370.003	370.003	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:207	:9:9:8	ry:5.205:en:0
i5	280.875	0.75	0	10	0	0	1	1	0	0	0	830.6298	830.629	830.629	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:208	:10:C:9	ry:0:en:0
i5	281.625	2.625	70	10	0	0	1	1	0	0	0	233.0876	233.087	233.087	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:209	:11:F:7	ry:0:en:0
i5	284.25	3	70	10	0	0	1	1	0	0	0	897.1298	897.129	897.129	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:210	:12:E:9	ry:0:en:0
i5	287.25	3.75	70	10	0	0	1	1	0	0	0	41.2044	41.204	41.204	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:211	:13:6:5	ry:0:en:0
i5	291	2.25	70	10	0	0	1	1	0	0	0	293.6719	293.671	293.671	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:212	:14:3:8	ry:0:en:0
i5	293.25	0.75	70	10	0	0	1	1	0	0	0	503.4970	503.497	503.497	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:213	:15:H:8	ry:0:en:0
i5	294	3.75	70	10	0	0	1	1	0	0	0	261.632	261.632	261.632	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:214	:16:0:8	ry:5.212:en:0
i5	297.75	0.75	70	10	0	0	1	1	0	0	0	99.9064	99.906	99.906	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:215	:17:B:6	ry:5.213:en:0
i5	298.5	0.375	70	10	0	0	1	1	0	0	0	73.4179	73.417	73.417	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:216	:0:3:6	ry:5.214:en:0
i5	298.875	0.375	70	10	0	0	1	1	0	0	0	897.1298	897.129	897.129	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:217	:1:E:9	ry:5.215:en:0
i5	299.25	1.5	70	10	0	0	1	1	0	0	0	932.3504	932.350	932.350	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:218	:2:F:9	ry:0:en:0
i5	300.75	0.375	70	10	0	0	1	1	0	0	0	99.9064	99.906	99.906	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:219	:3:B:6	ry:5.217:en:0
i5	301.125	1.5	70	10	0	0	1	1	0	0	0	356.0262	356.026	356.026	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:220	:4:8:8	ry:5.218:en:0
i5	302.625	1.125	70	10	0	0	1	1	0	0	0	523.264	523.264	523.264	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:221	:5:0:9	ry:5.219:en:0
i5	303.75	1.875	70	10	0	0	1	1	0	0	0	31.4685	31.468	31.468	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:222	:6:H:4	ry:5.220:en:0
i5	305.625	1.5	70	10	0	0	1	1	0	0	0	141.2890	141.289	141.289	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:223	:7:2:7	ry:0:en:0
i5	307.125	0.75	70	10	0	0	1	1	0	0	0	634.3665	634.366	634.366	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:224	:8:5:9	ry:5.222:en:0
i5	307.875	4.5	70	10	0	0	1	1	0	0	0	152.6006	152.600	152.600	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:225	:9:4:7	ry:5.223:en:0
i5	312.375	0.375	70	10	0	0	1	1	0	0	0	384.5295	384.529	384.529	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:226	:10:A:8	ry:0:en:0
i5	312.75	2.625	70	10	0	0	1	1	0	0	0	171.2884	171.288	171.288	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:227	:11:7:7	ry:0:en:0
i5	315.375	0.75	70	10	0	0	1	1	0	0	0	33.9879	33.987	33.987	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:228	:12:1:5	ry:5.226:en:0
i5	316.125	2.625	0	10	0	0	1	1	0	0	0	103.8287	103.828	103.828	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:229	:13:C:6	ry:5.227:en:0
i5	318.75	3.75	0	10	0	0	1	1	0	0	0	431.6198	431.619	431.619	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:230	:14:D:8	ry:0:en:0
i5	322.5	0.75	70	10	0	0	1	1	0	0	0	185.0017	185.001	185.001	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:231	:15:9:7	ry:0:en:0
i5	323.25	0.375	70	10	0	0	1	1	0	0	0	329.6356	329.635	329.635	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:232	:16:6:8	ry:0:en:0
i5	323.625	0.375	70	10	0	0	1	1	0	0	0	242.2384	242.238	242.238	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:233	:17:G:7	ry:0:en:0
i5	324	0.375	0	10	0	0	1	1	0	0	0	89.0065	89.006	89.006	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:234	:0:8:6	ry:0:en:0
i5	324.375	0.375	70	10	0	0	1	1	0	0	0	65.408	65.408	65.408	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:235	:1:0:6	ry:0:en:0
i5	324.75	1.5	70	10	0	0	1	1	0	0	0	466.1752	466.175	466.175	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:236	:2:F:8	ry:0:en:0
i5	326.25	1.125	70	10	0	0	1	1	0	0	0	49.9532	49.953	49.953	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:237	:3:B:5	ry:0:en:0
i5	327.375	1.875	70	10	0	0	1	1	0	0	0	830.6298	830.629	830.629	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:238	:4:C:9	ry:0:en:0
i5	329.25	3	70	10	0	0	1	1	0	0	0	317.1832	317.183	317.183	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:239	:5:5:8	ry:0:en:0
i5	332.25	0.75	70	10	0	0	1	1	0	0	0	125.8742	125.874	125.874	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:240	:6:H:6	ry:0:en:0
i5	333	1.125	70	10	0	0	1	1	0	0	0	448.5649	448.564	448.564	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:241	:7:E:8	ry:5.239:en:0
i5	334.125	0.75	0	10	0	0	1	1	0	0	0	141.2890	141.289	141.289	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:242	:8:2:7	ry:5.240:en:0
i5	334.875	3.375	70	10	0	0	1	1	0	0	0	135.9517	135.951	135.951	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:243	:9:1:7	ry:5.241:en:0
i5	338.25	0.375	70	10	0	0	1	1	0	0	0	610.4026	610.402	610.402	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:244	:10:4:9	ry:5.242:en:0
i5	338.625	0.75	70	10	0	0	1	1	0	0	0	21.4110	21.411	21.411	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:245	:11:7:4	ry:5.243:en:0
i5	339.375	3	70	10	0	0	1	1	0	0	0	659.2713	659.271	659.271	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:246	:12:6:9	ry:0:en:0
i5	342.375	0.375	70	10	0	0	1	1	0	0	0	242.2384	242.238	242.238	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:247	:13:G:7	ry:5.245:en:0
i5	342.75	3.75	70	10	0	0	1	1	0	0	0	863.2397	863.239	863.239	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:248	:14:D:9	ry:0:en:0
i5	346.5	0.75	70	10	0	0	1	1	0	0	0	185.0017	185.001	185.001	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:249	:15:9:7	ry:0:en:0
i5	347.25	0.375	70	10	0	0	1	1	0	0	0	384.5295	384.529	384.529	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:250	:16:A:8	ry:0:en:0
i5	347.625	0.75	70	10	0	0	1	1	0	0	0	293.6719	293.671	293.671	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:251	:17:3:8	ry:5.249:en:0
i5	348.375	0.375	70	10	0	0	1	1	0	0	0	863.2397	863.239	863.239	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:252	:0:D:9	ry:5.250:en:0
i5	348.75	0.375	70	10	0	0	1	1	0	0	0	329.6356	329.635	329.635	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:253	:1:6:8	ry:5.251:en:0
i5	349.125	0.375	70	10	0	0	1	1	0	0	0	342.5769	342.576	342.576	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:254	:2:7:8	ry:5.252:en:0
i5	349.5	1.125	70	10	0	0	1	1	0	0	0	36.7089	36.708	36.708	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:255	:3:3:5	ry:0:en:0
i5	350.625	0.375	70	10	0	0	1	1	0	0	0	130.816	130.816	130.816	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:256	:4:0:7	ry:0:en:0
i5	351	1.125	70	10	0	0	1	1	0	0	0	96.1323	96.132	96.132	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:257	:5:A:6	ry:0:en:0
i5	352.125	1.875	0	10	0	0	1	1	0	0	0	46.2504	46.250	46.250	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:258	:6:9:5	ry:5.256:en:0
i5	354	4.125	70	10	0	0	1	1	0	0	0	415.3149	415.314	415.314	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:259	:7:C:8	ry:5.257:en:0
i5	358.125	0.75	70	10	0	0	1	1	0	0	0	932.3504	932.350	932.350	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:260	:8:F:9	ry:5.258:en:0
i5	358.875	4.5	0	10	0	0	1	1	0	0	0	448.5649	448.564	448.564	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:261	:9:E:8	ry:5.259:en:0
i5	363.375	0.375	70	10	0	0	1	1	0	0	0	282.5781	282.578	282.578	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:262	:10:2:8	ry:5.260:en:0
i5	363.75	0.375	70	10	0	0	1	1	0	0	0	31.4685	31.468	31.468	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:263	:11:H:4	ry:5.261:en:0
i5	364.125	1.5	70	10	0	0	1	1	0	0	0	49.9532	49.953	49.953	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:264	:12:B:5	ry:5.262:en:0
i5	365.625	2.25	70	10	0	0	1	1	0	0	0	305.2013	305.201	305.201	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:265	:13:4:8	ry:0:en:0
i5	367.875	0.375	70	10	0	0	1	1	0	0	0	317.1832	317.183	317.183	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:266	:14:5:8	ry:5.264:en:0
i5	368.25	0.375	70	10	0	0	1	1	0	0	0	67.9758	67.975	67.975	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:267	:15:1:6	ry:5.265:en:0
i5	368.625	3.75	70	10	0	0	1	1	0	0	0	121.1192	121.119	121.119	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:268	:16:G:6	ry:5.266:en:0
i5	372.375	0.75	70	10	0	0	1	1	0	0	0	712.0524	712.052	712.052	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:269	:17:8:9	ry:5.267:en:0
i5	373.125	0.375	70	10	0	0	1	1	0	0	0	65.408	65.408	65.408	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:270	:0:0:6	ry:5.268:en:0
i5	373.5	0.375	70	10	0	0	1	1	0	0	0	384.5295	384.529	384.529	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:271	:1:A:8	ry:5.269:en:0
i5	373.875	0.375	70	10	0	0	1	1	0	0	0	171.2884	171.288	171.288	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:272	:2:7:7	ry:5.270:en:0
i5	374.25	0.375	70	10	0	0	1	1	0	0	0	293.6719	293.671	293.671	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:273	:3:3:8	ry:5.271:en:0
i5	374.625	0.375	70	10	0	0	1	1	0	0	0	305.2013	305.201	305.201	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:274	:4:4:8	ry:5.272:en:0
i5	375	1.875	70	10	0	0	1	1	0	0	0	116.5438	116.543	116.543	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:275	:5:F:6	ry:5.273:en:0
i5	376.875	0.75	70	10	0	0	1	1	0	0	0	92.5008	92.500	92.500	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:276	:6:9:6	ry:0:en:0
i5	377.625	4.5	70	10	0	0	1	1	0	0	0	82.4089	82.408	82.408	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:277	:7:6:6	ry:0:en:0
i5	382.125	0.375	70	10	0	0	1	1	0	0	0	207.6574	207.657	207.657	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:278	:8:C:7	ry:0:en:0
i5	382.5	0.375	70	10	0	0	1	1	0	0	0	399.6259	399.625	399.625	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:279	:9:B:8	ry:0:en:0
i5	382.875	1.5	0	10	0	0	1	1	0	0	0	112.1412	112.141	112.141	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:280	:10:E:6	ry:0:en:0
i5	384.375	0.375	70	10	0	0	1	1	0	0	0	62.9371	62.937	62.937	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:281	:11:H:5	ry:0:en:0
i5	384.75	0.375	70	10	0	0	1	1	0	0	0	121.1192	121.119	121.119	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:282	:12:G:6	ry:0:en:0
i5	385.125	0.375	70	10	0	0	1	1	0	0	0	178.0131	178.013	178.013	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:283	:13:8:7	ry:5.281:en:0
i5	385.5	3.75	0	10	0	0	1	1	0	0	0	79.2958	79.295	79.295	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:284	:14:5:6	ry:0:en:0
i5	389.25	0.75	70	10	0	0	1	1	0	0	0	67.9758	67.975	67.975	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:285	:15:1:6	ry:0:en:0
i5	390	4.5	70	10	0	0	1	1	0	0	0	282.5781	282.578	282.578	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:286	:16:2:8	ry:5.284:en:0
i5	394.5	2.625	70	10	0	0	1	1	0	0	0	215.8099	215.809	215.809	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:287	:17:D:7	ry:5.285:en:0
i5	397.125	0.375	70	10	0	0	1	1	0	0	0	317.1832	317.183	317.183	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:288	:0:5:8	ry:5.286:en:0
i5	397.5	0.375	70	10	0	0	1	1	0	0	0	242.2384	242.238	242.238	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:289	:1:G:7	ry:5.287:en:0
i5	397.875	0.375	70	10	0	0	1	1	0	0	0	251.7485	251.748	251.748	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:290	:2:H:7	ry:5.288:en:0
i5	398.25	1.875	70	10	0	0	1	1	0	0	0	107.9049	107.904	107.904	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:291	:3:D:6	ry:0:en:0
i5	400.125	0.375	70	10	0	0	1	1	0	0	0	24.0330	24.033	24.033	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:292	:4:A:4	ry:5.290:en:0
i5	400.5	1.125	70	10	0	0	1	1	0	0	0	282.5781	282.578	282.578	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:293	:5:2:8	ry:0:en:0
i5	401.625	0.75	70	10	0	0	1	1	0	0	0	67.9758	67.975	67.975	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:294	:6:1:6	ry:0:en:0
i5	402.375	4.125	70	10	0	0	1	1	0	0	0	76.3003	76.300	76.300	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:295	:7:4:6	ry:5.293:en:0
i5	406.5	0.75	0	10	0	0	1	1	0	0	0	342.5769	342.576	342.576	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:296	:8:7:8	ry:5.294:en:0
i5	407.25	0.375	70	10	0	0	1	1	0	0	0	659.2713	659.271	659.271	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:297	:9:6:9	ry:5.295:en:0
i5	407.625	0.375	70	10	0	0	1	1	0	0	0	207.6574	207.657	207.657	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:298	:10:C:7	ry:5.296:en:0
i5	408	0.375	70	10	0	0	1	1	0	0	0	370.0035	370.003	370.003	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:299	:11:9:8	ry:5.297:en:0
i5	408.375	1.5	70	10	0	0	1	1	0	0	0	293.6719	293.671	293.671	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:300	:12:3:8	ry:5.298:en:0
i5	409.875	3.75	70	10	0	0	1	1	0	0	0	224.2824	224.282	224.282	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:301	:13:E:7	ry:0:en:0
i5	413.625	0.375	70	10	0	0	1	1	0	0	0	58.2719	58.271	58.271	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:302	:14:F:5	ry:5.300:en:0
i5	414	2.625	70	10	0	0	1	1	0	0	0	399.6259	399.625	399.625	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:303	:15:B:8	ry:0:en:0
i5	416.625	0.375	0	10	0	0	1	1	0	0	0	356.0262	356.026	356.026	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:304	:16:8:8	ry:0:en:0
i5	417	0.375	70	10	0	0	1	1	0	0	0	523.264	523.264	523.264	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:305	:17:0:9	ry:0:en:0
i5	417.375	0.375	70	10	0	0	1	1	0	0	0	192.2647	192.264	192.264	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:306	:0:A:7	ry:0:en:0
i5	417.75	0.375	70	10	0	0	1	1	0	0	0	565.1563	565.156	565.156	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:307	:1:2:9	ry:5.305:en:0
i5	418.125	0.375	0	10	0	0	1	1	0	0	0	503.4970	503.497	503.497	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:308	:2:H:8	ry:5.306:en:0
i5	418.5	1.875	70	10	0	0	1	1	0	0	0	431.6198	431.619	431.619	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:309	:3:D:8	ry:0:en:0
i5	420.375	3	70	10	0	0	1	1	0	0	0	448.5649	448.564	448.564	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:310	:4:E:8	ry:0:en:0
i5	423.375	1.875	70	10	0	0	1	1	0	0	0	342.5769	342.576	342.576	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:311	:5:7:8	ry:5.309:en:0
i5	425.25	0.75	70	10	0	0	1	1	0	0	0	271.9034	271.903	271.903	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:312	:6:1:8	ry:5.310:en:0
i5	426	2.25	70	10	0	0	1	1	0	0	0	484.4769	484.476	484.476	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:313	:7:G:8	ry:5.311:en:0
i5	428.25	0.375	70	10	0	0	1	1	0	0	0	305.2013	305.201	305.201	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:314	:8:4:8	ry:0:en:0
i5	428.625	4.5	70	10	0	0	1	1	0	0	0	293.6719	293.671	293.671	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:315	:9:3:8	ry:5.313:en:0
i5	433.125	0.375	70	10	0	0	1	1	0	0	0	329.6356	329.635	329.635	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:316	:10:6:8	ry:5.314:en:0
i5	433.5	0.375	70	10	0	0	1	1	0	0	0	370.0035	370.003	370.003	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:317	:11:9:8	ry:5.315:en:0
i5	433.875	0.75	70	10	0	0	1	1	0	0	0	356.0262	356.026	356.026	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:318	:12:8:8	ry:5.316:en:0
i5	434.625	0.375	70	10	0	0	1	1	0	0	0	130.816	130.816	130.816	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:319	:13:0:7	ry:0:en:0
i5	435	2.25	70	10	0	0	1	1	0	0	0	466.1752	466.175	466.175	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:320	:14:F:8	ry:5.318:en:0
i5	437.25	3.75	70	10	0	0	1	1	0	0	0	399.6259	399.625	399.625	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:321	:15:B:8	ry:5.319:en:0
i5	441	4.5	70	10	0	0	1	1	0	0	0	415.3149	415.314	415.314	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:322	:16:C:8	ry:5.320:en:0
i5	445.5	2.625	0	10	0	0	1	1	0	0	0	317.1832	317.183	317.183	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_6:323	:17:5:8	ry:5.321:en:0

; Seq_7 comments: Soprane (O) oppgrad support with randocts.
;ins	sta	dur	amp	ft1	aty	atk	rel	hd1	hd2	gl1	gl2	fq1	fq2	fq3	pa1	pa2	del	car	mod	hm1	hm2	cro	buz	rvn	rvs	ft2	pcd	
i6	0	0.375	70	10	0	0	1	1	0	0	0	65.408	65.408	65.408	0.5	0.5	0.3	1	1	0	0	0	0	0	0	24	2	;Sec:0:Seq_7:0	:0:0:6	ry:0:en:0
i6	0.375	0.375	70	10	0	0	1	1	0	0	0	356.0262	356.026	356.026	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:1	:1:8:8	ry:0:en:0
i6	0.75	0.75	70	10	0	0	1	1	0	0	0	799.2518	799.251	799.251	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:2	:2:B:9	ry:0:en:0
i6	1.5	2.625	70	10	0	0	1	1	0	0	0	466.1752	466.175	466.175	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:3	:3:F:8	ry:0:en:0
i6	4.125	3	70	10	0	0	1	1	0	0	0	112.1412	112.141	112.141	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:4	:4:E:6	ry:0:en:0
i6	7.125	1.875	70	10	0	0	1	1	0	0	0	146.8359	146.835	146.835	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:5	:5:3:7	ry:0:en:0
i6	9	0.75	0	10	0	0	1	1	0	0	0	370.0035	370.003	370.003	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:6	:6:9:8	ry:0:en:0
i6	9.75	3.375	70	10	0	0	1	1	0	0	0	207.6574	207.657	207.657	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:7	:7:C:7	ry:0:en:0
i6	13.125	0.375	0	10	0	0	1	1	0	0	0	329.6356	329.635	329.635	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:8	:8:6:8	ry:0:en:0
i6	13.5	0.75	70	10	0	0	1	1	0	0	0	171.2884	171.288	171.288	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:9	:9:7:7	ry:0:en:0
i6	14.25	0.75	70	10	0	0	1	1	0	0	0	19.0750	19.075	19.075	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:10	:10:4:4	ry:0:en:0
i6	15	0.375	70	10	0	0	1	1	0	0	0	543.8069	543.806	543.806	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:11	:11:1:9	ry:0:en:0
i6	15.375	0.75	70	10	0	0	1	1	0	0	0	70.6445	70.644	70.644	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:12	:12:2:6	ry:0:en:0
i6	16.125	1.125	70	10	0	0	1	1	0	0	0	384.5295	384.529	384.529	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:13	:13:A:8	ry:0:en:0
i6	17.25	3.75	70	10	0	0	1	1	0	0	0	215.8099	215.809	215.809	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:14	:14:D:7	ry:0:en:0
i6	21	0.75	70	10	0	0	1	1	0	0	0	503.4970	503.497	503.497	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:15	:15:H:8	ry:0:en:0
i6	21.75	0.375	70	10	0	0	1	1	0	0	0	121.1192	121.119	121.119	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:16	:16:G:6	ry:0:en:0
i6	22.125	0.375	70	10	0	0	1	1	0	0	0	317.1832	317.183	317.183	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:17	:17:5:8	ry:0:en:0
i6	22.5	0.375	70	10	0	0	1	1	0	0	0	26.9762	26.976	26.976	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:18	:0:D:4	ry:0:en:0
i6	22.875	0.375	0	10	0	0	1	1	0	0	0	141.2890	141.289	141.289	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:19	:1:2:7	ry:0:en:0
i6	23.25	0.375	0	10	0	0	1	1	0	0	0	271.9034	271.903	271.903	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:20	:2:1:8	ry:0:en:0
i6	23.625	1.875	70	10	0	0	1	1	0	0	0	19.8239	19.823	19.823	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:21	:3:5:4	ry:0:en:0
i6	25.5	0.375	70	10	0	0	1	1	0	0	0	89.0065	89.006	89.006	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:22	:4:8:6	ry:0:en:0
i6	25.875	0.375	70	10	0	0	1	1	0	0	0	484.4769	484.476	484.476	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:23	:5:G:8	ry:0:en:0
i6	26.25	0.75	70	10	0	0	1	1	0	0	0	125.8742	125.874	125.874	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:24	:6:H:6	ry:0:en:0
i6	27	4.5	70	10	0	0	1	1	0	0	0	224.2824	224.282	224.282	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:25	:7:E:7	ry:0:en:0
i6	31.5	0.375	70	10	0	0	1	1	0	0	0	199.8129	199.812	199.812	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:26	:8:B:7	ry:0:en:0
i6	31.875	0.375	70	10	0	0	1	1	0	0	0	415.3149	415.314	415.314	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:27	:9:C:8	ry:0:en:0
i6	32.25	1.5	70	10	0	0	1	1	0	0	0	82.4089	82.408	82.408	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:28	:10:6:6	ry:0:en:0
i6	33.75	0.375	70	10	0	0	1	1	0	0	0	23.1252	23.125	23.125	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:29	:11:9:4	ry:0:en:0
i6	34.125	3.375	70	10	0	0	1	1	0	0	0	58.2719	58.271	58.271	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:30	:12:F:5	ry:0:en:0
i6	37.5	2.25	70	10	0	0	1	1	0	0	0	305.2013	305.201	305.201	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:31	:13:4:8	ry:0:en:0
i6	39.75	2.25	70	10	0	0	1	1	0	0	0	36.7089	36.708	36.708	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:32	:14:3:5	ry:0:en:0
i6	42	4.5	70	10	0	0	1	1	0	0	0	342.5769	342.576	342.576	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:33	:15:7:8	ry:0:en:0
i6	46.5	0.375	70	10	0	0	1	1	0	0	0	96.1323	96.132	96.132	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:34	:16:A:6	ry:0:en:0
i6	46.875	0.375	70	10	0	0	1	1	0	0	0	65.408	65.408	65.408	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:35	:17:0:6	ry:0:en:0
i6	47.25	0.375	70	10	0	0	1	1	0	0	0	356.0262	356.026	356.026	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:36	:0:8:8	ry:0:en:0
i6	47.625	0.375	70	10	0	0	1	1	0	0	0	968.9538	968.953	968.953	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:37	:1:G:9	ry:0:en:0
i6	48	0.375	70	10	0	0	1	1	0	0	0	271.9034	271.903	271.903	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:38	:2:1:8	ry:0:en:0
i6	48.375	1.875	70	10	0	0	1	1	0	0	0	317.1832	317.183	317.183	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:39	:3:5:8	ry:0:en:0
i6	50.25	1.875	70	10	0	0	1	1	0	0	0	152.6006	152.600	152.600	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:40	:4:4:7	ry:0:en:0
i6	52.125	1.875	70	10	0	0	1	1	0	0	0	199.8129	199.812	199.812	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:41	:5:B:7	ry:0:en:0
i6	54	0.75	0	10	0	0	1	1	0	0	0	62.9371	62.937	62.937	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:42	:6:H:5	ry:0:en:0
i6	54.75	1.5	70	10	0	0	1	1	0	0	0	35.3222	35.322	35.322	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:43	:7:2:5	ry:0:en:0
i6	56.25	0.375	70	10	0	0	1	1	0	0	0	224.2824	224.282	224.282	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:44	:8:E:7	ry:0:en:0
i6	56.625	0.75	70	10	0	0	1	1	0	0	0	116.5438	116.543	116.543	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:45	:9:F:6	ry:0:en:0
i6	57.375	0.75	70	10	0	0	1	1	0	0	0	830.6298	830.629	830.629	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:46	:10:C:9	ry:0:en:0
i6	58.125	0.375	70	10	0	0	1	1	0	0	0	740.0070	740.007	740.007	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:47	:11:9:9	ry:0:en:0
i6	58.5	0.75	70	10	0	0	1	1	0	0	0	192.2647	192.264	192.264	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:48	:12:A:7	ry:0:en:0
i6	59.25	0.375	70	10	0	0	1	1	0	0	0	65.408	65.408	65.408	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:49	:13:0:6	ry:0:en:0
i6	59.625	2.25	70	10	0	0	1	1	0	0	0	587.3439	587.343	587.343	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:50	:14:3:9	ry:0:en:0
i6	61.875	4.5	70	10	0	0	1	1	0	0	0	685.1538	685.153	685.153	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:51	:15:7:9	ry:0:en:0
i6	66.375	0.375	0	10	0	0	1	1	0	0	0	164.8178	164.817	164.817	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:52	:16:6:7	ry:0:en:0
i6	66.75	0.375	70	10	0	0	1	1	0	0	0	107.9049	107.904	107.904	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:53	:17:D:6	ry:0:en:0
i6	67.125	0.375	70	10	0	0	1	1	0	0	0	293.6719	293.671	293.671	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:54	:0:3:8	ry:0:en:0
i6	67.5	0.375	70	10	0	0	1	1	0	0	0	384.5295	384.529	384.529	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:55	:1:A:8	ry:0:en:0
i6	67.875	0.375	70	10	0	0	1	1	0	0	0	185.0017	185.001	185.001	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:56	:2:9:7	ry:0:en:0
i6	68.25	1.875	70	10	0	0	1	1	0	0	0	215.8099	215.809	215.809	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:57	:3:D:7	ry:0:en:0
i6	70.125	0.375	70	10	0	0	1	1	0	0	0	242.2384	242.238	242.238	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:58	:4:G:7	ry:0:en:0
i6	70.5	3.75	70	10	0	0	1	1	0	0	0	329.6356	329.635	329.635	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:59	:5:6:8	ry:0:en:0
i6	74.25	4.5	70	10	0	0	1	1	0	0	0	85.6442	85.644	85.644	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:60	:6:7:6	ry:0:en:0
i6	78.75	3.375	70	10	0	0	1	1	0	0	0	152.6006	152.600	152.600	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:61	:7:4:7	ry:0:en:0
i6	82.125	0.375	70	10	0	0	1	1	0	0	0	271.9034	271.903	271.903	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:62	:8:1:8	ry:0:en:0
i6	82.5	0.375	70	10	0	0	1	1	0	0	0	282.5781	282.578	282.578	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:63	:9:2:8	ry:0:en:0
i6	82.875	1.5	0	10	0	0	1	1	0	0	0	28.0353	28.035	28.035	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:64	:10:E:4	ry:0:en:0
i6	84.375	0.375	70	10	0	0	1	1	0	0	0	503.4970	503.497	503.497	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:65	:11:H:8	ry:0:en:0
i6	84.75	2.25	70	10	0	0	1	1	0	0	0	158.5916	158.591	158.591	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:66	:12:5:7	ry:0:en:0
i6	87	2.25	70	10	0	0	1	1	0	0	0	415.3149	415.314	415.314	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:67	:13:C:8	ry:0:en:0
i6	89.25	2.25	0	10	0	0	1	1	0	0	0	399.6259	399.625	399.625	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:68	:14:B:8	ry:0:en:0
i6	91.5	4.5	70	10	0	0	1	1	0	0	0	233.0876	233.087	233.087	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:69	:15:F:7	ry:0:en:0
i6	96	0.375	70	10	0	0	1	1	0	0	0	130.816	130.816	130.816	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:70	:16:0:7	ry:0:en:0
i6	96.375	0.375	70	10	0	0	1	1	0	0	0	89.0065	89.006	89.006	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:71	:17:8:6	ry:0:en:0
i6	96.75	0.375	70	10	0	0	1	1	0	0	0	242.2384	242.238	242.238	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:72	:0:G:7	ry:0:en:0
i6	97.125	0.75	70	10	0	0	1	1	0	0	0	329.6356	329.635	329.635	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:73	:1:6:8	ry:0:en:0
i6	97.875	0.375	70	10	0	0	1	1	0	0	0	370.0035	370.003	370.003	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:74	:2:9:8	ry:0:en:0
i6	98.25	1.875	70	10	0	0	1	1	0	0	0	215.8099	215.809	215.809	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:75	:3:D:7	ry:0:en:0
i6	100.125	1.875	70	10	0	0	1	1	0	0	0	415.3149	415.314	415.314	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:76	:4:C:8	ry:0:en:0
i6	102	0.375	70	10	0	0	1	1	0	0	0	67.9758	67.975	67.975	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:77	:5:1:6	ry:0:en:0
i6	102.375	4.5	0	10	0	0	1	1	0	0	0	685.1538	685.153	685.153	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:78	:6:7:9	ry:0:en:0
i6	106.875	1.5	0	10	0	0	1	1	0	0	0	24.0330	24.033	24.033	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:79	:7:A:4	ry:0:en:0
i6	108.375	0.375	70	10	0	0	1	1	0	0	0	305.2013	305.201	305.201	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:80	:8:4:8	ry:0:en:0
i6	108.75	0.375	70	10	0	0	1	1	0	0	0	317.1832	317.183	317.183	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:81	:9:5:8	ry:0:en:0
i6	109.125	0.375	70	10	0	0	1	1	0	0	0	282.5781	282.578	282.578	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:82	:10:2:8	ry:0:en:0
i6	109.5	0.375	70	10	0	0	1	1	0	0	0	503.4970	503.497	503.497	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:83	:11:H:8	ry:0:en:0
i6	109.875	0.375	70	10	0	0	1	1	0	0	0	65.408	65.408	65.408	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:84	:12:0:6	ry:0:en:0
i6	110.25	0.375	70	10	0	0	1	1	0	0	0	178.0131	178.013	178.013	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:85	:13:8:7	ry:0:en:0
i6	110.625	2.25	70	10	0	0	1	1	0	0	0	99.9064	99.906	99.906	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:86	:14:B:6	ry:0:en:0
i6	112.875	4.5	70	10	0	0	1	1	0	0	0	116.5438	116.543	116.543	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:87	:15:F:6	ry:0:en:0
i6	117.375	0.375	70	10	0	0	1	1	0	0	0	448.5649	448.564	448.564	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:88	:16:E:8	ry:0:en:0
i6	117.75	0.375	70	10	0	0	1	1	0	0	0	293.6719	293.671	293.671	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:89	:17:3:8	ry:0:en:0
i6	118.125	0.375	0	10	0	0	1	1	0	0	0	399.6259	399.625	399.625	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:90	:0:B:8	ry:0:en:0
i6	118.5	0.375	70	10	0	0	1	1	0	0	0	261.632	261.632	261.632	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:91	:1:0:8	ry:0:en:0
i6	118.875	0.375	70	10	0	0	1	1	0	0	0	251.7485	251.748	251.748	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:92	:2:H:7	ry:0:en:0
i6	119.25	1.125	70	10	0	0	1	1	0	0	0	73.4179	73.417	73.417	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:93	:3:3:6	ry:0:en:0
i6	120.375	3	70	10	0	0	1	1	0	0	0	329.6356	329.635	329.635	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:94	:4:6:8	ry:0:en:0
i6	123.375	3.75	70	10	0	0	1	1	0	0	0	112.1412	112.141	112.141	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:95	:5:E:6	ry:0:en:0
i6	127.125	4.5	70	10	0	0	1	1	0	0	0	233.0876	233.087	233.087	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:96	:6:F:7	ry:0:en:0
i6	131.625	3.375	70	10	0	0	1	1	0	0	0	25.9571	25.957	25.957	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:97	:7:C:4	ry:0:en:0
i6	135	0.375	70	10	0	0	1	1	0	0	0	370.0035	370.003	370.003	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:98	:8:9:8	ry:0:en:0
i6	135.375	0.375	70	10	0	0	1	1	0	0	0	48.0661	48.066	48.066	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:99	:9:A:5	ry:0:en:0
i6	135.75	0.75	70	10	0	0	1	1	0	0	0	152.6006	152.600	152.600	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:100	:10:4:7	ry:0:en:0
i6	136.5	2.625	0	10	0	0	1	1	0	0	0	685.1538	685.153	685.153	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:101	:11:7:9	ry:0:en:0
i6	139.125	2.25	70	10	0	0	1	1	0	0	0	107.9049	107.904	107.904	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:102	:12:D:6	ry:0:en:0
i6	141.375	1.125	70	10	0	0	1	1	0	0	0	282.5781	282.578	282.578	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:103	:13:2:8	ry:0:en:0
i6	142.5	0.75	70	10	0	0	1	1	0	0	0	543.8069	543.806	543.806	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:104	:14:1:9	ry:0:en:0
i6	143.25	4.125	70	10	0	0	1	1	0	0	0	158.5916	158.591	158.591	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:105	:15:5:7	ry:0:en:0
i6	147.375	0.375	70	10	0	0	1	1	0	0	0	44.5032	44.503	44.503	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:106	:16:8:5	ry:0:en:0
i6	147.75	0.375	70	10	0	0	1	1	0	0	0	968.9538	968.953	968.953	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:107	:17:G:9	ry:0:en:0
i6	148.125	0.375	70	10	0	0	1	1	0	0	0	164.8178	164.817	164.817	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:108	:0:6:7	ry:0:en:0
i6	148.5	0.75	0	10	0	0	1	1	0	0	0	112.1412	112.141	112.141	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:109	:1:E:6	ry:0:en:0
i6	149.25	0.375	70	10	0	0	1	1	0	0	0	251.7485	251.748	251.748	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:110	:2:H:7	ry:0:en:0
i6	149.625	1.125	70	10	0	0	1	1	0	0	0	587.3439	587.343	587.343	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:111	:3:3:9	ry:0:en:0
i6	150.75	0.75	70	10	0	0	1	1	0	0	0	282.5781	282.578	282.578	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:112	:4:2:8	ry:0:en:0
i6	151.5	0.375	70	10	0	0	1	1	0	0	0	370.0035	370.003	370.003	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:113	:5:9:8	ry:0:en:0
i6	151.875	4.5	70	10	0	0	1	1	0	0	0	116.5438	116.543	116.543	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:114	:6:F:6	ry:0:en:0
i6	156.375	0.375	70	10	0	0	1	1	0	0	0	130.816	130.816	130.816	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:115	:7:0:7	ry:0:en:0
i6	156.75	0.375	70	10	0	0	1	1	0	0	0	830.6298	830.629	830.629	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:116	:8:C:9	ry:0:en:0
i6	157.125	0.375	70	10	0	0	1	1	0	0	0	107.9049	107.904	107.904	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:117	:9:D:6	ry:0:en:0
i6	157.5	0.375	70	10	0	0	1	1	0	0	0	192.2647	192.264	192.264	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:118	:10:A:7	ry:0:en:0
i6	157.875	2.625	70	10	0	0	1	1	0	0	0	171.2884	171.288	171.288	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:119	:11:7:7	ry:0:en:0
i6	160.5	0.375	70	10	0	0	1	1	0	0	0	89.0065	89.006	89.006	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:120	:12:8:6	ry:0:en:0
i6	160.875	0.375	70	10	0	0	1	1	0	0	0	484.4769	484.476	484.476	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:121	:13:G:8	ry:0:en:0
i6	161.25	0.75	0	10	0	0	1	1	0	0	0	271.9034	271.903	271.903	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:122	:14:1:8	ry:0:en:0
i6	162	4.125	70	10	0	0	1	1	0	0	0	317.1832	317.183	317.183	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:123	:15:5:8	ry:0:en:0
i6	166.125	0.375	70	10	0	0	1	1	0	0	0	76.3003	76.300	76.300	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:124	:16:4:6	ry:0:en:0
i6	166.5	0.375	70	10	0	0	1	1	0	0	0	399.6259	399.625	399.625	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:125	:17:B:8	ry:0:en:0
i6	166.875	0.375	70	10	0	0	1	1	0	0	0	67.9758	67.975	67.975	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:126	:0:1:6	ry:0:en:0
i6	167.25	0.375	70	10	0	0	1	1	0	0	0	178.0131	178.013	178.013	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:127	:1:8:7	ry:0:en:0
i6	167.625	1.5	70	10	0	0	1	1	0	0	0	42.8221	42.822	42.822	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:128	:2:7:5	ry:0:en:0
i6	169.125	1.125	70	10	0	0	1	1	0	0	0	199.8129	199.812	199.812	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:129	:3:B:7	ry:0:en:0
i6	170.25	3	70	10	0	0	1	1	0	0	0	448.5649	448.564	448.564	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:130	:4:E:8	ry:0:en:0
i6	173.25	2.25	70	10	0	0	1	1	0	0	0	152.6006	152.600	152.600	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:131	:5:4:7	ry:0:en:0
i6	175.5	3.75	70	10	0	0	1	1	0	0	0	317.1832	317.183	317.183	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:132	:6:5:8	ry:0:en:0
i6	179.25	1.5	70	10	0	0	1	1	0	0	0	282.5781	282.578	282.578	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:133	:7:2:8	ry:0:en:0
i6	180.75	0.375	0	10	0	0	1	1	0	0	0	503.4970	503.497	503.497	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:134	:8:H:8	ry:0:en:0
i6	181.125	0.375	70	10	0	0	1	1	0	0	0	65.408	65.408	65.408	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:135	:9:0:6	ry:0:en:0
i6	181.5	0.75	70	10	0	0	1	1	0	0	0	415.3149	415.314	415.314	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:136	:10:C:8	ry:0:en:0
i6	182.25	2.625	70	10	0	0	1	1	0	0	0	116.5438	116.543	116.543	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:137	:11:F:6	ry:0:en:0
i6	184.875	1.5	70	10	0	0	1	1	0	0	0	293.6719	293.671	293.671	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:138	:12:3:8	ry:0:en:0
i6	186.375	1.125	70	10	0	0	1	1	0	0	0	96.1323	96.132	96.132	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:139	:13:A:6	ry:0:en:0
i6	187.5	0.75	70	10	0	0	1	1	0	0	0	185.0017	185.001	185.001	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:140	:14:9:7	ry:0:en:0
i6	188.25	4.125	70	10	0	0	1	1	0	0	0	863.2397	863.239	863.239	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:141	:15:D:9	ry:0:en:0
i6	192.375	0.375	70	10	0	0	1	1	0	0	0	121.1192	121.119	121.119	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:142	:16:G:6	ry:0:en:0
i6	192.75	0.75	0	10	0	0	1	1	0	0	0	329.6356	329.635	329.635	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:143	:17:6:8	ry:0:en:0
i6	193.5	0.375	70	10	0	0	1	1	0	0	0	224.2824	224.282	224.282	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:144	:0:E:7	ry:0:en:0
i6	193.875	0.375	70	10	0	0	1	1	0	0	0	305.2013	305.201	305.201	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:145	:1:4:8	ry:0:en:0
i6	194.25	1.5	70	10	0	0	1	1	0	0	0	42.8221	42.822	42.822	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:146	:2:7:5	ry:0:en:0
i6	195.75	1.125	70	10	0	0	1	1	0	0	0	399.6259	399.625	399.625	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:147	:3:B:8	ry:0:en:0
i6	196.875	0.75	0	10	0	0	1	1	0	0	0	384.5295	384.529	384.529	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:148	:4:A:8	ry:0:en:0
i6	197.625	0.375	70	10	0	0	1	1	0	0	0	31.4685	31.468	31.468	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:149	:5:H:4	ry:0:en:0
i6	198	3.75	70	10	0	0	1	1	0	0	0	317.1832	317.183	317.183	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:150	:6:5:8	ry:0:en:0
i6	201.75	0.375	70	10	0	0	1	1	0	0	0	89.0065	89.006	89.006	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:151	:7:8:6	ry:0:en:0
i6	202.125	0.375	70	10	0	0	1	1	0	0	0	282.5781	282.578	282.578	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:152	:8:2:8	ry:0:en:0
i6	202.5	0.375	70	10	0	0	1	1	0	0	0	146.8359	146.835	146.835	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:153	:9:3:7	ry:0:en:0
i6	202.875	0.375	0	10	0	0	1	1	0	0	0	523.264	523.264	523.264	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:154	:10:0:9	ry:0:en:0
i6	203.25	2.625	70	10	0	0	1	1	0	0	0	58.2719	58.271	58.271	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:155	:11:F:5	ry:0:en:0
i6	205.875	0.375	70	10	0	0	1	1	0	0	0	242.2384	242.238	242.238	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:156	:12:G:7	ry:0:en:0
i6	206.25	3.75	70	10	0	0	1	1	0	0	0	329.6356	329.635	329.635	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:157	:13:6:8	ry:0:en:0
i6	210	0.75	70	10	0	0	1	1	0	0	0	23.1252	23.125	23.125	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:158	:14:9:4	ry:0:en:0
i6	210.75	4.125	70	10	0	0	1	1	0	0	0	107.9049	107.904	107.904	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:159	:15:D:6	ry:0:en:0
i6	214.875	0.375	70	10	0	0	1	1	0	0	0	103.8287	103.828	103.828	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:160	:16:C:6	ry:0:en:0
i6	215.25	0.375	70	10	0	0	1	1	0	0	0	67.9758	67.975	67.975	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:161	:17:1:6	ry:0:en:0
i6	215.625	0.375	70	10	0	0	1	1	0	0	0	370.0035	370.003	370.003	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:162	:0:9:8	ry:0:en:0
i6	216	0.375	70	10	0	0	1	1	0	0	0	484.4769	484.476	484.476	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:163	:1:G:8	ry:0:en:0
i6	216.375	1.5	70	10	0	0	1	1	0	0	0	466.1752	466.175	466.175	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:164	:2:F:8	ry:0:en:0
i6	217.875	0.375	70	10	0	0	1	1	0	0	0	67.9758	67.975	67.975	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:165	:3:1:6	ry:0:en:0
i6	218.25	1.875	70	10	0	0	1	1	0	0	0	152.6006	152.600	152.600	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:166	:4:4:7	ry:0:en:0
i6	220.125	2.25	70	10	0	0	1	1	0	0	0	415.3149	415.314	415.314	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:167	:5:C:8	ry:0:en:0
i6	222.375	3.75	0	10	0	0	1	1	0	0	0	863.2397	863.239	863.239	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:168	:6:D:9	ry:0:en:0
i6	226.125	1.5	70	10	0	0	1	1	0	0	0	769.0591	769.059	769.059	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:169	:7:A:9	ry:0:en:0
i6	227.625	0.375	70	10	0	0	1	1	0	0	0	85.6442	85.644	85.644	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:170	:8:7:6	ry:0:en:0
i6	228	0.375	70	10	0	0	1	1	0	0	0	356.0262	356.026	356.026	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:171	:9:8:8	ry:0:en:0
i6	228.375	0.375	70	10	0	0	1	1	0	0	0	282.5781	282.578	282.578	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:172	:10:2:8	ry:0:en:0
i6	228.75	1.875	70	10	0	0	1	1	0	0	0	158.5916	158.591	158.591	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:173	:11:5:7	ry:0:en:0
i6	230.625	1.5	70	10	0	0	1	1	0	0	0	399.6259	399.625	399.625	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:174	:12:B:8	ry:0:en:0
i6	232.125	0.375	70	10	0	0	1	1	0	0	0	130.816	130.816	130.816	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:175	:13:0:7	ry:0:en:0
i6	232.5	0.75	70	10	0	0	1	1	0	0	0	503.4970	503.497	503.497	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:176	:14:H:8	ry:0:en:0
i6	233.25	2.625	70	10	0	0	1	1	0	0	0	587.3439	587.343	587.343	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:177	:15:3:9	ry:0:en:0
i6	235.875	0.375	0	10	0	0	1	1	0	0	0	659.2713	659.271	659.271	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:178	:16:6:9	ry:0:en:0
i6	236.25	0.75	70	10	0	0	1	1	0	0	0	112.1412	112.141	112.141	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:179	:17:E:6	ry:0:en:0
i6	237	0.375	70	10	0	0	1	1	0	0	0	38.1501	38.150	38.150	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:180	:0:4:5	ry:0:en:0
i6	237.375	0.375	70	10	0	0	1	1	0	0	0	415.3149	415.314	415.314	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:181	:1:C:8	ry:0:en:0
i6	237.75	1.5	70	10	0	0	1	1	0	0	0	466.1752	466.175	466.175	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:182	:2:F:8	ry:0:en:0
i6	239.25	0.375	70	10	0	0	1	1	0	0	0	33.9879	33.987	33.987	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:183	:3:1:5	ry:0:en:0
i6	239.625	0.375	70	10	0	0	1	1	0	0	0	261.632	261.632	261.632	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:184	:4:0:8	ry:0:en:0
i6	240	4.125	70	10	0	0	1	1	0	0	0	42.8221	42.822	42.822	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:185	:5:7:5	ry:0:en:0
i6	244.125	3.75	0	10	0	0	1	1	0	0	0	863.2397	863.239	863.239	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:186	:6:D:9	ry:0:en:0
i6	247.875	0.375	70	10	0	0	1	1	0	0	0	484.4769	484.476	484.476	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:187	:7:G:8	ry:0:en:0
i6	248.25	0.375	70	10	0	0	1	1	0	0	0	384.5295	384.529	384.529	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:188	:8:A:8	ry:0:en:0
i6	248.625	0.375	70	10	0	0	1	1	0	0	0	799.2518	799.251	799.251	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:189	:9:B:9	ry:0:en:0
i6	249	0.375	70	10	0	0	1	1	0	0	0	178.0131	178.013	178.013	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:190	:10:8:7	ry:0:en:0
i6	249.375	1.875	70	10	0	0	1	1	0	0	0	79.2958	79.295	79.295	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:191	:11:5:6	ry:0:en:0
i6	251.25	3	0	10	0	0	1	1	0	0	0	41.2044	41.204	41.204	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:192	:12:6:5	ry:0:en:0
i6	254.25	3.75	70	10	0	0	1	1	0	0	0	28.0353	28.035	28.035	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:193	:13:E:4	ry:0:en:0
i6	258	0.75	70	10	0	0	1	1	0	0	0	503.4970	503.497	503.497	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:194	:14:H:8	ry:0:en:0
i6	258.75	2.625	70	10	0	0	1	1	0	0	0	146.8359	146.835	146.835	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:195	:15:3:7	ry:0:en:0
i6	261.375	0.375	70	10	0	0	1	1	0	0	0	70.6445	70.644	70.644	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:196	:16:2:6	ry:0:en:0
i6	261.75	0.375	70	10	0	0	1	1	0	0	0	185.0017	185.001	185.001	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:197	:17:9:7	ry:0:en:0
i6	262.125	0.375	70	10	0	0	1	1	0	0	0	251.7485	251.748	251.748	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:198	:0:H:7	ry:0:en:0
i6	262.5	0.75	70	10	0	0	1	1	0	0	0	82.4089	82.408	82.408	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:199	:1:6:6	ry:0:en:0
i6	263.25	1.125	70	10	0	0	1	1	0	0	0	317.1832	317.183	317.183	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:200	:2:5:8	ry:0:en:0
i6	264.375	0.375	0	10	0	0	1	1	0	0	0	185.0017	185.001	185.001	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:201	:3:9:7	ry:0:en:0
i6	264.75	1.875	70	10	0	0	1	1	0	0	0	207.6574	207.657	207.657	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:202	:4:C:7	ry:0:en:0
i6	266.625	1.125	70	10	0	0	1	1	0	0	0	282.5781	282.578	282.578	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:203	:5:2:8	ry:0:en:0
i6	267.75	2.25	0	10	0	0	1	1	0	0	0	293.6719	293.671	293.671	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:204	:6:3:8	ry:0:en:0
i6	270	0.375	70	10	0	0	1	1	0	0	0	65.408	65.408	65.408	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:205	:7:0:6	ry:0:en:0
i6	270.375	0.375	70	10	0	0	1	1	0	0	0	116.5438	116.543	116.543	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:206	:8:F:6	ry:0:en:0
i6	270.75	0.375	70	10	0	0	1	1	0	0	0	121.1192	121.119	121.119	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:207	:9:G:6	ry:0:en:0
i6	271.125	0.375	70	10	0	0	1	1	0	0	0	769.0591	769.059	769.059	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:208	:10:A:9	ry:0:en:0
i6	271.5	1.875	70	10	0	0	1	1	0	0	0	26.9762	26.976	26.976	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:209	:11:D:4	ry:0:en:0
i6	273.375	0.375	70	10	0	0	1	1	0	0	0	135.9517	135.951	135.951	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:210	:12:1:7	ry:0:en:0
i6	273.75	0.375	70	10	0	0	1	1	0	0	0	22.2516	22.251	22.251	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:211	:13:8:4	ry:0:en:0
i6	274.125	4.5	70	10	0	0	1	1	0	0	0	21.4110	21.411	21.411	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:212	:14:7:4	ry:0:en:0
i6	278.625	2.625	70	10	0	0	1	1	0	0	0	199.8129	199.812	199.812	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:213	:15:B:7	ry:0:en:0
i6	281.25	0.375	70	10	0	0	1	1	0	0	0	112.1412	112.141	112.141	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:214	:16:E:6	ry:0:en:0
i6	281.625	0.375	70	10	0	0	1	1	0	0	0	152.6006	152.600	152.600	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:215	:17:4:7	ry:0:en:0
i6	282	0.375	70	10	0	0	1	1	0	0	0	103.8287	103.828	103.828	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:216	:0:C:6	ry:0:en:0
i6	282.375	0.375	70	10	0	0	1	1	0	0	0	70.6445	70.644	70.644	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:217	:1:2:6	ry:0:en:0
i6	282.75	1.125	0	10	0	0	1	1	0	0	0	158.5916	158.591	158.591	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:218	:2:5:7	ry:0:en:0
i6	283.875	0.375	70	10	0	0	1	1	0	0	0	185.0017	185.001	185.001	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:219	:3:9:7	ry:0:en:0
i6	284.25	0.375	70	10	0	0	1	1	0	0	0	89.0065	89.006	89.006	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:220	:4:8:6	ry:0:en:0
i6	284.625	4.125	0	10	0	0	1	1	0	0	0	116.5438	116.543	116.543	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:221	:5:F:6	ry:0:en:0
i6	288.75	2.25	70	10	0	0	1	1	0	0	0	587.3439	587.343	587.343	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:222	:6:3:9	ry:0:en:0
i6	291	4.5	70	10	0	0	1	1	0	0	0	82.4089	82.408	82.408	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:223	:7:6:6	ry:0:en:0
i6	295.5	0.375	70	10	0	0	1	1	0	0	0	16.352	16.352	16.352	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:224	:8:0:4	ry:0:en:0
i6	295.875	0.375	70	10	0	0	1	1	0	0	0	67.9758	67.975	67.975	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:225	:9:1:6	ry:0:en:0
i6	296.25	0.375	70	10	0	0	1	1	0	0	0	121.1192	121.119	121.119	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:226	:10:G:6	ry:0:en:0
i6	296.625	1.875	70	10	0	0	1	1	0	0	0	863.2397	863.239	863.239	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:227	:11:D:9	ry:0:en:0
i6	298.5	3	70	10	0	0	1	1	0	0	0	56.0706	56.070	56.070	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:228	:12:E:5	ry:0:en:0
i6	301.5	2.25	70	10	0	0	1	1	0	0	0	305.2013	305.201	305.201	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:229	:13:4:8	ry:0:en:0
i6	303.75	4.5	70	10	0	0	1	1	0	0	0	85.6442	85.644	85.644	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:230	:14:7:6	ry:0:en:0
i6	308.25	2.625	70	10	0	0	1	1	0	0	0	399.6259	399.625	399.625	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:231	:15:B:8	ry:0:en:0
i6	310.875	0.375	70	10	0	0	1	1	0	0	0	384.5295	384.529	384.529	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:232	:16:A:8	ry:0:en:0
i6	311.25	0.375	70	10	0	0	1	1	0	0	0	503.4970	503.497	503.497	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:233	:17:H:8	ry:0:en:0
i6	311.625	0.375	70	10	0	0	1	1	0	0	0	685.1538	685.153	685.153	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:234	:0:7:9	ry:0:en:0
i6	312	0.75	70	10	0	0	1	1	0	0	0	224.2824	224.282	224.282	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:235	:1:E:7	ry:0:en:0
i6	312.75	1.125	70	10	0	0	1	1	0	0	0	215.8099	215.809	215.809	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:236	:2:D:7	ry:0:en:0
i6	313.875	0.375	70	10	0	0	1	1	0	0	0	503.4970	503.497	503.497	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:237	:3:H:8	ry:0:en:0
i6	314.25	0.75	70	10	0	0	1	1	0	0	0	141.2890	141.289	141.289	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:238	:4:2:7	ry:0:en:0
i6	315	1.125	70	10	0	0	1	1	0	0	0	769.0591	769.059	769.059	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:239	:5:A:9	ry:0:en:0
i6	316.125	2.25	70	10	0	0	1	1	0	0	0	49.9532	49.953	49.953	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:240	:6:B:5	ry:0:en:0
i6	318.375	0.375	70	10	0	0	1	1	0	0	0	712.0524	712.052	712.052	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:241	:7:8:9	ry:0:en:0
i6	318.75	0.375	70	10	0	0	1	1	0	0	0	19.8239	19.823	19.823	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:242	:8:5:4	ry:0:en:0
i6	319.125	0.75	70	10	0	0	1	1	0	0	0	82.4089	82.408	82.408	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:243	:9:6:6	ry:0:en:0
i6	319.875	0.375	70	10	0	0	1	1	0	0	0	65.408	65.408	65.408	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:244	:10:0:6	ry:0:en:0
i6	320.25	1.125	70	10	0	0	1	1	0	0	0	587.3439	587.343	587.343	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:245	:11:3:9	ry:0:en:0
i6	321.375	0.375	70	10	0	0	1	1	0	0	0	370.0035	370.003	370.003	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:246	:12:9:8	ry:0:en:0
i6	321.75	0.375	70	10	0	0	1	1	0	0	0	242.2384	242.238	242.238	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:247	:13:G:7	ry:0:en:0
i6	322.125	4.5	0	10	0	0	1	1	0	0	0	116.5438	116.543	116.543	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:248	:14:F:6	ry:0:en:0
i6	326.625	0.75	0	10	0	0	1	1	0	0	0	16.9939	16.993	16.993	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:249	:15:1:4	ry:0:en:0
i6	327.375	0.375	70	10	0	0	1	1	0	0	0	152.6006	152.600	152.600	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:250	:16:4:7	ry:0:en:0
i6	327.75	0.375	70	10	0	0	1	1	0	0	0	103.8287	103.828	103.828	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:251	:17:C:6	ry:0:en:0
i6	328.125	0.375	70	10	0	0	1	1	0	0	0	565.1563	565.156	565.156	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:252	:0:2:9	ry:0:en:0
i6	328.5	0.375	70	10	0	0	1	1	0	0	0	96.1323	96.132	96.132	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:253	:1:A:6	ry:0:en:0
i6	328.875	1.125	70	10	0	0	1	1	0	0	0	53.9524	53.952	53.952	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:254	:2:D:5	ry:0:en:0
i6	330	0.375	70	10	0	0	1	1	0	0	0	503.4970	503.497	503.497	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:255	:3:H:8	ry:0:en:0
i6	330.375	0.375	70	10	0	0	1	1	0	0	0	121.1192	121.119	121.119	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:256	:4:G:6	ry:0:en:0
i6	330.75	3	70	10	0	0	1	1	0	0	0	634.3665	634.366	634.366	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:257	:5:5:9	ry:0:en:0
i6	333.75	2.25	0	10	0	0	1	1	0	0	0	49.9532	49.953	49.953	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:258	:6:B:5	ry:0:en:0
i6	336	4.5	70	10	0	0	1	1	0	0	0	448.5649	448.564	448.564	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:259	:7:E:8	ry:0:en:0
i6	340.5	0.375	70	10	0	0	1	1	0	0	0	89.0065	89.006	89.006	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:260	:8:8:6	ry:0:en:0
i6	340.875	0.375	70	10	0	0	1	1	0	0	0	370.0035	370.003	370.003	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:261	:9:9:8	ry:0:en:0
i6	341.25	1.5	0	10	0	0	1	1	0	0	0	82.4089	82.408	82.408	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:262	:10:6:6	ry:0:en:0
i6	342.75	1.125	70	10	0	0	1	1	0	0	0	293.6719	293.671	293.671	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:263	:11:3:8	ry:0:en:0
i6	343.875	1.875	70	10	0	0	1	1	0	0	0	19.0750	19.075	19.075	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:264	:12:4:4	ry:0:en:0
i6	345.75	2.25	70	10	0	0	1	1	0	0	0	207.6574	207.657	207.657	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:265	:13:C:7	ry:0:en:0
i6	348	4.5	70	10	0	0	1	1	0	0	0	466.1752	466.175	466.175	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:266	:14:F:8	ry:0:en:0
i6	352.5	0.75	70	10	0	0	1	1	0	0	0	271.9034	271.903	271.903	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:267	:15:1:8	ry:0:en:0
i6	353.25	0.375	70	10	0	0	1	1	0	0	0	261.632	261.632	261.632	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:268	:16:0:8	ry:0:en:0
i6	353.625	0.75	70	10	0	0	1	1	0	0	0	85.6442	85.644	85.644	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:269	:17:7:6	ry:0:en:0
i6	354.375	0.375	70	10	0	0	1	1	0	0	0	466.1752	466.175	466.175	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:270	:0:F:8	ry:0:en:0
i6	354.75	0.375	70	10	0	0	1	1	0	0	0	76.3003	76.300	76.300	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:271	:1:4:6	ry:0:en:0
i6	355.125	0.75	70	10	0	0	1	1	0	0	0	293.6719	293.671	293.671	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:272	:2:3:8	ry:0:en:0
i6	355.875	2.625	70	10	0	0	1	1	0	0	0	342.5769	342.576	342.576	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:273	:3:7:8	ry:0:en:0
i6	358.5	0.75	0	10	0	0	1	1	0	0	0	192.2647	192.264	192.264	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:274	:4:A:7	ry:0:en:0
i6	359.25	0.375	70	10	0	0	1	1	0	0	0	261.632	261.632	261.632	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:275	:5:0:8	ry:0:en:0
i6	359.625	0.75	70	10	0	0	1	1	0	0	0	271.9034	271.903	271.903	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:276	:6:1:8	ry:0:en:0
i6	360.375	0.375	70	10	0	0	1	1	0	0	0	121.1192	121.119	121.119	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:277	:7:G:6	ry:0:en:0
i6	360.75	0.375	70	10	0	0	1	1	0	0	0	215.8099	215.809	215.809	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:278	:8:D:7	ry:0:en:0
i6	361.125	0.75	70	10	0	0	1	1	0	0	0	28.0353	28.035	28.035	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:279	:9:E:4	ry:0:en:0
i6	361.875	0.375	0	10	0	0	1	1	0	0	0	178.0131	178.013	178.013	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:280	:10:8:7	ry:0:en:0
i6	362.25	1.125	70	10	0	0	1	1	0	0	0	24.9766	24.976	24.976	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:281	:11:B:4	ry:0:en:0
i6	363.375	0.375	70	10	0	0	1	1	0	0	0	503.4970	503.497	503.497	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:282	:12:H:8	ry:0:en:0
i6	363.75	3.75	70	10	0	0	1	1	0	0	0	329.6356	329.635	329.635	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:283	:13:6:8	ry:0:en:0
i6	367.5	3.75	70	10	0	0	1	1	0	0	0	634.3665	634.366	634.366	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:284	:14:5:9	ry:0:en:0
i6	371.25	0.75	70	10	0	0	1	1	0	0	0	185.0017	185.001	185.001	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:285	:15:9:7	ry:0:en:0
i6	372	0.375	70	10	0	0	1	1	0	0	0	830.6298	830.629	830.629	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:286	:16:C:9	ry:0:en:0
i6	372.375	0.375	70	10	0	0	1	1	0	0	0	282.5781	282.578	282.578	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:287	:17:2:8	ry:0:en:0
i6	372.75	0.375	0	10	0	0	1	1	0	0	0	192.2647	192.264	192.264	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:288	:0:A:7	ry:0:en:0
i6	373.125	0.375	70	10	0	0	1	1	0	0	0	523.264	523.264	523.264	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:289	:1:0:9	ry:0:en:0
i6	373.5	0.75	70	10	0	0	1	1	0	0	0	293.6719	293.671	293.671	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:290	:2:3:8	ry:0:en:0
i6	374.25	2.625	70	10	0	0	1	1	0	0	0	342.5769	342.576	342.576	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:291	:3:7:8	ry:0:en:0
i6	376.875	3	70	10	0	0	1	1	0	0	0	82.4089	82.408	82.408	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:292	:4:6:6	ry:0:en:0
i6	379.875	3	70	10	0	0	1	1	0	0	0	431.6198	431.619	431.619	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:293	:5:D:8	ry:0:en:0
i6	382.875	0.75	70	10	0	0	1	1	0	0	0	271.9034	271.903	271.903	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:294	:6:1:8	ry:0:en:0
i6	383.625	3.375	70	10	0	0	1	1	0	0	0	305.2013	305.201	305.201	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:295	:7:4:8	ry:0:en:0
i6	387	0.375	70	10	0	0	1	1	0	0	0	484.4769	484.476	484.476	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:296	:8:G:8	ry:0:en:0
i6	387.375	0.375	70	10	0	0	1	1	0	0	0	503.4970	503.497	503.497	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:297	:9:H:8	ry:0:en:0
i6	387.75	1.5	0	10	0	0	1	1	0	0	0	56.0706	56.070	56.070	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:298	:10:E:5	ry:0:en:0
i6	389.25	1.125	70	10	0	0	1	1	0	0	0	49.9532	49.953	49.953	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:299	:11:B:5	ry:0:en:0
i6	390.375	1.875	70	10	0	0	1	1	0	0	0	207.6574	207.657	207.657	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:300	:12:C:7	ry:0:en:0
i6	392.25	1.125	70	10	0	0	1	1	0	0	0	565.1563	565.156	565.156	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:301	:13:2:9	ry:0:en:0
i6	393.375	3.75	70	10	0	0	1	1	0	0	0	317.1832	317.183	317.183	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:302	:14:5:8	ry:0:en:0
i6	397.125	0.75	70	10	0	0	1	1	0	0	0	740.0070	740.007	740.007	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:303	:15:9:9	ry:0:en:0
i6	397.875	0.375	70	10	0	0	1	1	0	0	0	89.0065	89.006	89.006	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:304	:16:8:6	ry:0:en:0
i6	398.25	0.75	70	10	0	0	1	1	0	0	0	233.0876	233.087	233.087	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:305	:17:F:7	ry:0:en:0
i6	399	0.375	70	10	0	0	1	1	0	0	0	39.6479	39.647	39.647	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:306	:0:5:5	ry:0:en:0
i6	399.375	0.375	70	10	0	0	1	1	0	0	0	207.6574	207.657	207.657	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:307	:1:C:7	ry:0:en:0
i6	399.75	0.75	70	10	0	0	1	1	0	0	0	399.6259	399.625	399.625	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:308	:2:B:8	ry:0:en:0
i6	400.5	2.625	70	10	0	0	1	1	0	0	0	233.0876	233.087	233.087	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:309	:3:F:7	ry:0:en:0
i6	403.125	0.375	70	10	0	0	1	1	0	0	0	65.408	65.408	65.408	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:310	:4:0:6	ry:0:en:0
i6	403.5	0.375	70	10	0	0	1	1	0	0	0	178.0131	178.013	178.013	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:311	:5:8:7	ry:0:en:0
i6	403.875	0.75	70	10	0	0	1	1	0	0	0	185.0017	185.001	185.001	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:312	:6:9:7	ry:0:en:0
i6	404.625	4.5	0	10	0	0	1	1	0	0	0	164.8178	164.817	164.817	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:313	:7:6:7	ry:0:en:0
i6	409.125	0.375	70	10	0	0	1	1	0	0	0	587.3439	587.343	587.343	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:314	:8:3:9	ry:0:en:0
i6	409.5	0.375	70	10	0	0	1	1	0	0	0	152.6006	152.600	152.600	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:315	:9:4:7	ry:0:en:0
i6	409.875	0.375	70	10	0	0	1	1	0	0	0	121.1192	121.119	121.119	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:316	:10:G:6	ry:0:en:0
i6	410.25	0.375	70	10	0	0	1	1	0	0	0	135.9517	135.951	135.951	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:317	:11:1:7	ry:0:en:0
i6	410.625	3.375	0	10	0	0	1	1	0	0	0	342.5769	342.576	342.576	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:318	:12:7:8	ry:0:en:0
i6	414	3.75	70	10	0	0	1	1	0	0	0	448.5649	448.564	448.564	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:319	:13:E:8	ry:0:en:0
i6	417.75	3.75	70	10	0	0	1	1	0	0	0	863.2397	863.239	863.239	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:320	:14:D:9	ry:0:en:0
i6	421.5	0.75	70	10	0	0	1	1	0	0	0	503.4970	503.497	503.497	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:321	:15:H:8	ry:0:en:0
i6	422.25	0.375	70	10	0	0	1	1	0	0	0	70.6445	70.644	70.644	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:322	:16:2:6	ry:0:en:0
i6	422.625	0.375	70	10	0	0	1	1	0	0	0	192.2647	192.264	192.264	0.5	0.5	.	.	.	.	.	.	.	.	.	.	.	;Sec:0:Seq_7:323	:17:A:7	ry:0:en:0

; FX for Section 0.

i576	0	448.125	1	;

; End of Section 0.

e; END

</CsScore>

</CsoundSynthesizer>

; Notes:

Some notes.


EOF
