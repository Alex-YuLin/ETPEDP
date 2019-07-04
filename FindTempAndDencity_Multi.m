clc,clear,%close all;
%{
input signal : �h�ߪi ��J �_�l�ɶ�: 0.2s �}�Үɶ�:0.4s  �����ɶ�: 0.3s
%}
%{
 �ݭקﶵ��:
    1.���y�q�� -3V ��אּ -2V (�w�ק� BUT �W�٥��ק����n30 ) (�w�ק�)
 ���Ӧ��i��קﳡ��
    1.�ק�߽Ķ��� ���{��[-5 -2 0.3] �קאּ[-5 -2 0 0.3]   (���ק�)
%}

% PSPICE ���� �q�y-�ɶ� data
path='C:\Users\q8529\Documents\NCU_LAB\07_EDPETP_handover\ProDes\Matlab\DMSP\DMSPTiCurr\';
content='Time';
[T2000.D1E11.T]=textread([path  content '.txt'],'%f');
content='Current';
[T2000.D1E11.I]=textread([path  content '.txt'],'%f');

%--------------���ΰT��(�R�q+��q)--------------------%

%/////////////////////////////////////////A
    ChargeTime = 80e-3;
    DischargeTime = 40e-3;
    PulseTime = ChargeTime+DischargeTime;
    % �Ĥ@�ߪi�}�l�ɶ�
    FirPulseTime=0.2;
%//////////////////////////////////////// /


Label=T2000.D1E11;
count1=1;count2=1;count3=1;
for long = 1:length(T2000.D1E11.T)
    if Label.T(long)<FirPulseTime
        StableCurr = Label.I(long);
    end
    if Label.T(long)>=FirPulseTime && Label.T(long)<=(FirPulseTime+PulseTime)
        SingnalCurr_n50(count1,1)=Label.I(long);
        SingnalTime_n50(count1,1)=Label.T(long)-FirPulseTime;
        count1=count1+1;
    end
    if Label.T(long)>=(FirPulseTime+PulseTime) && Label.T(long)<=(FirPulseTime+PulseTime*2)
        SingnalCurr_n30(count2,1)=Label.I(long);
        SingnalTime_n30(count2,1)=Label.T(long)-(FirPulseTime+PulseTime);
        count2=count2+1;
    end
    if Label.T(long)>=(FirPulseTime+PulseTime*2) && Label.T(long)<=(FirPulseTime+PulseTime*3)
        SingnalCurr_p03(count3,1)=Label.I(long);
        SingnalTime_p03(count3,1)=Label.T(long)-(FirPulseTime+PulseTime*2);
        count3=count3+1;
    end
end
%--------------���ΰT��(��q)--------------------%
count1=1;count2=1;count3=1;
for long = 1:length(T2000.D1E11.T)
    if Label.T(long)<0.2
        StableCurr = Label.I(long);
    
    elseif Label.T(long)>=(FirPulseTime+ChargeTime) && Label.T(long)<=(FirPulseTime+ChargeTime+DischargeTime)
        SingnalCurr_n50_filter(count1,1)=Label.I(long);
        SingnalTime_n50_filter(count1,1)=Label.T(long)-(FirPulseTime+ChargeTime);
        count1=count1+1;
    
    elseif Label.T(long)>=(FirPulseTime+ChargeTime*2+DischargeTime) && Label.T(long)<=(FirPulseTime+ChargeTime*2+DischargeTime*2)
        SingnalCurr_n30_filter(count2,1)=Label.I(long);
        SingnalTime_n30_filter(count2,1)=Label.T(long)-(FirPulseTime+ChargeTime+PulseTime);
        count2=count2+1;
    
    elseif Label.T(long)>=(FirPulseTime+ChargeTime*3+DischargeTime*2) && Label.T(long)<=(FirPulseTime+ChargeTime*3+DischargeTime*3)
        SingnalCurr_p03_filter(count3,1)=Label.I(long);
        SingnalTime_p03_filter(count3,1)=Label.T(long)-(FirPulseTime+ChargeTime+PulseTime*2);
        count3=count3+1;        
    end
end

%-----------------------------------------%

%�R�q�Ѽ�
% �q�y�ɶ��`��
tau_c=0.1674;
% �]�w�q�y�M�q���ɶ��`�ƪ����
tau_v=tau_c/500;
% �X�����q�y�ɶ��`�Ʒ����˰϶��A�ѫe�����窾�D0.4���̲z�Q
interval=0.2*tau_c;
% �X�����q���ɶ��`�ƨ��˲Ĥ@�ӭȡA�ѫe�����窾�D7���̲z�Q
baisuu=6;
% �ֳt���˪����˶g��
rapid_S=100*10^(-6);

