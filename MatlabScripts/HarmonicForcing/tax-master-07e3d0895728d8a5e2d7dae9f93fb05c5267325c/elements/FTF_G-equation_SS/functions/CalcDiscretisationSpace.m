function DiscSpace = CalcDiscretisationSpace(Param,Geometrie)
% Erstellt Diskretisierung in Raumrichtung
Logging(Param.filename,1,'Diskretisierung Raum:')
% Unterscheide Flammentypen
if Param.Flammentyp == 'M'
    %%%%%%%% V-Anteil
    DiscSpace.V.nY = Param.nY;
    DiscSpace.V.dY = Geometrie.V.Lf / (Param.nY-1);
    DiscSpace.V.SchemeSpace = Param.SchemeSpace;
    
    Logging(Param.filename,1,['\tnY_V: ',DiscSpace.V.nY])
    Logging(Param.filename,1,['\tdY_V: ',DiscSpace.V.dY])
    Logging(Param.filename,1,['\tScheme_V: ',DiscSpace.V.SchemeSpace])
    
    %%%%%%%% K-Anteil
    DiscSpace.K.nY = Param.nY;
    DiscSpace.K.dY = Geometrie.K.Lf / (Param.nY-1);
    DiscSpace.K.SchemeSpace = Param.SchemeSpace;
    
    Logging(Param.filename,1,['\tnY_K: ',DiscSpace.K.nY])
    Logging(Param.filename,1,['\tdY_K: ',DiscSpace.K.dY])
    Logging(Param.filename,1,['\tScheme_K: ',DiscSpace.K.SchemeSpace])
else
    DiscSpace.nY = Param.nY;
    DiscSpace.dY = Geometrie.Lf / (Param.nY-1);
    DiscSpace.SchemeSpace = Param.SchemeSpace;
    
    Logging(Param.filename,1,['\tnY: ',DiscSpace.nY])
    Logging(Param.filename,1,['\tdY: ',DiscSpace.dY])
    Logging(Param.filename,1,['\tScheme: ',DiscSpace.SchemeSpace])
end


end