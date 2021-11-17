function [outMsgChar, outArgFloat, outArgInt, outArgChar, outArgBool] = ...
    globalNavigator(inMsgChar, inArgFloat, inArgInt, inArgChar, inArgBool)
%% Аргументы функции
%  inMsgChar - входное сообщение с UART (приемник или управл. устройство)
%  outMsgChar - выходное сообщение (приемник или управл. устройство):
outMsgChar = '';
outArgFloat = inArgFloat;
outArgInt = inArgInt;
outArgChar = inArgChar;
outArgBool = inArgBool;
% Глобальные переменные (задаются стандартные значения и могут изменятся)
%  номер UART порта принимаемого и отправляемого сообщения:
GLOBAL_inMsgPort = inArgInt(1);        %1 - с спутника, 2 - с управляющего устройства
GLOBAL_outMsgPort = inArgInt(2);       %1 - на управляющее устройство, 2 - на приемник
%  установить время:
GLOBAL_setTimeUTC = inArgBool;          %true - время добавляется в выходное сообщение
%  само время:
GLOBAL_prevTimeUTC = inArgChar(1:9);   %время из прошлого сообщения ччммсс.сс
GLOBAL_thisTimeUTC = inArgChar(10:18);   %время из текущего сообщения ччммсс.сс
%  общие переменные:
GLOBAL_prevPosition = inArgFloat(1:3); %данные из пред. сообщения
GLOBAL_thisPosition = inArgFloat(4:6);                      %данные из этого сообщения
GLOBAL_newPosition  = inArgFloat(7:9);                      %данные после фильтра
GLOBAL_thisNSEW = inArgChar(19:20); %направления координат из предыдущего сообщения
GLOBAL_newNSEW = inArgChar(21:22);  %направления координат из текущего сообщения
%  тип фильтра:
GLOBAL_filterType = inArgInt(3);       %1 - Калман, 2 - альфа-бета, 3 - сырые данные
%  тип передаваемых данных:
GLOBAL_dataType = inArgInt(4);         %1 - только спутниковые, 2 - фильтрованные, 3 - спутник и фильтрованные
%  тип передаваемых координат:
GLOBAL_coordinatesType = inArgInt(5);  %1 - десятичные градусы, 2 - град'мин''сек, 3 - град.десятичные минуты
%  точность передаваемых координат:
GLOBAL_dataFormat_dd_dd1 = inArgChar(23:29);   %широта в десятичных градусах 7
GLOBAL_dataFormat_dd_dd2 = inArgChar(30:36);   %долгота в десятичных градусах 7
GLOBAL_dataFormat_dd_mm1 = inArgChar(37:44);  %широта в градусах и в десятичных минутах 8
GLOBAL_dataFormat_dd_mm2 = inArgChar(45:52);  %долгота в градусах и в десятичных минутах 8
GLOBAL_dataFormat3 = inArgChar(53:59);         %высота 7
%  фильтр Калмана:
GLOBAL_kalman_F = reshape(inArgFloat(10:18), 3, 3);    % F
GLOBAL_kalman_G = reshape(inArgFloat(19:21), 3, 1);                  % G
GLOBAL_kalman_H = inArgFloat(22:24);                          % H
GLOBAL_kalman_Q = inArgFloat(25:27);                    % Q
%  a-b фильтр:
GLOBAL_alpha_Step = inArgInt(6);       %
GLOBAL_alpha_Tob = inArgFloat(28);       %
GLOBAL_alpha_Predel = inArgFloat(29);    %
GLOBAL_alpha_Kb = inArgFloat(30);        %
GLOBAL_alpha_Ka = inArgFloat(31);        %
GLOBAL_alpha_Kg = inArgFloat(32);        %
GLOBAL_alpha_Az = inArgFloat(33);        %
GLOBAL_alpha_Vz = inArgFloat(34);        %

%% Функция, декодирующая сообщения со входа UART
if (length(inMsgChar) < 18)
    outMsgChar = ['Error, message length must be at least 18' char(13) char(10)];
    outArgConfig;
    return
end

