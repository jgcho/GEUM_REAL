!234567
!######################################################################
! Define Variables START
!234567################################################################
      integer Lmax,Rmax,Rsi,Rsj,nw,nwt
      parameter(Lmax=36,Rmax=87,Rsi=165,Rsj=77,nw=6,nwt=2)
      ! RDAPS 격자의 시작은 165,77
      ! nw: 기상자료의 수 (기온, 습도, 바람u, 바람v, 기압, 일사)
      ! nwt: wth의 지점 수 (140 군산, 236 부여)

      character*8 cymd
      character*3,allocatable,dimension(:)::code ! point code
      character*22 cdir
      character*44 cin
      character*34 cou

      real,allocatable,dimension(:,:,:)::Lprec ! LDAPS precipitation
      real,allocatable,dimension(:,:,:)::Rprec ! RDAPS precipitation
      real,allocatable,dimension(:)::WLprec ! write LDAPS precipitation
      real,allocatable,dimension(:)::WRprec ! write RDAPS precipitation
      
      real,allocatable,dimension(:,:,:,:)::Lwth ! LDAPS weather
      real,allocatable,dimension(:,:,:,:)::Rwth ! RDAPS weather
      real,allocatable,dimension(:,:)::WLwth ! write LDAPS weather
      real,allocatable,dimension(:,:)::WRwth ! write RDAPS weather
      
      integer lm,iml,jml,imr,jmr
      integer iy
      integer mn,idy,ih
      integer,allocatable,dimension(:)::Li
      integer,allocatable,dimension(:)::Lj
      integer,allocatable,dimension(:)::Ri
      integer,allocatable,dimension(:)::Rj
      
      integer mday(12)
      data mday/31,28,31,30,31,30,31,31,30,31,30,31/
!234567################################################################
! Define Variables END
!######################################################################
      
      call CHKDATE
      cdir='../02.ws_hor/'//cymd//'/'
      write(*,*) iy,mn,idy
      if ( mod(iy,4).eq.0 .and. (mod(iy,100).ne.0 &
       .or. mod(iy,400).eq.0) ) then 
        mday(2)=29. 
      endif
      call READPNT
      
      call READPRE
      call WRITEPRE
      
      call READWTH
      call WRITEWTH
      
      contains

subroutine CHKDATE
      open(11,file='../ymd.dat')
      read(11,*) cymd
      read(cymd(1:4),'(i4)') iy
      read(cymd(5:6),'(i2)') mn
      read(cymd(7:8),'(i2)') idy      
      close(11)
endsubroutine !subroutine CHKDATE

subroutine READPNT
      open(12,file='./ws_point.dat')
      read(12,*) 
      lm=0
  121 read(12,*,end=129) idum
        lm=lm+1
      goto 121
  129 continue
      allocate(code(lm))
      allocate(Li(lm))
      allocate(Lj(lm))
      allocate(Ri(lm))
      allocate(Rj(lm))
      allocate(WLprec(lm))
      allocate(WRprec(lm))
      
      allocate(WLwth(nw-1,lm)) ! nw-1=5, lm=15 2018.05.04
      allocate(WRwth(nw-1,lm)) ! 5개변수 항목, 15개 지점 2018.05.04

      
      rewind(12)
      read(12,*) 
      do l=1,lm
        read(12,*) code(l),Li(l),Lj(l),Ri(l),Rj(l)
      enddo
      close(12)
endsubroutine !subroutine READPNT

subroutine READPRE

      ! LDAPS start
      write(cin,'(4a)') cdir,'L_NCPCP_',cymd,'00.dat'
      open(21,file=cin)
      read(21,*) iml,jml
      allocate(Lprec(iml,jml,0:Lmax))
      close(21)
      do l=0,Lmax
        write(cin,'(3a,i2.2,a)') cdir,'L_NCPCP_',cymd,l,'.dat'
        write(*,*) cin
        open(21,file=cin)
        read(21,*)
        do j=1,jml
          do i=1,iml
            read(21,*) Lprec(i,j,l)
          enddo
        enddo
        close(21)
      enddo
      ! LDAPS end
      
      ! RDAPS start
      write(cin,'(4a)') cdir,'R_NCPCP_',cymd,'00.dat'
      open(22,file=cin)
      read(22,*) imr,jmr
      imr=Rsi+imr-1
      jmr=Rsj+jmr-1
      allocate(Rprec(imr,jmr,0:Rmax))
      close(22)
      do l=0,Rmax,3
        write(cin,'(3a,i2.2,a)') cdir,'R_NCPCP_',cymd,l,'.dat'
        write(*,*) cin
        open(22,file=cin)
        read(22,*)
        do j=Rsj,jmr
          do i=Rsi,imr
            read(22,*) Rprec(i,j,l)
          enddo
        enddo
        close(22)
      enddo
      ! RDAPS end
