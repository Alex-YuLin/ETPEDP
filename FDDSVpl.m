function [Vplo]=FDDSVpl(Ar,B1,B2,Te)
%��J Ar:����/���w���n�� B1:���wbeta B2:����beta �ū�:Te �D��Debye�T�q��
%��X Vplo �q�߹q��
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


V1=0;V2=3; Vm=1.5;%���k���� 
I1=IE(V1); I2=IE(V2); I=IE(Vm);
  %plot(Vm,I,'ro');
if(I1*I2>=0)% �P�� I1,I2 �P��
    message='FDDSVpl �q�߹q���W�L�_�l���k���'
    return;
end
Err=1;
while(Err>=1E-12)
  if(I1*I>0)%�����q�y�M�����q�y�P��
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