%  проверка на целостность сообщения
if (inMsgChar(1) == '$' &&...
    inMsgChar(end) == char(10) &&...
    inMsgChar(end-1) == char(13) &&...
    inMsgChar(end-4) == '*')

    %  избавление от $ и /r/n
    mainData = inMsgChar(2:end-2);
    %  контрольная сумма
    checkData = mainData(end-1:end);
    %  основная часть сообщения с инфо
    mainData = mainData(1:end-3);

    switch (GLOBAL_inMsgPort)
        %----------------------------------------------------------------------
        %----------------------------------------------------------------------
        %---------------------- со спутникового приемника ---------------------
        %----------------------------------------------------------------------
        %----------------------------------------------------------------------
        case 1  
            %  Пришло ли проприетарное сообщение от UBLOX:
            if (mainData(1:4) == "PUBX")
                countryData = '  ';
                idData = mainData(1:3);
                iData = mainData(5:end);
            else
                countryData = mainData(1:2);    %инфо о стране спутниковой ГНСС
                idData = mainData(3:5);         %идентификатор строки
                iData = mainData(6:end);        %информация    
            end   

            %  Сравнение дешифрованной КС и полученной:
            if (getXOR(mainData) == char2bin(hex2dec(checkData)))
                parId = uint32(find(iData == ','));
                parIdLen = uint32(length(parId));
                %  Идентификатор строки:
                switch (idData)
                    case 'PUB'
                        if parIdLen >= 7
                            [GLOBAL_thisPosition(1), GLOBAL_newNSEW(1), GLOBAL_thisPosition(2), GLOBAL_newNSEW(2), GLOBAL_thisPosition(3), GLOBAL_thisTimeUTC] = ...
                                getGCS(iData, parId, uint32([3 4 5 6 7 0]));
                        else
                            GLOBAL_thisPosition = GLOBAL_prevPosition;
                        end
                    case 'GGA'
                        if parIdLen >= 9
                            [GLOBAL_thisPosition(1), GLOBAL_newNSEW(1), GLOBAL_thisPosition(2), GLOBAL_newNSEW(2), GLOBAL_thisPosition(3), GLOBAL_thisTimeUTC] = ...
                                getGCS(iData, parId, uint32([2 3 4 5 9 1]));
                        else
                            GLOBAL_thisPosition = GLOBAL_prevPosition;
                        end
                    case 'GLL'
                        if parIdLen >= 5
                            [GLOBAL_thisPosition(1), GLOBAL_newNSEW(1), GLOBAL_thisPosition(2), GLOBAL_newNSEW(2), GLOBAL_thisPosition(3), GLOBAL_thisTimeUTC] = ...
                                getGCS(iData, parId, uint32([1 2 3 4 0 5]));
                        else
                            GLOBAL_thisPosition = GLOBAL_prevPosition;
                        end
                    case 'RMA'
                        if parIdLen >= 5
                            [GLOBAL_thisPosition(1), GLOBAL_newNSEW(1), GLOBAL_thisPosition(2), GLOBAL_newNSEW(2), GLOBAL_thisPosition(3), GLOBAL_thisTimeUTC] = ...
                                getGCS(iData, parId, uint32([2 3 4 5 0 0]));
                        else
                            GLOBAL_thisPosition = GLOBAL_prevPosition;
                        end
                    case 'RMC'
                        if parIdLen >= 6
                            [GLOBAL_thisPosition(1), GLOBAL_newNSEW(1), GLOBAL_thisPosition(2), GLOBAL_newNSEW(2), GLOBAL_thisPosition(3), GLOBAL_thisTimeUTC] = ...
                                getGCS(iData, parId, uint32([3 4 5 6 0 1]));
                        else
                            GLOBAL_thisPosition = GLOBAL_prevPosition;
                        end
                    case 'WPL'
                        if parIdLen >= 4
                            [GLOBAL_thisPosition(1), GLOBAL_newNSEW(1), GLOBAL_thisPosition(2), GLOBAL_newNSEW(2), GLOBAL_thisPosition(3), GLOBAL_thisTimeUTC] = ...
                                getGCS(iData, parId, uint32([1 2 3 4 0 0]));
                        else
                            GLOBAL_thisPosition = GLOBAL_prevPosition;
                        end
                        
                    case 'RMF'
                        if parIdLen >= 9
                            [GLOBAL_thisPosition(1), GLOBAL_newNSEW(1), GLOBAL_thisPosition(2), GLOBAL_newNSEW(2), GLOBAL_thisPosition(3), GLOBAL_thisTimeUTC] = ...
                                getGCS(iData, parId, uint32([6 7 8 9 0 0]));
                        else
                            GLOBAL_thisPosition = GLOBAL_prevPosition;
                        end
                    case 'RMI'
                        if parIdLen >= 4
                            [GLOBAL_thisPosition(1), GLOBAL_newNSEW(1), GLOBAL_thisPosition(2), GLOBAL_newNSEW(2), GLOBAL_thisPosition(3), GLOBAL_thisTimeUTC] = ...
                                getGCS(iData, parId, uint32([1 2 3 4 0 0]));
                        else
                            GLOBAL_thisPosition = GLOBAL_prevPosition;
                        end                       
                    otherwise
                        GLOBAL_thisPosition = GLOBAL_prevPosition;
                        GLOBAL_newPosition = GLOBAL_prevPosition;
                        GLOBAL_newNSEW = GLOBAL_thisNSEW;
                        GLOBAL_thisTimeUTC = GLOBAL_prevTimeUTC;
                end
                
            else
                %  Если сообщение не прошло проверку контрольной суммой:
                GLOBAL_thisPosition = GLOBAL_prevPosition;
                GLOBAL_newPosition = GLOBAL_prevPosition;
                GLOBAL_newNSEW = GLOBAL_thisNSEW;
                GLOBAL_thisTimeUTC = GLOBAL_prevTimeUTC;
            end
            
            %  если декодированные координаты меньше 0
            if (GLOBAL_thisPosition(1) < 0)
                GLOBAL_thisPosition(1) = GLOBAL_prevPosition(1);
            end
            if (GLOBAL_thisPosition(2) < 0)
                GLOBAL_thisPosition(2) = GLOBAL_prevPosition(2);
            end
            if (GLOBAL_thisPosition(3) < 0)
                GLOBAL_thisPosition(3) = GLOBAL_prevPosition(3);
            end

            %  если декодированные координаты больше допустимых значений
            if (GLOBAL_thisPosition(1) > 90)
                GLOBAL_thisPosition(1) = 90 - mod(GLOBAL_thisPosition(1), 90);
            end
            if (GLOBAL_thisPosition(2) > 180)
                GLOBAL_thisPosition(2) = 180 - mod(GLOBAL_thisPosition(2), 180);
                if (GLOBAL_thisNSEW(2) == 'E')
                    GLOBAL_thisNSEW(2) = 'W';
                else
                    GLOBAL_thisNSEW(2) = 'E';
                end
            end
            if (GLOBAL_thisPosition(3) == 0)
                GLOBAL_thisPosition(3) = GLOBAL_prevPosition(3);
            end

            %  Изменение знака значения широты и долготы при изменении их направления
            if (GLOBAL_thisNSEW(1) == 'S')
                GLOBAL_thisPosition(1) = -GLOBAL_thisPosition(1);
            end
            if (GLOBAL_thisNSEW(2) == 'W')
                GLOBAL_thisPosition(2) = -GLOBAL_thisPosition(2);
            end
            
            switch (GLOBAL_filterType)
                %  фильтрация калмана
                case 1
                    %  широта
                    if (GLOBAL_prevPosition(1) ~= GLOBAL_thisPosition(1))
                        GLOBAL_newPosition(1) = kalmanFilterExecution(...
                            GLOBAL_thisPosition(1), GLOBAL_kalman_Q(1), GLOBAL_prevPosition(1));
                    else
                        GLOBAL_newPosition(1) = GLOBAL_thisPosition(1);
                    end
                    %  долгота
                    if (GLOBAL_prevPosition(2) ~= GLOBAL_thisPosition(2))
                        GLOBAL_newPosition(2) = kalmanFilterExecution(...
                            GLOBAL_thisPosition(2), GLOBAL_kalman_Q(2), GLOBAL_prevPosition(2));
                    else
                        GLOBAL_newPosition(2) = GLOBAL_thisPosition(2);
                    end
                    %  высота
                    if (GLOBAL_prevPosition(3) ~= GLOBAL_thisPosition(3))
                        GLOBAL_newPosition(3) = kalmanFilterExecution(...
                            GLOBAL_thisPosition(3), GLOBAL_kalman_Q(3), GLOBAL_prevPosition(3));
                    else
                        GLOBAL_newPosition(3) = GLOBAL_thisPosition(3);
                    end 
                %  фильтрация альфа-бета
                case 2
                    GLOBAL_alpha_step = GLOBAL_alpha_Step + 1;
                    %  широта
                    if (GLOBAL_prevPosition(1) ~= GLOBAL_thisPosition(1))
                        GLOBAL_newPosition(1) = alphaFilterExecution(GLOBAL_thisPosition(1), GLOBAL_prevPosition(1));
                    end
                    %  долгота
                    if (GLOBAL_prevPosition(2) ~= GLOBAL_thisPosition(2))
                        GLOBAL_newPosition(2) = alphaFilterExecution(GLOBAL_thisPosition(2), GLOBAL_prevPosition(2));
                    end
                    %  высота
                    if (GLOBAL_prevPosition(3) ~= GLOBAL_thisPosition(3))
                        GLOBAL_newPosition(3) = alphaFilterExecution(GLOBAL_thisPosition(3), GLOBAL_prevPosition(3));
                    end 
                %  сырые данные со спутника
                case 3
                    GLOBAL_newPosition = GLOBAL_thisPosition;
                otherwise
                    outMsgChar = ['Error, parameter GLOBAL_filterType set incorrectly (GLOBAL_filterType = 1...3)' char(13) char(10)];
                    GLOBAL_outMsgPort = uint32(1);
                    outArgConfig;
                    return
            end
            
            %  тест на пидора
            if (isinf(GLOBAL_newPosition(1)) || isnan(GLOBAL_newPosition(1)))
                GLOBAL_newPosition(1) = GLOBAL_thisPosition(1);
            end
            if (isinf(GLOBAL_newPosition(2)) || isnan(GLOBAL_newPosition(2)))
                GLOBAL_newPosition(2) = GLOBAL_thisPosition(2);
            end
            if (isinf(GLOBAL_newPosition(3)) || isnan(GLOBAL_newPosition(3)))
                GLOBAL_newPosition(3) = GLOBAL_thisPosition(3);
            end
            
            %  если декодированные координаты меньше 0
            if (GLOBAL_thisPosition(1) < 0)
                GLOBAL_thisPosition(1) = -GLOBAL_thisPosition(1);
            end
            if (GLOBAL_thisPosition(2) < 0)
                GLOBAL_thisPosition(2) = -GLOBAL_thisPosition(2);
            end
            if (GLOBAL_thisPosition(3) < 0)
                GLOBAL_thisPosition(3) = -GLOBAL_thisPosition(3);
            end
            
            %  если фильтрованные координаты меньше 0
            if (GLOBAL_newPosition(1) < 0)
                GLOBAL_newPosition(1) = -GLOBAL_newPosition(1);
                if (GLOBAL_newNSEW(1) == 'N')
                    GLOBAL_newNSEW(1) = 'S';
                else
                    GLOBAL_newNSEW(1) = 'N';
                end
            end
            if (GLOBAL_newPosition(2) < 0)
                GLOBAL_newPosition(2) = -GLOBAL_newPosition(2);
                if (GLOBAL_newNSEW(2) == 'E')
                    GLOBAL_newNSEW(2) = 'W';
                else
                    GLOBAL_newNSEW(2) = 'E';
                end
            end
            if (GLOBAL_newPosition(3) < 0)
                GLOBAL_newPosition(3) = GLOBAL_prevPosition(3);
            end
            
            %  если фильтрованные координаты больше допустимых значений
            if (GLOBAL_newPosition(1) > 90)
                GLOBAL_newPosition(1) = 90 - mod(GLOBAL_thisPosition(1), 90);
            end
            if (GLOBAL_newPosition(2) > 180)
                GLOBAL_newPosition(2) = 180 - mod(GLOBAL_thisPosition(2), 180);
                if (GLOBAL_newNSEW(1) == 'E')
                    GLOBAL_newNSEW(1) = 'W';
                else
                    GLOBAL_newNSEW(1) = 'E';
                end
            end
                   
            %  кодирование сообщения с координатами для отправки
            switch (GLOBAL_dataType)
                %  только спутниковые координаты
                case 1
                    if (GLOBAL_coordinatesType == 1)
                        if (GLOBAL_setTimeUTC == false)
                            outMsgChar = [sprintf(GLOBAL_dataFormat_dd_dd1, GLOBAL_thisPosition(1)) GLOBAL_thisNSEW(1) ', '...
                                sprintf(GLOBAL_dataFormat_dd_dd2, GLOBAL_thisPosition(2)) GLOBAL_thisNSEW(2) ', '...
                                sprintf(GLOBAL_dataFormat3, GLOBAL_thisPosition(3)) 'm' ';' char(13) char(10)];
                        else
                            outMsgChar = [GLOBAL_thisTimeUTC(1:2) 'h' GLOBAL_thisTimeUTC(3:4) 'm' GLOBAL_thisTimeUTC(5:end) 's' ', '...
                                sprintf(GLOBAL_dataFormat_dd_dd1, GLOBAL_thisPosition(1)) GLOBAL_thisNSEW(1) ', '...
                                sprintf(GLOBAL_dataFormat_dd_dd2, GLOBAL_thisPosition(2)) GLOBAL_thisNSEW(2) ', '...
                                sprintf(GLOBAL_dataFormat3, GLOBAL_thisPosition(3)) 'm' ';' char(13) char(10)];
                        end
                    elseif (GLOBAL_coordinatesType == 2)
                        if (GLOBAL_setTimeUTC == false)
                            outMsgChar1 = mydegrees2dms(GLOBAL_thisPosition(1));
                            outMsgChar2 = mydegrees2dms(GLOBAL_thisPosition(2));
                            outMsgChar = [sprintf('%02.0f', outMsgChar1(1)) 'd'...
                                sprintf('%02.0f', outMsgChar1(2)) char(39)...
                                sprintf('%07.4f', outMsgChar1(3)) char(39) char(39) GLOBAL_thisNSEW(1) ', '...
                                sprintf('%03.0f', outMsgChar2(1)) 'd'...
                                sprintf('%02.0f', outMsgChar2(2)) char(39)...
                                sprintf('%07.4f', outMsgChar2(3)) char(39) char(39) GLOBAL_thisNSEW(2) ', '...
                                sprintf('%08.02f', GLOBAL_thisPosition(3)) 'm' ';' char(13) char(10)];
                        else
                            outMsgChar1 = mydegrees2dms(GLOBAL_thisPosition(1));
                            outMsgChar2 = mydegrees2dms(GLOBAL_thisPosition(2));
                            outMsgChar = [GLOBAL_thisTimeUTC(1:2) 'h' GLOBAL_thisTimeUTC(3:4) 'm' GLOBAL_thisTimeUTC(5:end) 's' ', '...
                                sprintf('%02.0f', outMsgChar1(1)) 'd'...
                                sprintf('%02.0f', outMsgChar1(2)) char(39)...
                                sprintf('%07.4f', outMsgChar1(3)) char(39) char(39) GLOBAL_thisNSEW(1) ', '...
                                sprintf('%03.0f', outMsgChar2(1)) 'd'...
                                sprintf('%02.0f', outMsgChar2(2)) char(39)...
                                sprintf('%07.4f', outMsgChar2(3)) char(39) char(39) GLOBAL_thisNSEW(2) ', '...
                                sprintf('%08.02f', GLOBAL_thisPosition(3)) 'm' ';' char(13) char(10)];
                        end
                    elseif (GLOBAL_coordinatesType == 3)
                        if (GLOBAL_setTimeUTC == false)
                            outMsgChar = [sprintf(GLOBAL_dataFormat_dd_mm1, mydegrees2dm(GLOBAL_thisPosition(1))) GLOBAL_thisNSEW(1) ', '...
                                sprintf(GLOBAL_dataFormat_dd_mm2, mydegrees2dm(GLOBAL_thisPosition(2))) GLOBAL_thisNSEW(2) ', '...
                                sprintf(GLOBAL_dataFormat3, GLOBAL_thisPosition(3)) 'm' ';' char(13) char(10)];
                        else
                            outMsgChar = [GLOBAL_thisTimeUTC(1:2) 'h' GLOBAL_thisTimeUTC(3:4) 'm' GLOBAL_thisTimeUTC(5:end) 's' ', '...
                                sprintf(GLOBAL_dataFormat_dd_mm1, mydegrees2dm(GLOBAL_thisPosition(1))) GLOBAL_thisNSEW(1) ', '...
                                sprintf(GLOBAL_dataFormat_dd_mm2, mydegrees2dm(GLOBAL_thisPosition(2))) GLOBAL_thisNSEW(2) ', '...
                                sprintf(GLOBAL_dataFormat3, GLOBAL_thisPosition(3)) 'm' ';' char(13) char(10)];
                        end
                    else
                        outMsgChar = ['Error, parameter GLOBAL_coordinatesType set incorrectly (GLOBAL_coordinatesType = 1...3)' char(13) char(10)];
                    end
                %  только фильтрованные координаты
                case 2
                    if (GLOBAL_coordinatesType == 1)
                        if (GLOBAL_setTimeUTC == false)
                            outMsgChar = [sprintf(GLOBAL_dataFormat_dd_dd1, GLOBAL_newPosition(1)) GLOBAL_newNSEW(1) ', '...
                                sprintf(GLOBAL_dataFormat_dd_dd2, GLOBAL_newPosition(2)) GLOBAL_newNSEW(2) ', '...
                                sprintf(GLOBAL_dataFormat3, GLOBAL_newPosition(3)) 'm' ';' char(13) char(10)];
                        else
                            outMsgChar = [GLOBAL_thisTimeUTC(1:2) 'h' GLOBAL_thisTimeUTC(3:4) 'm' GLOBAL_thisTimeUTC(5:end) 's' ', '...
                                sprintf(GLOBAL_dataFormat_dd_dd1, GLOBAL_newPosition(1)) GLOBAL_newNSEW(1) ', '...
                                sprintf(GLOBAL_dataFormat_dd_dd2, GLOBAL_newPosition(2)) GLOBAL_newNSEW(2) ', '...
                                sprintf(GLOBAL_dataFormat3, GLOBAL_newPosition(3)) 'm' ';' char(13) char(10)];
                        end
                    elseif (GLOBAL_coordinatesType == 2)
                        if (GLOBAL_setTimeUTC == false)
                            outMsgChar1 = mydegrees2dms(GLOBAL_newPosition(1));
                            outMsgChar2 = mydegrees2dms(GLOBAL_newPosition(2));
                            outMsgChar = [sprintf('%02.0f', outMsgChar1(1)) 'd'...
                                sprintf('%02.0f', outMsgChar1(2)) char(39)...
                                sprintf('%07.4f', outMsgChar1(3)) char(39) char(39) GLOBAL_newNSEW(1) ', '...
                                sprintf('%03.0f', outMsgChar2(1)) 'd'...
                                sprintf('%02.0f', outMsgChar2(2)) char(39)...
                                sprintf('%07.4f', outMsgChar2(3)) char(39) char(39) GLOBAL_newNSEW(2) ', '...
                                sprintf('%08.02f', GLOBAL_newPosition(3)) 'm' ';' char(13) char(10)];
                        else
                            outMsgChar1 = mydegrees2dms(GLOBAL_newPosition(1));
                            outMsgChar2 = mydegrees2dms(GLOBAL_newPosition(2));
                            outMsgChar = [GLOBAL_thisTimeUTC(1:2) 'h' GLOBAL_thisTimeUTC(3:4) 'm' GLOBAL_thisTimeUTC(5:end) 's' ', '...
                                sprintf('%02.0f', outMsgChar1(1)) 'd'...
                                sprintf('%02.0f', outMsgChar1(2)) char(39)...
                                sprintf('%07.4f', outMsgChar1(3)) char(39) char(39) GLOBAL_newNSEW(1) ', '...
                                sprintf('%03.0f', outMsgChar2(1)) 'd'...
                                sprintf('%02.0f', outMsgChar2(2)) char(39)...
                                sprintf('%07.4f', outMsgChar2(3)) char(39) char(39) GLOBAL_newNSEW(2) ', '...
                                sprintf('%08.02f', GLOBAL_newPosition(3)) 'm' ';' char(13) char(10)];
                        end
                    elseif (GLOBAL_coordinatesType == 3)
                        if (GLOBAL_setTimeUTC == false)
                            outMsgChar = [sprintf(GLOBAL_dataFormat_dd_mm1, mydegrees2dm(GLOBAL_newPosition(1))) GLOBAL_newNSEW(1) ', '...
                                sprintf(GLOBAL_dataFormat_dd_mm2, mydegrees2dm(GLOBAL_newPosition(2))) GLOBAL_newNSEW(2) ', '...
                                sprintf(GLOBAL_dataFormat3, GLOBAL_newPosition(3)) 'm' ';' char(13) char(10)];
                        else
                            outMsgChar = [GLOBAL_thisTimeUTC(1:2) 'h' GLOBAL_thisTimeUTC(3:4) 'm' GLOBAL_thisTimeUTC(5:end) 's' ', '...
                                sprintf(GLOBAL_dataFormat_dd_mm1, mydegrees2dm(GLOBAL_newPosition(1))) GLOBAL_newNSEW(1) ', '...
                                sprintf(GLOBAL_dataFormat_dd_mm2, mydegrees2dm(GLOBAL_newPosition(2))) GLOBAL_newNSEW(2) ', '...
                                sprintf(GLOBAL_dataFormat3, GLOBAL_newPosition(3)) 'm' ';' char(13) char(10)];
                        end
                    else
                        outMsgChar = ['Error, parameter GLOBAL_coordinatesType set incorrectly (GLOBAL_coordinatesType = 1...3)' char(13) char(10)];
                    end
                %  спутниковые и фильтрованные координаты
                case 3
                    if (GLOBAL_coordinatesType == 1)
                        if (GLOBAL_setTimeUTC == false)
                            outMsgChar = [sprintf(GLOBAL_dataFormat_dd_dd1, GLOBAL_thisPosition(1)) GLOBAL_thisNSEW(1) ', '...
                                sprintf(GLOBAL_dataFormat_dd_dd2, GLOBAL_thisPosition(2)) GLOBAL_thisNSEW(2) ', '...
                                sprintf(GLOBAL_dataFormat3, GLOBAL_thisPosition(3)) 'm' ', ' ...
                                sprintf(GLOBAL_dataFormat_dd_dd1, GLOBAL_newPosition(1)) GLOBAL_newNSEW(1) ', '...
                                sprintf(GLOBAL_dataFormat_dd_dd2, GLOBAL_newPosition(2)) GLOBAL_newNSEW(2) ', '...
                                sprintf(GLOBAL_dataFormat3, GLOBAL_newPosition(3)) 'm' ';' char(13) char(10)];
                        else
                            outMsgChar = [GLOBAL_thisTimeUTC(1:2) 'h' GLOBAL_thisTimeUTC(3:4) 'm' GLOBAL_thisTimeUTC(5:end) 's' ', '...
                                sprintf(GLOBAL_dataFormat_dd_dd1, GLOBAL_thisPosition(1)) GLOBAL_thisNSEW(1) ', '...
                                sprintf(GLOBAL_dataFormat_dd_dd2, GLOBAL_thisPosition(2)) GLOBAL_thisNSEW(2) ', '...
                                sprintf(GLOBAL_dataFormat3, GLOBAL_thisPosition(3)) 'm' ', ' ...
                                sprintf(GLOBAL_dataFormat_dd_dd1, GLOBAL_newPosition(1)) GLOBAL_newNSEW(1) ', '...
                                sprintf(GLOBAL_dataFormat_dd_dd2, GLOBAL_newPosition(2)) GLOBAL_newNSEW(2) ', '...
                                sprintf(GLOBAL_dataFormat3, GLOBAL_newPosition(3)) 'm' ';' char(13) char(10)];
                        end
                    elseif (GLOBAL_coordinatesType == 2)
                        if (GLOBAL_setTimeUTC == false)
                            outMsgChar1 = mydegrees2dms(GLOBAL_thisPosition(1));
                            outMsgChar2 = mydegrees2dms(GLOBAL_thisPosition(2));
                            outMsgChar4 = mydegrees2dms(GLOBAL_newPosition(1));
                            outMsgChar5 = mydegrees2dms(GLOBAL_newPosition(2));
                            outMsgChar = [sprintf('%02.0f', outMsgChar1(1)) 'd'...
                                sprintf('%02.0f', outMsgChar1(2)) char(39)...
                                sprintf('%07.4f', outMsgChar1(3)) char(39) char(39) GLOBAL_thisNSEW(1) ', '...
                                sprintf('%03.0f', outMsgChar2(1)) 'd'...
                                sprintf('%02.0f', outMsgChar2(2)) char(39)...
                                sprintf('%07.4f', outMsgChar2(3)) char(39) char(39) GLOBAL_thisNSEW(2) ', '...
                                sprintf('%08.02f', GLOBAL_thisPosition(3)) 'm' ', '...
                                sprintf('%02.0f', outMsgChar4(1)) 'd'...
                                sprintf('%02.0f', outMsgChar4(2)) char(39)...
                                sprintf('%07.4f', outMsgChar4(3)) char(39) char(39) GLOBAL_newNSEW(1) ', '...
                                sprintf('%03.0f', outMsgChar5(1)) 'd'...
                                sprintf('%02.0f', outMsgChar5(2)) char(39)...
                                sprintf('%07.4f', outMsgChar5(3)) char(39) char(39) GLOBAL_newNSEW(2) ', '...
                                sprintf('%08.02f', GLOBAL_newPosition(3)) 'm' ';' char(13) char(10)];
                        else
                            outMsgChar1 = mydegrees2dms(GLOBAL_thisPosition(1));
                            outMsgChar2 = mydegrees2dms(GLOBAL_thisPosition(2));
                            outMsgChar4 = mydegrees2dms(GLOBAL_newPosition(1));
                            outMsgChar5 = mydegrees2dms(GLOBAL_newPosition(2));
                            outMsgChar = [GLOBAL_thisTimeUTC(1:2) 'h' GLOBAL_thisTimeUTC(3:4) 'm' GLOBAL_thisTimeUTC(5:end) 's' ', '...
                                sprintf('%02.0f', outMsgChar1(1)) 'd'...
                                sprintf('%02.0f', outMsgChar1(2)) char(39)...
                                sprintf('%07.4f', outMsgChar1(3)) char(39) char(39) GLOBAL_thisNSEW(1) ', '...
                                sprintf('%03.0f', outMsgChar2(1)) 'd'...
                                sprintf('%02.0f', outMsgChar2(2)) char(39)...
                                sprintf('%07.4f', outMsgChar2(3)) char(39) char(39) GLOBAL_thisNSEW(2) ', '...
                                sprintf('%08.02f', GLOBAL_thisPosition(3)) 'm' ', '...
                                sprintf('%02.0f', outMsgChar4(1)) 'd'...
                                sprintf('%02.0f', outMsgChar4(2)) char(39)...
                                sprintf('%07.4f', outMsgChar4(3)) char(39) char(39) GLOBAL_newNSEW(1) ', '...
                                sprintf('%03.0f', outMsgChar5(1)) 'd'...
                                sprintf('%02.0f', outMsgChar5(2)) char(39)...
                                sprintf('%07.4f', outMsgChar5(3)) char(39) char(39) GLOBAL_newNSEW(2) ', '...
                                sprintf('%08.02f', GLOBAL_newPosition(3)) 'm' ';' char(13) char(10)];
                        end
                    elseif (GLOBAL_coordinatesType == 3)
                        if (GLOBAL_setTimeUTC == false)
                            outMsgChar = [sprintf(GLOBAL_dataFormat_dd_mm1, mydegrees2dm(GLOBAL_thisPosition(1))) GLOBAL_thisNSEW(1) ', '...
                                sprintf(GLOBAL_dataFormat_dd_mm2, mydegrees2dm(GLOBAL_thisPosition(2))) GLOBAL_thisNSEW(2) ', '...
                                sprintf(GLOBAL_dataFormat3, GLOBAL_thisPosition(3)) 'm' ', ' ...
                                sprintf(GLOBAL_dataFormat_dd_mm1, mydegrees2dm(GLOBAL_newPosition(1))) GLOBAL_newNSEW(1) ', '...
                                sprintf(GLOBAL_dataFormat_dd_mm2, mydegrees2dm(GLOBAL_newPosition(2))) GLOBAL_newNSEW(2) ', '...
                                sprintf(GLOBAL_dataFormat3, GLOBAL_newPosition(3)) 'm' ';' char(13) char(10)];
                        else
                            outMsgChar = [GLOBAL_thisTimeUTC(1:2) 'h' GLOBAL_thisTimeUTC(3:4) 'm' GLOBAL_thisTimeUTC(5:end) 's' ', '...
                                sprintf(GLOBAL_dataFormat_dd_mm1, mydegrees2dm(GLOBAL_thisPosition(1))) GLOBAL_thisNSEW(1) ', '...
                                sprintf(GLOBAL_dataFormat_dd_mm2, mydegrees2dm(GLOBAL_thisPosition(2))) GLOBAL_thisNSEW(2) ', '...
                                sprintf(GLOBAL_dataFormat3, GLOBAL_thisPosition(3)) 'm' ', ' ...
                                sprintf(GLOBAL_dataFormat_dd_mm1, mydegrees2dm(GLOBAL_newPosition(1))) GLOBAL_newNSEW(1) ', '...
                                sprintf(GLOBAL_dataFormat_dd_mm2, mydegrees2dm(GLOBAL_newPosition(2))) GLOBAL_newNSEW(2) ', '...
                                sprintf(GLOBAL_dataFormat3, GLOBAL_newPosition(3)) 'm' ';' char(13) char(10)];
                        end
                    else
                        outMsgChar = ['Error, parameter GLOBAL_coordinatesType set incorrectly (GLOBAL_coordinatesType = 1...3)' char(13) char(10)];
                    end
                otherwise
                    outMsgChar = ['Error, parameter GLOBAL_dataType set incorrectly (GLOBAL_dataType = 1...3)' char(13) char(10)];
            end
            GLOBAL_outMsgPort = uint32(1);
            outArgConfig;
            return
            
        %----------------------------------------------------------------------
        %----------------------------------------------------------------------
        %---------------------- с управляющего устройства --------------------- 
        %----------------------------------------------------------------------
        %----------------------------------------------------------------------
        case 2
            if (getXOR(mainData) == char2bin(hex2dec(checkData)))
                %  изменение параметров фильтра Калмана
                switch (mainData(1:3))
                    case 'KAL'
                        accuracy = uint16(real(str2double(mainData(5:6))));

                        GLOBAL_kalman_F(1) = single(real(str2double(mainData(8+accuracy*0:7+accuracy*1))));
                        GLOBAL_kalman_F(2) = single(real(str2double(mainData(8+accuracy*1:7+accuracy*2))));
                        GLOBAL_kalman_F(3) = single(real(str2double(mainData(8+accuracy*2:7+accuracy*3))));
                        GLOBAL_kalman_F(4) = single(real(str2double(mainData(8+accuracy*3:7+accuracy*4))));
                        GLOBAL_kalman_F(5) = single(real(str2double(mainData(8+accuracy*4:7+accuracy*5))));
                        GLOBAL_kalman_F(6) = single(real(str2double(mainData(8+accuracy*5:7+accuracy*6))));
                        GLOBAL_kalman_F(7) = single(real(str2double(mainData(8+accuracy*6:7+accuracy*7))));
                        GLOBAL_kalman_F(8) = single(real(str2double(mainData(8+accuracy*7:7+accuracy*8))));
                        GLOBAL_kalman_F(9) = single(real(str2double(mainData(8+accuracy*8:7+accuracy*9))));

                        GLOBAL_kalman_G(1) = single(real(str2double(mainData(8+accuracy*9:7+accuracy*10))));
                        GLOBAL_kalman_G(2) = single(real(str2double(mainData(8+accuracy*10:7+accuracy*11))));
                        GLOBAL_kalman_G(3) = single(real(str2double(mainData(8+accuracy*11:7+accuracy*12))));

                        GLOBAL_kalman_H(1) = single(real(str2double(mainData(8+accuracy*12:7+accuracy*13))));
                        GLOBAL_kalman_H(2) = single(real(str2double(mainData(8+accuracy*13:7+accuracy*14))));
                        GLOBAL_kalman_H(3) = single(real(str2double(mainData(8+accuracy*14:7+accuracy*15))));

                        GLOBAL_kalman_Q(1) = single(real(str2double(mainData(8+accuracy*15:7+accuracy*16))));
                        GLOBAL_kalman_Q(2) = single(real(str2double(mainData(8+accuracy*16:7+accuracy*17))));
                        GLOBAL_kalman_Q(3) = single(real(str2double(mainData(8+accuracy*17:7+accuracy*18))));
                        
                        outMsgChar = ['Configuration of Kalman filter changed successfully' char(13) char(10)];
                        
                    %  изменение параметров a-b фильтра
                    case 'ALP'
                        accuracy = uint16(real(str2double(mainData(5:6))));
                        GLOBAL_alpha_Step =     uint32(real(str2double(mainData(8+accuracy*0:7+accuracy*1))));
                        GLOBAL_alpha_Tob =      single(real(str2double(mainData(8+accuracy*1:7+accuracy*2))));
                        GLOBAL_alpha_Predel =   single(real(str2double(mainData(8+accuracy*2:7+accuracy*3))));
                        GLOBAL_alpha_Kb =       single(real(str2double(mainData(8+accuracy*3:7+accuracy*4))));
                        GLOBAL_alpha_Ka =       single(real(str2double(mainData(8+accuracy*4:7+accuracy*5))));
                        GLOBAL_alpha_Kg =       single(real(str2double(mainData(8+accuracy*5:7+accuracy*6))));
                        GLOBAL_alpha_Az =       single(real(str2double(mainData(8+accuracy*6:7+accuracy*7))));
                        GLOBAL_alpha_Vz =       single(real(str2double(mainData(8+accuracy*7:7+accuracy*8))));
                        
                        outMsgChar = ['Configuration of alpha-betha filter changed successfully' char(13) char(10)];
                        
                    %  изменение параметров отправки данных
                    case 'SET'
                        if (mainData == ...
                                "SET,type of sending data,only sputnik data,")
                            GLOBAL_dataType = 1;
                            outMsgChar = ['Configuration changed successfully' char(13) char(10)...
                                'Now transmite only sputnik data' char(13) char(10)];
                        end

                        if (mainData == ...
                                "SET,type of sending data,only filtered data,")
                            GLOBAL_dataType = 2;
                            outMsgChar = ['Configuration changed successfully' char(13) char(10)...
                                'Now transmite only filtered data' char(13) char(10)];
                        end

                        if (mainData == ...
                                "SET,type of sending data,sputnik and filtered data,")
                            GLOBAL_dataType = 3;
                            outMsgChar = ['Configuration changed successfully' char(13) char(10)...
                                'Now transmite sputnik and filtered data' char(13) char(10)];
                        end

                        if (mainData(1:12) == ...
                                "SET,presicio")
                            if (length(mainData) == 33)
                                GLOBAL_dataFormat_dd_dd1(5:6) = mainData(31:32);
                                GLOBAL_dataFormat_dd_dd2(5:6) = mainData(31:32);
                                GLOBAL_dataFormat_dd_mm1(6:7) = mainData(31:32);
                                GLOBAL_dataFormat_dd_mm2(6:7) = mainData(31:32);
                                outMsgChar = ['Configuration changed successfully' char(13) char(10)...
                                    'Now precision of transmite data = ', mainData(31:32) char(13) char(10)];
                            else
                                outMsgChar = ['Precision setting error, check message length, must be 33 chars' char(13) char(10)];
                            end
                        end

                        if (mainData == ...
                                "SET,type of coordinates data,dd.dd,")
                            GLOBAL_coordinatesType = 1;
                            outMsgChar = ['Configuration changed successfully' char(13) char(10)...
                                'Now coordinates transmit like dd.dd' char(13) char(10)];
                        end

                        if (mainData == ...
                                "SET,type of coordinates data,ddmmss.ss,")
                            GLOBAL_coordinatesType = 2;
                            outMsgChar = ['Configuration changed successfully' char(13) char(10)...
                                'Now coordinates transmit like ddmmss.ss' char(13) char(10)];
                        end

                        if (mainData == ...
                                "SET,type of coordinates data,ddmm.mm,")
                            GLOBAL_coordinatesType = 3;
                            outMsgChar = ['Configuration changed successfully' char(13) char(10)...
                                'Now coordinates transmit like ddmm.mm' char(13) char(10)];
                        end

                        if (mainData == ...
                                "SET,add timeUTC,")
                            GLOBAL_setTimeUTC = true;
                            outMsgChar = ['Configuration changed successfully' char(13) char(10)...
                                'Now time UTC transmite' char(13) char(10)];
                        end
                        
                        if (mainData == ...
                                "SET,delete timeUTC,")
                            GLOBAL_setTimeUTC = false;
                            outMsgChar = ['Configuration changed successfully' char(13) char(10)...
                                'Now time UTC dont transmite' char(13) char(10)];
                        end

                        if (mainData(1:12) == ...
                                "SET,default,")
                            GLOBAL_inMsgPort = uint32(1);
                            GLOBAL_outMsgPort = uint32(1);
                            GLOBAL_setTimeUTC = false;
                            GLOBAL_prevTimeUTC = '000000.00';
                            GLOBAL_thisTimeUTC = '000000.00';
                            GLOBAL_prevPosition = single([0 0 0]);
                            GLOBAL_thisPosition = single([0 0 0]);
                            GLOBAL_newPosition  = single([0 0 0]);
                            GLOBAL_thisNSEW = 'NE';
                            GLOBAL_newNSEW = 'NE';
                            GLOBAL_filterType = uint32(1);
                            GLOBAL_dataType = uint32(2);
                            GLOBAL_coordinatesType = uint32(1);
                            GLOBAL_dataFormat_dd_dd1 = '%08.05f';
                            GLOBAL_dataFormat_dd_dd2 = '%09.05f';
                            GLOBAL_dataFormat_dd_mm1 = '%010.05f';
                            GLOBAL_dataFormat_dd_mm2 = '%011.05f';
                            GLOBAL_dataFormat3 = '%08.02f';
                            GLOBAL_kalman_F = single([1 0.1 0.005; 0 1 0.1; 0 0 1]);
                            GLOBAL_kalman_G = single([0.005; 0.1; 1]);
                            GLOBAL_kalman_H = single([1 0 0]);
                            GLOBAL_kalman_Q = single([0 0 0]);
                            GLOBAL_alpha_Step = uint32(0);
                            GLOBAL_alpha_Tob = single(1);
                            GLOBAL_alpha_Predel = single(0);
                            GLOBAL_alpha_Kb = single(0);
                            GLOBAL_alpha_Ka = single(0);
                            GLOBAL_alpha_Kg = single(0);
                            GLOBAL_alpha_Az = single(0);
                            GLOBAL_alpha_Vz = single(0);   
                            outMsgChar = ['All settings are successfully set to default' char(13) char(10)];
                        end
                        
                        if (mainData == ...
                                "SET,type of filtration,kalman,")
                            GLOBAL_filterType = 1;
                            outMsgChar = ['Configuration changed successfully' char(13) char(10)...
                                'Now Kalman filter is set' char(13) char(10)];
                        end
                        
                        if (mainData == ...
                                "SET,type of filtration,alpha,")
                            GLOBAL_filterType = 2;
                            outMsgChar = ['Configuration changed successfully' char(13) char(10)...
                                'Now alpha-beta filter is set' char(13) char(10)];
                        end
                        
                        if (mainData == ...
                                "SET,type of filtration,raw,")
                            GLOBAL_filterType = 3;
                            outMsgChar = ['Configuration changed successfully' char(13) char(10)...
                                'Now raw data transmiting' char(13) char(10)];
                        end
                        
                        if (mainData(1:12) == ...
                                "SET,GLOBAL_i")
                            if (length(mainData) == 23)
                                GLOBAL_inMsgPort = uint32(str2double(mainData(22)));
                                switch (GLOBAL_inMsgPort)
                                    case 1
                                        outMsgChar = ['Configuration changed successfully' char(13) char(10)...
                                            'Now data receiving from sputnik' char(13) char(10)];
                                    case 2
                                        outMsgChar = ['Configuration changed successfully' char(13) char(10)...
                                            'Now data receiving from control device' char(13) char(10)];
                                    otherwise
                                        outMsgChar = ['Error, parameter GLOBAL_inMsgPort set incorrectly (GLOBAL_inMsgPort = 1...2)' char(13) char(10)];
                                            
                                end
                            else
                                outMsgChar = ['Configuration changed error, check message length, must be 23 chars' char(13) char(10)];
                            end
                        end  
                        
                        if mainData(1:12) == ...
                                "SET,previous"
                            if (length(mainData) == 73)
                                GLOBAL_prevPosition(1) = real(single(str2double(mainData(23:38))));
                                GLOBAL_prevPosition(2) = real(single(str2double(mainData(40:55))));
                                GLOBAL_prevPosition(3) = real(single(str2double(mainData(57:72))));
                                if (isinf(GLOBAL_prevPosition(1)) || isnan(GLOBAL_prevPosition(1) ||...
                                    isinf(GLOBAL_prevPosition(2)) || isnan(GLOBAL_prevPosition(2)) ||...
                                    isinf(GLOBAL_prevPosition(3)) || isnan(GLOBAL_prevPosition(3))))
                                    outMsgChar = ['Error, failed to decode the position, try again' char(13) char(10)];
                                else
                                    outMsgChar = ['Configuration of starting position changed successfully' char(13) char(10)];
                                end
                            else
                                outMsgChar = ['Configuration changed error, check message length, must be 73 chars' char(13) char(10)];
                            end
                        end
                    %  если сообщение декодировано не правильно
                    otherwise
                        outMsgChar = ['Error, message is not decoded correctly' char(13) char(10)];
                end
            %  если сообщение не прошло проверку контрольной суммой
            else
                outMsgChar = ['Error, message did not pass checksum check' char(13) char(10)];
            end
        %  если сообщение пришло на неправильный порт (хз как такое возможно)
        otherwise
            outMsgChar = ['Error, the message came to the wrong port' char(13) char(10)];
    end
