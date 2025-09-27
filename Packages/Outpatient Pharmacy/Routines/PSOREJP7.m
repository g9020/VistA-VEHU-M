PSOREJP7 ;AITC/PD - Third Party Reject Display Screen Cont;03/06/25
 ;;7.0;OUTPATIENT PHARMACY;**766**;DEC 1997;Build 25
 ;
 Q
 ;
DIA ; Protocol Action to allow user the ability to include a
 ;    Diagnosis Code on the claim
 ;
 N DIAG,PSOET
 ;
 I $$CLOSED^PSOREJP1(RX,REJ,1) Q
 ;
 S PSOET=$$PSOET^PSOREJP3(RX,FILL)
 I PSOET D  Q
 . S VALMSG="DIA not allowed for "_$$ELIGDISP^PSOREJP1(RX,FILL)_" Non-Billable claim."
 . S VALMBCK="R"
 ;
 D FULL^VALM1
 ;
 S DIAG=$$DIAG
 I DIAG="^" S VALMBCK="R" Q
 ;
 D SEND^PSOREJP3(,,,PSOET,DIAG)
 ;
 Q
 ;
DIAG() ; Ask for Diagnosis Code
 ;
 N DFLTDX,DIAG,DIR,DIRUT,DTOUT,DUOUT,PSOCLAIM,PSOIEN59,X,Y
 ;
 S PSOIEN59=$$CLAIM^BPSBUTL(RX,FILL)  ; ICR# 4719
 S PSOCLAIM=$P(PSOIEN59,U,2)
 S PSOIEN59=$P(PSOIEN59,U,1)
 ;
 ; Diagnosis Code, 424-DO
 ; Default Diagnosis Code from BPS CLAIMS file, field 424
 ; Only ICD-10-CM codes are allowed for selection
 ;
DIAG1 ;
 S DIAG=""
 S DIR(0)="PO^80:AEQMZ"
 S DFLTDX=$P($E($$GET1^DIQ(9002313.0201,1_","_PSOCLAIM_",",424),3,17)," ")
 I $G(DFLTDX)'="" S DFLTDX=$E(DFLTDX,1,3)_"."_$E(DFLTDX,4,10)
 S DIR("B")=DFLTDX
 S DIR("S")="I $P($G(^ICDS($P(^(1),""^"",1),0)),""^"",1)=""ICD-10-CM"""
 D ^DIR
 I ($D(DUOUT))!($D(DTOUT)) K DIR,X,Y Q "^"
 ; If no value entered, or @ was entered with no default value, prompt
 ; user to enter ^ to exit and return them to the Dx prompt
 I X=""!((X="@")&(DFLTDX="")) W " ??",!,"  Enter '^' to exit" G DIAG1
 S DIAG=$P(Y,U,2)
 I $D(DIRUT),X="@" D  I $D(DIRUT) K DIR,X,Y Q "^"
 . K DIR,DIRUT,X,Y
 . S DIR(0)="Y^E"
 . S DIR("A")="  Are you sure you want to delete "_DFLTDX
 . S DIR("B")="No"
 . S DIAG=DFLTDX
 . D ^DIR
 . I Y S DIAG="REMOVED"
 K DIR,X,Y
 ;
 Q DIAG
