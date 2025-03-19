/*
   1.  Use python to scrape data from a wiki page
   2.  Use SAS text functions to clean up the data
   3.  Use SGPlot and SQL to show some results


Code Source:  Jim Box
Update: Samiul Haque 
	- Save the .sashdat file
	- Promote as global table
 	- print python version
  
*/


/*
   Use python to scrape data from a wiki page
   https://en.wikipedia.org/wiki/List_of_Super_Bowl_champions
   Then write it out to a work file
   The python output of the head statement is in the log

*/

proc python;
submit;
import sys
print(sys.version)

import pandas as pd
URL = "https://en.wikipedia.org/wiki/List_of_Super_Bowl_champions"

tables = pd.read_html(URL,attrs = {'class' : 'wikitable sortable sticky-header'})
sb = tables[0]
sb.head()

ds = SAS.df2sd(sb, 'work.sb')
endsubmit;
run;

/*
  Use SAS text functions to clean up the dataset and then make some analysis tables
*/

data SB2;
set SB;
  SB = _N_;
  Season = SB + 1965;
/*   if Attendance in ('TBD', 'Attendance') then delete; */
/*   fans = input(Attendance,8.); */

  Winner = substr('Winning team'n,1,index('Winning team'n,'(')-2);
  Loser = substr('Losing team'n,1,index('Losing team'n,'(')-2);
  WS = input(substr(Score,1,2),2.);
  points = trim(left(scan (score,1,' ')));
  LS = input(substr(points,6,2),2.);

  OT = index(Score,"OT")>0;
  paren = index(City,'(');
  bracket = index(City,'[');
  if paren then locale = substr(City,1,paren-1);
   else if bracket then locale = substr(City,1,bracket-1);
   else locale = trim(left(City));
 
  City1 = scan(locale,1,',');
  State = scan(locale,2,',');
  

run;


Proc SQL;
create table SuperBowl as 
Select SB as Superbowl "SuperBowl Number"
      ,Season "Season"
      ,City1 as City "SB City"
      ,State "SB State"
/*       ,fans as Attendance "Attendance" format = comma9. */
      ,Winner "Winning Team"
      ,Loser "Losing Team"
      ,points as Score "Score"
      ,WS "Winning Score"
      ,LS "Losing Score"
      ,OT "Overtime"
from SB2;
QUIT;


data winners;
set Superbowl;
Team = Winner;
rename WS = Score;
Outcome = "W";
keep SuperBowl Season City State /*Attendance */ Team WS Outcome;
run;

data Losers;
set Superbowl;
Team = Loser;
rename LS = Score;
Outcome = "L";
keep SuperBowl Season City State /*Attendance*/ Team LS Outcome;
run;
 

data teams;
set winners losers;
Franchise = scan(Team,-1);
label Score = "Score";
run;


/*
  Use SG Plot and PROC SQL to show some outputs
*/


ods graphics / reset width=6.4in height=4.8in imagemap;

proc sgplot data=WORK.TEAMS;
	title height=14pt "Superbowl Scores by Outcome";
	vbox Score / category=Outcome boxwidth=0.4;
	yaxis grid label="Score";
run;

ods graphics / reset;
title;



proc sql;
title "Wins by Team";
select winner, count(*) as wins
from Superbowl
group by winner
order by wins descending;

/* title "Attendance by State of Super Bowl Venue"; */
/* Select state, count(*) as games, sum(attendance) as total format = comma9., mean(attendance) as average format = comma9. */
/* from Superbowl */
/* group by state */
/* order by games descending; */

title;
quit;

cas mycas;
caslib _ALL_ assign;

proc casutil;
	droptable casdata='SBTeams' incaslib='PUBLIC' quiet;
	load data=work.teams outcaslib="public"
	casout="SBTeams" replace;
    promote incaslib="public" casdata="SBTeams" outcaslib="public";
	save casdata='SBTeams' incaslib='public' outcaslib='public' replace;
run;


