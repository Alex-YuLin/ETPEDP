%{
Input:
    LoadTable: 查表table
    tau_c_time: Td(tau_c_time*tau_c)
    Times: 去雜訊 多組數平均
    target_time:目標時間
    noice:雜訊比
    ori_T:原始時間
    ori_I:原始電流
    oriFil_T: filter後的時間(2.5s後)
    oriFil_V: filter後的電壓(2.5s後)
    noice_circuit:充電 穩定電流(加雜訊用)
    voltage: 掃描電壓
Output:
    V_r: 驗算法目標時間 殘餘電壓
    TimerDiff: 包含 MuGroup(多組數平均);OriTaTime(目標時間);V_e(理論殘電);TaTime(目標時間);V_r(演算法殘電);TaTimeEr(理論 演算法 殘電Diff); 
    Data_Y:求出 A、B 代入 0:0.02:1 求出之數列
%}

function[V_r,TimerDiff, Data_Y]=MutilGroupAver(LoadTable, tau_c_time, Times, target_time, noice, ori_T, ori_I, oriFil_T, oriFil_V, noice_circuit, voltage, para)
 	cont=1;tamp=0;count=1; 
    %舊資料(不知道為何為0.001)tau_v=0.001;
    tau_c=0.1674;
    % tau_c/tau_v=500
    tau_v=tau_c/500;
    % Tp幾倍的tau_c -> Ideal_in dou_ID()
    times = 0.5;
    % ADC速度 100u 
    Step = 10^-5;  
    %放電起始時間 (驗證階段(pspice data)放電起始時間3.5s) (統整階段(pspice)多脈衝放電起始時間 0s)
    Ti=0;
    %未使用
    D=1E11;
    kan=0.0001;
    Ten=100;
    %起始延遲 (預設)(未使用)
    baisuu=7;
    
    
    MuGroup=16;
    for kk=1:1
        row_count=1;
        for u=1:Times
            [~,AA,BB]=Ideal_idou_ID_HiDen([ori_T,ori_I] ,Ti ,baisuu*tau_v , Step ,MuGroup ,tau_c_time*tau_c, D, Ten, voltage, noice , LoadTable, noice_circuit, para);
            AB_value_2500_p10_1E11(cont,1+tamp)=AA;
            AB_value_2500_p10_1E11(cont,2+tamp)=BB;
            AA=real(AA);
            BB=real(BB);
            data_count=1;
            for t=0:0.02:1
                Data_Y(row_count,data_count) = AA*exp(BB*t);
                data_count=data_count+1;
            end
            row_count=row_count+1;
        end
        data_count=1;
        for tt=0:0.02:1
            Er(data_count,1) = tt;
            Er(data_count,2) = mean(Data_Y(:,data_count));
            Er(data_count,3) = std(Data_Y(:,data_count));      
            data_count=data_count+1;
        end
%         errorbar(Er(:,1)',Er(:,2)',Er(:,3)');
%         xlabel('Time(s)');  ylabel('Voltage(V)');
        Ar = 6;
        beta1= 0;
        beta2= 0;
        if voltage>=0
           [TaTime,V_r,index]= T_find_D(Er(:,1), Er(:,2), target_time);
        else
            [TaTime,V_r,index]= T_find_D(Er(:,1), Er(:,2), target_time);
        end
        % 驗證階段 oriFil_T-3.5
        % 最後階段 oriFil_T-3.5 -> oriFil_T
%         [OriTaTime,V_e,~]= T_find_D(oriFil_T, oriFil_V , target_time); %找出理論殘壓
%         TaTimeEr =abs(V_r-V_e)/abs(voltage);
        TimerDiff(count,1)=MuGroup;
%         TimerDiff(count,2)=OriTaTime;
%         TimerDiff(count,3)=V_e;
        TimerDiff(count,4)=TaTime;
        TimerDiff(count,5)=V_r;
%         TimerDiff(count,6)=TaTimeEr; 
%        Error = TaTimeEr;
%       TimerDiff=1;
        count=count+1;
        MuGroup=MuGroup*2;
    end
%     oriFil_T=oriFil_T-3.5;
%     plot(oriFil_T,oriFil_V); 
%     legend('group:16','origin','Location','southeast');
end