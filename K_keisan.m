function[K]=K_keisan(t,I)
tamp=(I(2)-I(1))*(I(2)-I(3));
if tamp<0
   K=(I(1)-I(3))/(I(1)-I(2)); 
else
    K=0;
end
        
end