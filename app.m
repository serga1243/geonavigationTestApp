classdef app < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure              matlab.ui.Figure
        Menu                  matlab.ui.container.Menu
        importMenu            matlab.ui.container.Menu
        importFromFile        matlab.ui.container.Menu
        uploadingMenu         matlab.ui.container.Menu
        Menu_6                matlab.ui.container.Menu
        Menu_3                matlab.ui.container.Menu
        Menu_4                matlab.ui.container.Menu
        Menu_5                matlab.ui.container.Menu
        Menu_7                matlab.ui.container.Menu
        Menu_8                matlab.ui.container.Menu
        helpMenu              matlab.ui.container.Menu
        aboutProgrammMenu     matlab.ui.container.Menu
        exitMenu              matlab.ui.container.Menu
        mainTabGroup          matlab.ui.container.TabGroup
        mapBrowser            matlab.ui.container.Tab
        mapSwitch             matlab.ui.container.TabGroup
        mapAxesTab            matlab.ui.container.Tab
        mapAxes               matlab.ui.container.Panel
        Label_20              matlab.ui.control.Label
        mapZoom               matlab.ui.control.Slider
        uploadingCheck_1      matlab.ui.control.CheckBox
        ButtonGroup           matlab.ui.container.ButtonGroup
        mapbluegreen          matlab.ui.control.RadioButton
        mapdarkwater          matlab.ui.control.RadioButton
        maplandcover          matlab.ui.control.RadioButton
        traectoryAxesTab      matlab.ui.container.Tab
        traectoryAxes         matlab.ui.container.Panel
        Label_17              matlab.ui.control.Label
        traectorySwitch       matlab.ui.control.Switch
        uploadingCheck_2      matlab.ui.control.CheckBox
        positionErrorBrowser  matlab.ui.container.Tab
        lat                   matlab.ui.control.UIAxes
        long                  matlab.ui.control.UIAxes
        sumaryError           matlab.ui.control.UIAxes
        alt                   matlab.ui.control.UIAxes
        uploadingCheck_6      matlab.ui.control.CheckBox
        uploadingCheck_7      matlab.ui.control.CheckBox
        uploadingCheck_8      matlab.ui.control.CheckBox
        uploadingCheck_9      matlab.ui.control.CheckBox
        contolComandsBrowser  matlab.ui.container.Tab
        sendingData           matlab.ui.container.ButtonGroup
        sputnikData           matlab.ui.control.RadioButton
        filteredData          matlab.ui.control.RadioButton
        sputnikFilteredData   matlab.ui.control.RadioButton
        filterType            matlab.ui.container.ButtonGroup
        kalmanFilter          matlab.ui.control.RadioButton
        alphaFilter           matlab.ui.control.RadioButton
        rawData               matlab.ui.control.RadioButton
        coordinatesType       matlab.ui.container.ButtonGroup
        dd_dd                 matlab.ui.control.RadioButton
        dd_mm_mm              matlab.ui.control.RadioButton
        dd_mm_ss_ss           matlab.ui.control.RadioButton
        Label                 matlab.ui.control.Label
        dataPresicion         matlab.ui.control.NumericEditField
        Label_2               matlab.ui.control.Label
        addTime               matlab.ui.control.Switch
        EditFieldLabel        matlab.ui.control.Label
        EditField             matlab.ui.control.EditField
        kalmanConfigTable     matlab.ui.control.Table
        alphaConfigTable      matlab.ui.control.Table
        Label_14              matlab.ui.control.Label
        errorContolLat        matlab.ui.control.Slider
        Label_15              matlab.ui.control.Label
        errorContolLong       matlab.ui.control.Slider
        setDefault            matlab.ui.control.Button
        Label_16              matlab.ui.control.Label
        errorContolAlt        matlab.ui.control.Slider
        BACKButton            matlab.ui.control.Button
        STARTButton           matlab.ui.control.Button
        FINISHButton          matlab.ui.control.Button
        Label_10              matlab.ui.control.Label
        goToTime              matlab.ui.control.NumericEditField
        Label_12              matlab.ui.control.Label
        timeDuration          matlab.ui.control.EditField
        Label_13              matlab.ui.control.Label
        itDuration            matlab.ui.control.EditField
        PAUSEButton           matlab.ui.control.StateButton
        FORWARDButton         matlab.ui.control.Button
        mapAxesData           matlab.ui.control.Table
        Label_11              matlab.ui.control.Label
        pauseBetwenIt         matlab.ui.control.NumericEditField
        Label_18              matlab.ui.control.Label
        fromSputnik           matlab.ui.control.TextArea
        Label_19              matlab.ui.control.Label
        toFilter              matlab.ui.control.TextArea
        uploadingCheck_3      matlab.ui.control.CheckBox
        uploadingCheck_4      matlab.ui.control.CheckBox
        uploadingCheck_5      matlab.ui.control.CheckBox
        Label_34              matlab.ui.control.Label
        generalSpeed          matlab.ui.control.NinetyDegreeGauge
        Label_33              matlab.ui.control.Label
        generalAcceleration   matlab.ui.control.NinetyDegreeGauge
        itDuration_2          matlab.ui.control.EditField
        timeDuration_2        matlab.ui.control.EditField
        speedLabel            matlab.ui.control.Label
        accelerationLabel     matlab.ui.control.Label
        startImagePanel       matlab.ui.container.Panel
        startImageAxes        matlab.ui.control.UIAxes
        startLabel            matlab.ui.control.Label
    end

    
    properties (Access = public)
        gx
        tx
        programm_i                 uint64
        programm_dt                double
        programm_t                 double
        programm_r                 double
        inMsgChar                  char
        outMsgChar                 char
        inArgBool                  
        inArgChar                  char
        inArgInt                   int32
        inArgFloat                 single
        speed                      double
        acceleration               double
        dXdYdZ                double
        sumaryErrorData                double
        nonFilteredGCS             double
        filteredGCS                double
        pauseTime                  double
        msgIt                      uint8
        linearErrorLat                double
        linearErrorLong                double
        linearErrorAlt                double
        wgs84
        fromSputnikMsgs            string
        toFilterMsgs               string  
        plotFiltLat
        plotFiltLong
        plotFiltAlt
        plotAbsErrorLat
        plotAbsErrorLong
        plotAbsErrorAlt
        plotMeanErrorLat
        plotMeanErrorLong
        plotMeanErrorAlt
        sumaryMeanErrorData
        refTraectoryGeo
        nonFiltTraectoryGeo
        filtTraectoryGeo
        refTraectoryPlot
        nonFiltTraectoryPlot
        filtTraectoryPlot
    end
    
    methods (Access = private)
        function goModeling(app)
            
                switch(1)
                    case 1
                        type = 'GGA';
                    case 2
                        type = 'GLL';
                    case 3
                        type = 'RMA';
                    case 4
                        type = 'RMC';
                    case 5
                        type = 'WPL';
                    case 6
                        type = 'RMF';
                    case 7
                        type = 'RMI';
                end
                app.inArgInt(1) = int32(1);
                
                % добавление метровых порешности к геоцентрицеским координатам
                [X, Y, Z] = geodetic2ecef(app.wgs84, app.programm_r(1,app.programm_i), app.programm_r(2,app.programm_i), app.programm_r(3,app.programm_i));
                X = app.addError(X, app.linearErrorLat);
                Y = app.addError(Y, app.linearErrorLong);
                Z = app.addError(Z, app.linearErrorAlt);
                
                [thislat, thislon, thisalt] = ecef2geodetic(app.wgs84, X, Y, Z);
                
                app.inMsgChar = getSputnikMsg(type, [thislat thislon thisalt], 'NE', app.programm_t(app.programm_i));
                
                
                [app.outMsgChar, app.inArgFloat, app.inArgInt, app.inArgChar, app.inArgBool] = ...
                    globalNavigator(app.inMsgChar, app.inArgFloat, app.inArgInt, app.inArgChar, app.inArgBool);
                
                [app.dXdYdZ(1), app.dXdYdZ(2), app.dXdYdZ(3)] = ...
                    ecefOffset(app.wgs84, app.programm_r(1,app.programm_i), app.programm_r(2,app.programm_i), app.programm_r(3,app.programm_i),...
                    app.inArgFloat(7), app.inArgFloat(8), app.inArgFloat(9));
                app.sumaryErrorData(:,app.programm_i) = abs(app.dXdYdZ);
                app.sumaryMeanErrorData(:,app.programm_i) = mean(app.sumaryErrorData(:,1:app.programm_i), 2);
                
                          
                app.speed(1) = app.speed(2);
                [thisdX, thisdY, thisdZ] = ecefOffset(app.wgs84, app.inArgFloat(1), app.inArgFloat(2), app.inArgFloat(3),...
                     app.inArgFloat(7), app.inArgFloat(8), app.inArgFloat(9));
                app.speed(2) = norm([thisdX, thisdY, thisdZ])/app.programm_dt;
                app.acceleration = (app.speed(2) - app.speed(1))/app.programm_dt/9.8;
                
                
                app.generalSpeed.Value = abs(app.speed(2));
                app.generalAcceleration.Value = abs(app.acceleration);
                
                if (app.uploadingCheck_5.Value)
                    app.mapAxesData.Data.Var2(1) = convertCharsToStrings(num2str(app.inArgFloat(9), '%08.2f'));
                    app.mapAxesData.Data.Var2(2) = convertCharsToStrings(num2str(app.inArgFloat(7), '%010.6f'));
                    app.mapAxesData.Data.Var2(3) = convertCharsToStrings(num2str(app.inArgFloat(8), '%010.6f'));
                    app.mapAxesData.Data.Var3(2) = convertCharsToStrings(num2str(app.mydegrees2dm(app.inArgFloat(7)), '%012.6f'));
                    app.mapAxesData.Data.Var3(3) = convertCharsToStrings(num2str(app.mydegrees2dm(app.inArgFloat(8)), '%012.6f'));
                    ddmmss1 = app.mydegrees2dms(app.inArgFloat(7));
                    ddmmss2 = app.mydegrees2dms(app.inArgFloat(8));
                    app.mapAxesData.Data.Var4(2) = convertCharsToStrings([num2str(ddmmss1(1), '%08.2f') '°' num2str(ddmmss1(2), '%02.0f') char(39) num2str(ddmmss1(3), '%07.4f') char(39) ' ' app.inArgChar(21)]);
                    app.mapAxesData.Data.Var4(3) = convertCharsToStrings([num2str(ddmmss2(1), '%08.2f') '°' num2str(ddmmss2(2), '%02.0f') char(39) num2str(ddmmss2(3), '%07.4f') char(39) ' ' app.inArgChar(22)]);
                end
                
                app.itDuration.Value = num2str(app.programm_i-1);
                app.timeDuration.Value = num2str(app.programm_t(app.programm_i));
    
                
                app.setTablesData(app.inMsgChar, app.outMsgChar);
                
                app.nonFilteredGCS(:,app.programm_i) = app.inArgFloat(4:6);
                app.filteredGCS(:,app.programm_i) = app.inArgFloat(7:9);
                app.inArgFloat(1:3) = app.inArgFloat(4:6);
                
                app.showMap;
                app.showError;
                
                pause(app.pauseTime);
            
        end
    
        
        function setTablesData(app, data1, data2)
