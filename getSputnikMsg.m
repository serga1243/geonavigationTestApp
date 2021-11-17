function sputnikMsgChar = getSputnikMsg(type, position, NSEW, time)
    position = abs(position);
    if (position(1) > 90)
        position(1) = 90 - mod(position(1), 90);
    end
    if (position(2) > 180)
        position(2) = 180 - mod(position(2), 180);
    end
    if (position(3) >= 1e5)
        position(3) = 99999;
    end
    position(1) = mydegrees2dm(position(1));
    position(2) = mydegrees2dm(position(2));
    time = abs(time);
    if time > 240000
        time = mod(time, 240000);
    end
    tt = sprintf('%09.2f', time);
    switch (type)
        case 'GGA'
            sputnikMsgChar = [getCountry(randi(6)) 'GGA' ',' tt ',' num2str(position(1), '%010.05f') ',' NSEW(1) ',' num2str(position(2),...
                '%011.05f') ',' NSEW(2) ',' codeGen(2, 'n') ',' codeGen(1, 'n') ',' codeGen(2, 'n') ',' num2str(position(3), '%08.2f')...
                ',' codeGen(1, 'l'), ',' codeGen(3, 'n'), ',' codeGen(1, 'l') ','];
            sputnikMsgChar = ['$' sputnikMsgChar '*' getXOR(sputnikMsgChar) char(13) newline];

        case 'GLL'
            sputnikMsgChar = [getCountry(randi(6)) 'GLL' ',' num2str(position(1), '%010.05f') ',' NSEW(1) ',' num2str(position(2),...
                '%011.05f') ',' NSEW(2) ',' tt ',' codeGen(1, 'l') ',' codeGen(1, 'l') ','];
            sputnikMsgChar = ['$' sputnikMsgChar '*' getXOR(sputnikMsgChar) char(13) newline];

        case 'RMA'
            sputnikMsgChar = [getCountry(randi(6)) 'RMA' ',' codeGen(1, 'l') ',' num2str(position(1), '%010.05f') ',' NSEW(1)...
                ',' num2str(position(2), '%011.05f') ',' NSEW(2) ',' codeGen(2, 'n') ',' codeGen(2, 'n') ',' codeGen(2, 'n') ',' ...
                codeGen(2, 'n') ',' codeGen(2, 'n') ','];
            sputnikMsgChar = ['$' sputnikMsgChar '*' getXOR(sputnikMsgChar) char(13) newline];

        case 'RMC'
            sputnikMsgChar = [getCountry(randi(6)) 'RMC' ','  tt ',' codeGen(1, 'l') ',' num2str(position(1), '%010.05f') ',' NSEW(1)...
                ',' num2str(position(2), '%011.05f') ',' NSEW(2) ',' codeGen(4, 'n') ',' codeGen(4, 'n') ',' codeGen(5, 'n') ',' ',' ','];
            sputnikMsgChar = ['$' sputnikMsgChar '*' getXOR(sputnikMsgChar) char(13) newline];

        case 'WPL'
            sputnikMsgChar = [getCountry(randi(6)) 'WPL' ',' num2str(position(1), '%010.05f') ',' NSEW(1)...
                ',' num2str(position(2), '%011.05f') ',' NSEW(2) ','  codeGen(5, 'l') ','];
            sputnikMsgChar = ['$' sputnikMsgChar '*' getXOR(sputnikMsgChar) char(13) newline];

        case 'RMF'
            sputnikMsgChar = ['PG' 'RMF' ',' codeGen(4, 'n') ',' codeGen(5, 'n') ',' codeGen(6, 'n') ',' codeGen(6, 'n') ','...
                codeGen(2, 'n') ',' num2str(position(1), '%010.05f') ',' NSEW(1) ',' num2str(position(2), '%011.05f') ',' NSEW(2) ','...
                codeGen(1, 'l') ',' codeGen(1, 'n') ',' codeGen(3, 'n') ',' codeGen(3, 'n') ',' codeGen(1, 'n') ',' codeGen(1, 'n') ','];
            sputnikMsgChar = ['$' sputnikMsgChar '*' getXOR(sputnikMsgChar) char(13) newline];

        case 'RMI'
            sputnikMsgChar = ['PG' 'RMI' ',' num2str(position(1), '%010.05f') ',' NSEW(1)...
                ',' num2str(position(2), '%011.05f') ',' NSEW(2) ','  codeGen(6, 'l') ',' codeGen(6, 'l') ','];
            sputnikMsgChar = ['$' sputnikMsgChar '*' getXOR(sputnikMsgChar) char(13) newline];
        otherwise
            sputnikMsgChar = getSputnikMsg('GGA', position, NSEW, time);
    end

    function codeChar = codeGen(N, type)
        codeChar = char(zeros([1 N], 'uint8'));
        % Specify what characters you want to use in generating your password
        Ab = ['0' '1' '2' '3' '4' '5' '6' '7'...
              '8' '9' 'A' 'B' 'C' 'D' 'E' 'F'...
              'G' 'H' 'I' 'J' 'K' 'L' 'M' 'N'...
              'O' 'P' 'Q' 'R' 'S' 'T' 'U' 'V'...
              'W' 'X' 'Y' 'Z'];
        if type == 'n'
            Abcd = Ab(1:10);
            Ablen = length(Abcd);
        elseif type == 'l'
            Abcd = Ab(11:end);
            Ablen = length(Abcd);
        else
            Abcd = Ab;
            Ablen = length(Abcd);
        end
        for i = 1:N
            inp = uint16(rand*65535);
            cod = randi([1 Ablen], 'like', inp);
            codeChar(i) = Abcd(cod);
        end
    end
    % Получить инфо о стране
    function country = getCountry(N)
        if N > 6
            N = 6;
        end
        aaa = ['GP'; 'GL'; 'GA'; 'BD'; 'GQ'; 'GN'];
        country = aaa(N,:);
    end
    % Функция перевода десятичного кода символа ASCII в бинарный
    function out = char2bin(userInput)
        strAscii = dec2bin(userInput);
        strAscii = reshape(strAscii', [1, numel(strAscii)]);
        asciiLogicalArray = logical(strAscii - 48);
        out = false(1,8);
        out(end-length(asciiLogicalArray)+1:end) = asciiLogicalArray;
    end

    % Логическая операция XOR для типа данных char
    function msgXORChar = getXOR(msgChar)
        msgXOR = bitxor(char2bin(uint8(msgChar(1))),...
            char2bin(uint8(msgChar(2))));
        for j = uint8(3):uint8(length(msgChar))
            msgXOR = bitxor(msgXOR, char2bin(uint8(msgChar(j))));
        end

        msgXORChar = char([48 48 48 48 48 48 48 48]);
        for i = 1:8
            if (msgXOR(i) == true)
                msgXORChar(i) = '1';
            end
        end
        msgXORChar = dec2hex(bin2dec(msgXORChar), 2);
    end
    % Перевод десятичных градусов в градусы-десятичные минуты
    function ddmm = mydegrees2dm(dd_dd)
        dd_dd_floor = floor(dd_dd);
        ddmm = dd_dd_floor*100 + (dd_dd - dd_dd_floor)*60;
    end
end