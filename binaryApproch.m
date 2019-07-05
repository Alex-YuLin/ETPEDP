%{
    目的: 二分逼近法 (OML公式)
    輸入:
        VV= 雙deby電壓
        Vscan = 雙汙染成電壓
    輸出:
        V_r = 逼近出的電壓值
%}

function [V_r]=binaryApproch(VV, Tar_I, Te, Ne, Ar, Beta1, Beta2)
    Vpl=FDDSVpl(Ar,Beta1,Beta2,Te);
    Vt=abs(VV);
    A=58.2E-4;
    %{
        Vpr <-> Vsat 電流方向相反
    %}
    Vpr = SFDV(VV, Vpl, Tar_I, Te, Ne, A, Beta1);
    Vsat = SFDV(VV, Vpl, -Tar_I, Te, Ne, A*Ar, Beta2);
    V_r = Vpr - Vsat;
end