%  если сообщение пришло некорректным
else
    outMsgChar = ['Error, the message does not correspond to the standard' char(13) char(10)];
end

GLOBAL_outMsgPort = uint32(1);
outArgConfig;
return


%% Конфигурирование выходных аргументов функции:
function outArgConfig
    % outArgFloat, outArgInt, outArgChar, outArgBool
    % BOOL:
    outArgBool = GLOBAL_setTimeUTC;
    
    % CHAR:
    outArgChar(1:9) = GLOBAL_thisTimeUTC;
    outArgChar(10:18) = GLOBAL_thisTimeUTC;
    outArgChar(19:20) = GLOBAL_newNSEW;
    outArgChar(21:22) = GLOBAL_newNSEW;
    outArgChar(23:29) = GLOBAL_dataFormat_dd_dd1;
    outArgChar(30:36) = GLOBAL_dataFormat_dd_dd2;
    outArgChar(37:44) = GLOBAL_dataFormat_dd_mm1;
    outArgChar(45:52) = GLOBAL_dataFormat_dd_mm2;
    outArgChar(53:59) = GLOBAL_dataFormat3;
    
    % INT:
    outArgInt(1) = GLOBAL_inMsgPort;
    outArgInt(2) = GLOBAL_outMsgPort;
    outArgInt(3) = GLOBAL_filterType;
    outArgInt(4) = GLOBAL_dataType;
    outArgInt(5) = GLOBAL_coordinatesType;
    outArgInt(6) = GLOBAL_alpha_Step;
    
    % FLOAT:
    outArgFloat(1:3) = GLOBAL_prevPosition;
    outArgFloat(4:6) = GLOBAL_thisPosition;
    outArgFloat(7:9) = GLOBAL_newPosition;
    outArgFloat(10:18) = GLOBAL_kalman_F;
    outArgFloat(19:21) = GLOBAL_kalman_G;
    outArgFloat(22:24) = GLOBAL_kalman_H;
    outArgFloat(25:27) = GLOBAL_kalman_Q;
    outArgFloat(28) = GLOBAL_alpha_Tob;
    outArgFloat(29) = GLOBAL_alpha_Predel;
    outArgFloat(30) = GLOBAL_alpha_Kb;
    outArgFloat(31) = GLOBAL_alpha_Ka;
    outArgFloat(32) = GLOBAL_alpha_Kg;
    outArgFloat(33) = GLOBAL_alpha_Az;
    outArgFloat(34) = GLOBAL_alpha_Vz;
