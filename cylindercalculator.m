function [volume, surface] = cylindercalculator()
radius = input("Enter a radius here:");
height = input("Enter a height here:");
volume = pi * radius^2 * height;
surface = 2 * pi * radius * height;
fprintf("Volume of a cylinder is %.2f \n", volume)
fprintf("Surface of a cylinder is %.2f \n", surface)
end
