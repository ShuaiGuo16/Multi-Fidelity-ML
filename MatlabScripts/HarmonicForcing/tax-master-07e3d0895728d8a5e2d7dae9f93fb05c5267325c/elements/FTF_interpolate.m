function [sys,pars] = FTF_interpolate(pars, ~)
    % FTF_interpolate interplolates flame transfer functions.
    % ------------------------------------------------------------------
    % This file is part of tax, a code designed to investigate
    % thermoacoustic network systems. It is developed by the
    % Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen
    % For updates and further information please visit www.tfd.mw.tum.de
    % ------------------------------------------------------------------
    % [sys,pars] = FTF_interpolate(pars, ~);
    % Input:   * pars.pi: interpolation parameters
    %          * pars.C: Matrix of interpolation points
    %          * pars.P: Matrix of corresponding FTFs
    %          * pars.Tsi: Time step of interpolated models
    % Output:  * sys: FTF object 
    % Output:  * pars: updated pars struct
    % ------------------------------------------------------------------
    % Authors:      Stefan Jaensch (jaensch@tfd.mw.tum.de)
    % Last Change:  08 Mar 2016
    % ------------------------------------------------------------------
    % See also: FTF_ntau
if ~isa(pars.pi,'sss')
    if iscell(pars.pi)
        load(pars.data{1})
        pi = str2num(pars.pi{1});
        pars.pi = pi;
        pars.C = C;
        pars.P = P;
        pars.Tsi = Tsi;
    else
        pi = pars.pi;
        C = pars.C;
        P = pars.P;
        Tsi = pars.Tsi;
    end
    
    b = zeros(1,size(P,2));
    for i = 1:size(P,2)
        F = scatteredInterpolant(C(:,1),C(:,2),C(:,3),P(:,i));
        b(i) = F(pi(1),pi(2),pi(3));
    end
       
    sys = idpoly([],b,'Ts',Tsi);
else
    sys = pars.pi;
end


