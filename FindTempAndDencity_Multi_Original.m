clc,clear,
%close all;
%{
input signal : 多脈波 輸入 起始時間: 0.2s 開啟時間:0.4s  關閉時間: 0.3s
%}


path='C:\Users\q8529\Documents\NCU_LAB\07_EDPETP_handover\ProDes\Matlab\DMSP\DMSPTiCurr\';
content='Time';
[T2000.D1E11.T]=textread([path  content '.txt'],'%f');
content='Current';
[T2000.D1E11.I]=textread([path  content '.txt'],'%f');

%--------------切割訊號(充電+放電)--------------------%

%/////////////////////////////////////////A
    ChargeTime = 80e-3;
    DischargeTime = 40e-3;
    PulseTime = ChargeTime+DischargeTime;
    % 第一脈波開始時間
    FirPulseTime=0.2;
%/////////////////////////////////////////

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
%--------------切割訊號(放電)--------------------%
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

%充電參數
% 電流時間常數
tau_c=0.1674;
% 設定電流和電壓時間常數的比值
tau_v=tau_c/500;
% 幾倍的電流時間常數當做取樣區間，由前面實驗知道0.4倍最理想
interval=0.2*tau_c;
% 幾倍的電壓時間常數取樣第一個值，由前面實驗知道7倍最理想
baisuu=6;
% 快速取樣的取樣週期
rapid_S=100*10^(-6);

%----------------------------------------%
%雜訊比
gosa=3;
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
%--------------------因濃度與電流成正比--------------------------------%
load('ideal_IV_table_2500k_1E12.mat');
% 初設濃度
NNe=1e12;
Guess.IV(:,1)=Guess.IV(:,1)/NNe;
Unit_TI=Guess.IV;
%---------------------------------------------------------------------%
% 疊代次數、初猜溫度    
DT=1;TTtmp=2500;
% Te、Ne疊代(TTtmp NNe)
for DeTime=1:DT
    para=[TTtmp NNe];
    Unit_TI(:,1)=Unit_TI(:,1)*NNe;
    
    LoadTable = Unit_TI;
    
    
     %--------------------------------------%
    %放電參數
    tau_c_time=0.2;
    Times=10;
    target_time=0.1;
    %--------------------------------------%
    
    
    part=1; count=1;
    %雜訊 多組數電流平均 降低誤差
    times=1;  
    for i=1:times
    index=1;
    
    %離子區打兩點 最大電流(無演算法)
    length2 = length(SingnalCurr_n50);
    Ireal=-4.054*10^(-8); 
    Inoise=SingnalCurr_n50(:,1)+rand(length2,1)*Ireal*gosa/100-Ireal*gosa/100/2;
    [max_I] = max_Current([SingnalTime_n50,Inoise],tau_v*baisuu);
    Imax(count,index)=max_I; index=index+1;
    
    
    length1 = length(SingnalCurr_n30);
    Ireal=-4.054*10^(-8);
    Inoise=SingnalCurr_n30(:,1)+rand(length1,1)*Ireal*gosa/100-Ireal*gosa/100/2;
    [max_I]=max_Current([SingnalTime_n30,Inoise],tau_v*baisuu);
    Imax(count,index)=max_I; index=index+1;
    
    %過度區打一點 最大電流(無演算法)
    length1 = length(SingnalCurr_p03);
    Ireal=-4.054*10^(-8);
    Inoise=SingnalCurr_p03(:,1)+rand(length1,1)*Ireal*gosa/100-Ireal*gosa/100/2;
    [max_I]=max_Current([SingnalTime_p03,Inoise],tau_v*baisuu);
    Imax(count,index)=max_I;
    
   
    count=count+1;
    end
    
    % 取平均 -5 -2 0.3
    for i=1:3
        ImaxFina(i)=mean(Imax(:,i));
    end
    ImaxFina
%     VrFina
    
%     save('ignore2.mat');
% 
%       load('ignore2.mat')
    % 假設溫度T2000 濃度D1E11
     Ar = 6; beta1=0;beta2=0; %TTtmp=2500;
     ramp=0;
%---------------------------- 溫度疊代d Start -------------------------------%
% 疊代次數
dtimes=10;
%開始疊代
for  d=1:dtimes
     Te = TTtmp;
     index=1;
    % Single Debye
     for Vscan=[-5 -2 0 0.3]
        vpr(index)=Vscan;
        index=index+1;
     end
    % 離子區 逼近曲線方程
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

        % 去除離子區影響之電流
        Point03_Curr =  ImaxFina(3)-(Fun_a*0.3+Fun_b);
        Point00_Curr =  StableCurr - (Fun_a*0.3+Fun_b);
        
        
        k=1.3806488*10^-23;
        e=1.602*10^-19;
        me=9.109*10^-31;
        mi=14*1.672*10^-27;
        A=58.2E-4;
        
        % 計算溫度
        Ttmp(d,1+ramp)=e/k*(vpr(4)-vpr(3))/(log(Point03_Curr)-log(Point00_Curr));
        TTtmp=Ttmp(d,1+ramp);
        
        % 電離層電壓
        vpl=FDDSVpl(Ar,beta1,beta2,Ttmp(d,1+ramp)); 
        % 計算濃度
        Ne(d,1+ramp) = Point03_Curr/(e*A*sqrt(k*Ttmp(d,1+ramp)/2/pi/me)*exp(e*(vpr(4)-vpl)/k/Ttmp(d,1+ramp)));
        NNe= Ne(d,1+ramp);
end
ramp=ramp+1;


    
    
    finalNeTe(DeTime,1)=NNe;
    finalNeTe(DeTime,2)=TTtmp;
end

path='C:\Users\q8529\Documents\NCU_LAB\07_EDPETP_handover\ProDes\Matlab\DMSP\PrintData_Oringinal.txt';
fid= fopen(path,'a+');
fprintf(fid,'%0.3f %0.3f \r\n',NNe ,TTtmp);
fclose(fid);



% %---- 溫度濃度疊代圖------%
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
%     title('濃度疊代(無雜訊)');
%     xlabel('Interation Times');ylabel('Dencity');


% for i=1:ramp
%      plot(1:dtimes,Ne(:,i));hold on;
%      title('Diff start Temp of Guess');
%      xlabel('Interation Times');ylabel('Dencity');
%      grid on;
% end
    %{
        index=1;
        % 無電壓電流
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
        a.table=['濃度誤差'];
        a.TwoGrop=Err(1);
        a.ThreeGrop=Err(2);
        a.FourGrop=Err(3);
    %}
    
 
 


