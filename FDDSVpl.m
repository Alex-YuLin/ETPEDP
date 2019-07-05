function [Vplo]=FDDSVpl(Ar,B1,B2,Te)
%輸入 Ar:機殼/探針面積比 B1:探針beta B2:機殼beta 溫度:Te 求雙Debye鞘電壓
%輸出 Vplo 電漿電壓
k=1.3806488*10^-23;
e=1.602*10^-19;
me=9.109*10^-31;
mi=14*1.672*10^-27;
IE=@(V1in)sqrt(me/mi)*( (1-e/k/Te*(-V1in))^B1 +Ar*(1-e/k/Te*(-V1in))^B2 )  -exp( e/k/Te*(-V1in) )- Ar*exp( e/k/Te*(-V1in) );
Vplo=0;


V=0:0.001:3;
for i=1:length(V)
    Iplot(i)=IE(V(i));
end
%plot(V,Iplot); hold on; grid on;


V1=0;V2=3; Vm=1.5;%左右極限 
I1=IE(V1); I2=IE(V2); I=IE(Vm);
  %plot(Vm,I,'ro');
if(I1*I2>=0)% 同號 I1,I2 同邊
    message='FDDSVpl 電漿電壓超過起始左右邊界'
    return;
end
Err=1;
while(Err>=1E-12)
  if(I1*I>0)%中間電流和左極電流同邊
      I1=I;V1=Vm;
  else
      V2=Vm;
  end
    %plot(Vm,I,'ro');
  Vm=(V1+V2)/2; Im=IE(Vm);
  Err=abs(I-Im); I=Im;
end

Vplo=Vm;
return;

end
