% deklaraci iptsetpref(prefname,value) nastavime
% preferenci IPT
iptsetpref('UseIPPL',false);

filename = '../xvitas02.bmp';
original = imread(filename); % prvotni cteni

% 1/ sharpen
H = [-0.5 -0.5 -0.5; -0.5 5 -0.5; -0.5 -0.5 -0.5];
prvni = imfilter(original,H);
imwrite(prvni, '../step1.bmp'); % ulozeni

% 2/ horizontal flip
druhy = fliplr(prvni);
imwrite(druhy,'../step2.bmp'); % ulozeni

% 3/ median filter
% medfilt2 provadi medianovy filtr
% dvourozmerne matice A
treti = medfilt2(druhy,[5 5]);
imwrite(treti,'../step3.bmp'); % ulozeni

% 4/ image blur
H = [1 1 1 1 1; 1 3 3 3 1; 1 3 9 3 1; 1 3 3 3 1; 1 1 1 1 1]/49;
ctvrty = imfilter(treti,H);
imwrite(ctvrty,'../step4.bmp'); % ulozeni

% 5/ error in image
helper = fliplr(original);
doub_puv = im2double(helper);
doub_nov = im2double(ctvrty);
chyba = 0;
for(i = 1:512)
    for(j = 1:512)
        chyba = chyba + double(abs(doub_puv(i,j)-doub_nov(i,j)));
    end;
end;

chyba = (chyba/(512*512))*255

% 6/ histogram stretching
a = min(min(im2double(ctvrty)));
b = max(max(im2double(ctvrty)));
paty = imadjust(ctvrty, [a b], [0 1]);
imwrite(paty, '../step5.bmp');

% 7/ standard and mean deviation
mean_nohist = mean2(im2double(ctvrty))
std_nohist = std2(im2double(ctvrty))
mean_hist = mean2(im2double(paty))
std_hist = std2(im2double(paty))

% 8/ quantization, 2 bits N=2
a = 0;
b = 255;
N = 2;
helper = double(paty);
sesty = zeros(512,512);
for(i = 1:512)
    for(j = 1:512)
        sesty(i,j) = round(((2^N)-1)*(helper(i,j)-a)/(b-a))*(b-a)/((2^N)-1)+a;
    end;
end;
sesty = uint8(sesty);
imwrite(sesty, '../step6.bmp');
