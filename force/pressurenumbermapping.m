m1 = [301,302];
m2 = m1;
for i = 1:13
    m2 = [m2,m1 + i*8];
end
m3 = m2;
for i = 1:3
    m3 = [m3,m2 + i*2];
end

m4 = [m3, m3 + 28*4, m3 + 28*8];

pressurenumbermaping = m4;
