
function [Io]=FDCurrent(A,Beta,Vp,Vpl,Te)
   k=1.3806488*10^-23;
   e=1.602*10^-19;
   me=9.109*10^-31;
   mi=14*1.672*10^-27;
  if(Vp>Vpl)
      Io=A*(-sqrt(1/mi)*exp(-e*(Vp-Vpl)/k/Te)+sqrt(1/me)*(1+e*(Vp-Vpl)/k/Te).^Beta);
  else
      Io=A*(-sqrt(1/mi)*(1-e*(Vp-Vpl)/k/Te).^Beta+sqrt(1/me)*exp( e*(Vp-Vpl)/k/Te));
  end
end