endsubroutine !subroutine READPRE

subroutine WRITEPRE
      real TMPPRE1(lm),TMPPRE2(lm)
      
      write(cou,'(3a)') cdir,cymd,'.pre'
      open(51,file=cou)
      write(51,'(a,100(a,i2.2,a,a))') 'yyyy-mm-dd hh:mm',(',',l,'_',code(l),',',l,'_',code(l),l=1,lm)
      
      ih=0
      do l=0,Lmax ! LDAPS prec.
        call WDATE

        do ll=1,lm
          WLprec(ll)=Lprec(Li(ll),Lj(ll),l)
        enddo
        write(51,5101) iy,mn,idy,ih,(WLprec(ll),0.,ll=1,lm)
        
        ih=ih+1
      enddo ! LDAPS prec.

      w1=2./3.  ! interpolation raate 1
      w2=1./3.  ! interpolation raate 2
      do l=36,Rmax-3,3 ! RDAPS prec.
        do ll=1,lm
          TMPPRE1(ll)=w1*Rprec(Ri(ll),Rj(ll),l) + w2*Rprec(Ri(ll),Rj(ll),l+3)
          TMPPRE2(ll)=w2*Rprec(Ri(ll),Rj(ll),l) + w1*Rprec(Ri(ll),Rj(ll),l+3)
        enddo
        
        call WDATE
        write(51,5101) iy,mn,idy,ih,(TMPPRE1(ll),0.,ll=1,lm)
        ih=ih+1
        
        call WDATE
        write(51,5101) iy,mn,idy,ih,(TMPPRE2(ll),0.,ll=1,lm)
        ih=ih+1
        
        call WDATE
        do ll=1,lm
          WRprec(ll)=Rprec(Ri(ll),Rj(ll),l+3)
        enddo
        write(51,5101) iy,mn,idy,ih,(WRprec(ll),0.,ll=1,lm)
        ih=ih+1
      enddo ! RDAPS prec.
      
      close(51)
 5101 format(i4.4,'-',i2.2,'-',i2.2,' ',i2.2,':00',<lm>(',',f4.1,',',f4.1))

endsubroutine !subroutine WRITEPRE

subroutine WDATE
        if (ih.eq.24) then
          ih=0
          idy=idy+1
          if (idy.gt.mday(mn)) then
            idy=1
            mn=mn+1
            if (mn.eq.13) then
              mn=1
              iy=iy+1
            endif
          endif
        endif
endsubroutine !subroutine WDATE

subroutine READWTH
      character*5 cwth(nw)
      data cwth/'TMP','RH','u','v','PRES','NDNSW'/
      