%----------------------------------------%
%���T�� 
gosa=100;
%{
% Draw Idea-IV curive
Apr = 58.2E-4;
Ar = 6;
beta1= 0;
beta2= 0;
Te= 2000;
Ne= 1E11;

count=1;
for i=-5:0.01:0 
    Guess.IV(count,2)=i;
count=count+1;
end

[Guess.IV(:,1),~]=FDDSI_Vcurve(Guess.IV(:,2),Apr,Ar,beta1,beta2,Te,Ne);
Guess.IV(:,1)=-Guess.IV(:,1);
%}

% save('ignore.mat'); 
% load('ignore.mat');
%--------------------�]�@�׻P�q�y������--------------------------------%
load('ideal_IV_table_2500k_1E12.mat');
% ��]�@��
NNe=1e12;
Guess.IV(:,1)=Guess.IV(:,1)/NNe;
Unit_TI=Guess.IV;
%---------------------------------------------------------------------%
% �|�N���ơB��q�ū�    
DT=10;TTtmp=2500;
% Te�BNe�|�N(TTtmp NNe)
for DeTime=1:DT
    para=[TTtmp NNe];
    Unit_TI(:,1)=Unit_TI(:,1)*NNe;
    
    LoadTable = Unit_TI;
    
    %--------------------------------------%
    %��q�Ѽ�
    tau_c_time=0.2;
    Times=10;
    target_time=0.03;
    %--------------------------------------%
    
    
    part=1; count=1;
    %���T �h�ռƹq�y���� ���C�~�t
    times=1;  
    for i=1:times
    index=1;
    
    %���l�ϥ����I �̤j�q�y
    length2 = length(SingnalCurr_n50);
    Ireal=6.1938e-10; 
    Inoise=SingnalCurr_n50(:,1)+rand(length2,1)*Ireal*gosa/100-Ireal*gosa/100/2;
    [~,~,A,B,~,~]=mean_I_ID([SingnalTime_n50,Inoise],tau_v*baisuu,interval,rapid_S,48,Ireal);
    Imax(count,index)=A+B; index=index+1;
    
    
    length1 = length(SingnalCurr_n30);
    Ireal=6.1938e-10;
    Inoise=SingnalCurr_n30(:,1)+rand(length1,1)*Ireal*gosa/100-Ireal*gosa/100/2;
    [~,~,A,B,~,~]=mean_I_ID([SingnalTime_n30,Inoise],tau_v*baisuu,interval,rapid_S,48,Ireal);
    Imax(count,index)=A+B; index=index+1;
    
    %�L�װϥ��@�I �̤j�q�y
    length1 = length(SingnalCurr_p03);
    Ireal=6.1938e-10;
    Inoise=SingnalCurr_p03(:,1)+rand(length1,1)*Ireal*gosa/100-Ireal*gosa/100/2;
    [~,~,A,B,~,~]=mean_I_ID([SingnalTime_p03,Inoise],tau_v*baisuu,interval,rapid_S,48,Ireal);
    Imax(count,index)=A+B;
    
    % �ݹq    
    ori_T=SingnalTime_n50_filter;     ori_I=SingnalCurr_n50_filter;
    oriFil_T=SingnalTime_n50_filter;  oriFil_V=1;
    noice_circuit=6.1938e-10;   voltage=-5;
    [V_r(count,1),~,~]=MutilGroupAver(LoadTable, tau_c_time, Times, target_time, gosa, ori_T, ori_I, oriFil_T, oriFil_V, noice_circuit, voltage, para);
    
    ori_T=SingnalTime_n30_filter;     ori_I=SingnalCurr_n30_filter;
    oriFil_T=SingnalTime_n30_filter;  oriFil_V=1;
    noice_circuit=6.1938e-10;   voltage=-3;
    [V_r(count,2),~,~]=MutilGroupAver(LoadTable, tau_c_time, Times, target_time, gosa, ori_T, ori_I, oriFil_T, oriFil_V, noice_circuit, voltage, para);
    
    ori_T=SingnalTime_p03_filter;     ori_I=SingnalCurr_p03_filter;
    oriFil_T=SingnalTime_p03_filter;  oriFil_V=0;
    noice_circuit=6.1938e-10;   voltage=0.3;
    [V_r(count,3),~,~]=MutilGroupAver(LoadTable, tau_c_time, Times, target_time, gosa, ori_T, ori_I, oriFil_T, oriFil_V, noice_circuit, voltage, para);
    
    count=count+1;
    end
    
    % ������ -5 -2 0.3
    for i=1:3
        ImaxFina(i)=mean(Imax(:,i));
        VrFina(i)=mean(V_r(:,i));
    end
    
%     save('ignore2.mat');
% 
%       load('ignore2.mat')
    % ���]�ū�T2000 �@��D1E11
     Ar = 6; beta1=0;beta2=0; %TTtmp=2500;
     ramp=0;