end

%% Функция получения географических координат и высоты из сообщения
function [lat, NS, long, EW, alt, timeUTC] = getGCS(iData, parId, id)
    %  широта
    latC = iData(parId(id(1))+1:parId(id(1)+1)-1);
    if (sum(find(latC == '.')) < 3)
        lat = GLOBAL_prevPosition(1);
    else
        lat1 = latC(1:sum(find(latC == '.')-3));
        lat2 = latC(sum(find(latC == '.')-2):end);
        lat = single(real(str2double(lat1)) + real(str2double(lat2)/60));
    end

    %  направление широты
    NS = iData(parId(id(2))+1:parId(id(2)+1)-1);
    if (NS ~= "N" && NS ~= "S" && (length(NS) > 1))
        NS = GLOBAL_newNSEW(1);
    end

    %  долгота
    longC = iData(parId(id(3))+1:parId(id(3)+1)-1);
    if (sum(find(longC == '.')) < 3)
        long = GLOBAL_prevPosition(2);
    else
        long1 = longC(1:sum(find(longC == '.')-3));
        long2 = longC(sum(find(longC == '.')-2):end);
        long = single(real(str2double(long1)) + real(str2double(long2)/60)); 
    end

    %  направление долготы
    EW = iData(parId(id(4))+1:parId(id(4)+1)-1);
    if (EW ~= "E" && EW ~= "W" && (length(EW) > 1))
        EW = GLOBAL_newNSEW(2);
    end

    %  высота
    if (id(5) == 0)
        alt = GLOBAL_prevPosition(3);
    else
        alt = real(single(str2double(iData(parId(id(5))+1:parId(id(5)+1)-1))));
    end

    %  время
    if (id(6) == 0)
        timeUTC = GLOBAL_prevTimeUTC;
    else
        timeUTC = iData(parId(id(6))+1:parId(id(6)+1)-1);
    end

    % тест на пидора для lat, long, alt
    if (isinf(lat) || isnan(lat))
        lat = GLOBAL_prevPosition(1);
    end
    if (isinf(long) || isnan(long))
        long = GLOBAL_prevPosition(2);
    end
    if (isinf(alt) || isnan(alt))
        alt = GLOBAL_prevPosition(3);
    end