!      write(*,*) iml,jml,imr,jmr
      allocate(Lwth(iml,jml,0:Lmax,nw))
      allocate(Rwth(imr,jmr,0:Rmax,nw))

      ! LDAPS start
      do n=1,nw
        do l=0,Lmax
          write(cin,'(5a,i2.2,a)') cdir,'L_',trim(cwth(n)),'_',cymd,l,'.dat'
          if (n.eq.3) then
            write(cin,'(3a,i2.2,2a)') cdir,'l',cymd,l,trim(cwth(n)),'.dat'
          endif
          if (n.eq.4) then
            write(cin,'(3a,i2.2,2a)') cdir,'l',cymd,l,trim(cwth(n)),'.dat'
          endif
          write(*,*) cin
          open(31,file=trim(cin))
          read(31,*)
          do j=1,jml
            do i=1,iml
              read(31,*) Lwth(i,j,l,n)
            enddo
          enddo
          close(31)
        enddo
      enddo
      ! LDAPS end
      
      ! RDAPS start
      do n=1,nw
        do l=0,Rmax,3
          write(cin,'(5a,i2.2,a)') cdir,'R_',trim(cwth(n)),'_',cymd,l,'.dat'
          if (n.eq.3) then
            write(cin,'(3a,i2.2,2a)') cdir,'r',cymd,l,trim(cwth(n)),'.dat'
          endif
          if (n.eq.4) then
            write(cin,'(3a,i2.2,2a)') cdir,'r',cymd,l,trim(cwth(n)),'.dat'
          endif
          write(*,*) cin
          open(32,file=trim(cin))
          read(32,*)
          do j=Rsj,jmr
            do i=Rsi,imr
              read(32,*) Rwth(i,j,l,n)
            enddo
          enddo
          close(32)
        enddo
      enddo
      ! RDAPS end
endsubroutine !subroutine READWTH

