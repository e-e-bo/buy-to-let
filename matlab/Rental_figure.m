%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by Erlend Eide Bø¸ // eeb@ssb.no
%
% Last changed 05.09.2026 
%
% Making the data for Figure E.4 in 
% Buy-to-let.
%
% Input: datablsim.mat; created by
%  /matlab/buytolet.m;
%
% Output: rentalfig.csv.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Uniformly distributed
clear

load('databtlsim');

rn = 0:99;

ru = rmax*(rn/100); % Rent
rmu = (rmax - ru)/2; % Mean return to renters

ermu = (1-rn/100).*rmu; % Expected return to buyers

exdat = [rn' ru' rmu' ermu'];
csvwrite('rentalfig.csv',exdat);