end

%% Алгоритм Калмана
function filteredData = kalmanFilterExecution(thisData, Q, P)
    FSize = uint32(3);
    X = GLOBAL_kalman_F*thisData' + repmat(GLOBAL_kalman_G, 1, FSize);
    P = GLOBAL_kalman_F*P*GLOBAL_kalman_F' + GLOBAL_kalman_G*Q*GLOBAL_kalman_G';
    M = GLOBAL_kalman_H*P*GLOBAL_kalman_H' + Q;
    K = P*GLOBAL_kalman_H'/(M);
    Z = GLOBAL_kalman_H*X;
    N = thisData' - Z;
    f = (X + K * N)';
    filteredData = f(1);         
end

%% Альфа-бета фильтр
function filteredData = alphaFilterExecution(thisData, P)
    if (GLOBAL_alpha_step == 1)
        GLOBAL_alpha_Vz = 120;  %начальная скорость
        GLOBAL_alpha_Az = 0;    %начальное ускорение
        filteredData = thisData;
    else
        if (GLOBAL_alpha_step == 2)
            GLOBAL_alpha_Vz = (thisData - P)/GLOBAL_alpha_Tob;
            GLOBAL_alpha_Az = 0;
            filteredData = thisData;
        else
            GLOBAL_alpha_Ka = single(2*(2*GLOBAL_alpha_Step - 1)/(GLOBAL_alpha_Step*GLOBAL_alpha_Step + GLOBAL_alpha_Step));
            if(GLOBAL_alpha_Ka < GLOBAL_alpha_Predel) 
                GLOBAL_alpha_Ka = GLOBAL_alpha_Predel;
            end

            GLOBAL_alpha_Kb = 2*(2 - GLOBAL_alpha_Ka) - 4*sqrt(1 - GLOBAL_alpha_Ka);
            GLOBAL_alpha_Kg = GLOBAL_alpha_Kb*GLOBAL_alpha_Kb/(2*GLOBAL_alpha_Ka);

            Zeks = P + GLOBAL_alpha_Vz*GLOBAL_alpha_Tob + GLOBAL_alpha_Az*GLOBAL_alpha_Tob*GLOBAL_alpha_Tob/2;
            filteredData = Zeks + GLOBAL_alpha_Ka*(thisData - Zeks);
            GLOBAL_alpha_Vz = GLOBAL_alpha_Vz + GLOBAL_alpha_Kb/GLOBAL_alpha_Tob*(thisData - Zeks);              %фильтрация скорости
            GLOBAL_alpha_Az = GLOBAL_alpha_Az + (2*GLOBAL_alpha_Kg/(GLOBAL_alpha_Tob*GLOBAL_alpha_Tob))*(thisData - Zeks);    %фильтрация ускорения
        end
    end
