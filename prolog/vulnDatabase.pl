%vuln( Description, [prereqs], [result], [Role-[key-(pred, [val]),...,key-(pred,[val])]] )
%note, result cannot be empty
%note, config values must be strings or predicates


% == FTP ==
vuln('scan-ftp', [start], [ftp, vsftpd234], MachineSrcNum, MachineSrcNum, [vsftpd-[version-(only, ["2.3.4"])]]).
vuln('scan-ftp', [start], [ftp, vsftpd303], MachineSrcNum, MachineSrcNum, [vsftpd-[version-(only, ["3.0.3"])]]).


vuln('vsftpd-backdoor', [vsftpd234], [root_shell], MachineSrcNum, MachineSrcNum, [vsftpd-[version-(only, ["2.3.4"])]]).

% == SSH ==
vuln('scan-ssh', [], [ssh, openssh76p1], MachineSrcNum, MachineSrcNum, [openssh-[version-(only, ["7.6p1"])]]).

%vuln('ssh-login-root(brute-force)', [ssh], [root_shell],
%        [openssh-[allowrootlogin-(only, ["Yes"])],
%        users-[root-(only, [generatePassword])]]).
vuln('ssh-login-root', [ssh, passwords], [root_shell], MachineSrcNum, MachineSrcNum, [openssh-[allowrootlogin-(only, ["Yes"])], users-[root-(only, [generatePassword])]]).

%vuln('ssh-login(brute-force)', [ssh, user_list], [user_shell],
%        [users-[logins-(exists, [generateUsername]),
%                passwords-(exists, [generatePassword])]]).
vuln('ssh-login-user', [ssh, user_list, passwords], [user_shell], MachineSrcNum, MachineSrcNum, [users-[logins-(exists, [generateUsername]), passwords-(exists, [generatePassword])]]).

vuln('enumerate-users', [openssh76p1], [user_list], MachineSrcNum, MachineSrcNum, []).

% == Web ==
vuln('scan-http', [], [http], MachineSrcNum, MachineSrcNum, [apache-[]]).

vuln('find-login-page', [http], [php_webapp, login_page], MachineSrcNum, MachineSrcNum, [apache-[modules-(exists, ["libapache2-mod-php"])], php-[deployments-(exists, ["loginpage1"])], mysql-[db-(exists, ["logindb1"]), root-(only, [generatePassword])]]).

vuln('find-login-page', [http], [php_webapp, login_page, bad_sql], MachineSrcNum, MachineSrcNum, [apache-[modules-(exists, ["libapache2-mod-php"])], php-[deployments-(exists, ["loginpage1-badsql"])], mysql-[db-(exists, ["logindb1"]), root-(only, [generatePassword])]]).

%vuln('web-login-admin(brute-force)', [login_page, web_user_list], [web_admin_access, web_passwords], []).
vuln('web-login-admin', [login_page, web_user_list, web_passwords], [web_admin_access], MachineSrcNum, MachineSrcNum, []).

vuln('sql-injection', [login_page, bad_sql], [db_access], MachineSrcNum, MachineSrcNum, []).

vuln('exec-custom-php', [php_webapp, web_admin_access], [user_shell], MachineSrcNum, MachineSrcNum, []).

% == Database ==
vuln('db-query-users', [db_access], [web_user_list, hashed_web_passwords], MachineSrcNum, MachineSrcNum, [mysql-[db-(exists, ["logindb1"])]]).

% == Java ==

%vuln('scan-jboss', [http], [jboss],
%        [jboss-[]]).

% CVE-2017-12149
%vuln('deserialization-attack', [jboss], [user_shell],
%        [jboss-[version-(only, ["5.2.2"]),
%                deployments-(exists, ["jbossdemo1.war"])]]).

% == Password cracking ==
vuln('exposed-shadow-file', [user_shell], [hashed_passwords], MachineSrcNum, MachineSrcNum, []).
vuln('exposed-shadow-file', [ftp], [hashed_passwords], MachineSrcNum, MachineSrcNum, []).

vuln('crack-hashes', [hashed_passwords], [passwords], MachineSrcNum, MachineSrcNum, []).
vuln('crack-hashes', [hashed_web_passwords], [web_passwords], MachineSrcNum, MachineSrcNum, []).

% == User shell to root shell (privilege escalation) ==
vuln('scan-for-setuid-binary', [user_shell], [setuid_binary], MachineSrcNum, MachineSrcNum, []).

vuln('examine-setuid-binary', [setuid_binary], [assumed_PATH_var], MachineSrcNum, MachineSrcNum, []).

vuln('custom-PATH-setuid', [user_shell, setuid_binary, assumed_PATH_var], [root_shell], MachineSrcNum, MachineSrcNum, []).

%vuln('scan-for-root-cronjobs', [user_shell], [root_cronjob], []).

%vuln('hijack-root-cronjob', [root_cronjob], [root_shell], []).
% vuln('ip-whitelist01', [], [whitelist], 0, 1, [ufw-[ips-[(only, '0')]]]).
% vuln('goal-vuln', [middle], [goal], MachineSrcNum, MachineSrcNum, []).
% vuln('middle-vuln', [start], [middle], MachineSrcNum, MachineSrcNum, []).
% vuln('start-vuln', [], [start], MachineSrcNum, MachineSrcNum, []).