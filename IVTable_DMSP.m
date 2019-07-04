clc;clear;
%{
    �̾� "TeNedata.mat" �̪��ū׿@��  
    �̾ڦU�ſ@ �إ�PSPIC�һݭn�� model 
    ��J: DMSP �ū׿@�� �Ȧs��
    ��X:
        ��m: 
            C:\Users\q8529\Documents\NCU_LAB\07_EDPETP_handover\ProDes\Matlab\DMSPtable\pro
            C:\Users\q8529\Documents\NCU_LAB\07_EDPETP_handover\ProDes\Matlab\DMSPtable\sta
        ��צW��:
            FiTemDec_x.txt
            
%}
%close all
load('C:\Users\q8529\Documents\NCU_LAB\07_EDPETP_handover\ProDes\Matlab\DMSP\ConRowData\TeNedata.mat','SD');
source(:,1:2)=SD(:,6:7);
tt=size(source,1);
for ttime=1:tt
%���n��
  Ar=6;
  D.para.k=1.3806488*10^-23;
  D.para.e=1.602*10^-19;
%���w���n
  D.para.A=58.2e-4;
%�q�l���q
  D.para.m_e=9.109*10^-31;
%���l���q
  D.para.m_i=14*1.66e-27;
%�q�l�@��   1e9~1e12 m3
  D.para.Ne =source(ttime,2)*1e6;
%���l�@��   1e9~1e12 m3
  D.para.Ni =D.para.Ne;
%���l�ū� 
  D.para.Te =source(ttime,1);

  V=-10:0.01:9.99;
%���w curve
  D.para.beta=0;
for i=1:size(V,2)% �z�׹q�y
  [~,~,I_Pro(i)]=DebyeCurrentSim(V(i),0,D.para.Ne,D.para.Ni,D.para.Te,D.para.A,D.para.beta);
  [~,~,I_Sat(i)]=DebyeCurrentSim(V(i),0,D.para.Ne,D.para.Ni,D.para.Te,D.para.A*Ar,D.para.beta);
end
% % ���� Ar�� ��W
%   D.para.beta=0.5;
% for i=1:size(V,2)% �z�׹q�y
%   [~,~,I2(i)]=DebyeCurrentSim(V(i),0,D.para.Ne,D.para.Ni,D.para.Te,D.para.A*Ar,D.para.beta);
% end
% % ���� Ar�� �y
%   D.para.beta=1;
% for i=1:size(V,2)% �z�׹q�y
%   [~,~,I3(i)]=DebyeCurrentSim(V(i),0,D.para.Ne,D.para.Ni,D.para.Te,D.para.A*Ar,D.para.beta);
% end
% I1=I1*-1;I2=I2*-1;I3=I3*-1;
I_Pro=I_Pro*-1;
I_Sat=I_Sat*-1;

L=length(V);
path='C:\Users\q8529\Documents\NCU_LAB\07_EDPETP_handover\ProDes\Matlab\DMSPtable\';
ttamp=int2str(ttime);
FNam=['C:\Users\q8529\Documents\NCU_LAB\07_EDPETP_handover\ProDes\Matlab\DMSP\DMSPtable\Pro\' 'FiTemDec_' ttamp '.txt'];
fid=fopen(FNam,'w+');

fprintf(fid,'* OrCAD Model Editor - Version 9.1 \r\n');
fprintf(fid,'*$\r\n.SUBCKT G_test outp outn \r\nG_G1 outp outn TABLE { V(outp, outn) }= \r\n');


for i=1:1:ceil(L/4)
  n=(i-1)*4;
  %fprintf(fid,'+(%0.2f,%0.4fm)(%0.2f,%0.4fm)(%0.2f,%0.4fm)(%0.2f,%0.4fm)\r\n',V(n+1),I3(n+1)*1E6,V(n+2),I3(n+2)*1E6,V(n+3),I3(n+3)*1E6,V(n+4),I3(n+4)*1E6);
  fprintf(fid,'+(%0.2f,%0.4fn)(%0.2f,%0.4fn)(%0.2f,%0.4fn)(%0.2f,%0.4fn)\r\n',V(n+1),I_Pro(n+1)*1E9,V(n+2),I_Pro(n+2)*1E9,V(n+3),I_Pro(n+3)*1E9,V(n+4),I_Pro(n+4)*1E9);
end

fprintf(fid,'\r\n.ENDS G_test \r\n\r\n*$\r\n');
fclose(fid);

FNam=['C:\Users\q8529\Documents\NCU_LAB\07_EDPETP_handover\ProDes\Matlab\DMSP\DMSPtable\Sat\' 'FiTemDec_' ttamp '.txt'];
fid=fopen(FNam,'w+');

fprintf(fid,'* OrCAD Model Editor - Version 9.1\r\n');
fprintf(fid,'*$\r\n.SUBCKT G_test2 outp outn \r\nG_G2 outp outn TABLE { V(outp, outn) }=\r\n');

for i=1:1:ceil(L/4)
  n=(i-1)*4;
  %fprintf(fid,'+(%0.2f,%0.4fm)(%0.2f,%0.4fm)(%0.2f,%0.4fm)(%0.2f,%0.4fm)\r\n',V(n+1),I3(n+1)*1E6,V(n+2),I3(n+2)*1E6,V(n+3),I3(n+3)*1E6,V(n+4),I3(n+4)*1E6);
  fprintf(fid,'+(%0.2f,%0.4fn)(%0.2f,%0.4fn)(%0.2f,%0.4fn)(%0.2f,%0.4fn)\r\n',V(n+1),I_Sat(n+1)*1E9,V(n+2),I_Sat(n+2)*1E9,V(n+3),I_Sat(n+3)*1E9,V(n+4),I_Sat(n+4)*1E9);
end
fprintf(fid,'\r\n.ENDS G_test2 \r\n\r\n*$\r\n');
fclose(fid);
a=1

end
%{
plot(V,I1)
hold on; grid;
plot(V,I2,'r')
plot(V,I3,'k')
%axis([-0.9 0.5 -inf 0.13])
legend('Plane','Cylinder','Sphere')
xlabel('Probe voltage relative to the plasma potential(Vpr-Vpl)')
ylabel('Current(A)')
%}