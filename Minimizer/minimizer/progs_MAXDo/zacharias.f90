module zacharias
 
  use particles
  use format_declaration
  use run_parameter

  implicit none

  contains

subroutine make_model
!====================
 
  integer :: i,j,ia
  integer :: part
  integer :: prot,nunit
  integer :: Nca
  integer :: position
  integer :: nterm, oterm
  integer :: count

  real(8) ::  x,y,z
  real(8) ::  x1,y1,z1
  real(8) ::  x2,y2,z2
 
  character*80 line
  character*3 amino
  character*1 chain

  N_particle=0
  part=0

  amino='GLY'
  molecule(:)%x=0.d0  
  molecule(:)%y=0.d0  
  molecule(:)%z=0.d0  
  molecule(:)%radius=0.d0  
  molecule(:)%charge=0.d0

  do prot=1,N_protein

    i=0
    ia=0

    nunit=30+prot

    open(unit=nunit,file=protein_file(prot),status='old')

    do 
      read(unit=nunit,fmt=form_line,end=999) line

      if(line(:4)=='ATOM'.and.line(14:15)=='CA') then
        part=part+1
        i=i+1
        ia=ia+1  

        if(part>N_part_max) stop 'too many atoms'

        read(line,form_pdb) residue(part)%atom, residue(part)%aa, residue(part)%chain,&
                            residue(part)%number, molecule(part)%x, molecule(part)%y, molecule(part)%z

        molecule(part)%x=molecule(part)%x/side_x
        molecule(part)%y=molecule(part)%y/side_y
        molecule(part)%z=molecule(part)%z/side_z

        old_position(part)%x=molecule(part)%x
        old_position(part)%y=molecule(part)%y
        old_position(part)%z=molecule(part)%z
      
        molecule(part)%radius=2.00
        molecule(part)%energy=1.00

        prot_id(prot)%Pstot_item(i)=part
        prot_id(prot)%Ca_item(ia)=part
 
        residue(part)%type='CA'
        amino=residue(part)%aa(:3)
        chain=residue(part)%chain
        position=residue(part)%number
         
      end if

      if(amino/='GLY') then
        select case (amino)
          case('ALA')
            if(line(:4)=='ATOM'.and.line(14:15)=='CB') then
              part=part+1
              i=i+1               

              read(line,form_pdb) residue(part)%atom, residue(part)%aa, residue(part)%chain,&
                            residue(part)%number, molecule(part)%x, molecule(part)%y, molecule(part)%z
 
              molecule(part)%x=molecule(part)%x/side_x
              molecule(part)%y=molecule(part)%y/side_y
              molecule(part)%z=molecule(part)%z/side_z

              old_position(part)%x=molecule(part)%x
              old_position(part)%y=molecule(part)%y
              old_position(part)%z=molecule(part)%z
     
              molecule(part)%radius=1.90
              molecule(part)%energy=1.00

              prot_id(prot)%Pstot_item(i)=part

              residue(part)%type='CB'              
            end if
          case('ARG')
            if(line(:4)=='ATOM'.and.line(14:15)=='CB') then
               
              x1=0.0
              y1=0.0
              z1=0.0

              read(line,form_coord) x,y,z
         
              x1=x1+x
              y1=y1+y
              z1=z1+z  
            else if(line(:4)=='ATOM'.and.line(14:16)=='CG ') then
              read(line,form_coord) x,y,z
              part=part+1
              i=i+1

              x1=x1+x
              y1=y1+y
              z1=z1+z  

              molecule(part)%x=x1/(2.0*side_x)
              molecule(part)%y=y1/(2.0*side_y)
              molecule(part)%z=z1/(2.0*side_z)

              old_position(part)%x=molecule(part)%x
              old_position(part)%y=molecule(part)%y
              old_position(part)%z=molecule(part)%z

              molecule(part)%radius=1.95
              molecule(part)%energy=2.00

              prot_id(prot)%Pstot_item(i)=part
  
              residue(part)%type='CB'
              residue(part)%aa=amino
              residue(part)%chain=chain
              residue(part)%number=position         
            else if(line(:4)=='ATOM'.and.line(14:16)=='CD ') then 
              count=1
 
              x2=0.0
              y2=0.0
              z2=0.0

              read(line,form_coord) x,y,z
         
              x2=x2+x
              y2=y2+y
              z2=z2+z
            else if(line(:4)=='ATOM'.and.(line(14:16)=='NE '.or.line(14:16)=='CZ '&
                                      .or.line(14:16)=='NH1'.or.line(14:16)=='NH2')) then
              read(line,form_coord) x,y,z
         
              x2=x2+x
              y2=y2+y
              z2=z2+z

              count=count+1

              if(count==5) then
                part=part+1
                i=i+1  

                molecule(part)%x=x2/(5.0*side_x)
                molecule(part)%y=y2/(5.0*side_y)
                molecule(part)%z=z2/(5.0*side_z)

                old_position(part)%x=molecule(part)%x
                old_position(part)%y=molecule(part)%y
                old_position(part)%z=molecule(part)%z

                molecule(part)%radius=1.90
                molecule(part)%energy=0.60
                molecule(part)%charge=1.00

                prot_id(prot)%Pstot_item(i)=part

                residue(part)%type='CG'
                residue(part)%aa=amino
                residue(part)%chain=chain
                residue(part)%number=position    
              end if     
            end if
          case('ASN')
            if(line(:4)=='ATOM'.and.line(14:15)=='CB') then
              count=1               

              x1=0.0
              y1=0.0
              z1=0.0

              read(line,form_coord) x,y,z
         
              x1=x1+x
              y1=y1+y
              z1=z1+z  
            else if(line(:4)=='ATOM'.and.(line(14:16 )=='CG '.or.line(14:16)=='OD1'&
                                      .or.line(14:16)=='ND2')) then
              read(line,form_coord) x,y,z
         
              x1=x1+x
              y1=y1+y
              z1=z1+z 

              count=count+1
 
              if(count==4) then 
                part=part+1
                i=i+1

                molecule(part)%x=x1/(4.0*side_x)
                molecule(part)%y=y1/(4.0*side_y)
                molecule(part)%z=z1/(4.0*side_z)

                old_position(part)%x=molecule(part)%x
                old_position(part)%y=molecule(part)%y
                old_position(part)%z=molecule(part)%z
     
                molecule(part)%radius=1.90
                molecule(part)%energy=0.60

                prot_id(prot)%Pstot_item(i)=part

                residue(part)%type='CB'
                residue(part)%aa=amino
                residue(part)%chain=chain
                residue(part)%number=position 
              end if        
            end if
          case('ASP')
            if(line(:4)=='ATOM'.and.line(14:15)=='CB') then
              count=1              

              x1=0.0
              y1=0.0
              z1=0.0

              read(line,form_coord) x,y,z
         
              x1=x1+x
              y1=y1+y
              z1=z1+z
            else if(line(:4)=='ATOM'.and.(line(14:16)=='CG '.or.line(14:16)=='OD1'&
                                      .or.line(14:16)=='OD2')) then
              read(line,form_coord) x,y,z
         
              x1=x1+x
              y1=y1+y
              z1=z1+z  

              count=count+1

              if(count==4) then
                part=part+1
                i=i+1 

                molecule(part)%x=x1/(4.0*side_x)
                molecule(part)%y=y1/(4.0*side_y)
                molecule(part)%z=z1/(4.0*side_z)

                old_position(part)%x=molecule(part)%x
                old_position(part)%y=molecule(part)%y
                old_position(part)%z=molecule(part)%z
     
                molecule(part)%radius= 1.90
                molecule(part)%energy= 0.50
                molecule(part)%charge=-1.00

                prot_id(prot)%Pstot_item(i)=part

                residue(part)%type='CB'
                residue(part)%aa=amino
                residue(part)%chain=chain
                residue(part)%number=position   
              end if      
            end if
          case('CYS')
            if(line(:4)=='ATOM'.and.line(14:15)=='CB') then

              x1=0.0
              y1=0.0
              z1=0.0

              read(line,form_coord) x,y,z
         
              x1=x1+x
              y1=y1+y
              z1=z1+z
            else if(line(:4)=='ATOM'.and.line(14:15)=='SG') then
              read(line,form_coord) x,y,z
              part=part+1
              i=i+1               

              x1=x1+x
              y1=y1+y
              z1=z1+z  

              molecule(part)%x=x1/(2.0*side_x)
              molecule(part)%y=y1/(2.0*side_y)
              molecule(part)%z=z1/(2.0*side_z)

              old_position(part)%x=molecule(part)%x
              old_position(part)%y=molecule(part)%y
              old_position(part)%z=molecule(part)%z

              molecule(part)%radius=2.00
              molecule(part)%energy=2.00

              prot_id(prot)%Pstot_item(i)=part

              residue(part)%type='CB'
              residue(part)%aa=amino
              residue(part)%chain=chain
              residue(part)%number=position         
            end if    
          case('GLN')
            if(line(:4)=='ATOM'.and.line(14:15)=='CB') then

              x1=0.0
              y1=0.0
              z1=0.0

              read(line,form_coord) x,y,z
         
              x1=x1+x
              y1=y1+y
              z1=z1+z
            else if(line(:4)=='ATOM'.and.line(14:16)=='CG ') then
              read(line,form_coord) x,y,z
              part=part+1
              i=i+1               

              x1=x1+x
              y1=y1+y
              z1=z1+z  

              molecule(part)%x=x1/(2.0*side_x)
              molecule(part)%y=y1/(2.0*side_y)
              molecule(part)%z=z1/(2.0*side_z)

              old_position(part)%x=molecule(part)%x
              old_position(part)%y=molecule(part)%y
              old_position(part)%z=molecule(part)%z

              molecule(part)%radius=2.00
              molecule(part)%energy=1.50

              prot_id(prot)%Pstot_item(i)=part

              residue(part)%type='CB'
              residue(part)%aa=amino
              residue(part)%chain=chain
              residue(part)%number=position         
            else if(line(:4)=='ATOM'.and.line(14:16)=='CD ') then 
              count=1 
              x2=0.0
              y2=0.0
              z2=0.0

              read(line,form_coord) x,y,z
         
              x2=x2+x
              y2=y2+y
              z2=z2+z
            else if(line(:4)=='ATOM'.and.(line(14:16)=='OE1'.or.line(14:16)=='NE2')) then
              read(line,form_coord) x,y,z
         
              x2=x2+x
              y2=y2+y
              z2=z2+z

              count=count+1
              if(count==1) then
              part=part+1
              i=i+1
         
              molecule(part)%x=x2/(3.0*side_x)
              molecule(part)%y=y2/(3.0*side_y)
              molecule(part)%z=z2/(3.0*side_z)

              old_position(part)%x=molecule(part)%x
              old_position(part)%y=molecule(part)%y
              old_position(part)%z=molecule(part)%z

              molecule(part)%radius=1.90
              molecule(part)%energy=0.6

              prot_id(prot)%Pstot_item(i)=part

              residue(part)%type='CG'
              residue(part)%aa=amino
              residue(part)%chain=chain
              residue(part)%number=position    
              end if
            end if
          case('GLU')
            if(line(:4)=='ATOM'.and.line(14:15)=='CB') then

              x1=0.0
              y1=0.0
              z1=0.0

              read(line,form_coord) x,y,z
         
              x1=x1+x
              y1=y1+y
              z1=z1+z
            else if(line(:4)=='ATOM'.and.line(14:16)=='CG ') then
              read(line,form_coord) x,y,z
              part=part+1
              i=i+1               

              x1=x1+x
              y1=y1+y
              z1=z1+z  

              molecule(part)%x=x1/(2.0*side_x)
              molecule(part)%y=y1/(2.0*side_y)
              molecule(part)%z=z1/(2.0*side_z)

              old_position(part)%x=molecule(part)%x
              old_position(part)%y=molecule(part)%y
              old_position(part)%z=molecule(part)%z

              molecule(part)%radius=2.00
              molecule(part)%energy=1.50

              prot_id(prot)%Pstot_item(i)=part
             
              residue(part)%type='CB'
              residue(part)%aa=amino
              residue(part)%chain=chain
              residue(part)%number=position         
            else if(line(:4)=='ATOM'.and.line(14:16)=='CD ') then 

              x2=0.0
              y2=0.0
              z2=0.0

              read(line,form_coord) x,y,z
         
              x2=x2+x
              y2=y2+y
              z2=z2+z
            else if(line(:4)=='ATOM'.and.line(14:16)=='OE1') then
              read(line,form_coord) x,y,z
         
              x2=x2+x
              y2=y2+y
              z2=z2+z
            else if(line(:4)=='ATOM'.and.line(14:16)=='OE2') then
              read(line,form_coord) x,y,z
              part=part+1
              i=i+1  
         
              x2=x2+x
              y2=y2+y
              z2=z2+z

              molecule(part)%x=x2/(3.0*side_x)
              molecule(part)%y=y2/(3.0*side_y)
              molecule(part)%z=z2/(3.0*side_z)

              old_position(part)%x=molecule(part)%x
              old_position(part)%y=molecule(part)%y
              old_position(part)%z=molecule(part)%z

              molecule(part)%radius= 1.90
              molecule(part)%energy= 0.50
              molecule(part)%charge=-1.00 
 
              prot_id(prot)%Pstot_item(i)=part

              residue(part)%type='CG'
              residue(part)%aa=amino
              residue(part)%chain=chain
              residue(part)%number=position         
            end if
          case('HIS')
            if(line(:4)=='ATOM'.and.line(14:15)=='CB') then

              x1=0.0
              y1=0.0
              z1=0.0

              read(line,form_coord) x,y,z
         
              x1=x1+x
              y1=y1+y
              z1=z1+z
            else if(line(:4)=='ATOM'.and.line(14:16)=='CG ') then
              read(line,form_coord) x,y,z
              part=part+1
              i=i+1               

              x1=x1+x
              y1=y1+y
              z1=z1+z  

              molecule(part)%x=x1/(2.0*side_x)
              molecule(part)%y=y1/(2.0*side_y)
              molecule(part)%z=z1/(2.0*side_z)

              old_position(part)%x=molecule(part)%x
              old_position(part)%y=molecule(part)%y
              old_position(part)%z=molecule(part)%z

              molecule(part)%radius=2.00
              molecule(part)%energy=1.50

              prot_id(prot)%Pstot_item(i)=part

              residue(part)%type='CB'
              residue(part)%aa=amino
              residue(part)%chain=chain
              residue(part)%number=position 

              count=0

              x2=0.0
              y2=0.0
              z2=0.0
        
            else if(line(:4)=='ATOM'.and.(line(14:16)=='ND1'.or.line(14:16)=='CD2'&
                                      .or.line(14:16)=='CE1'.or.line(14:16)=='NE2')) then 
              read(line,form_coord) x,y,z
         
              x2=x2+x
              y2=y2+y
              z2=z2+z
 
              count=count+1

              if(count==4) then
                part=part+1
                i=i+1

                molecule(part)%x=x2/(4.0*side_x)
                molecule(part)%y=y2/(4.0*side_y)
                molecule(part)%z=z2/(4.0*side_z)

                old_position(part)%x=molecule(part)%x
                old_position(part)%y=molecule(part)%y
                old_position(part)%z=molecule(part)%z

                molecule(part)%radius=1.90
                molecule(part)%energy=0.5

                prot_id(prot)%Pstot_item(i)=part

                residue(part)%type='CG'
                residue(part)%aa=amino
                residue(part)%chain=chain
                residue(part)%number=position
              end if          
            end if
          case('ILE')
            if(line(:4)=='ATOM'.and.line(14:15)=='CB') then

              x1=0.0
              y1=0.0
              z1=0.0

              read(line,form_coord) x,y,z
         
              x1=x1+x
              y1=y1+y
              z1=z1+z  

              count=1

            else if(line(:4)=='ATOM'.and.(line(14:16)=='CG1'.or.line(14:16)=='CG2'&
                                      .or.line(14:16)=='CD1')) then
              read(line,form_coord) x,y,z
         
              x1=x1+x
              y1=y1+y
              z1=z1+z  

              count=count+1

              if(count==4) then
                part=part+1
                i=i+1               

                molecule(part)%x=x1/(4.0*side_x)
                molecule(part)%y=y1/(4.0*side_y)
                molecule(part)%z=z1/(4.0*side_z)

                old_position(part)%x=molecule(part)%x
                old_position(part)%y=molecule(part)%y
                old_position(part)%z=molecule(part)%z
     
                molecule(part)%radius=2.20
                molecule(part)%energy=3.00

                prot_id(prot)%Pstot_item(i)=part

                residue(part)%type='CB'
                residue(part)%aa=amino
                residue(part)%chain=chain
                residue(part)%number=position        
              end if 
            end if
          case('LEU')
            if(line(:4)=='ATOM'.and.line(14:15)=='CB') then
              count=1               

              x1=0.0
              y1=0.0
              z1=0.0

              read(line,form_coord) x,y,z
         
              x1=x1+x
              y1=y1+y
              z1=z1+z  
            else if(line(:4)=='ATOM'.and.(line(14:16)=='CG '.or.line(14:16)=='CD1'&
                                      .or.line(14:16)=='CD2')) then
              read(line,form_coord) x,y,z
         
              x1=x1+x
              y1=y1+y
              z1=z1+z

              count=count+1

              if(count==4) then
                part=part+1
                i=i+1

                molecule(part)%x=x1/(4.0*side_x)
                molecule(part)%y=y1/(4.0*side_y)
                molecule(part)%z=z1/(4.0*side_z)

                old_position(part)%x=molecule(part)%x
                old_position(part)%y=molecule(part)%y
                old_position(part)%z=molecule(part)%z
     
                molecule(part)%radius=2.20
                molecule(part)%energy=3.00

                prot_id(prot)%Pstot_item(i)=part

                residue(part)%type='CB'
                residue(part)%aa=amino
                residue(part)%chain=chain
                residue(part)%number=position
              end if         
            end if
          case('LYS')
            if(line(:4)=='ATOM'.and.line(14:15)=='CB') then

              x1=0.0
              y1=0.0
              z1=0.0

              read(line,form_coord) x,y,z
         
              x1=x1+x
              y1=y1+y
              z1=z1+z
            else if(line(:4)=='ATOM'.and.line(14:16)=='CG ') then
              read(line,form_coord) x,y,z
              part=part+1
              i=i+1               

              x1=x1+x
              y1=y1+y
              z1=z1+z  

              molecule(part)%x=x1/(2.0*side_x)
              molecule(part)%y=y1/(2.0*side_y)
              molecule(part)%z=z1/(2.0*side_z)

              old_position(part)%x=molecule(part)%x
              old_position(part)%y=molecule(part)%y
              old_position(part)%z=molecule(part)%z

              molecule(part)%radius=2.00
              molecule(part)%energy=2.00

              prot_id(prot)%Pstot_item(i)=part

              residue(part)%type='CB'
              residue(part)%aa=amino
              residue(part)%chain=chain
              residue(part)%number=position         
            else if(line(:4)=='ATOM'.and.line(14:16)=='CD ') then 

              x2=0.0
              y2=0.0
              z2=0.0

              read(line,form_coord) x,y,z
         
              x2=x2+x
              y2=y2+y
              z2=z2+z
            else if(line(:4)=='ATOM'.and.line(14:16)=='CE ') then
              read(line,form_coord) x,y,z
         
              x2=x2+x
              y2=y2+y
              z2=z2+z
            else if(line(:4)=='ATOM'.and.line(14:15)=='NZ') then
              read(line,form_coord) x,y,z
              part=part+1
              i=i+1  
         
              x2=x2+x
              y2=y2+y
              z2=z2+z

              molecule(part)%x=x2/(3.0*side_x)
              molecule(part)%y=y2/(3.0*side_y)
              molecule(part)%z=z2/(3.0*side_z)

              old_position(part)%x=molecule(part)%x
              old_position(part)%y=molecule(part)%y
              old_position(part)%z=molecule(part)%z

              molecule(part)%radius=1.90
              molecule(part)%energy=0.60
              molecule(part)%charge=1.00

              prot_id(prot)%Pstot_item(i)=part

              residue(part)%type='CG'
              residue(part)%aa=amino
              residue(part)%chain=chain
              residue(part)%number=position         
            end if
          case('MET')
            if(line(:4)=='ATOM'.and.line(14:15)=='CB') then

              x1=0.0
              y1=0.0
              z1=0.0

              read(line,form_coord) x,y,z
         
              x1=x1+x
              y1=y1+y
              z1=z1+z
            else if(line(:4)=='ATOM'.and.line(14:16)=='CG ') then
              read(line,form_coord) x,y,z
              part=part+1
              i=i+1               

              x1=x1+x
              y1=y1+y
              z1=z1+z  

              molecule(part)%x=x1/(2.0*side_x)
              molecule(part)%y=y1/(2.0*side_y)
              molecule(part)%z=z1/(2.0*side_z)

              old_position(part)%x=molecule(part)%x
              old_position(part)%y=molecule(part)%y
              old_position(part)%z=molecule(part)%z

              molecule(part)%radius=2.00
              molecule(part)%energy=2.00

              prot_id(prot)%Pstot_item(i)=part
 
              residue(part)%type='CB'
              residue(part)%aa=amino
              residue(part)%chain=chain
              residue(part)%number=position         
           else if(line(:4)=='ATOM'.and.line(14:15)=='SD') then 

              x2=0.0
              y2=0.0
              z2=0.0

              read(line,form_coord) x,y,z
         
              x2=x2+x
              y2=y2+y
              z2=z2+z
            else if(line(:4)=='ATOM'.and.line(14:16)=='CE ') then
              read(line,form_coord) x,y,z
              part=part+1
              i=i+1  
         
              x2=x2+x
              y2=y2+y
              z2=z2+z

              molecule(part)%x=x2/(2.0*side_x)
              molecule(part)%y=y2/(2.0*side_y)
              molecule(part)%z=z2/(2.0*side_z)

              old_position(part)%x=molecule(part)%x
              old_position(part)%y=molecule(part)%y
              old_position(part)%z=molecule(part)%z

              molecule(part)%radius=2.00
              molecule(part)%energy=2.90

              prot_id(prot)%Pstot_item(i)=part

              residue(part)%type='CG'
              residue(part)%aa=amino
              residue(part)%chain=chain
              residue(part)%number=position         
            end if
          case('PHE')
            if(line(:4)=='ATOM'.and.line(14:15)=='CB') then
               
              x1=0.0
              y1=0.0
              z1=0.0

              read(line,form_coord) x,y,z
         
              x1=x1+x
              y1=y1+y
              z1=z1+z 
            else if(line(:4)=='ATOM'.and.line(14:16)=='CG ') then
              read(line,form_coord) x,y,z
              part=part+1
              i=i+1

              x1=x1+x
              y1=y1+y
              z1=z1+z  

              molecule(part)%x=x1/(2.0*side_x)
              molecule(part)%y=y1/(2.0*side_y)
              molecule(part)%z=z1/(2.0*side_z)

              old_position(part)%x=molecule(part)%x
              old_position(part)%y=molecule(part)%y
              old_position(part)%z=molecule(part)%z

              molecule(part)%radius=2.20
              molecule(part)%energy=2.00

              prot_id(prot)%Pstot_item(i)=part

              residue(part)%type='CB'
              residue(part)%aa=amino
              residue(part)%chain=chain
              residue(part)%number=position         
            else if(line(:4)=='ATOM'.and.line(14:16)=='CD1') then 
              count=1 

              x2=0.0
              y2=0.0
              z2=0.0

              read(line,form_coord) x,y,z
         
              x2=x2+x
              y2=y2+y
              z2=z2+z
            else if(line(:4)=='ATOM'.and.(line(14:16)=='CD2'.or.line(14:16)=='CE1'&
                                      .or.line(14:16)=='CE2'.or.line(14:16)=='CZ ')) then
              read(line,form_coord) x,y,z
         
              x2=x2+x
              y2=y2+y
              z2=z2+z

              count=count+1

              if(count==5) then
                part=part+1
                i=i+1 

                molecule(part)%x=x2/(5.0*side_x)
                molecule(part)%y=y2/(5.0*side_y)
                molecule(part)%z=z2/(5.0*side_z)

                old_position(part)%x=molecule(part)%x
                old_position(part)%y=molecule(part)%y
                old_position(part)%z=molecule(part)%z

                molecule(part)%radius=2.20
                molecule(part)%energy=3.00

                prot_id(prot)%Pstot_item(i)=part

                residue(part)%type='CG'
                residue(part)%aa=amino
                residue(part)%chain=chain
                residue(part)%number=position
              end if         
            end if
          case('PRO')
            if(line(:4)=='ATOM'.and.line(14:15)=='CB') then

              x1=0.0
              y1=0.0
              z1=0.0

              read(line,form_coord) x,y,z
         
              x1=x1+x
              y1=y1+y
              z1=z1+z  
            else if(line(:4)=='ATOM'.and.line(14:16)=='CG ') then
              read(line,form_coord) x,y,z
         
              x1=x1+x
              y1=y1+y
              z1=z1+z  
            else if(line(:4)=='ATOM'.and.line(14:16)=='CD ') then
              read(line,form_coord) x,y,z
              part=part+1
              i=i+1               

              x1=x1+x
              y1=y1+y
              z1=z1+z  

              molecule(part)%x=x1/(3.0*side_x)
              molecule(part)%y=y1/(3.0*side_y)
              molecule(part)%z=z1/(3.0*side_z)

              old_position(part)%x=molecule(part)%x
              old_position(part)%y=molecule(part)%y
              old_position(part)%z=molecule(part)%z
     
              molecule(part)%radius=1.90
              molecule(part)%energy=1.00

              prot_id(prot)%Pstot_item(i)=part

              residue(part)%type='CB'
              residue(part)%aa=amino
              residue(part)%chain=chain
              residue(part)%number=position         
            end if
          case('SER')
            if(line(:4)=='ATOM'.and.line(14:15)=='CB') then

              x1=0.0
              y1=0.0
              z1=0.0

              read(line,form_coord) x,y,z
         
              x1=x1+x
              y1=y1+y
              z1=z1+z
            else if(line(:4)=='ATOM'.and.line(14:15)=='OG') then
              read(line,form_coord) x,y,z
              part=part+1
              i=i+1               

              x1=x1+x
              y1=y1+y
              z1=z1+z  

              molecule(part)%x=x1/(2.0*side_x)
              molecule(part)%y=y1/(2.0*side_y)
              molecule(part)%z=z1/(2.0*side_z)

              old_position(part)%x=molecule(part)%x
              old_position(part)%y=molecule(part)%y
              old_position(part)%z=molecule(part)%z

              molecule(part)%radius=1.90
              molecule(part)%energy=0.60

              prot_id(prot)%Pstot_item(i)=part

              residue(part)%type='CB'
              residue(part)%aa=amino
              residue(part)%chain=chain
              residue(part)%number=position         
            end if    
          case('THR')
            if(line(:4)=='ATOM'.and.line(14:15)=='CB') then
              count=1 
 
              x1=0.0
              y1=0.0
              z1=0.0

              read(line,form_coord) x,y,z
         
              x1=x1+x
              y1=y1+y
              z1=z1+z
            else if(line(:4)=='ATOM'.and.(line(14:16)=='OG1'.or.line(14:16)=='CG2')) then
              read(line,form_coord) x,y,z
         
              x1=x1+x
              y1=y1+y
              z1=z1+z 

              count=count+1

              if(count==3) then
 
              part=part+1
              i=i+1               


              molecule(part)%x=x1/(3.0*side_x)
              molecule(part)%y=y1/(3.0*side_y)
              molecule(part)%z=z1/(3.0*side_z)

              old_position(part)%x=molecule(part)%x
              old_position(part)%y=molecule(part)%y
              old_position(part)%z=molecule(part)%z
     
              molecule(part)%radius=1.90
              molecule(part)%energy=0.60

              prot_id(prot)%Pstot_item(i)=part

              residue(part)%type='CB'
              residue(part)%aa=amino
              residue(part)%chain=chain
              residue(part)%number=position         
              end if
            end if
          case('TRP')
            if(line(:4)=='ATOM'.and.line(14:15)=='CB') then
               
              x1=0.0
              y1=0.0
              z1=0.0

              read(line,form_coord) x,y,z
         
              x1=x1+x
              y1=y1+y
              z1=z1+z 
            else if(line(:4)=='ATOM'.and.line(14:16)=='CG ') then
              read(line,form_coord) x,y,z
              part=part+1
              i=i+1

              x1=x1+x
              y1=y1+y
              z1=z1+z  

              molecule(part)%x=x1/(2.0*side_x)
              molecule(part)%y=y1/(2.0*side_y)
              molecule(part)%z=z1/(2.0*side_z)

              old_position(part)%x=molecule(part)%x
              old_position(part)%y=molecule(part)%y
              old_position(part)%z=molecule(part)%z

              molecule(part)%radius=2.20
              molecule(part)%energy=1.50

              prot_id(prot)%Pstot_item(i)=part

              residue(part)%type='CB'
              residue(part)%aa=amino
              residue(part)%chain=chain
              residue(part)%number=position         
            else if(line(:4)=='ATOM'.and.line(14:16)=='CD1') then 
              count=1

              x2=0.0
              y2=0.0
              z2=0.0

              read(line,form_coord) x,y,z
         
              x2=x2+x
              y2=y2+y
              z2=z2+z
            else if(line(:4)=='ATOM'.and.(line(14:16)=='CD2'.or.line(14:16)=='NE1'.or.line(14:16)=='CE2'&
                                      .or.line(14:16)=='CE3'.or.line(14:16)=='CZ2'&
                                      .or.line(14:16)=='CZ3'.or.line(14:16)=='CH2')) then
              read(line,form_coord) x,y,z
         
              x2=x2+x
              y2=y2+y
              z2=z2+z

              count=count+1

              if(count==8) then 
                part=part+1
                i=i+1  

                molecule(part)%x=x2/(8.0*side_x)
                molecule(part)%y=y2/(8.0*side_y)
                molecule(part)%z=z2/(8.0*side_z)

                old_position(part)%x=molecule(part)%x
                old_position(part)%y=molecule(part)%y
                old_position(part)%z=molecule(part)%z

                molecule(part)%radius=2.20
                molecule(part)%energy=2.60

                prot_id(prot)%Pstot_item(i)=part

                residue(part)%type='CG'
                residue(part)%aa=amino
                residue(part)%chain=chain
                residue(part)%number=position
              end if         
            end if
          case('TYR')
            if(line(:4)=='ATOM'.and.line(14:15)=='CB') then
               
              x1=0.0
              y1=0.0
              z1=0.0

              read(line,form_coord) x,y,z
         
              x1=x1+x
              y1=y1+y
              z1=z1+z  
            else if(line(:4)=='ATOM'.and.line(14:16)=='CG ') then
              read(line,form_coord) x,y,z
              part=part+1
              i=i+1

              x1=x1+x
              y1=y1+y
              z1=z1+z  

              molecule(part)%x=x1/(2.0*side_x)
              molecule(part)%y=y1/(2.0*side_y)
              molecule(part)%z=z1/(2.0*side_z)

              old_position(part)%x=molecule(part)%x
              old_position(part)%y=molecule(part)%y
              old_position(part)%z=molecule(part)%z

              molecule(part)%radius=2.20
              molecule(part)%energy=2.00

              prot_id(prot)%Pstot_item(i)=part

              residue(part)%type='CB'
              residue(part)%aa=amino
              residue(part)%chain=chain
              residue(part)%number=position         
            else if(line(:4)=='ATOM'.and.line(14:16)=='CD1') then 
              count=1  

              x2=0.0
              y2=0.0
              z2=0.0

              read(line,form_coord) x,y,z
         
              x2=x2+x
              y2=y2+y
              z2=z2+z
            else if(line(:4)=='ATOM'.and.(line(14:16)=='CD2'.or.line(14:16)=='CE1'&
                                      .or.line(14:16)=='CE2'.or.line(14:16)=='CZ '&
                                      .or.line(14:16)=='OH ')) then
              read(line,form_coord) x,y,z
         
              x2=x2+x
              y2=y2+y
              z2=z2+z

              count=count+1

              if(count==6) then
                part=part+1
                i=i+1

                molecule(part)%x=x2/(6.0*side_x)
                molecule(part)%y=y2/(6.0*side_y)
                molecule(part)%z=z2/(6.0*side_z)

                old_position(part)%x=molecule(part)%x
                old_position(part)%y=molecule(part)%y
                old_position(part)%z=molecule(part)%z

                molecule(part)%radius=2.20
                molecule(part)%energy=2.60

                prot_id(prot)%Pstot_item(i)=part

                residue(part)%type='CG'
                residue(part)%aa=amino
                residue(part)%chain=chain
                residue(part)%number=position     
              end if    
            end if
          case('VAL')
            if(line(:4)=='ATOM'.and.line(14:15)=='CB') then

              x1=0.0
              y1=0.0
              z1=0.0

              read(line,form_coord) x,y,z
         
              x1=x1+x
              y1=y1+y
              z1=z1+z  
            else if(line(:4)=='ATOM'.and.line(14:16)=='CG1') then
              read(line,form_coord) x,y,z
         
              x1=x1+x
              y1=y1+y
              z1=z1+z
            else if(line(:4)=='ATOM'.and.line(14:16)=='CG2') then
              read(line,form_coord) x,y,z
              part=part+1
              i=i+1               

              x1=x1+x
              y1=y1+y
              z1=z1+z  

              molecule(part)%x=x1/(3.0*side_x)
              molecule(part)%y=y1/(3.0*side_y)
              molecule(part)%z=z1/(3.0*side_z)

              old_position(part)%x=molecule(part)%x
              old_position(part)%y=molecule(part)%y
              old_position(part)%z=molecule(part)%z
     
              molecule(part)%radius=2.00
              molecule(part)%energy=2.50

              prot_id(prot)%Pstot_item(i)=part

              residue(part)%type='CB'
              residue(part)%aa=amino
              residue(part)%chain=chain
              residue(part)%number=position         
            end if 
        end select
      end if
    
    end do 

    999 continue

    prot_id(prot)%Pstot_number=i
    prot_id(prot)%Ca_number=ia

    prot_id(prot)%chain=residue(part)%chain

    write(6,form_zach) 'Protein number', prot, 'chain', prot_id(prot)%chain, 'particles', prot_id(prot)%Pstot_number

    do j=1,prot_id(prot)%Pstot_number
      residue(prot_id(prot)%Pstot_item(j))%prot=prot
    end do
   
!    nterm=prot_id(prot)%Pstot_item(1)
!    oterm=prot_id(prot)%Pstot_item(i)
!    molecule(nterm)%charge=1.00
!    molecule(oterm)%charge=-1.00
  
     close(nunit)
  end do

  N_particle=part

  write(6,form_tens) 'Total number of particles  :', real(N_particle)

  return

end subroutine make_model

end module zacharias
