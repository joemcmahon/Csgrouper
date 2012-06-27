; Default Title; Author Name, 2012-06-26_19:06:35.


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

garvbsig init 0 ;


; Instruments:

; i1 (path: internal)
; note: A basic instrument.


instr 1 ;
 idur = p3 ;
 ifq1 = p5 ;
 irvs = p7 ;
 a1  oscil ampdb(p4), ifq1, p6 ;
 garvbsig = garvbsig+(a1*irvs) ;
 outs a1,a1 ;
endin ;


; i576 (path: internal)
; note: An instrument that is receiving input from a global variable should have a higher number than any instrument that are producing output for that variable.(R. Pinkston)


instr 576
 idur = p3 ;
 irvbtime = p4 ;
 asig reverb garvbsig,irvbtime ;
 outs asig,asig ;
 garvbsig = 0 ;
endin ;



</CsInstruments>

<CsScore>

; F-tables:

f10  0   65536 10 1 ; Sine


; Score:

s ; Section 0.

; Tempo:

t 0 60

; Seq_4 comments: Some comments.
;ins	sta	dur	amp	fq1	ft1	rvs	
i1	0	0.25	60	130.816	10	0.2	;Sec:0:Seq_4:0	:0:0:7	ry:0:en:0
i1	0.25	0.25	60	138.5947	10	0.2	;Sec:0:Seq_4:1	:1:1:7	ry:0:en:0
i1	0.5	0.5	60	146.8359	10	0.2	;Sec:0:Seq_4:2	:2:2:7	ry:0:en:0
i1	1	1.125	60	311.1346	10	0.2	;Sec:0:Seq_4:3	:3:3:8	ry:0:en:0
i1	2.125	1.5	60	329.6356	10	0.2	;Sec:0:Seq_4:4	:4:4:8	ry:0:en:0
i1	3.625	1.5	60	349.2368	10	0.2	;Sec:0:Seq_4:5	:5:5:8	ry:0:en:0
i1	5.125	1.5	60	185.0017	10	0.2	;Sec:0:Seq_4:6	:6:6:7	ry:0:en:0
i1	6.625	1.5	60	196.0025	10	0.2	;Sec:0:Seq_4:7	:7:7:7	ry:0:en:0
i1	8.125	0.25	60	207.6574	10	0.2	;Sec:0:Seq_4:8	:8:8:7	ry:0:en:0
i1	8.375	0.25	60	440.0108	10	0.2	;Sec:0:Seq_4:9	:9:9:8	ry:0:en:0
i1	8.625	0.5	60	466.1752	10	0.2	;Sec:0:Seq_4:10	:10:A:8	ry:0:en:0
i1	9.125	1.125	60	493.8954	10	0.2	;Sec:0:Seq_4:11	:11:B:8	ry:0:en:0

; FX for Section 0.

i576	0	10.25	120	;

; End of Section 0.

e; END

</CsScore>

</CsoundSynthesizer>

; Notes:

Some notes.


EOF
