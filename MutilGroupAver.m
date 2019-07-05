%{
Input:
    LoadTable: �d��table
    tau_c_time: Td(tau_c_time*tau_c)
    Times: �h���T �h�ռƥ���
    target_time:�ؼЮɶ�
    noice:���T��
    ori_T:��l�ɶ�
    ori_I:��l�q�y
    oriFil_T: filter�᪺�ɶ�(2.5s��)
    oriFil_V: filter�᪺�q��(2.5s��)
    noice_circuit:�R�q í�w�q�y(�[���T��)
    voltage: ���y�q��
Output:
    V_r: ���k�ؼЮɶ� �ݾl�q��
    TimerDiff: �]�t MuGroup(�h�ռƥ���);OriTaTime(�ؼЮɶ�);V_e(�z�״ݹq);TaTime(�ؼЮɶ�);V_r(�t��k�ݹq);TaTimeEr(�z�� �t��k �ݹqDiff); 
    Data_Y:�D�X A�BB �N�J 0:0.02:1 �D�X���ƦC
%}

function[V_r,TimerDiff, Data_Y]=MutilGroupAver(LoadTable, tau_c_time, Times, target_time, noice, ori_T, ori_I, oriFil_T, oriFil_V, noice_circuit, voltage, para)
 	cont=1;tamp=0;count=1; 
    %�¸��(�����D����0.001)tau_v=0.001;
    tau_c=0.1674;
    % tau_c/tau_v=500
    tau_v=tau_c/500;
    % Tp�X����tau_c -> Ideal_in dou_ID()
    times = 0.5;
    % ADC�t�� 100u 
    Step = 10^-5;  
    %��q�_�l�ɶ� (���Ҷ��q(pspice data)��q�_�l�ɶ�3.5s) (�ξ㶥�q(pspice)�h�߽ĩ�q�_�l�ɶ� 0s)
    Ti=0;
    %���ϥ�
    D=1E11;
    kan=0.0001;
    Ten=100;
    %�_�l���� (�w�])(���ϥ�)
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
        % ���Ҷ��q oriFil_T-3.5
        % �̫ᶥ�q oriFil_T-3.5 -> oriFil_T
%         [OriTaTime,V_e,~]= T_find_D(oriFil_T, oriFil_V , target_time); %��X�z�״���
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