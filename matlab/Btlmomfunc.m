%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by Erlend Eide Bø¸ // eeb@ssb.no
%
% Last changed 22.09.2026 
%
% BTLMOMFUNC Moment function for buy to let model
% With 6 variables. 
% Needed for /matlab/buytolet.m.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = btlmomfunc(beta,y,x)

mya = mean(y,1); 
sdya = std(y,0,1);
my = [mya(1),mya(3)]; % Mean investor share; mean ratio rents to price
cov = [sdya(1)/mya(1),sdya(2)/mya(2),sdya(4)/mya(4)]; % Coeficient of variation for investor share, house prices and rents
my2 = mya(6); % Mean transaction share
out = [my cov my2]';

end
