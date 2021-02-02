function [AcVec, name, unit] = calcProperty(sys, f,g, property)
% calcProperty function translates a solution vector x into a certain format
% specified by property
% ------------------------------------------------------------------
% This file is part of tax, a code designed to investigate thermoacoustic
% network systems. It is developed by:
% Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen.
% For updates and further information please visit www.tfd.mw.tum.de
% ------------------------------------------------------------------
% [AcVec, name, unit] = calcProperty(sys, f,g, property);
% Input:        * sys:      tax object
%               * f:        f waves of state vector
%               * g:        g waves of state vector
%               * property: Property to be evaluated: 'p_u', 'f_g',
%                           'impedance_admittance', 'intensity'
% Output:       * AcVec:    Structure containing the vectors of the two
%                           desired properties 
%               * name:     Labels of the two properties
%               * unit:     units of the two properties
% ------------------------------------------------------------------
% Authors:      Thomas Emmert (emmert@tfd.mw.tum.de)
% Last Change:  15 Jun 2015
% ------------------------------------------------------------------
% (c) Copyright 2015 Emmert tfdTUM. all Rights Reserved.


rho = sys.state.rho;
c = sys.state.c;
Mach = sys.state.Mach;

switch property
    case 'p_u'
        p = full(bsxfun(@times,(f+g),(rho.*c)'));
        u = full(f-g);
        AcVec{1} = p; name{1} = 'p'; unit{1} = '[Pa]';
        AcVec{2} = u; name{2} = 'u'; unit{2} = '[m/s]';
    case 'p/rho/c_u'
        p = full(f+g);
        u = full(f-g);
        AcVec{1} = p; name{1} = 'p/(\rho c)'; unit{1} = '[m/s]';
        AcVec{2} = u; name{2} = 'u'; unit{2} = '[m/s]';
        
    case 'f_g'
        AcVec{1} = full(f); name{1} = 'f'; unit{1} = '[m/s]';
        AcVec{2} = full(g); name{2} = 'g'; unit{2} = '[m/s]';
        
    case 'impedance_admittance'
        p = bsxfun(@times,(f+g),(rho.*c)');
        u = f-g;
        AcVec{1} = p./u; name{1} = 'impedance'; unit{1} = '[Pa s/m]';
        AcVec{2} = u./p; name{2} = 'admittance'; unit{2} = '[m/s /Pa]';
        
    case 'intensity'
        % \cite{Morfe71.acoustic}
        % Emmert: Hier wird eventuell die Machzahl vernachlaessigt.
        % I = f^2*rho/(2*c)*(c+u)^2 - g^2*rho/(2*c)*(c-u)^2
        % I = f^2*(sqrt(rho*c/2)*(1+Mach))^2 - g^2*(sqrt(rho*c/2)*(1-Mach))^2
        
        a = bsxfun(@times,f,(sqrt(rho.*c/2).*(1+Mach))');
        b = bsxfun(@times,g,(sqrt(rho.*c/2).*(1-Mach))');
        AcVec{1} = conj(a).*(a) - conj(b).*(b);
        name{1} = 'intensity'; unit{1} = '[N/m²]';
end