%---------------------------- �ū��|�Nd Start -------------------------------%
% �|�N����
dtimes=10;
%�}�l�|�N
for  d=1:dtimes
     Te = TTtmp;
     index=1;
     % Vscan:-2.0V ��ڹq�� -> -2V ��-5V������
     % Vscan: 0.3V ��ڹq�� -> 0.3V ��-2V������
     for Vscan=[-5 (-2-VrFina(1)) 0 (0.3+VrFina(2))]
        vpr(index)=FDDSv(Vscan,Ar,beta1,beta2,Te); 
        index=index+1;
     end
    % ���l�� �G�񦱽u��{
    Fun_a=(ImaxFina(1)-ImaxFina(2))/(vpr(1)-vpr(2));
    Fun_b=ImaxFina(1)-Fun_a*vpr(1);

%{
%     index=1;
%     for vscan=-5:1:0
%         Ii_line(part,index) = Fun_a*vscan + Fun_b; 
% %         plot(vscan,Ii_line(part,index),'gx');
%         index=index+1;
%     end
%     part=part+1;
    
    
    
%     ----------------------------------------------------------------   %
%     index=1;
%     for i=1:1:5
%         MinusI(index) = Fun_a*vpr(i)+Fun_b;
%         index=index+1;
%     end
%         Final_I = ImaxFina-MinusI;
%}

        % �h�����l�ϼv�T���q�y
        Point03_Curr =  ImaxFina(3)-(Fun_a*0.3+Fun_b);
        Point00_Curr =  StableCurr - (Fun_a*0.3+Fun_b);
        
        
        k=1.3806488*10^-23;
        e=1.602*10^-19;
        me=9.109*10^-31;
        mi=14*1.672*10^-27;
        A=58.2E-4;
        
        % �p��ū�
        Ttmp(d,1+ramp)=e/k*(vpr(4)-vpr(3))/(log(Point03_Curr)-log(Point00_Curr));
        TTtmp=Ttmp(d,1+ramp);
        
        % �q���h�q��
        vpl=FDDSVpl(Ar,beta1,beta2,Ttmp(d,1+ramp)); 
        % �p��@��
        Ne(d,1+ramp) = Point03_Curr/(e*A*sqrt(k*Ttmp(d,1+ramp)/2/pi/me)*exp(e*(vpr(4)-vpl)/k/Ttmp(d,1+ramp)));
        NNe= Ne(d,1+ramp);
end
ramp=ramp+1;


    
    
    finalNeTe(DeTime,1)=NNe;
    finalNeTe(DeTime,2)=TTtmp;
end

path='C:\Users\q8529\Documents\NCU_LAB\07_EDPETP_handover\ProDes\Matlab\DMSP\PrintData.txt';
fid= fopen(path,'a+');
fprintf(fid,'%0.3f %0.3f \r\n',NNe ,TTtmp);
fclose(fid);



% %---- �ū׿@���|�N��------%
% plot(1:10,finalNeTe(:,1));
% figure
% plot(1:10,finalNeTe(:,2));
% %------------------------%

%     figure;
%     subplot(1,2,1);
%     for i=1:ramp
%         plot(1:dtimes,Ttmp(:,i));hold on;
%         title('Diff start Temp of Guess(no noice)');
%         xlabel('Interation Times');ylabel('Temperature');
%         legend('1000','1500','2000','2500','Location','southeast');
%         grid on;
%     end
%     subplot(1,2,2);
%     plot(1:DT, finalNe);
%     title('�@���|�N(�L���T)');
%     xlabel('Interation Times');ylabel('Dencity');


% for i=1:ramp
%      plot(1:dtimes,Ne(:,i));hold on;
%      title('Diff start Temp of Guess');
%      xlabel('Interation Times');ylabel('Dencity');
%      grid on;
% end
    %{
        index=1;
        % �L�q���q�y
        Ne(index)= (3.922*10^(-13)-Fun_b)/(e*A*sqrt(k*Ttmp/2/pi/me)*exp(e*(vpr(6)-vpl)/k/Ttmp));
        index=index+1;
        
        for j=1:1:3
            for i=3:3+j-1
                Ne(index)=Final_I(i)/(e*A*sqrt(k*Ttmp/2/pi/me)*exp(e*(vpr(i)-vpl)/k/Ttmp));
                index=index+1;
            end
        
        Final_Ne(j)=mean(Ne)
        end
        
        
        
        Err=abs((1e11-Final_Ne)/1e11);
        a=table;
        a.table=['�@�׻~�t'];
        a.TwoGrop=Err(1);
        a.ThreeGrop=Err(2);
        a.FourGrop=Err(3);
    %}
    
 
 


