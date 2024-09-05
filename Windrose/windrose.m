clear
tic

filename = 'Wind data.xlsx';
data = xlsread(filename);       % διαβαζει τα δεδομενα και φτιαχνει πινακα στον οποιο ειναι αποθηκευμενα

% Προσθήκη σε κάθε κελί της στήλης του χρόνου του αριθμου 2
% Ετσι απο UTC σε LTS (LST=UTC+2)

data(:, 4) = data(:, 4) + 2;

xlswrite(filename, data);                                                  % Αλλαγη των δεδομενων με τον χρονο σε LST

year_min = min(data(:,1));                                                 % βρισκω το ελαχιστο ετος που ειναι στην 1η στηλη του αρχειο
year_max = max(data(:,1));                                                 % βρισκω το μεγιστο ετος που ειναι στην 1η στηλη του αρχειο

year1 = randi([year_min,year_max-5]);                                      % επιλεται τυχαια ενα ετος στο διάστημα year_min - (year_max-5)

index = find(data(:,1)>=year1 & data(:,1)<=(year1 +5));                    % επιλέγονται τα δεδομένα που αφορούν στην εξαετία year1 – (year1+5)

WS_knot = data(index,5);             % Οριζει την ταχυτητα του ανεμου knot
WS = WS_knot.*0.51;                  % Αλλαζει την ταχυτητα του ανεμου σε m/s
WD = data(index,6);                  % Κατευθυνση ανεμου

pc_name = getenv('COMPUTERNAME');   % οριζει μεταβλητη που φαινεται το ονομα του υπολογιστη
%title_diagramm = sprintf('Περίοδος μετρήσεων από %d έως %d', year1 , year1+5);  %Ορισμος της μεταβλητης που θα χρησιμοποιησω ως τιτλο

% Οριζονται οι επιλογες του διαγραμματος που θελουμε 
% Στη συνεχεια καλουμε τη συναρτηση windrose που φτιαχνει το ραβδογραμμα
      
Options = {'anglenorth',0,'angleeast',90,'labels',{'N (0)', 'E (90)', 'S (180)', 'W(270)'},'freqlabelangle',30,'nDirections', 16, 'labels', { 'Ν(0°)','NE(22.5°)','NE(45°)','NE(67.5°)','E(90°)','SE(112.5°)','SE(135°)','SE(157.5°)','S(180°)','SW(202.5°)','SW(225°)', 'SW(247.5°)','W(270°)','NW(292.5°)','NW(315°)','NW(337.5°)'}};
WindRose (WD,WS,Options)

% Αρτιο ΑΕΜ ----> Φθινοπωρο   Περιττο ΑΕΜ ----> Καλοκαιρι
AEM=15372; % ΤΟ ΑΕΜ ΜΟΥ
% Βλεπω αν το αεμ ειναι αρτιο η περιττο
if mod(AEM,2)==0
    fprintf("Autumn\n");
    season = 'Autumn';
else
    fprintf("Summer\n");
    season = 'Summer';
end

selected_month = data (index,2);  % οριζω ενα πινακα που επιλεγω ολους του μηνες των ετων που με ενδιαφερουν
w = 1 ;
for n=1:length(selected_month)    % φτιαχνω εναν πινακα που περιεχει τις κατευθυνσεις των ανεμων του φθινοπωρινους μηνες
    if selected_month(n) == 9 || selected_month(n) == 10 || selected_month(n) == 11
        autumn_data(w,:) = WD(n);
        w=w+1;
    end
end

W = unique(autumn_data(:,1));               % Βρισκω τις μοναδικες τιμες των κατευθυνσεων του ανεμου
Wout = [W,histc(autumn_data(:,1),W)];       % Βρισκω καθε κατευθυνση του ανεμου ποσες φορες εμφανιζεται μεσα στο φθινοπωρο

% Βρισκω την επικρατουσα διευθυνση (Usual_WD)

for y = 1:length(Wout)
    if Wout(y,2)==max(Wout(:,2))
        MAXY=y;
        Usual_WD=Wout(MAXY,1);
    end
end


text1 = 'Ονοματεπώνυμο: Καρέλας Ιωάννης';                                  % εμφανιζει το ονομα
text2 = sprintf('Όνομα υπολογιστή: %s', pc_name);                          % εκτυπωνει το ονομα του υπολογιστη
text3 = 'Ημερομηνία: 12/1/2024';                                           % εμφανιζει την ημερομηνια
text4 = sprintf('Η επικρατούσα διεύθυνση είναι στις %d °',Usual_WD);       % εκτυπωνει την επικρατουσα διευθυνση που βρηκαμε  
text5 = sprintf('Περίοδος μετρήσεων από %d έως %d', year1 , year1+5);      % εκτυπωνει την περιοδο των μετρησεων που πηραμε

annotation('textbox', [0.8, 0.1, 0.8, 0.1], 'String', text1, 'FitBoxToText', 'on', 'BackgroundColor', 'white');        % εμφανιση ονοματος στο διαγραμμα
annotation('textbox', [0.8, 0.1, 1, 0], 'String', text2, 'FitBoxToText', 'on', 'BackgroundColor', 'white');            % εμφανιση ονοματος υπολογιστη
annotation('textbox', [0.1, 0.1, 0.3, 0.1], 'String', text3, 'FitBoxToText', 'on', 'BackgroundColor', 'white');        % εμφανιση ημερομηνιας
annotation('textbox', [0.45, 0.01, 0.1, 0.05], 'String', text4, 'FitBoxToText', 'on', 'BackgroundColor', 'white');     % εμφανιση επικρατουσας διευθυνσης
annotation('textbox', [0.45, 0.94, 0.1, 0.05], 'String', text5, 'FitBoxToText', 'on', 'BackgroundColor', 'white');     % εμφανιση της περιοδου των μετρησεων


toc
