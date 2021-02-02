function Logging(filename,code,Msg)
% Schreibt Log-Datei und beendet das Programm notfalls mit einer
% Fehlermeldung

% Oeffnen texfile
if code == 0
    % Initialise logging facility
    fileID = fopen(filename,'w');
    
    fprintf(fileID,['Programmstart: ', datestr(clock), '\n']);
    fprintf(fileID,'---------------------------------------');
else
    % In Datei schreiben
    fileID = fopen(filename,'a');
end


% log
switch code
    case 1
        % Write Log
        fprintf(fileID,['\n\t', Msg]);
    case 2
        % Warning
        fprintf(fileID,['\nWarning: ', Msg]);
    case 3
        % Error
        fprintf(fileID,['\nERROR: ', Msg]);
        fprintf(fileID,'\n\nProgram terminated!\n');
        fprintf(fileID,'---------------------------------------');
        fprintf(fileID,['\n', datestr(clock)]);
        fclose(fileID);
        error(Msg)
    case 4
        % Program finishd successfull
        fprintf(fileID,'\n\nProgram finishd successfully!\n');
        fprintf(fileID,'---------------------------------------');
        fprintf(fileID,['\n', datestr(clock)]);
    otherwise
        % Default
        fprintf(fileID,['\n', Msg]);
end

fclose(fileID);

end