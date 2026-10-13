#!/usr/bin/env python3
"""Minimal Android boot image v0 packer with DTBH dt.img support (Samsung Exynos3475 layout).
usage: mkbootimg.py --kernel zImage --out boot.img   (ramdisk/dt/params come from tools-ci/stock)"""
import argparse, hashlib, json, os, struct
ap=argparse.ArgumentParser(); ap.add_argument('--kernel',required=True); ap.add_argument('--out',required=True)
ap.add_argument('--stock-trailer',action='store_true',help='append the original 288B Samsung trailer (tag + signature block) instead of the bare tag')
ap.add_argument('--stock',default=os.path.join(os.path.dirname(__file__),'stock')); a=ap.parse_args()
P=json.load(open(os.path.join(a.stock,'params.json')))
k=open(a.kernel,'rb').read(); r=open(os.path.join(a.stock,'ramdisk.cpio.gz'),'rb').read(); dt=open(os.path.join(a.stock,'dt.img'),'rb').read(); s=b''
page=P['page_size']; pad=lambda b:b+b'\0'*((-len(b))%page)
h=hashlib.sha1()
for blob in (k,r,s,dt): h.update(blob); h.update(struct.pack('<I',len(blob)))
ident=h.digest().ljust(32,b'\0')
hdr=struct.pack('<8s10I16s512s32s1024s',b'ANDROID!',len(k),P['kernel_addr'],len(r),P['ramdisk_addr'],len(s),P['second_addr'],
    P['tags_addr'],page,len(dt),P['os_version'],P['name'].encode(),P['cmdline'].encode(),ident,P['extra_cmdline'].encode())
trailer=open(os.path.join(a.stock,'trailer.bin'),'rb').read() if a.stock_trailer else b'SEANDROIDENFORCE'
img=pad(hdr)+pad(k)+pad(r)+pad(s)+pad(dt)+trailer
open(a.out,'wb').write(img)
print(f'wrote {a.out}: {len(img)} bytes (kernel {len(k)}, stock total {P["stock_total"]})')
