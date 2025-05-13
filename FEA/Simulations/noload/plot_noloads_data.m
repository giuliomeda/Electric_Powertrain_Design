function [] = plot_noloads_data(MD,SD,VecValues,folderName)
%PLOT_NOLOADS_DATA Summary of this function goes here
%   Detailed explanation goes here
%% Plotting BEMF of phases A, B, and C

% Define the folder name
folderName = fullfile(folderName,'plotsBemf');

% Check if the folder exists. If not, create it
if ~exist(folderName, 'dir')
    mkdir(folderName);
end


% Define parameters
mechanical_deg = SD.RotorPositions; % [deg]

% Create the plot for Phase A
figure;

% Maximize the figure window (full-screen)
%set(figure, 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);

plot(mechanical_deg, VecValues.BemfA, 'r', 'LineWidth', 1.5);  % Phase A in red
xlabel('Rotor Position (Mechanical Degrees)');
ylabel('BEMF (Volts)');
title('BEMF of Phase A vs Rotor Position');
grid on;
set(gca, 'FontSize',12);  % Adjust font size

% Save the plot as a PNG file in the created folder
fileName = fullfile(folderName, 'bemfA.png');
saveas(gcf, fileName);

% Create the plot for Phase B
figure;

% Maximize the figure window (full-screen)
% set(figure, 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);

plot(mechanical_deg, VecValues.BemfB, 'g', 'LineWidth', 1.5);  % Phase B in green
xlabel('Rotor Position (Mechanical Degrees)');
ylabel('BEMF (Volts)');
title('BEMF of Phase B vs Rotor Position');
grid on;
set(gca, 'FontSize',12);  % Adjust font size

% Save the plot as a PNG file in the created folder
fileName = fullfile(folderName, 'bemfB.png');
saveas(gcf, fileName);

% Create the plot for Phase C
figure;

% Maximize the figure window (full-screen)
%set(figure, 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);

plot(mechanical_deg, VecValues.BemfC, 'b', 'LineWidth', 1.5);  % Phase C in blue
xlabel('Rotor Position (Mechanical Degrees)');
ylabel('BEMF (Volts)');
title('BEMF of Phase C vs Rotor Position');
grid on;
set(gca, 'FontSize',12);  % Adjust font size

% Save the plot as a PNG file in the created folder
fileName = fullfile(folderName, 'bemfC.png');
saveas(gcf, fileName);

% Create the plot for Phases A, B, and C in the same figure
figure;

% Maximize the figure window (full-screen)
%set(figure, 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);


% Plot Phase A in red
plot(mechanical_deg, VecValues.BemfA, 'r', 'LineWidth', 1.5);  
hold on;

% Plot Phase B in green
plot(mechanical_deg, VecValues.BemfB, 'g', 'LineWidth', 1.5);
% hold on;

% Plot Phase C in blue
plot(mechanical_deg, VecValues.BemfC, 'b', 'LineWidth', 1.5);  

% Add labels and title
xlabel('Rotor Position (Mechanical Degrees)');
ylabel('BEMF (Volts)');
title('BEMF A, B, and C vs Rotor Position');

% Add grid, legend, and adjust font size
grid on;
legend('Phase A', 'Phase B', 'Phase C');
set(gca, 'FontSize',12);  % Adjust font size

hold off;

% Save the plot as a PNG file in the created folder
fileName = fullfile(folderName, 'bemf_A_B_C.png');
saveas(gcf, fileName);

%% Plotting BEMF AB, BC and CA

% Create the plot for BEMF AB
figure;

% Maximize the figure window (full-screen)
%set(figure, 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);

plot(mechanical_deg, VecValues.BemfAB, 'r', 'LineWidth', 1.5);  % BEMF AB in red
xlabel('Rotor Position (Mechanical Degrees)');
ylabel('BEMF (Volts)');
title('BEMF AB vs Rotor Position');
grid on;
set(gca, 'FontSize',12);  % Adjust font size

% Save the plot as a PNG file in the created folder
fileName = fullfile(folderName, 'bemfAB.png');
saveas(gcf, fileName);

% Create the plot for BEMF BC
figure;

% Maximize the figure window (full-screen)
%set(figure, 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);

