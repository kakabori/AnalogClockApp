classdef AnalogClock < matlab.graphics.chartcontainer.ChartContainer

    properties
        Time
        ShowSecond logical = true
    end
    
    properties (Access = private)
        
    end
    
    properties (Access = private,Transient,NonCopyable)
        SecondLineObj
        MinuteLineObj
        HourLineObj
        ClockFrame
        Numbers matlab.graphics.primitive.Text
    end
    
    methods
        function set.Time(obj,x)
            if isstring(x) || ischar(x)
                x = datetime(x,"InputFormat","hh:mm:ss");
            end
            obj.Time = x;
        end
    end
    
    methods (Access = protected)
        function setup(obj)
            % Get the axes
            ax = getAxes(obj);
            
            ax.PlotBoxAspectRatio = [1 1 1];
            ax.XTick = [];
            ax.YTick = [];
            % 軸の線を消す
            ax.XColor = "none";
            ax.YColor = "none";
            
            hold(ax,"on");
            
            % 時計枠を表示
            x = linspace(0,2*pi,100);
            obj.ClockFrame = plot(ax,sin(x),cos(x),"LineWidth",5);

            % 数字を表示
            for k = 1:12
                % 角度の計算
                hourInRad = -k/12*2*pi + pi/2;
                
                textH = text(ax,...
                    0.8*cos(hourInRad),...
                    0.8*sin(hourInRad),...
                    num2str(k));
                textH.HorizontalAlignment = "center";
                textH.FontSize = 30;
                textH.FontWeight = "bold";
                obj.Numbers(k) = textH;
            end
            
            % 針の見た目の設定
            obj.HourLineObj = plot(ax,nan(1,2),nan(1,2),'k','LineWidth',10);
            obj.SecondLineObj = plot(ax,nan(1,2),nan(1,2),'k','LineWidth',1);
            obj.MinuteLineObj = plot(ax,nan(1,2),nan(1,2),'k','LineWidth',5);
            
            hold(ax,"off");
            
            layout = obj.getLayout();
            layout.Padding = "none";
            
            obj.Time = "12:00:00";
        end
        
        function update(obj)
            [hourInRad,minInRad,secInRad] = convertToRadian(obj.Time);
            
            % 各針の描画の更新
            if obj.ShowSecond
                obj.SecondLineObj.XData = [0,cos(secInRad)];
                obj.SecondLineObj.YData = [0,sin(secInRad)];
            end
            
            obj.MinuteLineObj.XData = [0,cos(minInRad)];
            obj.MinuteLineObj.YData = [0,sin(minInRad)];
            
            obj.HourLineObj.XData = [0,0.6*cos(hourInRad)];
            obj.HourLineObj.YData = [0,0.6*sin(hourInRad)];
            
            ax = getAxes(obj);
            obj.drawNumbers(ax);
        end
        
    end
    
    methods (Access = private)
        function drawNumbers(obj,ax)
            ax.Units = "pixels";
            clockSize = min(ax.Position(3:4));
            fontSize = clockSize / 10;
            
            currentFontSize = obj.Numbers(1).FontSize;
            if currentFontSize == fontSize
                return
            end
            
            % 数字を表示
            for k = 1:12
                obj.Numbers(k).FontSize = fontSize;
            end
            
        end
    end
    
end

function [hourInRad,minInRad,secInRad] = convertToRadian(time)
% 時刻を00:00:00を基点にした秒で表現
d = datetime(time,"InputFormat","hh:mm:ss");
sec = hour(d)*3600 + minute(d)*60 + second(d);

% 秒針の角度
secInRad = -fix(sec)/60*2*pi + pi/2;
% 長針(分)の角度
minInRad = -sec/60/60*2*pi+pi/2;
% 短針(時間)の角度
hourInRad = -sec/60/60/12*2*pi+pi/2;
end
