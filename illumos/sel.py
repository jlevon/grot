#!/usr/bin/env python

def SEL_GDT(s, r):
 return ((s << 3) | r)

GDT_NULL    =    0       
GDT_B32DATA =    1       
GDT_B32CODE =    2       
GDT_B16CODE =    3       
GDT_B16DATA =    4       
GDT_B64CODE =    5       
GDT_BGSTMP  =    7       
GDT_CPUID   =    16      
GDT_KCODE   =    6       
GDT_KDATA   =    7       
GDT_U32CODE =    8       
GDT_UDATA   =    9       
GDT_UCODE   =    10      
GDT_LDT     =    12      
GDT_KTSS    =    14      
GDT_FS      =    GDT_NULL 
GDT_GS      =    GDT_NULL 
GDT_LWPFS   =    55      
GDT_LWPGS   =    56      
GDT_BRANDMIN=    57      
GDT_BRANDMAX=    61      
NGDT        =    62      
SEL_KPL = 0
SEL_UPL = 3



KCS_SEL          = SEL_GDT(GDT_KCODE, SEL_KPL)
KDS_SEL          = SEL_GDT(GDT_KDATA, SEL_KPL)
UCS_SEL          = SEL_GDT(GDT_UCODE, SEL_UPL)
#TEMP_CS64_SEL    = SEL_GDT(TEMPGDT_KCODE64, SEL_KPL)
U32CS_SEL        = SEL_GDT(GDT_U32CODE, SEL_UPL)
UDS_SEL          = SEL_GDT(GDT_UDATA, SEL_UPL)
ULDT_SEL         = SEL_GDT(GDT_LDT, SEL_KPL)
KTSS_SEL         = SEL_GDT(GDT_KTSS, SEL_KPL)
#DFTSS_SEL        = SEL_GDT(GDT_DBFLT, SEL_KPL)
KFS_SEL      =   0
KGS_SEL          = SEL_GDT(GDT_GS, SEL_KPL)
LWPFS_SEL        = SEL_GDT(GDT_LWPFS, SEL_UPL)
LWPGS_SEL        = SEL_GDT(GDT_LWPGS, SEL_UPL)
BRANDMIN_SEL     = SEL_GDT(GDT_BRANDMIN, SEL_UPL)
BRANDMAX_SEL     = SEL_GDT(GDT_BRANDMAX, SEL_UPL)
B64CODE_SEL      = SEL_GDT(GDT_B64CODE, SEL_KPL)
B32CODE_SEL      = SEL_GDT(GDT_B32CODE, SEL_KPL)
B32DATA_SEL      = SEL_GDT(GDT_B32DATA, SEL_KPL)
B16CODE_SEL      = SEL_GDT(GDT_B16CODE, SEL_KPL)
B16DATA_SEL      = SEL_GDT(GDT_B16DATA, SEL_KPL)

print "UCS_SEL is 0x%x" % UCS_SEL
print "U32CS_SEL is 0x%x" % U32CS_SEL
print "KCS_SEL is 0x%x" % KCS_SEL
print "UDS_SEL is 0x%x" % UDS_SEL
print "KDS_SEL is 0x%x" % KDS_SEL
print "UDS_SEL is 0x%x" % UDS_SEL
print "KFS_SEL is 0x%x" % KFS_SEL
print "KGS_SEL is 0x%x" % KGS_SEL
print "LWPFS_SEL is 0x%x" % LWPFS_SEL
print "LWPGS_SEL is 0x%x" % LWPGS_SEL
print "BRANDMIN_SEL is 0x%x" % BRANDMIN_SEL
