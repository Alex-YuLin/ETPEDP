clc;clear;close all
%-------- input DMSP Te Ne-------%
load('C:\Users\q8529\Documents\NCU_LAB\07_EDPETP_handover\ProDes\Matlab\DMSP\ConRowData\20171207.mat')
TeNe(:,1:2)=SD(:,6:7);
TeNe(:,2)=TeNe(:,2)*1e6;
%--------------------------------%
%----- Double Debye 殘電修正 -------%
path='C:\Users\q8529\Documents\NCU_LAB\07_EDPETP_handover\ProDes\Matlab\DMSP\PrintData.txt';
[Ne,Te]=textread([path],'%f %f');
%---- 無殘電修正 ------%
path='C:\Users\q8529\Documents\NCU_LAB\07_EDPETP_handover\ProDes\Matlab\DMSP\PrintData_NoResidualVol.txt';
[Ne_NoResVol,Te_NoResVol]=textread([path],'%f %f');
%---- 無 殘電、單俏、最大電流 修正 ------%
path='C:\Users\q8529\Documents\NCU_LAB\07_EDPETP_handover\ProDes\Matlab\DMSP\PrintData_Oringinal.txt';
[Ne_Oringinal,Te_Oringinal]=textread([path],'%f %f');

value_Te(1,:) = TeNe(:,1)'; value_Te(2,:) = Te';    
value_Te(5,:) = Te_NoResVol';                       
value_Te(8,:) = Te_Oringinal';                      

value_Ne(1,:) = TeNe(:,2)'.*1e-6;   value_Ne(2,:) = Ne'.*1e-6;                      
value_Ne(5,:) = Ne_NoResVol'.*1e-6;                       
value_Ne(8,:) = Ne_Oringinal'.*1e-6;                     

for i=1:length(TeNe(:,1))
    value_Te(3,i) = (-TeNe(i,1)+ Te(i,1))/TeNe(i,1)*100;
    value_Te(6,i) = (-TeNe(i,1)+ Te_NoResVol(i,1))/TeNe(i,1)*100;
    value_Te(9,i) = (-TeNe(i,1)+ Te_Oringinal(i,1))/TeNe(i,1)*100;
    
     value_Ne(3,i) = (-TeNe(i,2)+ Ne(i,1))/TeNe(i,2)*100;
     value_Ne(6,i) = (-TeNe(i,2)+ Ne_NoResVol(i,1))/TeNe(i,2)*100;
     value_Ne(9,i) = (-TeNe(i,2)+ Ne_Oringinal(i,1))/TeNe(i,2)*100;

end
% value(1,:) = TeNe(:,1)';value(2,:) = Te'; value(3,:) = abs((TeNe(:,1)'- Te')/TeNe(:,1)'*100);
% value(5,:) = TeNe(:,2)';value(6,:) = Ne'; value(7,:) = abs((TeNe(:,2)'- Ne')/TeNe(:,2)'*100);

figure;
plot(0:30-1,TeNe(:,1),'b-'); hold on ;
plot(0:length(Te)-1,Te,'r-');
plot(0:length(Te_NoResVol)-1,Te_NoResVol,'g-');
plot(0:length(Te_Oringinal)-1,Te_Oringinal,'b-');
title('Temperature');
w=legend('DMSP','with S.D.S. and C.L. correction','with S.D.S. correction','without correction','Location','southeast');
xlabel('Time'); ylabel('Temperature( K )');
set(gca,'XTickLabel',{'11:32','11:37','11:42','11:47','11:52','11:57','12:02'});
grid on;
neworder = [1,4,3,2];
w.PlotChildren = w.PlotChildren(neworder);

figure;
plot(0:30-1,TeNe(:,2)./1e6,'b-'); hold on ;
plot(0:length(Ne)-1,Ne./1e6,'r-');
plot(0:length(Ne_NoResVol)-1,Ne_NoResVol./1e6,'g-');
plot(0:length(Ne_Oringinal)-1,Ne_Oringinal./1e6,'b-');
title('Decenity');
w=legend('DMSP','with S.D.S. and C.L. correction','with S.D.S. correction','without correction','Location','southeast');
xlabel('Time'); ylabel('Dencity(cm^-3)');
set(gca,'XTickLabel',{'11:32','11:37','11:42','11:47','11:52','11:57','12:02'});
grid on;
neworder = [1,4,3,2];
w.PlotChildren = w.PlotChildren(neworder);

figure;
plot(0:length(value_Te(3,:))-1,value_Te(3,:),'r-');hold on ;
plot(0:length(value_Te(6,:))-1,value_Te(6,:),'g-');
plot(0:length(value_Te(9,:))-1,value_Te(9,:),'b-');
title('Temperature Error')
w=legend('with S.D.S. and C.L. correction','with S.D.S. correction','without correction','Location','southeast');
xlabel('Time'); ylabel('Temperature ( % )');
set(gca,'XTickLabel',{'11:32','11:37','11:42','11:47','11:52','11:57','12:02'});
grid on;
neworder = [3,2,1];
w.PlotChildren = w.PlotChildren(neworder);

figure;
plot(0:length(value_Ne(3,:))-1,value_Ne(3,:),'r-');hold on ;
plot(0:length(value_Ne(6,:))-1,value_Ne(6,:),'g-');
plot(0:length(value_Ne(9,:))-1,value_Ne(9,:),'b-');
title('Dencity Error');
w=legend('with S.D.S. and C.L. correction','with S.D.S. correction','without correction','Location','southeast');
xlabel('Time'); ylabel('Dencity ( % )');
set(gca,'XTickLabel',{'11:32','11:37','11:42','11:47','11:52','11:57','12:02'});
grid on;
neworder = [3,2,1];
w.PlotChildren = w.PlotChildren(neworder);
