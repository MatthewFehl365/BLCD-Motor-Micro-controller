%{
Title: Code for taking speed measurements at varying voltages on a DC Motor
for determining transfer function paramteres.
Project: AERSP 304 Arduino Project
Author: Matthew Fehl
Contributors: Eathan Rhodes, Grant Rodgers
%}

clear all; clear a; clc; pause on;

%Initialize Arduino and Encoder
a = arduino ('com7','Mega2560','Libraries','RotaryEncoder');
encoder = rotaryEncoder(a,'D2','D3',45);
resetCount(encoder);

%Set the sampling rate
n = input('Input the sampling rate per second')

%Set time domain of chirp Signal
t_t = input('Input the time to test over')

%Set the ending Frequency
f_i = input('Set the frequency range to test over.\n Initial Frequency')
f_f = input('Final Frequency')

%Set
t =(0:1/n:t_t);

%Create Chirp
chp= chirp(t,f_i,t_t,f_f);

%secondary way of getting RPM
%{
for i=1:n+1
    
  Voltage = abs(chp(i))*5
  
  
  writePWMVoltage(a,'D7',Voltage);
  
  pause(1);
  
  oldPosition = readCount(encoder);
  pause(0.01);
  newPosition = readCount(encoder);

  RPM=((newPosition-oldPosition)/(0.45))*60
    
  fprintf(fidw,'%.6     %5.4\n', chp(i), RPM);
  
end
%}

%Initialize array sizes
Voltage =chp()+4;
ang_vel =zeros(1,t_t*n+1);

%Spin up the motor before taking measurements
Voltage(1) = chp(1)+4;
writePWMVoltage(a,'D7',Voltage(1));
pause(2);

%getting RPM response of the motor
for i=1:t_t*n+1
  
  disp(i)
  
  writePWMVoltage(a,'D7',Voltage(i));
 
  ang_vel(i)=readSpeed(encoder);
  
end

%plots voltage and resulting velocity
subplot(2,1,1);
plot(t,Voltage);
title('Voltage (input)');

subplot(2,1,2);
plot(t, ang_vel);
title('Velocity (output)');

%Tablulate all measurements
Measurements = [t;Voltage;ang_vel];

%Print Measurements to text file
fidw = fopen('Motor_Measurements.txt','w');
fprintf(fidw,'%1.4f\n',n);
fprintf(fidw,'%1.4f\n',t_t);
fprintf(fidw,'%1.4f\t\t%1.4f\t\t%1.4f\n',Measurements);

%turn off Motor
writePWMVoltage(a,'D7',0);

%Close files
fclose('all');