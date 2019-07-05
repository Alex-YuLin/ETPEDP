

function [Td,N]=find_Td(data, Startime, Ts, Td_ori, loadFil , noice , noice_circuit, voltage)
   limitime=0; N=1;    
    % 因為要使用單位 I-T 表 so直接input Guesss.IV data
%     load(loadFil);
    Guess.IV=loadFil;
    
    index = length(Guess.IV);
    %設定飽和電流質 增加 1% Rage
    Curlim(1)=Guess.IV(2,1)-Guess.IV(2,1)*0.01;
    Curlim(2)=Guess.IV(index,1)-Guess.IV(index,1)*0.01;
    %找出各溫濃下的 Td 值
    if voltage>0
        limit =  Curlim(1);
        % Find the index of "<limit"  
        index = find(data(:,2) < limit);
        % Max Time of  "<limit"
        limitime = data(max(index),1);
        if limitime ~= 0
            Td = limitime-3.5;
        %if not cross the limit 
        else
            Td=Td_ori;
        end
    else
        limit =   Curlim(2);
        index = find(data(:,2) > limit);
        limitime = data(max(index),1);
        if limitime ~= 0
            Td = limitime-3.5;
        else
            Td=Td_ori;
        end
    end 
    
    
    
end