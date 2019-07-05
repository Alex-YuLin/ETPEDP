function [Vout]=FDDSv(Vscan,Ar,Beta1,Beta2,Te)
%{
  Vscan: 輸入掃描電壓    Vout: 輸出對應分壓
  Ar : 機殼/探針 面積比;  Beta1: 探針型狀  Beta2: 機殼型狀
  Vpl: 雙Debye鞘電漿電壓  Te: 電漿溫度
%}

Vpl=FDDSVpl(Ar,Beta1,Beta2,Te);

%{
V=0:0.0001:Vscan;
for i=1:length(V)
    I(i)=FDCurrent(1,Beta1,V(i) ,Vpl,Te)+FDCurrent(Ar,Beta2,V(i)-Vscan ,Vpl,Te);
end
plot(V,I); hold on; grid on;
%}

Vb1=0;Vb2=Vscan;Vm=(Vb1+Vb2)/2;
Ib2=FDCurrent(1,Beta1,Vb2,Vpl,Te)+FDCurrent(Ar,Beta2,Vb2-Vscan,Vpl,Te);
Im =FDCurrent(1,Beta1,Vm ,Vpl,Te)+FDCurrent(Ar,Beta2,Vm-Vscan ,Vpl,Te);
Err=1;
%------------------------------------%
% 測試程式 未完成
% Vb1=-Vt;Vb2=Vt;Vb3=Vscan;Vm=(Vb1+Vb2)/2;
% Ib1=FDCurrent(1,Beta1,Vb1,Vpl,Te)+FDCurrent(Ar,Beta2,Vb1-Vscan,Vpl,Te);
% Ib2=FDCurrent(1,Beta1,Vb2,Vpl,Te)+FDCurrent(Ar,Beta2,Vb2-Vscan,Vpl,Te);
% Ib3=FDCurrent(1,Beta1,Vb3,Vpl,Te)+FDCurrent(Ar,Beta2,Vb3-Vscan,Vpl,Te);
% Im =FDCurrent(1,Beta1,Vm ,Vpl,Te)+FDCurrent(Ar,Beta2,Vm-Vscan ,Vpl,Te);
% 
% while (Err>1E-9)
%     Diff1=Im-Ib1;
%     Diff2=Im-Ib2;
%         if (Im<Ib3)
%             Vb1=Vm;Ib1=Im; Vout=Vm;
%         elseif (Im>Ib3)
%             Vb2=Vm;Ib2=Im; Vout=Vm;
%         end
%         Vm=(Vb1+Vb2)/2;
%         Im =FDCurrent(1,Beta1,Vm ,Vpl,Te)+FDCurrent(Ar,Beta2,Vm-Vscan ,Vpl,Te);
%      Err = abs(Im-Ib3); 
% end

%------------------------------------%

  %plot(Vm,Im,'ro');
while( Err>1E-13 ) %當I疊代誤差 < 門檻
  Im_old=Im;
  if(Im*Ib2>=0)  %中間電壓與右極限 同號 以中間取待右極限
      Ib2=Im; Vb2=Vm;
  else
      Vb1=Vm;
  end
  Vm=(Vb1+Vb2)/2; 
  %Im =FDCurrent(1,Beta1,Vm ,Vpl,Te)+FDCurrent(Ar,Beta2,Vm-Vscan ,Vpl,Te);
  Im =FDCurrent_2(58.2e-4,Beta1,Vm ,Vpl,Te,1E12)...
      +FDCurrent_2(58.2e-4*Ar,Beta2,Vm-Vscan ,Vpl,Te,1e12);
  %plot(Vm,Im,'ro');
  Err=abs(Im-Im_old);
end
Vout=Vm;
end