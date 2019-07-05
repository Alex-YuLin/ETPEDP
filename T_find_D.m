function[T,D,index]=T_find_D(Time,Data,Timing)
    a=size(Time);
    for i=2:1:a(1)
        if Time(i-1)<=Timing && Time(i)>Timing
            index=i-1;
            T=Time(i-1);
            D=Data(i-1);
            break;
        end
    end
end