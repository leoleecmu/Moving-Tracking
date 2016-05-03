function q = density_estimation(T,Lmap,k,H,W)
q = zeros(Lmap,1);

for x=1:W
    for y=1:H 
        q(T(y,x)+1) = q(T(y,x)+1)+k(y,x);
    end
end

% Normalizing
C = 1/sum(sum(k));
q = C.*q;

end