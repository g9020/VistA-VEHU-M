SDCCRSEN2 ;CCRA/LB,PB - Appointment retrieval API;
 ;;5.3;Scheduling;**912**;;Build 61
 ;SAC EXEMPTION 202505291453-05 : CCRA use of vendor specific code
 ;Patch 912 change to add a new comment to the consult
 Q
 ;Check the status of the consult. if it is scheduled or canceled return 1, otherwise return 0
CHKAPPT(CONSID,TYPE) ;
 ;D APPERROR^%ZTER("SDCCRSEN2 8")
 I CONSID="" Q 0
 S ST=0
 I TYPE="SCHEDULE" D
 .S TSTATUS=$O(^ORD(100.01,"B","SCHEDULED",0))
 .S:$P(^GMR(123,CONSID,0),"^",12)=TSTATUS ST=1
 ;When checking cancel, check status, if status = scheduled, then check to see if there is an appointment
 ;for the appointment date/time (SDECSTART). if status = scheduled and there is an appointment for the 
 ;patient on the SDECSTART time, then it is considered the original and return 1. otherwise return 0
 I TYPE="CANCEL" D
 .S TSTATUS=$O(^ORD(100.01,"B","CANCELLED",0))
 .S:$P(^GMR(123,CONSID,0),"^",12)=TSTATUS ST=1
 .I ST=0 d
 ..S:'$D(^DPT(DFN,"S",STARTFM1)) ST=1
 Q ST
ADDCOMMENT(SDECSTART,PROV,PROV1,PROVADD) ;
 D WEBSERV
 S COMMENT(1)="Patient has an appointment on "_SDECSTART_" with "_$G(PROV)_"."
 S COMMENT(2)="Address: "_$G(OFFICE)
 S COMMENT(3)="         "_$G(STREET1)
 S COMMENT(4)="         "_$G(CITY)_", "_$G(STATE)_"  "_$G(ZIP)
 S COMMENT(5)="         "_"Office Phone: "_$G(PHONE)
 D NOW^%DTC
 D CMT^GMRCGUIB(CONID,.COMMENT,DUZ,%,DUZ)
 K ZIP,TSTATUS,STREET2,STATE,ST,PHONE,OFFICE,COMMENT,CITY,%
 Q
ADDCANCOMMENT(SDECSTART,PROV,PROV1,PROVADD) ;
 D WEBSERV
 D NOW^%DTC
 S CANCELEDBY=$P(USERMAIL,"@")
 S COMMENT(1)="Patient's appointment on "_SDECSTART_" with "_$G(PROV)
 S COMMENT(2)="at: "_$G(OFFICE)
 S COMMENT(3)="    "_$G(STREET1)
 S COMMENT(4)="    "_$G(CITY)_", "_$G(STATE)_"  "_$G(ZIP)
 S COMMENT(5)="    "_"Office Phone: "_$G(PHONE)
 S COMMENT(6)="was canceled by "_$P($G(CANCELEDBY),".",1)_" "_$P($G(CANCELEDBY),".",2)_" on "_SDECSTART_"."
 D NOW^%DTC
 D CMT^GMRCGUIB(CONID,.COMMENT,DUZ,%,DUZ)
 K ZIP,TSTATUS,STREET2,STATE,ST,PHONE,OFFICE,COMMENT,CITY,CANCELEDBY,%
 Q
NOSHOWCOMMENT(SDECSTART,PROV,PROV1,PROVADD) ;
 D WEBSERV
 S CANCELEDBY=$P(USERMAIL,"@")
 S COMMENT(1)="Patient failed to make an appointment on "_SDECSTART_" with "_$G(PROV)
 S COMMENT(2)="at: "_$G(OFFICE)
 S COMMENT(3)=$G(STREET1)
 S COMMENT(4)=$G(CITY)_", "_$G(STATE)_"  "_$G(ZIP)
 S COMMENT(5)="Office Phone: "_$G(PHONE)
 D NOW^%DTC
 D CMT^GMRCGUIB(CONID,.COMMENT,DUZ,%,DUZ)
 K ZIP,TSTATUS,STREET2,STATE,ST,PHONE,OFFICE,COMMENT,CITY,%
 Q
WEBSERV ;
 N MYREST,MYERR,resource,SC,NEWRESPONSE,JSON,RESPJSON,OUTJSON,XX,PROVPHONE
 S MYREST=$$GETREST^XOBWLIB("CCRA NPI SERVICE","CCRA NPI SERVER"),MYERR=""
 S resource="/"_NPI,PHONE=""
 S SC=$$GET^XOBWLIB(MYREST,resource,.MYERR,0)
 I 'SC I MYERR.code=404 D 
 .S PHONE=""
 I 'SC Q 1
 S NEWRESPONSE=MYREST.HttpResponse
 S JSON=NEWRESPONSE.Data
 S RESPJSON=""
 F  Q:JSON.AtEnd  S RESPJSON=RESPJSON_JSON.ReadLine()
 S OUTJSON=""
 D DECODE^XLFJSON("RESPJSON","OUTJSON","MYERR")
 d NOW^%DTC
 I $G(MYERR)="" D PARSEJSON
 Q
PARSEJSON ;
 S XX=0 F  S XX=$O(OUTJSON("PPMSLocations",XX)) Q:XX'>0  D
 .Q:$G(OUTJSON("PPMSLocations",XX,"Location","SiteName"))'=SITE
 .Q:$G(OUTJSON("PPMSLocations",XX,"Location","Street1"))'=STREET
 .S PHONE=$G(OUTJSON("PPMSLocations",XX,"Location","Phone"))
 .S STREET1=$G(OUTJSON("PPMSLocations",XX,"Location","Street1"))
 .S CITY=$G(OUTJSON("PPMSLocations",XX,"Location","City"))
 .S STATE=$G(OUTJSON("PPMSLocations",XX,"Location","State"))
 .S ZIP=$G(OUTJSON("PPMSLocations",XX,"Location","Zip"))
 .S OFFICE=$G(OUTJSON("PPMSLocations",XX,"Location","SiteName"))
 Q
