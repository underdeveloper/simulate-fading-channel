function y = fading(len, fd, T)
arguments
    len {mustBeNumeric} % Number of bits/symbols
    fd {mustBeNumeric}  % Doppler shift (fading rate) in Hz
    T {mustBeNumeric}   % Bit/symbol period in seconds
end

N = 34;
N0 = (N/2 - 1)/2;
alpha = pi/4;
xc = zeros(len,1);
xs = zeros(len,1);
sc = sqrt(2)*cos(alpha);
ss = sqrt(2)*sin(alpha);
ts = 0:len-1;
ts = ts'.*T + round(rand(1,1)*10000)*T;
wd = 2*pi*fd;
xc = sc.*cos(wd.*ts);
xs = ss.*cos(wd.*ts);
for lx =1:N0
    wn = wd*cos(2*pi*lx/N);
    xc = xc + (2*cos(pi*lx/N0)).*cos(wn.*ts);
    xs = xs + (2*sin(pi*lx/N0)).*cos(wn.*ts);
end
y = (xc + 1i.*xs)./sqrt(N0+1);