%             i = mod(app.programm_i, 64);
            app.fromSputnikMsgs(2:end) = app.fromSputnikMsgs(1:end-1);
            app.toFilterMsgs(2:end) = app.toFilterMsgs(1:end-1);
            app.fromSputnikMsgs(1) = data1;
            app.toFilterMsgs(1) = data2;
            if (app.uploadingCheck_3.Value)
                app.fromSputnik.Value = app.fromSputnikMsgs;
            end
            if (app.uploadingCheck_4.Value)
                app.toFilter.Value = app.toFilterMsgs;    
            end
        end
        
        function showError(app)
            if (app.uploadingCheck_6.Value)
                app.plotFiltLat.XData = app.programm_t(1:app.programm_i);
                app.plotFiltLat.YData = app.filteredGCS(1,1:app.programm_i);
                app.plotAbsErrorLat.XData = app.programm_t(1:app.programm_i);
                app.plotAbsErrorLat.YData = app.sumaryErrorData(1,1:app.programm_i);              
            end
            if (app.uploadingCheck_8.Value)
                app.plotFiltLong.XData = app.programm_t(1:app.programm_i);
                app.plotFiltLong.YData = app.filteredGCS(2,1:app.programm_i);
                app.plotAbsErrorLong.XData = app.programm_t(1:app.programm_i);
                app.plotAbsErrorLong.YData = app.sumaryErrorData(2,1:app.programm_i);    
            end
            if (app.uploadingCheck_7.Value)
                app.plotFiltAlt.XData = app.programm_t(1:app.programm_i);
                app.plotFiltAlt.YData = app.filteredGCS(3,1:app.programm_i);
                app.plotAbsErrorAlt.XData = app.programm_t(1:app.programm_i);
                app.plotAbsErrorAlt.YData = app.sumaryErrorData(3,1:app.programm_i);     
            end
            if (app.uploadingCheck_9.Value)
                app.plotMeanErrorLat.XData = app.programm_t(1:app.programm_i);
                app.plotMeanErrorLat.YData = app.sumaryMeanErrorData(1,1:app.programm_i);  
                
                app.plotMeanErrorLong.XData = app.programm_t(1:app.programm_i);
                app.plotMeanErrorLong.YData = app.sumaryMeanErrorData(2,1:app.programm_i);  
                
                app.plotMeanErrorAlt.XData = app.programm_t(1:app.programm_i);
                app.plotMeanErrorAlt.YData = app.sumaryMeanErrorData(3,1:app.programm_i);  
            end
        end
    
        function showMap(app)
            if (app.mapSwitch.SelectedTab == app.mapAxesTab && app.uploadingCheck_1.Value)

                app.refTraectoryGeo.XData = app.programm_r(1,1:app.programm_i);
                app.refTraectoryGeo.YData = app.programm_r(2,1:app.programm_i);
                
                app.filtTraectoryGeo.XData = app.filteredGCS(1,1:app.programm_i);
                app.filtTraectoryGeo.YData = app.filteredGCS(2,1:app.programm_i);
                
                app.nonFiltTraectoryGeo.XData = app.nonFilteredGCS(1,1:app.programm_i);
                app.nonFiltTraectoryGeo.YData = app.nonFilteredGCS(2,1:app.programm_i);
                
                app.gx.MapCenter = [app.programm_r(1,app.programm_i), app.programm_r(2,app.programm_i)];
            elseif (app.mapSwitch.SelectedTab == app.traectoryAxesTab && app.traectorySwitch.Value == "да" && app.uploadingCheck_2.Value)
                app.nonFiltTraectoryPlot.Visible = 'on';
                app.filtTraectoryPlot.Visible = 'on';
                
                app.refTraectoryPlot.XData = app.programm_r(1,1:app.programm_i);
                app.refTraectoryPlot.YData = app.programm_r(2,1:app.programm_i);
                app.refTraectoryPlot.ZData = app.programm_r(3,1:app.programm_i);
                
                app.nonFiltTraectoryPlot.XData = app.nonFilteredGCS(1,1:app.programm_i);
                app.nonFiltTraectoryPlot.YData = app.nonFilteredGCS(2,1:app.programm_i);
                app.nonFiltTraectoryPlot.ZData = app.nonFilteredGCS(3,1:app.programm_i);
                
                app.filtTraectoryPlot.XData = app.filteredGCS(1,1:app.programm_i);
                app.filtTraectoryPlot.YData = app.filteredGCS(2,1:app.programm_i);
                app.filtTraectoryPlot.ZData = app.filteredGCS(3,1:app.programm_i);
            elseif (app.mapSwitch.SelectedTab == app.traectoryAxesTab && app.traectorySwitch.Value == "нет" && app.uploadingCheck_2.Value)
                app.nonFiltTraectoryPlot.Visible = 'off';
                app.filtTraectoryPlot.Visible = 'off';
                
                app.refTraectoryPlot.XData = app.programm_r(1,1:app.programm_i);
                app.refTraectoryPlot.YData = app.programm_r(2,1:app.programm_i);
                app.refTraectoryPlot.ZData = app.programm_r(3,1:app.programm_i);
            end
        end
        
        function setKalmanAlphaTablesData(app, type)
            switch (type)
                case "kalman"
                    app.kalmanConfigTable.Data.Var2 =  double(...
                                                       [app.inArgFloat(10); app.inArgFloat(13); app.inArgFloat(16);...
                                                        app.inArgFloat(19); app.inArgFloat(22); app.inArgFloat(25);]);
                    app.kalmanConfigTable.Data.Var3 =  double(...
                                                       [app.inArgFloat(11); app.inArgFloat(14); app.inArgFloat(17);...
                                                        app.inArgFloat(20); app.inArgFloat(23); app.inArgFloat(26);]);
                    app.kalmanConfigTable.Data.Var4 =  double(...
                                                       [app.inArgFloat(12); app.inArgFloat(15); app.inArgFloat(18);...
                                                        app.inArgFloat(21); app.inArgFloat(24); app.inArgFloat(27);]);
                case "alpha"
                    app.alphaConfigTable.Data.Var2 = double([app.inArgInt(6); app.inArgFloat(28); app.inArgFloat(29); app.inArgFloat(30);]);
                    app.alphaConfigTable.Data.Var4 = double([app.inArgFloat(31); app.inArgFloat(32); app.inArgFloat(33); app.inArgFloat(34);]);
                otherwise
                    app.setKalmanAlphaTablesData("kalman");
                    app.setKalmanAlphaTablesData("alpha");
            end
        end
    end
    
    methods (Access = private, Static)
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

            function out = char2bin(userInput)
                strAscii = dec2bin(userInput);
                strAscii = reshape(strAscii', [1, numel(strAscii)]);
                asciiLogicalArray = logical(strAscii - 48);
                out = false(1,8);
                out(end-length(asciiLogicalArray)+1:end) = asciiLogicalArray;
            end
        end
    
        % Перевод десятичных градусов в градусы-десятичные минуты
        function ddmm = mydegrees2dm(dd_dd)
            dd_dd_floor = floor(dd_dd);
            ddmm = dd_dd_floor*100 + (dd_dd - dd_dd_floor)*60;
        end
        
        % Перевод десятичных градусов в градусы-минуты-секунды
        function ddmmss = mydegrees2dms(dd_dd)
            dd = floor(dd_dd);
            mm = (dd_dd - dd)*60;
            ss = (mm - floor(mm))*60;
            ddmmss = [dd floor(mm) ss];
        end
    
        % Добавление погрешности координат
        function X = addError(X, sigma)
            X = X + randn*sigma;
        end
    end
    

    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % Начальная заставка (почему бы и нет?)
            function [Data, mu, sigma] = MyMultiNormRND(n, d, k)
            Data = zeros([n d k], 'double');
            
            mu = zeros([1 d k], 'double');
            sigma =  zeros([d d k], 'double');    
                for j = 1:k
                    mu(1,:,j) = (rand([1 d])*k)*k;
                    sigma(:,:,j) = eye(d);
                    sigma(find(sigma == 1,round(d/2))) = (rand() + 1)*k;
                    sigma(find(sigma == 1,d)) = (rand() + 0.25)*k;
                    sigma(find(sigma == 0,d)) = rand();
                    
                    fprintf('%f\n%f\n',...
                    mu(1,:,j), sigma(:,:,j));
                    
                    Data(:,:,j) = mvnrnd(mu(1,:,j), sigma(:,:,j), n);
                    Data(:,1,j) = Data(:,1,j) + randn(n, 1)*100;
                    Data(:,2,j) = Data(:,2,j) + randn(n, 1)*56.25;
%                     Data(:,1,j) = 1920*Data(:,1,j)/max(Data(:,1,j));
%                     Data(:,2,j) = 1080*Data(:,2,j)/max(Data(:,2,j));
                    
                end
            end
            %thisimg = imread('C:\Users\Sergey\OneDrive\Documents\Доки\5th\coronaProject\startImage3.png');
            kk = 20;
            thisimg = MyMultiNormRND(1, 2, kk);
            pause(0.5);     
            for jj = 1:kk
                scatter(app.startImageAxes, thisimg(:,1,jj), thisimg(:,2,jj), randi([2e2 1.1e4]), 'filled', 'LineWidth', 1e-9,...
                    'MarkerEdgeAlpha', 0, 'MarkerFaceAlpha', 0.75);
                hold(app.startImageAxes, 'on');
            end
            hold(app.startImageAxes, 'off');
            app.startImagePanel.Visible = 'on';
            pause(2);
            
            
            % Настройка параметров фильтра
            app.inArgBool = false;
            % CHAR:
            app.inArgChar(1:9)   = '000000.00';
            app.inArgChar(10:18) = '000000.00';
            app.inArgChar(19:20) = 'NE';
            app.inArgChar(21:22) = 'NE';
            app.inArgChar(23:29) = '%08.05f';
            app.inArgChar(30:36) = '%09.05f';
            app.inArgChar(37:44) = '%010.05f';
            app.inArgChar(45:52) = '%011.05f';
            app.inArgChar(53:59) = '%08.02f';
            % INT:
            app.inArgInt(1) = int32(2);
            app.inArgInt(2) = int32(1);
            app.inArgInt(3) = int32(1);
            app.inArgInt(4) = int32(2);
            app.inArgInt(5) = int32(1);
            app.inArgInt(6) = int32(1);
            % FLOAT:
            app.inArgFloat(1:3) = single([0 0 0]);
            app.inArgFloat(4:6) = single([0 0 0]);
            app.inArgFloat(7:9) = single([0 0 0]);
            app.inArgFloat(10:18) = single([1 0.1 0.005; 0 1 0.1; 0 0 1]);
            app.inArgFloat(19:21) = single([0.005; 0.1; 1]);
            app.inArgFloat(22:24) = single([1 0 0]);
            app.inArgFloat(25:27) = single([0 0 0]);
            app.inArgFloat(28) = single(0);
            app.inArgFloat(29) = single(0);
            app.inArgFloat(30) = single(0);
            app.inArgFloat(31) = single(0);
            app.inArgFloat(32) = single(0);
            app.inArgFloat(33) = single(0);
            app.inArgFloat(34) = single(0);
            
            % Главный счетчик программы
            app.programm_i = uint64(0);
            
            % Сброс настроек фильтра
            [app.outMsgChar, app.inArgFloat, app.inArgInt, app.inArgChar, app.inArgBool] = ...
                globalNavigator(['$SET,default,*29' char(13) newline], app.inArgFloat, app.inArgInt, app.inArgChar, app.inArgBool);
            
            
            % Координаты и скорости
            app.dXdYdZ = zeros(1, 3, 'double');
            app.speed = zeros(1, 2, 'double');
            app.itDuration.Value = '0';
            app.timeDuration.Value = '0';
            
            % Настройка таблиц
            app.fromSputnikMsgs = repmat(" ", 64, 1);
            app.toFilterMsgs = repmat(" ", 64, 1);
            app.mapAxesData.Data = table(["Высота"; "Широта"; "Долгота";], ["0"; "0"; "0";],...
                                         [""; "0"; "0";], [""; "0"; "0";]);
            app.kalmanConfigTable.Data = table(["матрица F(1:3,1) :"; "матрица F(1:3,2) :"; "матрица F(1:3,3) :"; "вектор  G(1:3,1) :"; "вектор  H(1,1:3) :"; "вектор  Q(1,1:3) :";],...
                                         [double(app.inArgFloat(10)); double(app.inArgFloat(11)); double(app.inArgFloat(12)); double(app.inArgFloat(19)); double(app.inArgFloat(22)); double(app.inArgFloat(25))],...
                                         [double(app.inArgFloat(13)); double(app.inArgFloat(14)); double(app.inArgFloat(15)); double(app.inArgFloat(20)); double(app.inArgFloat(23)); double(app.inArgFloat(26))],...
                                         [double(app.inArgFloat(16)); double(app.inArgFloat(17)); double(app.inArgFloat(18)); double(app.inArgFloat(21)); double(app.inArgFloat(24)); double(app.inArgFloat(27))]);
            app.alphaConfigTable.Data  = table(["STEP   :"; "TOB    :"; "PREDEL :"; "KB     :";],...
                                         [double(app.inArgInt(6)); double(app.inArgFloat(28)); double(app.inArgFloat(29)); double(app.inArgFloat(30))],...
                                         ["KA     :"; "KG     :"; "AZ     :"; "VZ     :";],...
                                         [double(app.inArgFloat(31)); double(app.inArgFloat(32)); double(app.inArgFloat(33)); double(app.inArgFloat(34))]);
          
                                         
       
            % Загрузка карты   
            app.gx = geoaxes(app.mapAxes);
            app.gx.InnerPosition = [0 0 1 1];  
            app.refTraectoryGeo = geoplot(app.gx, 0, 0);
            app.gx.Basemap = 'bluegreen';
            app.gx.ZoomLevel = 3;
            app.refTraectoryGeo.LineWidth = 1.5;
            hold(app.gx, 'on');
            app.nonFiltTraectoryGeo = geoplot(app.gx, 0, 0);
            app.nonFiltTraectoryGeo.LineWidth = 1.5;
            hold(app.gx, 'on');
            app.filtTraectoryGeo = geoplot(app.gx, 0, 0);
            app.filtTraectoryGeo.LineWidth = 1.5;
            hold(app.gx, 'off');
            legend(app.gx, 'реальная траектория', 'траектория со спутника', 'траектория со спутника фильтрованная');
            grid(app.gx, 'on');
            
            app.tx = uiaxes(app.traectoryAxes);      
            app.tx.Position = [1 59 1918 732];
            app.refTraectoryPlot = plot3(app.tx, 0, 0, 0);
            app.refTraectoryPlot.LineWidth = 1.5;
            hold(app.tx, 'on');
            app.nonFiltTraectoryPlot = plot3(app.tx, 0, 0, 0);
            app.nonFiltTraectoryPlot.LineWidth = 1.5;
            hold(app.tx, 'on');
            app.filtTraectoryPlot = plot3(app.tx, 0, 0, 0);
            app.filtTraectoryPlot.LineWidth = 1.5;
            hold(app.tx, 'off');
            legend(app.tx, 'labels ', ["реальная траектория", "траектория со спутника", "траектория со спутника фильтрованная"],...
                'location', 'northeast');
            grid(app.tx, 'on');
                        
            % Сообщения
%             app.msgIt = uint8(9);
            app.fromSputnik.Value = "";
            app.toFilter.Value = app.fromSputnik.Value;
%             app.msgIt = uint8(0);
            
            % Погрешность координат
            app.linearErrorLat = 0;
            app.linearErrorLong = 0;
            app.linearErrorAlt = 0;
            
            % Графики
            yyaxis(app.lat, 'left');
            app.plotFiltLat = plot(app.lat, 0);
            app.plotFiltLat.LineWidth = 1.5;
            yyaxis(app.lat, 'right');
            app.plotAbsErrorLat = plot(app.lat, 0);
            app.plotAbsErrorLat.LineWidth = 1.0;
            ylim(app.lat, [0 100]);
            legend(app.lat, 'широта, град', 'абсолютная погрешность фильтрации, м');
            
            yyaxis(app.long, 'left');
            app.plotFiltLong = plot(app.long, 0);
            app.plotFiltLong.LineWidth = 1.5;
            yyaxis(app.long, 'right');
            app.plotAbsErrorLong = plot(app.long, 0);
            app.plotAbsErrorLong.LineWidth = 1.0;
            ylim(app.long, [0 100]);
            legend(app.long, 'долгота, град', 'абсолютная погрешность фильтрации, м');
            
            yyaxis(app.alt, 'left');
            app.plotFiltAlt = plot(app.alt, 0);
            app.plotFiltAlt.LineWidth = 1.5;
            yyaxis(app.alt, 'right');
            app.plotAbsErrorAlt = plot(app.alt, 0);
            app.plotAbsErrorAlt.LineWidth = 1.0;
            ylim(app.alt, [0 100]);
            legend(app.alt, 'высота, м', 'абсолютная погрешность фильтрации, м');
            
            app.plotMeanErrorLat = plot(app.sumaryError, 0);
            app.plotMeanErrorLat.LineWidth = 1.0;
            app.plotMeanErrorLong = plot(app.sumaryError, 0);
            app.plotMeanErrorLong.LineWidth = 1.0;
            app.plotMeanErrorAlt = plot(app.sumaryError, 0);
            app.plotMeanErrorAlt.LineWidth = 1.0;
            ylim(app.sumaryError, [0 100]);
            legend(app.sumaryError, 'широта', 'долгота', 'высота');
            grid(app.sumaryError, 'on');
            
            
            app.wgs84 = wgs84Ellipsoid('meters');
            
            
            % Время между шагами моделирования
            app.pauseTime = 0.1;
            app.startImagePanel.Visible = 'off';
            pause(1);
            clear app.startImagePanel app.startImageAxes app.thisimg
               
            app.UIFigure.WindowState = 'fullscreen';  
        end

        % Value changed function: goToTime
        function goToTimeValueChanged(app, event)
            app.programm_i = app.goToTime.Value;  
            app.itDuration.Value = num2str(app.goToTime.Value);
            app.timeDuration.Value = num2str(app.programm_i*app.programm_dt);
        end

        % Value changed function: EditField
        function EditFieldValueChanged(app, event)
            app.inArgInt(1) = int32(2);
            [app.outMsgChar, app.inArgFloat, app.inArgInt, app.inArgChar, app.inArgBool] = ...
                globalNavigator([app.EditField.Value char(13) char(10)], app.inArgFloat, app.inArgInt, app.inArgChar, app.inArgBool);
            app.setTablesData(app.inMsgChar, app.outMsgChar);
            app.inArgInt(1) = int32(1);
        end

        % Cell edit callback: kalmanConfigTable
        function kalmanConfigTableCellEdit(app, event)
            indices = event.Indices;
            newData = event.NewData;
            
            if (indices(1,1) == 1)
                switch (indices(1,2))
                    case 2
                        app.inArgFloat(10) = newData;
                    case 3
                        app.inArgFloat(11) = newData;
                    case 4
                        app.inArgFloat(12) = newData;
                end
            end
            if (indices(1,1) == 2)
                switch (indices(1,2))
                    case 2
                        app.inArgFloat(13) = newData;
                    case 3
                        app.inArgFloat(14) = newData;
                    case 4
                        app.inArgFloat(15) = newData;
                end
            end
            if (indices(1,1) == 3)
                switch (indices(1,2))
                    case 2
                        app.inArgFloat(16) = newData;
                    case 3
                        app.inArgFloat(17) = newData;
                    case 4
                        app.inArgFloat(18) = newData;
                end
            end
            if (indices(1,1) == 4)
                switch (indices(1,2))
                    case 2
                        app.inArgFloat(19) = newData;
                    case 3
                        app.inArgFloat(20) = newData;
                    case 4
                        app.inArgFloat(21) = newData;
                end
            end
            if (indices(1,1) == 5)
                switch (indices(1,2))
                    case 2
                        app.inArgFloat(22) = newData;
                    case 3
                        app.inArgFloat(23) = newData;
                    case 4
                        app.inArgFloat(24) = newData;
                end
            end
            if (indices(1,1) == 6)
                switch (indices(1,2))
                    case 2
                        app.inArgFloat(25) = newData;
                    case 3
                        app.inArgFloat(26) = newData;
                    case 4
                        app.inArgFloat(27) = newData;
                end
            end

            MsgChar1 = sprintf('KAL,12,%1.6e%1.6e%1.6e%1.6e%1.6e%1.6e%1.6e%1.6e%1.6e%1.6e%1.6e%1.6e%1.6e%1.6e%1.6e%1.6e%1.6e%1.6e%1.6e,',...
                app.inArgFloat(10), app.inArgFloat(11), app.inArgFloat(12),...
                app.inArgFloat(13), app.inArgFloat(14), app.inArgFloat(15),...
                app.inArgFloat(16), app.inArgFloat(17), app.inArgFloat(18),...
                app.inArgFloat(19), app.inArgFloat(20), app.inArgFloat(21),...
                app.inArgFloat(22), app.inArgFloat(23), app.inArgFloat(24),...
                app.inArgFloat(25), app.inArgFloat(26), app.inArgFloat(27));
            MsgChar1 = ['$' MsgChar1 '*' sprintf('%s', app.getXOR(MsgChar1)) char(13) newline];
            
            app.inArgInt(1) = 2;
            [app.outMsgChar, app.inArgFloat, app.inArgInt, app.inArgChar, app.inArgBool] = ...
                globalNavigator(MsgChar1, app.inArgFloat, app.inArgInt, app.inArgChar, app.inArgBool);
            app.inArgInt(1) = 1;
            
            app.setKalmanAlphaTablesData("kalman");
            
            app.setTablesData('', app.outMsgChar);
        end

        % Cell edit callback: alphaConfigTable
        function alphaConfigTableCellEdit(app, event)
            indices = event.Indices;
            newData = event.NewData;
            
            if (indices(1,2) == 2)
                switch (indices(1,1))
                    case 1
                        app.inArgInt(6) = newData;
                    case 2
                        app.inArgFloat(28) = newData;
                    case 3
                        app.inArgFloat(29) = newData;
                    case 4
                        app.inArgFloat(30) = newData;
                end
            end
            if (indices(1,2) == 4)
                switch (indices(1,1))
                    case 1
                        app.inArgFloat(31) = newData;
                    case 2
                        app.inArgFloat(32) = newData;
                    case 3
                        app.inArgFloat(33) = newData;
                    case 4
                        app.inArgFloat(34) = newData;
                end
            end
            
            MsgChar2 = sprintf('ALP,12,%1.6e%1.6e%1.6e%1.6e%1.6e%1.6e%1.6e%1.6e,',...
                app.inArgInt(6), app.inArgFloat(28), app.inArgFloat(29), app.inArgFloat(30),...
                app.inArgFloat(31), app.inArgFloat(32), app.inArgFloat(33), app.inArgFloat(34));
            MsgChar2 = ['$' MsgChar2 '*' sprintf('%s', app.getXOR(MsgChar2)) char(13) newline];
            
            app.inArgInt(1) = 2;
            [app.outMsgChar, app.inArgFloat, app.inArgInt, app.inArgChar, app.inArgBool] = ...
                globalNavigator(MsgChar2, app.inArgFloat, app.inArgInt, app.inArgChar, app.inArgBool);
            app.inArgInt(1) = 1;
            
            app.setKalmanAlphaTablesData("alpha");
            
            app.setTablesData('', app.outMsgChar);
        end

        % Callback function
        function importFromWorkspaceMenuSelected(app, event)
            function textChanged(txt1, txt2, fig)
                app.programm_r = load(txt2.Value);
                app.programm_dt = txt1.Value;
                app.programm_t = linspace(0, app.programm_dt*(size(app.programm_r, 2) - 1), size(app.programm_r, 2));
                app.filteredGCS = zeros(size(app.programm_r), 'double');
                app.nonFilteredGCS = zeros(size(app.programm_r), 'double');
                app.filteredGCS(:,1) = app.inArgFloat(1:3);
                close(fig);
            end
            fig = uifigure('Position', [500 500 430 275]);
            fig.Name = 'Import data from workspace';
            txt1 = uieditfield(fig,...
              'Position',[100 375 100 22]);
            txt2 = uieditfield(fig,...
              'Position',[100 175 100 22],...
              'ValueChangedFcn',@(txt2, event) textChanged(txt1, txt2, fig));

          
        end

        % Menu selected function: importFromFile
        function importFromFileMenuSelected(app, event)
            function textEntered(textarea, fig)
                app.programm_i = 0;
                app.programm_dt = textarea.Value;
                app.programm_t = linspace(0, app.programm_dt*(size(app.programm_r, 2) - 1), size(app.programm_r, 2));
                app.filteredGCS = zeros(size(app.programm_r), 'double');
                app.nonFilteredGCS = zeros(size(app.programm_r), 'double');
                app.sumaryErrorData = zeros(size(app.programm_r), 'double');
                app.sumaryMeanErrorData = zeros(size(app.programm_r), 'double');
                app.filteredGCS(:,1) = app.inArgFloat(1:3);
                app.itDuration_2.Value = num2str(length(app.programm_t));
                app.timeDuration_2.Value = num2str(app.programm_t(end));
                
                close(fig);
            end
            file = uigetfile('*.mat');
            data = load(file);
            app.programm_r = data.pos;
            pause(0.5);
            fig = uifigure(app.UIFigure, 'Position', [500 500 480 240]);
            fig.Name = 'Импорт данных из файла';
            lbl = uilabel(fig, 'Position', [60 130 360 40],'FontSize', 16,...
                'HorizontalAlignment', 'center', 'Text', 'Укажите дискрету времени в сек.');
            textarea = uieditfield(fig,'numeric',...
                'Position',[150 60 180 60], 'FontSize', 16, ...
                'ValueChangedFcn',@(textarea,event) textEntered(textarea, fig)); 
            
            app.inArgFloat(1:3) = app.programm_r(:,1);
            app.inArgInt(1) = int32(1);
        end

        % Button pushed function: BACKButton
        function BACKButtonPushed(app, event)
            app.programm_i =app.programm_i - 1;
            app.goModeling;
        end

        % Button pushed function: FINISHButton
        function FINISHButtonPushed(app, event)
            app.programm_i = length(app.programm_t);
        end

        % Button pushed function: STARTButton
        function STARTButtonPushed(app, event)
            app.programm_i = 0;
        end

        % Selection changed function: sendingData
        function sendingDataSelectionChanged(app, event)
            app.inArgInt(1) = int32(2);
            switch (app.sendingData.SelectedObject.Text)
                case "не фильтрованные данные"
                    app.inMsgChar = ['$SET,type of sending data,only sputnik data,*59' char(13) newline];
                case "фильтрованные данные"
                    app.inMsgChar = ['$SET,type of sending data,only filtered data,*36' char(13) newline];
                case "оба типа"
                    app.inMsgChar = ['$SET,type of sending data,sputnik and filtered data,*07' char(13) newline];
            end
            [app.outMsgChar, app.inArgFloat, app.inArgInt, app.inArgChar, app.inArgBool] = ...
                globalNavigator(app.inMsgChar, app.inArgFloat, app.inArgInt, app.inArgChar, app.inArgBool);
            app.setTablesData(app.inMsgChar, app.outMsgChar);
            app.inArgInt(1) = int32(1);          
        end

        % Selection changed function: filterType
        function filterTypeSelectionChanged(app, event)
            app.inArgInt(1) = int32(2);
            switch (app.filterType.SelectedObject.Text)
                case "фильтр Калмана"
                    app.inMsgChar = ['$SET,type of filtration,kalman,*63' char(13) newline];
                case "альфа-бета фильтр"
                    app.inMsgChar = ['$SET,type of filtration,alpha,*13' char(13) newline];
                case "сырые данные"
                    app.inMsgChar = ['$SET,type of filtration,raw,*03' char(13) newline];
            end
            [app.outMsgChar, app.inArgFloat, app.inArgInt, app.inArgChar, app.inArgBool] = ...
                globalNavigator(app.inMsgChar, app.inArgFloat, app.inArgInt, app.inArgChar, app.inArgBool);
            app.setTablesData(app.inMsgChar, app.outMsgChar);
            app.inArgInt(1) = int32(1);
        end

        % Selection changed function: coordinatesType
        function coordinatesTypeSelectionChanged(app, event)
            app.inArgInt(1) = int32(2);
            switch (app.coordinatesType.SelectedObject.Text)
                case "десятичные градусы"
                    app.inMsgChar = ['$SET,type of coordinates data,dd.dd,*10' char(13) newline];
                case "градусы и десятичные минуты"
                    app.inMsgChar = ['$SET,type of coordinates data,ddmm.mm,*10' char(13) newline];
                case "градусы минуты секунды"
                    app.inMsgChar = ['$SET,type of coordinates data,ddmmss.ss,*10' char(13) newline];
            end
            [app.outMsgChar, app.inArgFloat, app.inArgInt, app.inArgChar, app.inArgBool] = ...
                globalNavigator(app.inMsgChar, app.inArgFloat, app.inArgInt, app.inArgChar, app.inArgBool);
            app.setTablesData(app.inMsgChar, app.outMsgChar);
            app.inArgInt(1) = int32(1);
        end

        % Value changed function: addTime
        function addTimeValueChanged(app, event)
            app.inArgInt(1) = int32(2);
            switch (app.addTime.Value)
                case "да"
                    app.inMsgChar = ['$SET,add timeUTC,*54' char(13) newline];
                case "нет"
                    app.inMsgChar = ['$SET,delete timeUTC,*2C' char(13) newline];
            end
            [app.outMsgChar, app.inArgFloat, app.inArgInt, app.inArgChar, app.inArgBool] = ...
                globalNavigator(app.inMsgChar, app.inArgFloat, app.inArgInt, app.inArgChar, app.inArgBool);
            app.setTablesData(app.inMsgChar, app.outMsgChar);
            app.inArgInt(1) = int32(1);
        end

        % Value changed function: dataPresicion
        function dataPresicionValueChanged(app, event)
            app.inArgInt(1) = int32(2);
            app.inMsgChar = ['SET,presicion of sending data,' sprintf('%02i', app.dataPresicion.Value) ','];
            app.inMsgChar = ['$' app.inMsgChar '*' app.getXOR(app.inMsgChar) char(13) newline];
            [app.outMsgChar, app.inArgFloat, app.inArgInt, app.inArgChar, app.inArgBool] = ...
                globalNavigator(app.inMsgChar, app.inArgFloat, app.inArgInt, app.inArgChar, app.inArgBool);
            app.setTablesData(app.inMsgChar, app.outMsgChar);
            app.inArgInt(1) = int32(1);
        end

        % Value changed function: PAUSEButton
        function PAUSEButtonValueChanged(app, event)
            app.PAUSEButton.Text = 'Пауза';
            while (app.PAUSEButton.Value && app.programm_i <= length(app.programm_t)-1)
                app.programm_i = app.programm_i + 1;
                app.goModeling;
            end
            app.PAUSEButton.Text = 'Старт';
        end

        % Button pushed function: FORWARDButton
        function FORWARDButtonPushed(app, event)
            app.programm_i = app.programm_i + 1;
            app.goModeling;
        end

        % Value changed function: pauseBetwenIt
        function pauseBetwenItValueChanged(app, event)
            app.pauseTime = app.pauseBetwenIt.Value;          
        end

        % Value changed function: mapZoom
        function mapZoomValueChanged(app, event)
            app.gx.ZoomLevel = app.mapZoom.Value;
        end

        % Value changed function: errorContolLat
        function errorContolLatValueChanged(app, event)
           app.linearErrorLat = app.errorContolLat.Value;        
        end

        % Value changed function: errorContolLong
        function errorContolLongValueChanged(app, event)
            app.linearErrorLong = app.errorContolLong.Value;    
        end

        % Value changed function: errorContolAlt
        function errorContolAltValueChanged(app, event)
            app.linearErrorAlt = app.errorContolAlt.Value;       
        end

        % Button pushed function: setDefault
        function setDefaultButtonPushed(app, event)
            app.inArgInt(1) = int32(2);
            app.inMsgChar = ['$SET,default,*29' char(13) newline];
            [app.outMsgChar, app.inArgFloat, app.inArgInt, app.inArgChar, app.inArgBool] = ...
                globalNavigator(app.inMsgChar, app.inArgFloat, app.inArgInt, app.inArgChar, app.inArgBool);
            app.setTablesData(app.inMsgChar, app.outMsgChar);
            
%             msg = sprintf('SET,previous position,%016.0f,%016.0f,%016.10f,', app.inArgFloat(1), app.inArgFloat(2), app.inArgFloat(3));
%             msg = ['$' msg '*' sprintf('%s', app.getXOR(msg)) char(13) newline];
%             
%             [app.outMsgChar, app.inArgFloat, app.inArgInt, app.inArgChar, app.inArgBool] = ...
%                 globalNavigator(msg, app.inArgFloat, app.inArgInt, app.inArgChar, app.inArgBool);
            app.inArgFloat(1:3) = app.programm_r(:,app.programm_i);
            app.setKalmanAlphaTablesData("both");
            app.inArgInt(1) = int32(1);
        end

        % Value changed function: traectorySwitch
        function traectorySwitchValueChanged(app, event)
            value = app.traectorySwitch.Value;
            app.showMap;
        end

        % Menu selected function: Menu_6
        function Menu_6Selected(app, event)
            switch (app.Menu_6.Checked)
                case "on"
                    app.uploadingCheck_1.Value = false;
                    app.uploadingCheck_2.Value = false;
                    app.uploadingCheck_3.Value = false;
                    app.uploadingCheck_4.Value = false;
                    app.uploadingCheck_5.Value = false;
                    app.uploadingCheck_6.Value = false;
                    app.uploadingCheck_7.Value = false;
                    app.uploadingCheck_8.Value = false;
                    app.uploadingCheck_9.Value = false;
                    app.Menu_6.Checked = "off";
                    app.Menu_3.Checked = "off";
                    app.Menu_4.Checked = "off";
                    app.Menu_5.Checked = "off";
                    app.Menu_7.Checked = "off";
                    app.Menu_8.Checked = "off";
                case "off"
                    app.uploadingCheck_1.Value = true;
                    app.uploadingCheck_2.Value = true;
                    app.uploadingCheck_3.Value = true;
                    app.uploadingCheck_4.Value = true;
                    app.uploadingCheck_5.Value = true;
                    app.uploadingCheck_6.Value = true;
                    app.uploadingCheck_7.Value = true;
                    app.uploadingCheck_8.Value = true;
                    app.uploadingCheck_9.Value = true;
                    app.Menu_6.Checked = "on";
                    app.Menu_3.Checked = "on";
                    app.Menu_4.Checked = "on";
                    app.Menu_5.Checked = "on";
                    app.Menu_7.Checked = "on";
                    app.Menu_8.Checked = "on";
            end
                
        end

        % Menu selected function: Menu_3
        function Menu_3Selected(app, event)
            switch (app.Menu_3.Checked)
                case "on"
                    app.uploadingCheck_1.Value = false;
                    app.Menu_3.Checked = "off";
                case "off"
                    app.uploadingCheck_1.Value = true;
                    app.Menu_3.Checked = "on";
            end
            
        end

        % Menu selected function: Menu_4
        function Menu_4Selected(app, event)
            switch (app.Menu_4.Checked)
                case "on"
                    app.uploadingCheck_2.Value = false;
                    app.Menu_4.Checked = "off";
                case "off"
                    app.uploadingCheck_2.Value = true;
                    app.Menu_4.Checked = "on";
            end
        end

        % Menu selected function: Menu_5
        function Menu_5Selected(app, event)
            switch (app.Menu_5.Checked)
                case "on"
                    app.uploadingCheck_3.Value = false;
                    app.uploadingCheck_4.Value = false;
                    app.Menu_5.Checked = "off";
                case "off"
                    app.uploadingCheck_3.Value = true;
                    app.uploadingCheck_4.Value = true;
                    app.Menu_5.Checked = "on";
            end
        end

        % Menu selected function: Menu_7
        function Menu_7Selected(app, event)
            switch (app.Menu_7.Checked)
                case "on"
                    app.uploadingCheck_5.Value = false;
                    app.Menu_7.Checked = "off";
                case "off"
                    app.uploadingCheck_5.Value = true;
                    app.Menu_7.Checked = "on";
            end
        end

        % Menu selected function: Menu_8
        function Menu_8Selected(app, event)
            switch (app.Menu_8.Checked)
                case "on"
                    app.uploadingCheck_6.Value = false;
                    app.uploadingCheck_7.Value = false;
                    app.uploadingCheck_8.Value = false;
                    app.uploadingCheck_9.Value = false;
                    app.Menu_8.Checked = "off";
                case "off"
                    app.uploadingCheck_6.Value = true;
                    app.uploadingCheck_7.Value = true;
                    app.uploadingCheck_8.Value = true;
                    app.uploadingCheck_9.Value = true;
                    app.Menu_8.Checked = "on";
            end
        end

        % Menu selected function: exitMenu
        function exitMenuSelected(app, event)
            app.delete;
        end

        % Menu selected function: aboutProgrammMenu
        function aboutProgrammMenuSelected(app, event)
            fig = uifigure('Position', [500 500 480 94]);
            fig.Name = 'О программе';
            txt.TextArea = uitextarea(fig);
            txt.TextArea.HorizontalAlignment = 'center';
            txt.TextArea.FontSize = 16;
            txt.TextArea.Position = [15 15 450 64];
            txt.TextArea.Value = {'Программа для моделирования движения объекта по сигналам от ГССН и фильтрация этих сигналов';...
                'Разработал: Сергей Мехоношин в 2021 г. по заказу ЮУрГУ'};

        end

        % Selection changed function: ButtonGroup
        function ButtonGroupSelectionChanged(app, event)
            switch (app.ButtonGroup.SelectedObject.Text)
                case "Darkwater" 
                    app.gx.Basemap = 'darkwater';
                    pause(1);
                case "Bluegreen"
                    app.gx.Basemap = 'bluegreen';
                    pause(1);
                case "Landcover"
                    app.gx.Basemap = 'landcover';
                    pause(1);
            end
        end

        % Menu selected function: helpMenu
        function helpMenuSelected(app, event)
            fig = uifigure('Position', [500,500,715,165]);
            fig.Name = 'Помощь';
            txt.TextArea = uitextarea(fig);
            txt.TextArea.HorizontalAlignment = 'left';
            txt.TextArea.FontSize = 16;
            txt.TextArea.Position = [15 15 685 135];
            txt.TextArea.Value ={'1. Откройте меню выберите "Импорт" "Из файла" и укажите .mat файл с траекторией';...
                '(размерность файла 3 x число отчетов)';...
                '2. Появится окно где нужно указать промежуток времени через который замерялись координаты';...
                '3.Дальше лень писать было)'};
        end
    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure
            app.UIFigure = uifigure;
            app.UIFigure.Position = [0 80 1920 1000];
            app.UIFigure.Name = 'Моделирование фильтрации траектории движения объекта';

            % Create Menu
            app.Menu = uimenu(app.UIFigure);
            app.Menu.Text = 'Меню';

            % Create importMenu
            app.importMenu = uimenu(app.Menu);
            app.importMenu.Text = 'Импорт';

            % Create importFromFile
            app.importFromFile = uimenu(app.importMenu);
            app.importFromFile.MenuSelectedFcn = createCallbackFcn(app, @importFromFileMenuSelected, true);
            app.importFromFile.Text = 'Из файла';

            % Create uploadingMenu
            app.uploadingMenu = uimenu(app.Menu);
            app.uploadingMenu.Text = 'Обновлять';

            % Create Menu_6
            app.Menu_6 = uimenu(app.uploadingMenu);
            app.Menu_6.MenuSelectedFcn = createCallbackFcn(app, @Menu_6Selected, true);
            app.Menu_6.Checked = 'on';
            app.Menu_6.Text = 'Все';
            app.Menu_6.Interruptible = 'off';

            % Create Menu_3
            app.Menu_3 = uimenu(app.uploadingMenu);
            app.Menu_3.MenuSelectedFcn = createCallbackFcn(app, @Menu_3Selected, true);
            app.Menu_3.Checked = 'on';
            app.Menu_3.Text = 'Карту';
            app.Menu_3.Interruptible = 'off';

            % Create Menu_4
            app.Menu_4 = uimenu(app.uploadingMenu);
            app.Menu_4.MenuSelectedFcn = createCallbackFcn(app, @Menu_4Selected, true);
            app.Menu_4.Checked = 'on';
            app.Menu_4.Text = 'Траекторию';
            app.Menu_4.Interruptible = 'off';

            % Create Menu_5
            app.Menu_5 = uimenu(app.uploadingMenu);
            app.Menu_5.MenuSelectedFcn = createCallbackFcn(app, @Menu_5Selected, true);
            app.Menu_5.Checked = 'on';
            app.Menu_5.Text = 'Сообщения';
            app.Menu_5.Interruptible = 'off';

            % Create Menu_7
            app.Menu_7 = uimenu(app.uploadingMenu);
            app.Menu_7.MenuSelectedFcn = createCallbackFcn(app, @Menu_7Selected, true);
            app.Menu_7.Checked = 'on';
            app.Menu_7.Text = 'Координаты';
            app.Menu_7.Interruptible = 'off';

            % Create Menu_8
            app.Menu_8 = uimenu(app.uploadingMenu);
            app.Menu_8.MenuSelectedFcn = createCallbackFcn(app, @Menu_8Selected, true);
            app.Menu_8.Checked = 'on';
            app.Menu_8.Text = 'Графики траекторий и ошибки';
            app.Menu_8.Interruptible = 'off';

            % Create helpMenu
            app.helpMenu = uimenu(app.Menu);
            app.helpMenu.MenuSelectedFcn = createCallbackFcn(app, @helpMenuSelected, true);
            app.helpMenu.Text = 'Помощь';

            % Create aboutProgrammMenu
            app.aboutProgrammMenu = uimenu(app.Menu);
            app.aboutProgrammMenu.MenuSelectedFcn = createCallbackFcn(app, @aboutProgrammMenuSelected, true);
            app.aboutProgrammMenu.Text = 'О программе';

            % Create exitMenu
            app.exitMenu = uimenu(app.Menu);
            app.exitMenu.MenuSelectedFcn = createCallbackFcn(app, @exitMenuSelected, true);
            app.exitMenu.Text = 'Выход';

            % Create mainTabGroup
            app.mainTabGroup = uitabgroup(app.UIFigure);
            app.mainTabGroup.Position = [0 219 1920 842];

            % Create mapBrowser
            app.mapBrowser = uitab(app.mainTabGroup);
            app.mapBrowser.Title = 'Карта и траектория';

            % Create mapSwitch
            app.mapSwitch = uitabgroup(app.mapBrowser);
            app.mapSwitch.Position = [0 1 1920 815];

            % Create mapAxesTab
            app.mapAxesTab = uitab(app.mapSwitch);
            app.mapAxesTab.Title = 'Карта мира';

            % Create mapAxes
            app.mapAxes = uipanel(app.mapAxesTab);
            app.mapAxes.Position = [2 1 1918 790];

            % Create Label_20
            app.Label_20 = uilabel(app.mapAxes);
            app.Label_20.HorizontalAlignment = 'right';
            app.Label_20.FontSize = 14;
            app.Label_20.Position = [1274 18 137 22];
            app.Label_20.Text = 'Приближение карты';

            % Create mapZoom
            app.mapZoom = uislider(app.mapAxes);
            app.mapZoom.Limits = [0 20];
            app.mapZoom.ValueChangedFcn = createCallbackFcn(app, @mapZoomValueChanged, true);
            app.mapZoom.FontSize = 14;
            app.mapZoom.Position = [652 37 606 3];
            app.mapZoom.Value = 3;

            % Create uploadingCheck_1
            app.uploadingCheck_1 = uicheckbox(app.mapAxes);
            app.uploadingCheck_1.Interruptible = 'off';
            app.uploadingCheck_1.Text = 'Обновлять';
            app.uploadingCheck_1.Position = [1831 18 83 22];
            app.uploadingCheck_1.Value = true;

            % Create ButtonGroup
            app.ButtonGroup = uibuttongroup(app.mapAxes);
            app.ButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @ButtonGroupSelectionChanged, true);
            app.ButtonGroup.TitlePosition = 'centertop';
            app.ButtonGroup.Title = 'Отображение карты';
            app.ButtonGroup.BackgroundColor = [1 1 1];
            app.ButtonGroup.FontSize = 14;
            app.ButtonGroup.Position = [16 16 146 106];

            % Create mapbluegreen
            app.mapbluegreen = uiradiobutton(app.ButtonGroup);
            app.mapbluegreen.Text = 'Bluegreen';
            app.mapbluegreen.FontSize = 14;
            app.mapbluegreen.Position = [11 58 86 22];
            app.mapbluegreen.Value = true;

            % Create mapdarkwater
            app.mapdarkwater = uiradiobutton(app.ButtonGroup);
            app.mapdarkwater.Text = 'Darkwater';
            app.mapdarkwater.FontSize = 14;
            app.mapdarkwater.Position = [11 36 86 22];

            % Create maplandcover
            app.maplandcover = uiradiobutton(app.ButtonGroup);
            app.maplandcover.Text = 'Landcover';
            app.maplandcover.FontSize = 14;
            app.maplandcover.Position = [11 14 87 22];

            % Create traectoryAxesTab
            app.traectoryAxesTab = uitab(app.mapSwitch);
            app.traectoryAxesTab.Title = 'Траектория';

            % Create traectoryAxes
            app.traectoryAxes = uipanel(app.traectoryAxesTab);
            app.traectoryAxes.Position = [2 1 1918 790];

            % Create Label_17
            app.Label_17 = uilabel(app.traectoryAxes);
            app.Label_17.HorizontalAlignment = 'center';
            app.Label_17.FontSize = 14;
            app.Label_17.Position = [1031 18 332 22];
            app.Label_17.Text = 'Отображать траекторию со спутника и с фильтра';

            % Create traectorySwitch
            app.traectorySwitch = uiswitch(app.traectoryAxes, 'slider');
            app.traectorySwitch.Items = {'нет', 'да'};
            app.traectorySwitch.ValueChangedFcn = createCallbackFcn(app, @traectorySwitchValueChanged, true);
            app.traectorySwitch.FontSize = 14;
            app.traectorySwitch.Position = [930 15 57 25];
            app.traectorySwitch.Value = 'нет';

            % Create uploadingCheck_2
            app.uploadingCheck_2 = uicheckbox(app.traectoryAxes);
            app.uploadingCheck_2.Interruptible = 'off';
            app.uploadingCheck_2.Text = 'Обновлять';
            app.uploadingCheck_2.Position = [1831 18 83 22];
            app.uploadingCheck_2.Value = true;

            % Create positionErrorBrowser
            app.positionErrorBrowser = uitab(app.mainTabGroup);
            app.positionErrorBrowser.Title = 'Координаты и погрешность';

            % Create lat
            app.lat = uiaxes(app.positionErrorBrowser);
            title(app.lat, 'Широта °')
            xlabel(app.lat, 'Время моделирования t сек')
            ylabel(app.lat, '   ')
            app.lat.PlotBoxAspectRatio = [1 0.38 0.9];
            app.lat.YLim = [0 90];
            app.lat.ColorOrder = [0 0.4471 0.7412;0.851 0.3255 0.098;0.4902 0.1804 0.5608;0.4667 0.6745 0.1882;0.302 0.7451 0.9333;0.6353 0.0784 0.1843;1 1 1];
            app.lat.Box = 'on';
            app.lat.NextPlot = 'add';
            app.lat.XGrid = 'on';
            app.lat.YGrid = 'on';
            app.lat.Position = [1 408 960 408];

            % Create long
            app.long = uiaxes(app.positionErrorBrowser);
            title(app.long, 'Долгота °')
            xlabel(app.long, 'Время моделирования t сек')
            ylabel(app.long, '   ')
            app.long.PlotBoxAspectRatio = [1 0.38 0.9];
            app.long.YLim = [0 180];
            app.long.ColorOrder = [0 0.4471 0.7412;0.851 0.3255 0.098;0.4902 0.1804 0.5608;0.4667 0.6745 0.1882;0.302 0.7451 0.9333;0.6353 0.0784 0.1843;1 1 1];
            app.long.Box = 'on';
            app.long.NextPlot = 'add';
            app.long.XGrid = 'on';
            app.long.YGrid = 'on';
            app.long.Position = [956 408 960 408];

            % Create sumaryError
            app.sumaryError = uiaxes(app.positionErrorBrowser);
            title(app.sumaryError, 'Средняя погрешность измерения положения объекта')
            xlabel(app.sumaryError, 'Время моделирования t сек')
            ylabel(app.sumaryError, '   ')
            app.sumaryError.PlotBoxAspectRatio = [1 0.38 0.9];
            app.sumaryError.YLim = [0 100];
            app.sumaryError.Box = 'on';
            app.sumaryError.NextPlot = 'add';
            app.sumaryError.XGrid = 'on';
            app.sumaryError.YGrid = 'on';
            app.sumaryError.Position = [956 1 944 408];

            % Create alt
            app.alt = uiaxes(app.positionErrorBrowser);
            title(app.alt, 'Высота м')
            xlabel(app.alt, 'Время моделирования t сек')
            ylabel(app.alt, '   ')
            app.alt.PlotBoxAspectRatio = [1 0.38 0.9];
            app.alt.YLim = [0 100000];
            app.alt.ColorOrder = [0 0.4471 0.7412;0.851 0.3255 0.098;0.4902 0.1804 0.5608;0.4667 0.6745 0.1882;0.302 0.7451 0.9333;0.6353 0.0784 0.1843;1 1 1];
            app.alt.Box = 'on';
            app.alt.NextPlot = 'add';
            app.alt.XGrid = 'on';
            app.alt.YGrid = 'on';
            app.alt.Position = [1 1 960 408];

            % Create uploadingCheck_6
            app.uploadingCheck_6 = uicheckbox(app.positionErrorBrowser);
            app.uploadingCheck_6.Interruptible = 'off';
            app.uploadingCheck_6.Text = 'Обновлять';
            app.uploadingCheck_6.Position = [874 794 83 22];
            app.uploadingCheck_6.Value = true;

            % Create uploadingCheck_7
            app.uploadingCheck_7 = uicheckbox(app.positionErrorBrowser);
            app.uploadingCheck_7.Interruptible = 'off';
            app.uploadingCheck_7.Text = 'Обновлять';
            app.uploadingCheck_7.Position = [874 386 83 22];
            app.uploadingCheck_7.Value = true;

            % Create uploadingCheck_8
            app.uploadingCheck_8 = uicheckbox(app.positionErrorBrowser);
            app.uploadingCheck_8.Interruptible = 'off';
            app.uploadingCheck_8.Text = 'Обновлять';
            app.uploadingCheck_8.Position = [1825 794 83 22];
            app.uploadingCheck_8.Value = true;

            % Create uploadingCheck_9
            app.uploadingCheck_9 = uicheckbox(app.positionErrorBrowser);
            app.uploadingCheck_9.Interruptible = 'off';
            app.uploadingCheck_9.Text = 'Обновлять';
            app.uploadingCheck_9.Position = [1825 386 83 22];
            app.uploadingCheck_9.Value = true;

            % Create contolComandsBrowser
            app.contolComandsBrowser = uitab(app.mainTabGroup);
            app.contolComandsBrowser.Title = 'Настройка фильтра и моделирования';

            % Create sendingData
            app.sendingData = uibuttongroup(app.contolComandsBrowser);
            app.sendingData.SelectionChangedFcn = createCallbackFcn(app, @sendingDataSelectionChanged, true);
            app.sendingData.TitlePosition = 'centertop';
            app.sendingData.Title = 'Что передавать?';
            app.sendingData.Position = [24 651 400 106];

            % Create sputnikData
            app.sputnikData = uiradiobutton(app.sendingData);
            app.sputnikData.Text = 'не фильтрованные данные';
            app.sputnikData.Position = [11 60 173 22];
            app.sputnikData.Value = true;

            % Create filteredData
            app.filteredData = uiradiobutton(app.sendingData);
            app.filteredData.Text = 'фильтрованные данные';
            app.filteredData.Position = [11 38 157 22];

            % Create sputnikFilteredData
            app.sputnikFilteredData = uiradiobutton(app.sendingData);
            app.sputnikFilteredData.Text = 'оба типа';
            app.sputnikFilteredData.Position = [11 16 71 22];

            % Create filterType
            app.filterType = uibuttongroup(app.contolComandsBrowser);
            app.filterType.SelectionChangedFcn = createCallbackFcn(app, @filterTypeSelectionChanged, true);
            app.filterType.TitlePosition = 'centertop';
            app.filterType.Title = 'Как фильтровать?';
            app.filterType.Position = [24 529 400 106];

            % Create kalmanFilter
            app.kalmanFilter = uiradiobutton(app.filterType);
            app.kalmanFilter.Text = 'фильтр Калмана';
            app.kalmanFilter.Position = [11 60 115 22];
            app.kalmanFilter.Value = true;

            % Create alphaFilter
            app.alphaFilter = uiradiobutton(app.filterType);
            app.alphaFilter.Text = 'альфа-бета фильтр';
            app.alphaFilter.Position = [11 38 132 22];

            % Create rawData
            app.rawData = uiradiobutton(app.filterType);
            app.rawData.Text = 'сырые данные';
            app.rawData.Position = [11 16 104 22];

            % Create coordinatesType
            app.coordinatesType = uibuttongroup(app.contolComandsBrowser);
            app.coordinatesType.SelectionChangedFcn = createCallbackFcn(app, @coordinatesTypeSelectionChanged, true);
            app.coordinatesType.TitlePosition = 'centertop';
            app.coordinatesType.Title = 'Тип передаваемых координат';
            app.coordinatesType.Position = [24 398 400 106];

            % Create dd_dd
            app.dd_dd = uiradiobutton(app.coordinatesType);
            app.dd_dd.Text = 'десятичные градусы';
            app.dd_dd.Position = [11 60 137 22];
            app.dd_dd.Value = true;

            % Create dd_mm_mm
            app.dd_mm_mm = uiradiobutton(app.coordinatesType);
            app.dd_mm_mm.Text = 'градусы и десятичные минуты';
            app.dd_mm_mm.Position = [11 38 193 22];

            % Create dd_mm_ss_ss
            app.dd_mm_ss_ss = uiradiobutton(app.coordinatesType);
            app.dd_mm_ss_ss.Text = 'градусы минуты секунды';
            app.dd_mm_ss_ss.Position = [11 16 162 22];

            % Create Label
            app.Label = uilabel(app.contolComandsBrowser);
            app.Label.HorizontalAlignment = 'right';
            app.Label.Position = [139 361 171 22];
            app.Label.Text = 'Точность координат и высоты';

            % Create dataPresicion
            app.dataPresicion = uieditfield(app.contolComandsBrowser, 'numeric');
            app.dataPresicion.Limits = [1 32];
            app.dataPresicion.ValueDisplayFormat = '%2.i';
            app.dataPresicion.ValueChangedFcn = createCallbackFcn(app, @dataPresicionValueChanged, true);
            app.dataPresicion.Position = [25 327 399 22];
            app.dataPresicion.Value = 1;

            % Create Label_2
            app.Label_2 = uilabel(app.contolComandsBrowser);
            app.Label_2.HorizontalAlignment = 'center';
            app.Label_2.Position = [110 277 116 22];
            app.Label_2.Text = 'Передавать время?';

            % Create addTime
            app.addTime = uiswitch(app.contolComandsBrowser, 'slider');
            app.addTime.Items = {'нет', 'да'};
            app.addTime.ValueChangedFcn = createCallbackFcn(app, @addTimeValueChanged, true);
            app.addTime.Position = [274 278 45 20];
            app.addTime.Value = 'нет';

            % Create EditFieldLabel
            app.EditFieldLabel = uilabel(app.contolComandsBrowser);
            app.EditFieldLabel.HorizontalAlignment = 'right';
            app.EditFieldLabel.Position = [166 227 115 22];
            app.EditFieldLabel.Text = 'Отправить команду';

            % Create EditField
            app.EditField = uieditfield(app.contolComandsBrowser, 'text');
            app.EditField.ValueChangedFcn = createCallbackFcn(app, @EditFieldValueChanged, true);
            app.EditField.Position = [24 78 399 150];

            % Create kalmanConfigTable
            app.kalmanConfigTable = uitable(app.contolComandsBrowser);
            app.kalmanConfigTable.ColumnName = {'Настройка фильтра Калмана'; ''; ''; ''};
            app.kalmanConfigTable.RowName = {};
            app.kalmanConfigTable.ColumnEditable = true;
            app.kalmanConfigTable.CellEditCallback = createCallbackFcn(app, @kalmanConfigTableCellEdit, true);
            app.kalmanConfigTable.ForegroundColor = [0.149 0.149 0.149];
            app.kalmanConfigTable.FontSize = 16;
            app.kalmanConfigTable.Position = [679 479 563 315];

            % Create alphaConfigTable
            app.alphaConfigTable = uitable(app.contolComandsBrowser);
            app.alphaConfigTable.ColumnName = {'Настройка альфа-бета фильтра'; ''; ''; ''};
            app.alphaConfigTable.RowName = {};
            app.alphaConfigTable.ColumnEditable = true;
            app.alphaConfigTable.CellEditCallback = createCallbackFcn(app, @alphaConfigTableCellEdit, true);
            app.alphaConfigTable.FontSize = 16;
            app.alphaConfigTable.Position = [679 84 563 315];

            % Create Label_14
            app.Label_14 = uilabel(app.contolComandsBrowser);
            app.Label_14.HorizontalAlignment = 'right';
            app.Label_14.Position = [1393 761 48 22];
            app.Label_14.Text = 'Широта';

            % Create errorContolLat
            app.errorContolLat = uislider(app.contolComandsBrowser);
            app.errorContolLat.ValueChangedFcn = createCallbackFcn(app, @errorContolLatValueChanged, true);
            app.errorContolLat.Position = [1462 770 400 3];

            % Create Label_15
            app.Label_15 = uilabel(app.contolComandsBrowser);
            app.Label_15.HorizontalAlignment = 'right';
            app.Label_15.Position = [1393 678 50 22];
            app.Label_15.Text = 'Долгота';

            % Create errorContolLong
            app.errorContolLong = uislider(app.contolComandsBrowser);
            app.errorContolLong.ValueChangedFcn = createCallbackFcn(app, @errorContolLongValueChanged, true);
            app.errorContolLong.Position = [1464 687 400 3];

            % Create setDefault
            app.setDefault = uibutton(app.contolComandsBrowser, 'push');
            app.setDefault.ButtonPushedFcn = createCallbackFcn(app, @setDefaultButtonPushed, true);
            app.setDefault.FontSize = 14;
            app.setDefault.Position = [120 770 208 24];
            app.setDefault.Text = 'Сбросить настройки фильтра';

            % Create Label_16
            app.Label_16 = uilabel(app.contolComandsBrowser);
            app.Label_16.HorizontalAlignment = 'right';
            app.Label_16.Position = [1393 600 47 22];
            app.Label_16.Text = 'Высота';

            % Create errorContolAlt
            app.errorContolAlt = uislider(app.contolComandsBrowser);
            app.errorContolAlt.ValueChangedFcn = createCallbackFcn(app, @errorContolAltValueChanged, true);
            app.errorContolAlt.Position = [1461 609 400 3];

            % Create BACKButton
            app.BACKButton = uibutton(app.UIFigure, 'push');
            app.BACKButton.ButtonPushedFcn = createCallbackFcn(app, @BACKButtonPushed, true);
            app.BACKButton.BusyAction = 'cancel';
            app.BACKButton.Interruptible = 'off';
            app.BACKButton.FontSize = 14;
            app.BACKButton.FontWeight = 'bold';
            app.BACKButton.Position = [800 162 100 40];
            app.BACKButton.Text = 'Назад';

            % Create STARTButton
            app.STARTButton = uibutton(app.UIFigure, 'push');
            app.STARTButton.ButtonPushedFcn = createCallbackFcn(app, @STARTButtonPushed, true);
            app.STARTButton.BusyAction = 'cancel';
            app.STARTButton.Interruptible = 'off';
            app.STARTButton.FontSize = 14;
            app.STARTButton.FontWeight = 'bold';
            app.STARTButton.Position = [690 162 100 40];
            app.STARTButton.Text = 'Начало';

            % Create FINISHButton
            app.FINISHButton = uibutton(app.UIFigure, 'push');
            app.FINISHButton.ButtonPushedFcn = createCallbackFcn(app, @FINISHButtonPushed, true);
            app.FINISHButton.BusyAction = 'cancel';
            app.FINISHButton.Interruptible = 'off';
            app.FINISHButton.FontSize = 14;
            app.FINISHButton.FontWeight = 'bold';
            app.FINISHButton.Position = [1130 162 100 40];
            app.FINISHButton.Text = 'Финиш';

            % Create Label_10
            app.Label_10 = uilabel(app.UIFigure);
            app.Label_10.HorizontalAlignment = 'right';
            app.Label_10.FontWeight = 'bold';
            app.Label_10.Position = [983 133 97 22];
            app.Label_10.Text = 'Перемотать на ';

            % Create goToTime
            app.goToTime = uieditfield(app.UIFigure, 'numeric');
            app.goToTime.ValueChangedFcn = createCallbackFcn(app, @goToTimeValueChanged, true);
            app.goToTime.BusyAction = 'cancel';
            app.goToTime.Interruptible = 'off';
            app.goToTime.Position = [1080 133 50 22];

            % Create Label_12
            app.Label_12 = uilabel(app.UIFigure);
            app.Label_12.HorizontalAlignment = 'right';
            app.Label_12.FontWeight = 'bold';
            app.Label_12.Position = [771 108 80 42];
            app.Label_12.Text = {'Прошло сек.'; '/'; 'из'};

            % Create timeDuration
            app.timeDuration = uieditfield(app.UIFigure, 'text');
            app.timeDuration.Editable = 'off';
            app.timeDuration.Position = [854 133 132 22];

            % Create Label_13
            app.Label_13 = uilabel(app.UIFigure);
            app.Label_13.HorizontalAlignment = 'right';
            app.Label_13.FontWeight = 'bold';
            app.Label_13.Position = [689 108 29 42];
            app.Label_13.Text = {'Шаг'; '/'; 'из'; ''};

            % Create itDuration
            app.itDuration = uieditfield(app.UIFigure, 'text');
            app.itDuration.Editable = 'off';
            app.itDuration.Position = [723 133 50 22];

            % Create PAUSEButton
            app.PAUSEButton = uibutton(app.UIFigure, 'state');
            app.PAUSEButton.ValueChangedFcn = createCallbackFcn(app, @PAUSEButtonValueChanged, true);
            app.PAUSEButton.Text = 'Старт';
            app.PAUSEButton.FontSize = 14;
            app.PAUSEButton.FontWeight = 'bold';
            app.PAUSEButton.Position = [910 162 100 40];

            % Create FORWARDButton
            app.FORWARDButton = uibutton(app.UIFigure, 'push');
            app.FORWARDButton.ButtonPushedFcn = createCallbackFcn(app, @FORWARDButtonPushed, true);
            app.FORWARDButton.BusyAction = 'cancel';
            app.FORWARDButton.Interruptible = 'off';
            app.FORWARDButton.FontSize = 14;
            app.FORWARDButton.FontWeight = 'bold';
            app.FORWARDButton.Position = [1020 162 100 40];
            app.FORWARDButton.Text = 'Вперед';

            % Create mapAxesData
            app.mapAxesData = uitable(app.UIFigure);
            app.mapAxesData.ColumnName = {'направление'; 'метр / град.град'; 'град-мин.мин'; 'град-мин-сек.сек'};
            app.mapAxesData.ColumnWidth = {204, 204, 204, 204};
            app.mapAxesData.RowName = {};
            app.mapAxesData.ColumnEditable = false;
            app.mapAxesData.FontSize = 16;
            app.mapAxesData.Position = [551 4 818 96];

            % Create Label_11
            app.Label_11 = uilabel(app.UIFigure);
            app.Label_11.HorizontalAlignment = 'right';
            app.Label_11.FontWeight = 'bold';
            app.Label_11.Position = [1128 133 43 22];
            app.Label_11.Text = 'Пауза ';

            % Create pauseBetwenIt
            app.pauseBetwenIt = uieditfield(app.UIFigure, 'numeric');
            app.pauseBetwenIt.ValueChangedFcn = createCallbackFcn(app, @pauseBetwenItValueChanged, true);
            app.pauseBetwenIt.BusyAction = 'cancel';
            app.pauseBetwenIt.Position = [1174 133 50 22];
            app.pauseBetwenIt.Value = 0.1;

            % Create Label_18
            app.Label_18 = uilabel(app.UIFigure);
            app.Label_18.HorizontalAlignment = 'right';
            app.Label_18.Position = [204 193 140 22];
            app.Label_18.Text = 'Сообщения со спутника';

            % Create fromSputnik
            app.fromSputnik = uitextarea(app.UIFigure);
            app.fromSputnik.Position = [4 4 540 190];

            % Create Label_19
            app.Label_19 = uilabel(app.UIFigure);
            app.Label_19.HorizontalAlignment = 'right';
            app.Label_19.Position = [1580 193 131 22];
            app.Label_19.Text = 'Сообщения с фильтра';

            % Create toFilter
            app.toFilter = uitextarea(app.UIFigure);
            app.toFilter.Position = [1376 4 540 190];

            % Create uploadingCheck_3
            app.uploadingCheck_3 = uicheckbox(app.UIFigure);
            app.uploadingCheck_3.Interruptible = 'off';
            app.uploadingCheck_3.Text = 'Обновлять';
            app.uploadingCheck_3.Position = [4 193 83 22];
            app.uploadingCheck_3.Value = true;

            % Create uploadingCheck_4
            app.uploadingCheck_4 = uicheckbox(app.UIFigure);
            app.uploadingCheck_4.Interruptible = 'off';
            app.uploadingCheck_4.Text = 'Обновлять';
            app.uploadingCheck_4.Position = [1833 193 83 22];
            app.uploadingCheck_4.Value = true;

            % Create uploadingCheck_5
            app.uploadingCheck_5 = uicheckbox(app.UIFigure);
            app.uploadingCheck_5.Interruptible = 'off';
            app.uploadingCheck_5.Text = 'Обновлять';
            app.uploadingCheck_5.Position = [1273 55 83 22];
            app.uploadingCheck_5.Value = true;

            % Create Label_34
            app.Label_34 = uilabel(app.UIFigure);
            app.Label_34.HorizontalAlignment = 'center';
            app.Label_34.FontSize = 16;
            app.Label_34.FontWeight = 'bold';
            app.Label_34.FontAngle = 'italic';
            app.Label_34.Position = [616 104 25 22];
            app.Label_34.Text = '';

            % Create generalSpeed
            app.generalSpeed = uigauge(app.UIFigure, 'ninetydegree');
            app.generalSpeed.Limits = [0 1000];
            app.generalSpeed.Position = [550 104 111 111];

            % Create Label_33
            app.Label_33 = uilabel(app.UIFigure);
            app.Label_33.HorizontalAlignment = 'center';
            app.Label_33.FontSize = 16;
            app.Label_33.FontWeight = 'bold';
            app.Label_33.FontAngle = 'italic';
            app.Label_33.Position = [1317 193 25 22];
            app.Label_33.Text = '';

            % Create generalAcceleration
            app.generalAcceleration = uigauge(app.UIFigure, 'ninetydegree');
            app.generalAcceleration.Limits = [0 10];
            app.generalAcceleration.Orientation = 'northeast';
            app.generalAcceleration.Position = [1259 104 111 111];

            % Create itDuration_2
            app.itDuration_2 = uieditfield(app.UIFigure, 'text');
            app.itDuration_2.Editable = 'off';
            app.itDuration_2.Position = [723 104 50 22];

            % Create timeDuration_2
            app.timeDuration_2 = uieditfield(app.UIFigure, 'text');
            app.timeDuration_2.Editable = 'off';
            app.timeDuration_2.Position = [854 104 132 22];

            % Create speedLabel
            app.speedLabel = uilabel(app.UIFigure);
            app.speedLabel.HorizontalAlignment = 'right';
            app.speedLabel.FontWeight = 'bold';
            app.speedLabel.Position = [616 122 39 28];
            app.speedLabel.Text = {'СКОР'; 'м/с'};

            % Create accelerationLabel
            app.accelerationLabel = uilabel(app.UIFigure);
            app.accelerationLabel.FontWeight = 'bold';
            app.accelerationLabel.Position = [1276 122 46 28];
            app.accelerationLabel.Text = {'УСКОР'; 'g'};

            % Create startImagePanel
            app.startImagePanel = uipanel(app.UIFigure);
            app.startImagePanel.AutoResizeChildren = 'off';
            app.startImagePanel.BorderType = 'none';
            app.startImagePanel.TitlePosition = 'centertop';
            app.startImagePanel.Visible = 'off';
            app.startImagePanel.Position = [650 370 620 340];

            % Create startImageAxes
            app.startImageAxes = uiaxes(app.startImagePanel);
            app.startImageAxes.DataAspectRatio = [1 1 1];
            app.startImageAxes.PlotBoxAspectRatio = [640 360 1];
            app.startImageAxes.ClippingStyle = 'rectangle';
            app.startImageAxes.ColorOrder = [0 0.4471 0.7412;0.851 0.3294 0.102;0.9294 0.6941 0.1255;0.4941 0.1843 0.5569;0.4667 0.6745 0.1882;0.302 0.7451 0.9333;0.6392 0.0784 0.1804];
            app.startImageAxes.Box = 'on';
            app.startImageAxes.XTick = [];
            app.startImageAxes.YTick = [];
            app.startImageAxes.Color = 'none';
            app.startImageAxes.BackgroundColor = [0.302 0.749 0.9294];
            app.startImageAxes.Position = [-10 -10 640 360];

            % Create startLabel
            app.startLabel = uilabel(app.startImagePanel);
            app.startLabel.VerticalAlignment = 'bottom';
            app.startLabel.FontSize = 24;
            app.startLabel.FontColor = [1 1 1];
            app.startLabel.Position = [9 4 513 148];
            app.startLabel.Text = {'Разработал Сергей Мехоношин в 2021 г. '; 'по заказу ЮУрГУ'; 'Никакие права не защищены'};
        end
    end

    methods (Access = public)

        % Construct app
        function app = app

            % Create and configure components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end