plot(mechanical_deg, VecValues.BemfBC, 'g', 'LineWidth', 1.5);  % BEMF BC in green
xlabel('Rotor Position (Mechanical Degrees)');
ylabel('BEMF (Volts)');
title('BEMF BC vs Rotor Position');
grid on;
set(gca, 'FontSize',12);  % Adjust font size

% Save the plot as a PNG file in the created folder
fileName = fullfile(folderName, 'bemfBC.png');
saveas(gcf, fileName);

% Create the plot for BEMF CA
figure;

% Maximize the figure window (full-screen)
%set(figure, 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);

plot(mechanical_deg, VecValues.BemfCA, 'b', 'LineWidth', 1.5);  % BEMF CA in blue
xlabel('Rotor Position (Mechanical Degrees)');
ylabel('BEMF (Volts)');
title('BEMF CA vs Rotor Position');
grid on;
set(gca, 'FontSize',12);  % Adjust font size

% Save the plot as a PNG file in the created folder
fileName = fullfile(folderName, 'bemfCA.png');
saveas(gcf, fileName);

% Create the plot for BEMF AB, BC and CA in the same figure
figure;

% Maximize the figure window (full-screen)
%set(figure, 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);

% Plot BEMF AB in red
plot(mechanical_deg, VecValues.BemfAB, 'r', 'LineWidth', 1.5);  
hold on;

% Plot BEMF BC in green
plot(mechanical_deg, VecValues.BemfBC, 'g', 'LineWidth', 1.5);
% hold on;

% Plot Phase CA in blue
plot(mechanical_deg, VecValues.BemfCA, 'b', 'LineWidth', 1.5);  

% Add labels and title
xlabel('Rotor Position (Mechanical Degrees)');
ylabel('BEMF (Volts)');
title('BEMF AB (Red), BC (Green), and CA (Blue) vs Rotor Position');

% Add grid, legend, and adjust font size
grid on;
legend('AB', 'BC', 'CA');
set(gca, 'FontSize',12);  % Adjust font size

hold off;

% Save the plot as a PNG file in the created folder
fileName = fullfile(folderName, 'bemf_AB_BC_CA.png');
saveas(gcf, fileName);


%% Plotting Cogging Torque and Torque DQ

% Create the plot for Cogging Torque
figure;

% Maximize the figure window (full-screen)
%set(figure, 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);

plot(mechanical_deg, VecValues.TorqueMXW, 'b', 'LineWidth', 1.5);  % Torque MXW
xlabel('Rotor Position [Mechanical Degrees]');
ylabel('Cogging Torque [Nm]');
title('Cogging Torque vs Rotor Position');
grid on;
set(gca, 'FontSize',12);  % Adjust font size

% Save the plot as a PNG file in the created folder
fileName = fullfile(folderName, 'Cogging_Torque.png');
saveas(gcf, fileName);

% Create the plot for Torque DQ
figure;

% Maximize the figure window (full-screen)
%set(figure, 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);

plot(mechanical_deg, VecValues.TorqueDQ, 'r', 'LineWidth', 1.5);  % Torque MXW
xlabel('Rotor Position [Mechanical Degrees]');
ylabel('Torque DQ [Nm]');
title('Torque DQ vs Rotor Position');
grid on;
set(gca, 'FontSize',12);  % Adjust font size

% Save the plot as a PNG file in the created folder
fileName = fullfile(folderName, 'TorqueDQ.png');
saveas(gcf, fileName);

% Create the plot for Torque MXW and Torque DQ in the same figure
figure;

% Maximize the figure window (full-screen)
%set(figure, 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);

% Plot Cogging Torque in blue
plot(mechanical_deg, VecValues.TorqueMXW, 'b', 'LineWidth', 1.5);  
hold on;

% Plot Torque DQ in red
plot(mechanical_deg, VecValues.TorqueDQ, 'r', 'LineWidth', 1.5);  
hold on;

% Add labels and title
xlabel('Rotor Position [Mechanical Degrees]');
ylabel('Torque [Nm]');
title('Cogging Torque and Torque DQ vs Rotor Position');

% Add grid, legend, and adjust font size
grid on;
legend('Cogging Torque', 'Torque DQ');
set(gca, 'FontSize',12);  % Adjust font size

hold off;

% Save the plot as a PNG file in the created folder
fileName = fullfile(folderName, 'Cogging_Torque_and_DQ.png');
saveas(gcf, fileName);

end

