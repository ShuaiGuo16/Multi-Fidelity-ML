function [axiss, linkedaxiss]= plotStateVector(sys, AcVec, name, unit, D, format, freqScaling, xScale, procedure)
% plotStateVector function plots the acoustic part of a state vector in a
% given format. It is usually called by a tax plotStateVector function.
% ------------------------------------------------------------------
% This file is part of tax, a code designed to investigate thermoacoustic
% network systems. It is developed by:
% Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen.
% For updates and further information please visit www.tfd.mw.tum.de
% ------------------------------------------------------------------
% [axiss, linkedaxiss]= plotStateVector(sys, AcVec, name, unit, D, format, freqScaling, xScale, procedure);
% Input:        * sys: tax object
%               * AcVec: Vector of acoustic state quantity of tax model
%               computed by ACBLOCK/CALCPROPERTY
%               * name:  Name of the figure
%               * unit:  Units of the quantities plottet
%               * D:     Frequency vector corresponding to AcVec
%               * format:      formatting of plotted values
%                              'realImag','absPhase','logAbsPhase'
%               * freqScaling: 'log' or linear scaling
%               * xScale:      'Connection [Index]' or 'X [m]'
%               * procedure:   if 'eigenValues' plot along spatial axis,
%                              else along frequency axis
% Output:       * axiss:       axis handles
%               * linkedaxiss: linked axis object for synchronized
%                              visualization
% ------------------------------------------------------------------
% Authors:      Thomas Emmert (emmert@tfd.mw.tum.de)
% Last Change:  15 Jun 2015
% (c) Copyright 2015 Emmert tfdTUM. all Rights Reserved.
% ------------------------------------------------------------------
% See also tax/PLOTSTATEVECTOR, ACBLOCK/calcProperty

switch sys.xScale
    case 'Connection [Index]'
        X = sys.state.idx;
    case 'X [m]'
        X = sys.state.x;
end

omega= imag(D);

for i = 1:length(AcVec)
    % Plot only positive frequencies
    propertyVector = AcVec{i};
    
    % Calculate phase angle of property
    phaseAngle = zeros(length(X),length(omega));
    if strcmp(procedure,'eigenmodes')
        for iOmega = 1:length(omega)
            phaseAngle(:,iOmega) =  unwrap(angle(propertyVector(:,iOmega)));
        end
    else
        for iPos = 1:length(X)
            phaseAngle(iPos,:) =  unwrap(angle(propertyVector(iPos,:)));
        end
    end
    
    % If the length of the frequency vector omega is smaller than the positions
    % vector, transpose the result, as the modeshapes are the more interesting
    % information
    if (length(omega)>= length(X))
        xLabel = 'Frequency [Hz]';
        freqScale = 'Xscale';
        freqScaleId = 'X';
        xVector = omega/2/pi;
        yLabel = xScale;
        yVector = X;
    else
        xLabel = xScale;
        xVector = X;
        yLabel = 'Frequency [Hz]';
        freqScale = 'Yscale';
        freqScaleId = 'Y';
        yVector = omega/2/pi;
        propertyVector = propertyVector.';
        phaseAngle = phaseAngle.';
    end
    
    %% Generate figure
    fig1 = figure();
    set(fig1,'Name',[name{i},' ',unit{i}],'Color',[1 1 1]);
    hold on
    xlabel(xLabel)
    ylabel(yLabel)
    
    
    fig2 = figure();
    set(fig2,'Name',[name{i},' ',unit{i}],'Color',[1 1 1]);
    hold on
    xlabel(xLabel)
    ylabel(yLabel)
    
    % Switch display format of plotted value
    switch format
        case 'realImag'
            figure(fig1);
            zlabel(['Re(',name{i},') ', unit{i}]);
            waterfall(xVector, yVector, real(propertyVector));
            axis(1) = gca();
            
            figure(fig2);
            zlabel(['Im(',name{i},') ', unit{i}])
            waterfall(xVector, yVector, imag(propertyVector));
            axis(2) = gca();
            
        case 'absPhase'
            figure(fig1);
            zlabel(['|',name{i},'| ',unit{i}]);
            waterfall(xVector, yVector, abs(propertyVector));
            axis(1) = gca();
            
            figure(fig2);
            zlabel(['\angle',name{i},' [rad]'])
            waterfall(xVector, yVector, phaseAngle);
            axis(2) = gca();
            piRetick(axis(2), 'Z')
            
        case 'logAbsPhase'
            figure(fig1);
            zlabel(['|',name{i},'| ',unit{i}]);
            waterfall(xVector, yVector, abs(propertyVector));
            set(gca,'ZScale','log')
            axis(1) = gca();
            logRetick(axis(1), 'Z')
            
            figure(fig2);
            zlabel(['\angle',name{i},' [rad]'])
            waterfall(xVector, yVector, phaseAngle);
            axis(2) = gca();
            piRetick(axis(2), 'Z')
            
    end
    
    % Apply logarithmic frequency axis scaling
    if strcmp(strtrim(freqScaling), 'log')
        set(axis(1), freqScale, freqScaling)
        set(axis(2), freqScale, freqScaling)
        logRetick(axis(1), freqScaleId)
        logRetick(axis(2), freqScaleId)
    end
    
    % Link the axis of the imag/real respectively abs/phase plots.
    linkedaxis = linkprop(axis,'View');
    linkedaxiss{i} = linkedaxis;
    axiss{i} = axis;
end
