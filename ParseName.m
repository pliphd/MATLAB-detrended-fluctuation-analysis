function NameStruc = ParseName(NameString, varargin)
%PARSENAME Parsing recording names
% 
% This is a general function and only one field in output (filename)
% 
% $Author:  Peng Li
%           Medical Biodynamical Program
%           Brigham and Women's Hospital and Harvard Medical School
% $Date:    Mar 28, 2016
% $Modif.:  Nov 14, 2016
%               Add another input to specify different segments
% 

NameStruc.FileName = {NameString};

if nargin > 1
    NameStruc.Segment = varargin(1);
end