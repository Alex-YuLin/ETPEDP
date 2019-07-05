%{
    �ت�: �G���G��k (OML����)
    ��J:
        VV= ��deby�q��
        Vscan = �����V���q��
    ��X:
        V_r = �G��X���q����
%}

function [V_r]=binaryApproch(VV, Tar_I, Te, Ne, Ar, Beta1, Beta2)
    Vpl=FDDSVpl(Ar,Beta1,Beta2,Te);
    Vt=abs(VV);
    A=58.2E-4;
    %{
        Vpr <-> Vsat �q�y��V�ۤ�
    %}
    Vpr = SFDV(VV, Vpl, Tar_I, Te, Ne, A, Beta1);
    Vsat = SFDV(VV, Vpl, -Tar_I, Te, Ne, A*Ar, Beta2);
    V_r = Vpr - Vsat;
end