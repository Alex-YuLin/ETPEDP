
function [Io]=FDCurrent_2(A,Beta,Vp,Vpl,Te, Ne)
   k=1.3806488*10^-23;
   e=1.602*10^-19;
   me=9.109*10^-31;
   mi=14*1.672*10^-27;
  if(Vp>Vpl)
      Io=Ne*e*A*(-sqrt(k*Te/2/pi/mi)*exp(-e*(Vp-Vpl)/k/Te)+sqrt(k*Te/2/pi/me)*(1+e*(Vp-Vpl)/k/Te).^Beta);
  else
      Io=Ne*e*A*(-sqrt(k*Te/2/pi/mi)*(1-e*(Vp-Vpl)/k/Te).^Beta+sqrt(k*Te/2/pi/me)*exp( e*(Vp-Vpl)/k/Te));
  end
end