end


%% Функция перевода десятичного кода символа ASCII в бинарный
function out = char2bin(userInput)
    strAscii = dec2bin(userInput);
    strAscii = reshape(strAscii', [1, numel(strAscii)]);
    asciiLogicalArray = logical(strAscii - 48);
    out = false(1,8);
    out(end-length(asciiLogicalArray)+1:end) = asciiLogicalArray;
end

%% Логическая операция XOR для типа данных char
function msgXOR = getXOR(msgChar)
    msgXOR = bitxor(char2bin(uint32(msgChar(1))), char2bin(uint32(msgChar(2))));
    for j = uint32(3):uint32(length(msgChar))
        msgXOR = bitxor(msgXOR, char2bin(uint32(msgChar(j))));
    end
end

%% Перевод десятичных градусов в градусы-десятичные минуты
function ddmm = mydegrees2dm(dd_dd)
    dd_dd_floor = floor(dd_dd);
    ddmm = dd_dd_floor*100 + (dd_dd - dd_dd_floor)*60;
end

%% Перевод десятичных градусов в градусы-минуты-секунды
function ddmmss = mydegrees2dms(dd_dd)
    dd = floor(dd_dd);
    mm = (dd_dd - dd)*60;
    ss = (mm - floor(mm))*60;
    ddmmss = [dd floor(mm) ss];
end

end