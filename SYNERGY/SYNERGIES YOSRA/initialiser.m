function initialiser()
% loads all the functions in the folders
close all;
clear all;
clc;
directory_name = cd;
try
    addpath([directory_name,'\EMGanalysis']);
    addpath([directory_name,'\Extraction']);
    addpath([directory_name,'\Graph_generation']);
    addpath([directory_name,'\PostAnalysis']);
    addpath([directory_name,'\Scripts']);
    addpath([directory_name,'\exampleDATA']);
catch err
    disp(err);
    fprintf(['error (synergy analysis): the current directory should contain the following folders: \n',...
             '\\EMGanalysis\n',...
    	     '\\Extraction\n',...
             '\\Graph_generation\n',...
    	     '\\PostAnalysis\n',...
             '\\Scripts\n']);
    return;
end

end