subroutine WRITEWTH
      real TMPWTH1(nw-1,lm),TMPWTH2(nw-1,lm) ! 2018.05.04 jgcho 2->15
      character*9 cwthd(nw-1)
      data cwthd/'TEM(C)','RH(%)','WS(m/s)','PRES(kPa)','SR(MJ/m2)'/

      read(cymd(1:4),'(i4)') iy
      read(cymd(5:6),'(i2)') mn
      read(cymd(7:8),'(i2)') idy
      
      write(cou,'(3a)') cdir,cymd,'.wth'
      open(52,file=cou)
      write(52,'(a,100(4a))') 'yyyy-mm-dd hh:mm', &
      ((',',code(l),'_',trim(cwthd(n)),n=1,nw-1),l=1,lm) ! 2018.05.04 2->15 jgcho
      
      ih=0
      do l=0,Lmax ! LDAPS Start
        call WDATE

        do ll=1,lm ! 지점 2018.05.04 2->15 jgcho
          do n=1,nw-1 ! 항목
            if (n.eq.1) then ! Air tem.(oC)
              WLwth(n,ll)=Lwth(Li(ll),Lj(ll),l,n) - 273.15
            elseif (n.eq.3) then ! Wind speed (m/s)
              u=Lwth(Li(ll),Lj(ll),l,n)
              v=Lwth(Li(ll),Lj(ll),l,n+1)
              WLwth(n,ll)=sqrt(u*u + v*v)
            elseif (n.eq.4) then ! Pres (kPa)
              WLwth(n,ll)=Lwth(Li(ll),Lj(ll),l,n+1)/1000.
            elseif (n.eq.5) then ! Solar short wave radiation (MJ/m2)
              WLwth(n,ll)=Lwth(Li(ll),Lj(ll),l,n+1)*3600./1000000.
            else
              WLwth(n,ll)=Lwth(Li(ll),Lj(ll),l,n)
            endif
            
          enddo
        enddo
        write(52,5201) iy,mn,idy,ih,((WLwth(n,ll),n=1,nw-1),ll=1,lm) !2018.05.04 2->15 jgcho

        ih=ih+1
      enddo ! LDAPS end
      
      w1=2./3.  ! interpolation raate 1
      w2=1./3.  ! interpolation raate 2
      do l=36,Rmax-3,3 ! RDAPS Start
        write(*,*) l  
        do ll=1,lm !nwt
          do n=1,nw-1
            if (n.eq.1) then ! Air tem.(oC)
              TMPWTH1(n,ll)=w1*Rwth(Ri(ll),Rj(ll),l,n) + w2*Rwth(Ri(ll),Rj(ll),l+3,n)
              TMPWTH1(n,ll)=TMPWTH1(n,ll) - 273.15
              TMPWTH2(n,ll)=w2*Rwth(Ri(ll),Rj(ll),l,n) + w1*Rwth(Ri(ll),Rj(ll),l+3,n)
              TMPWTH2(n,ll)=TMPWTH2(n,ll) - 273.15
              WRwth(n,ll)=Rwth(Ri(ll),Rj(ll),l+3,n) - 273.15
            elseif (n.eq.3) then ! Wind speed (m/s)
              u=w1*Rwth(Ri(ll),Rj(ll),l,n) + w2*Rwth(Ri(ll),Rj(ll),l+3,n)
              v=w1*Rwth(Ri(ll),Rj(ll),l,n+1) + w2*Rwth(Ri(ll),Rj(ll),l+3,n+1)
              TMPWTH1(n,ll)=sqrt(u*u + v*v)
              u=w2*Rwth(Ri(ll),Rj(ll),l,n) + w1*Rwth(Ri(ll),Rj(ll),l+3,n)
              v=w2*Rwth(Ri(ll),Rj(ll),l,n+1) + w1*Rwth(Ri(ll),Rj(ll),l+3,n+1)
              TMPWTH2(n,ll)=sqrt(u*u + v*v)
              u=Rwth(Ri(ll),Rj(ll),l+3,n)
              v=Rwth(Ri(ll),Rj(ll),l+3,n+1)
              WRwth(n,ll)=sqrt(u*u + v*v)
            elseif (n.eq.4) then ! Pres (kPa)
              TMPWTH1(n,ll)=w1*Rwth(Ri(ll),Rj(ll),l,n+1) + w2*Rwth(Ri(ll),Rj(ll),l+3,n+1)
              TMPWTH1(n,ll)=TMPWTH1(n,ll)/1000.
              TMPWTH2(n,ll)=w2*Rwth(Ri(ll),Rj(ll),l,n+1) + w1*Rwth(Ri(ll),Rj(ll),l+3,n+1)
              TMPWTH2(n,ll)=TMPWTH2(n,ll)/1000.
              WRwth(n,ll)=Rwth(Ri(ll),Rj(ll),l+3,n+1)/1000.
            elseif (n.eq.5) then ! Solar short wave radiation (MJ/m2)
              TMPWTH1(n,ll)=w1*Rwth(Ri(ll),Rj(ll),l,n+1) + w2*Rwth(Ri(ll),Rj(ll),l+3,n+1)
              TMPWTH1(n,ll)=TMPWTH1(n,ll)*3600./1000000.
              TMPWTH2(n,ll)=w2*Rwth(Ri(ll),Rj(ll),l,n+1) + w1*Rwth(Ri(ll),Rj(ll),l+3,n+1)
              TMPWTH2(n,ll)=TMPWTH2(n,ll)*3600./1000000.
              WRwth(n,ll)=Rwth(Ri(ll),Rj(ll),l+3,n+1)*3600./1000000.
            else
              TMPWTH1(n,ll)=w1*Rwth(Ri(ll),Rj(ll),l,n) + w2*Rwth(Ri(ll),Rj(ll),l+3,n)
              TMPWTH2(n,ll)=w2*Rwth(Ri(ll),Rj(ll),l,n) + w1*Rwth(Ri(ll),Rj(ll),l+3,n)
              WRwth(n,ll)=Rwth(Ri(ll),Rj(ll),l,n)
            endif
          enddo
        enddo
        
        call WDATE
        write(52,5201) iy,mn,idy,ih,((TMPWTH1(n,ll),n=1,nw-1),ll=1,lm) !2018.05.04 2->15 jgcho
        ih=ih+1
        
        call WDATE
        write(52,5201) iy,mn,idy,ih,((TMPWTH2(n,ll),n=1,nw-1),ll=1,lm) !2018.05.04 2->15 jgcho
        ih=ih+1
        
        call WDATE
        write(52,5201) iy,mn,idy,ih,((WRwth(n,ll),n=1,nw-1),ll=1,lm) !2018.05.04 2->15 jgcho
        ih=ih+1
      enddo ! RDAPS End

!      close(52)
! 5201 format(i4.4,'-',i2.2,'-',i2.2,' ',i2.2,':00',<nwt>(',',f5.1,',',f5.1,',',f6.2,',',f4.1,',',f5.2))
 5201 format(i4.4,'-',i2.2,'-',i2.2,' ',i2.2,':00',<lm>(',',f5.1,',',f5.1,',',f4.1,',',f6.2,',',f5.2))

endsubroutine !subroutine WRITEWTH

subroutine SAMPLE
      write(*,*) 'Sample'
endsubroutine !subroutine SAMPLE

      end