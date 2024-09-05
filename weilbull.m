clear

AEM = 15372;
tic

filename = 'Weibull data.xlsx';
if mod((AEM),2)==0
    data = xlsread(filename,1);                                            %διαβαζω τα δεδομενα
else                                                                       % αναγνωριζει αν το αεμ ειναι αρτιος η περιττος
    data = xlsread(filename,2);                                         
end

year_min = min(data(:,1));                                                 % βρισκω το ελαχιστο ετος που ειναι στην 1η στηλη του αρχειου
year_max = max(data(:,1));                                                 % βρισκω το μεγιστο ετος που ειναι στην 1η στηλη του αρχειου

year1 = randi([year_min,year_max-4]);                                      % επιλεται τυχαια ενα ετος στο διάστημα year_min - (year_max-4)

index = find(data(:,1)>=year1 & data(:,1)<=(year1 +4));                    % επιλέγονται τα δεδομένα που αφορούν στην πενταετία year1 – (year1+4)
 
WS_knot = data(index,6);            % Wind velocity σε knot   
WS = WS_knot.*0.51 ;                % Κανω την μετατροπη για Wind velocity σε m/s
sinolo_WS =length(WS);              % ποσες ταχυτητες υπαρχουν μεσα στα χρονικα ορια

WS_max = max(WS);                   % μεγιστη ταχυτητα ανεμου
WS_min = min(WS);                   % ελαχιστη ταχυτητα ανεμου

freq =zeros(1,ceil(WS_max));   % οριζω μηδενικο πινακα για να βρω συχνοτητες με στοιχεια οσα και η μεγιστη ταχυτητα στρογγυλεμενη προς τα πανω
% βρισκω ποσες φορες εμφανιζεται η καθε ταχυτητα
for i=1:sinolo_WS
     speed = floor(WS(i,1)) ;
     freq(speed+1)= freq(speed+1) + 1;
end

%συχνοτητα εμφανισης καθε μετρησης σε σχεση με το ολικο

freq_emfanisis = freq ;
for i=1:floor(WS_max)+1
    freq_emfanisis(1,i)=freq(1,i)/sinolo_WS;
    if i==1
        F(1,1) = freq_emfanisis(1,i);
    
    else
        F(1,i) = F(1,i-1) + freq_emfanisis(1,i);
    end
end
% φτιαχνω πινακα με τις ακεραιες ταχυτητες
V0 = (1:floor(WS_max)+1);
% εξισωσεις Weibull
X = log(V0);
Y = log(-log(1-F));

% ελεγχος για τιμες που απειριζονται
inf_indices = isinf(Y);

% Αφαίρεση των -inf στοιχείων από τα διανύσματα
X = X(~inf_indices);
Y = Y(~inf_indices);

%ευθεια ελαχιστων τετραγωνων
eutheia_elaxiston = polyfit(X,Y,1);
% βρισκω τα Α και Β που προκυπτουν απο την ευθεια ελαχιστων
A = eutheia_elaxiston(2);
B = eutheia_elaxiston(1);

% υπολογισμος C και k
C= real(exp(-A/B));
k= real(B);

% υπολογισμος θεωρητικης weibull
%f(v)=k/c*(v/c)^(k-1)*exp(-((v/c)^k))=k2*a3*exp(-a2), me  k2 = k/c, a3 = (v/c)^(k-1)
x_theoretical  = linspace(1, WS_max, 100);
a1 = x_theoretical /C;
a2 = a1.^k;
k1 = k-1;
a3 = a1.^k1;
k2 = k/C;
puk = k2*a3.*exp(-a2);

pc_name = getenv('COMPUTERNAME');   % οριζει μεταβλητη που φαινεται το ονομα του υπολογιστη

% Δημιουργία ιστογράμματος
figure;
bar(V0, freq_emfanisis, 'FaceAlpha', 0.7, 'EdgeColor', 'g');
hold on;
% Εμφανιζω και την θεωρητικη καμπυλη που προεκυψε απο τις εξισωσεις 
plot(x_theoretical , puk, 'b', 'LineWidth', 4);

xlabel('Ταχύτητα ανέμου [m/s]');
ylabel('Πιθανότητα');

legend('Πειραματικά δεδομένα','Προσαρμοσμένη κατανομή Weibull');
text1 = 'Ονοματεπώνυμο: Καρέλας Ιωάννης';                                  % εμφανιζει το ονομα
text2 = sprintf('Όνομα υπολογιστή: %s', pc_name);                          % εκτυπωνει το ονομα του υπολογιστη
text3 = sprintf('C = %f , k = %f', C,k);                          % εκτυπωνει τις μεταβλητες C και k
text4 = sprintf('Περίοδος μετρήσεων από %d έως %d', year1 , year1+4);      % εκτυπωνει την περιοδο των μετρησεων που πηραμε
text5 = sprintf('Αριθμός μετρήσεων: %d', sinolo_WS );      % εκτυπωνει τον αριθμο των μετρησεων που πηραμε

annotation('textbox', [0.001, 0.1, 0.3, 0.1], 'String', text1, 'FitBoxToText', 'on', 'BackgroundColor', 'white');      % εμφανιση ονοματος στο διαγραμμα
annotation('textbox', [0.001, 0.05, 0.3, 0.1], 'String', text2, 'FitBoxToText', 'on', 'BackgroundColor', 'white');     % εμφανιση ονοματος υπολογιστη
annotation('textbox', [0.8, 0.5, 0.8, 0.1], 'String', text3, 'FitBoxToText', 'on', 'BackgroundColor', 'white');        % εμφανιση C και k
annotation('textbox', [0.45, 0.94, 0.1, 0.05], 'String', text4, 'FitBoxToText', 'on', 'BackgroundColor', 'white');     % εμφανιση της περιοδου των μετρησεων
annotation('textbox', [0.48, 0.88, 0.1, 0.05], 'String', text5, 'FitBoxToText', 'on', 'BackgroundColor', 'white');     % εμφανιση του αριθμου των μετρησεων

hold off;
grid on;

toc
