% Initial Setup
clear all; close all; clf; clc;
moteur_cc_sugeno;

close all;
%dataset = readtable('C:/Users/univ/Desktop/stadiz/(PROJET)PFS_FuzzyLogic/TripA04_test_fuzzy_throttle_hvac.csv');
%dataset = readtable('C:/Users/univ/Desktop/stadiz/(PROJET)PFS_FuzzyLogic/TripA32_test_fuzzy_throttle_hvac.csv');
dataset = readtable('C:/Users/univ/Desktop/stadiz/(PROJET)PFS_FuzzyLogic/TripB10_B11_fuzzy_throttle_hvac_1.csv');
% Configuration Parameters remain mostly the same
timeInterval = 0.1;
motorMaxPower = 125;
motor_efficiency = 0.98;
vehicleWeight = 1550;
drivingMode =1.2; % 1 sport, 2.2 normal, 3.3 comfort
previousVelocity = 0;

% Data Processing
totalTime = max(dataset.Time_s);
numIntervals = floor(totalTime / timeInterval);
motorEnergyConsumption = zeros(1, numIntervals);
timeIntervals = (1:numIntervals) * timeInterval;

% Initialize arrays for 3D plotting
socValues = zeros(1, numIntervals);
slopeValues = zeros(1, numIntervals);
velocityValues = zeros(1, numIntervals);
motorCoefficients = zeros(1, numIntervals);

% Adaptive Fuzzy Logic loop
for i = 1:numIntervals
    startTime = (i-1) * timeInterval;
    endTime = i * timeInterval;
    intervalIndices = dataset.Time_s >= startTime & dataset.Time_s < endTime;

    temperature = mean(dataset.Ambient_Temperature(intervalIndices));
    soc = mean(dataset.SoC(intervalIndices));
    slope = mean(dataset.Slope(intervalIndices));
    currentVelocity = mean(dataset.Velocity_kmh(intervalIndices));  % Current average speed in the interval

    % Calculate velocity change
    velocityChange = currentVelocity - previousVelocity;
    previousVelocity = currentVelocity;  % Update previousVelocity for the next interval

    motorInput = [temperature, drivingMode, vehicleWeight, slope, soc, velocityChange,currentVelocity];
    motorInput2 = [temperature,slope, soc, velocityChange];
    motorCoefficient = evalfis(FIS_Moteur_cc, motorInput);
    predictedMotorEnergy = motorCoefficient * motorMaxPower * motor_efficiency;
    motorEnergyConsumption(i) = predictedMotorEnergy;

    % Store data for plotting
    socValues(i) = soc;
    temperatureval(i)=temperature;
    slopeValues(i) = slope;
    velocityValues(i)= velocityChange;
    v2(i) = currentVelocity;
    motorCoefficients(i) = motorCoefficient;
end
windowSize = 1;  % Smoothing window size
smoothedcoeff = movmean(motorCoefficients, windowSize);
% Plotting SoC, Velocity, Slope, and Motor Coefficient over Time
figure;
subplot(5,1,1); % First subplot for SoC
plot(timeIntervals, socValues, 'm', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('SoC (%)');
title('State of Charge (SoC) over Time');
grid on;

subplot(5,1,4); % Second subplot for velocity
plot(timeIntervals, v2, 'b', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Velocity (km/h)');
title('Velocity over Time');
grid on;

subplot(5,1,2); % Third subplot for slope
plot(timeIntervals, slopeValues, 'g', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Slope (degrees)');
title('Slope over Time');
grid on;

subplot(5,1,3); % Third subplot for slope
plot(timeIntervals, temperatureval, 'c', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Temperature (°C)');
title('Temperature over Time');
grid on;

subplot(5,1,5); % Fourth subplot for motor coefficient
plot(timeIntervals, smoothedcoeff, 'r', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Motor Coefficient');
title('Motor Coefficient over Time');
grid on;

% Define the time range for zoom (for example, from 20 to 40 seconds)
zoom_start = 0;  % Start time of zoom
zoom_end = 400;    % End time of zoom

% Create a figure for the zoomed plot
figure (2) ;

% Plot the velocity in the zoomed time range
yyaxis left;  % Left Y-axis for velocity
plot(timeIntervals, v2, 'b-', 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Velocity (km/h)');
title('Zoomed Velocity and Motor Coefficient Projection');
xlim([zoom_start, zoom_end]);  % Zoom in on the specified time range
grid on;

% Plot the motor coefficient values on the right Y-axis
yyaxis right;  % Right Y-axis for motor coefficients
plot(timeIntervals, smoothedcoeff, 'r-', 'LineWidth', 1.5);
ylabel('Motor Coefficient');
xlim([zoom_start, zoom_end]);  % Zoom in on the specified time range
grid on;

legend('Velocity (km/h)', 'Motor Coefficient');





% Plot 3D Surface for Motor Coefficient vs. SoC and Velocity Change
[X, Y] = meshgrid(linspace(min(socValues), max(socValues),200), linspace(min(velocityValues), max(velocityValues),200));
Z = griddata(socValues, velocityValues, motorCoefficients, X, Y, 'cubic');
Z = imgaussfilt(Z,0.5); % Gaussian smoothing

figure;
surf(X, Y, Z, 'EdgeColor', 'none');
colorbar;
xlabel('State of Charge (%)');
ylabel('Velocity Change (km/h)');
zlabel('Motor Coefficient');
title('Motor Coefficient vs. SoC and Velocity Change');
colormap jet;
rotate3d on; % Enable interactive rotation


figure (4) ;

% Plot the velocity in the zoomed time range

plot(timeIntervals, smoothedcoeff, 'r-', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Motor Coefficient');
title('Motor Coefficient over time using Matlab');
xlim([zoom_start, zoom_end]);  % Zoom in on the specified time range
grid on;


legend('Motor Coefficient');





