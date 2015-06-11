#include<io.h>
#include<time.h>
#include<conio.h>
#include<stdio.h>
#include<direct.h>
#include<stdlib.h>
#include<string.h>
#include<process.h>
#include<windows.h>
int s[40][23][2];
int head[2];
int head2[2];
int tail[2];
int tail2[2];
int direct[2];
int direct2[2];
int forbiddirect[2];
int forbiddirect2[2];
int food[2];
int grow;
int grow2;
int earn;
int over;
int life;
int life2;
int speed;
int score;
int score2;
int length;
int length2;
int player;
char again;
int d[8][2]={1,0,1,1,0,1,-1,1,-1,0,-1,-1,0,-1,1,-1};
void intout(int x,int y,int piece)
{
	COORD coord;
	coord.X=x;
	coord.Y=y;
	SetConsoleCursorPosition(GetStdHandle(STD_OUTPUT_HANDLE),coord);
	printf("%d",piece);
}
void strout(int x,int y,char *piece)
{
	COORD coord;
	coord.X=x;
	coord.Y=y;
	SetConsoleCursorPosition(GetStdHandle(STD_OUTPUT_HANDLE),coord);
	printf(piece);
}
void turn()
{
	char input;
	while(1)
	{
		input=getch();
		if(over)
			return;
		if(player==2)
		{
			switch(input)
			{
				case 'w':
					if(forbiddirect2[0]==0&&forbiddirect2[1]==-1)
						break;
					direct2[0]=0;
					direct2[1]=-1;
					break;
				case 'd':
					if(forbiddirect2[0]==1&&forbiddirect2[1]==0)
						break;
					direct2[0]=1;
					direct2[1]=0;
					break;
				case 's':
					if(forbiddirect2[0]==0&&forbiddirect2[1]==1)
						break;
					direct2[0]=0;
					direct2[1]=1;
					break;
				case 'a':
					if(forbiddirect2[0]==-1&&forbiddirect2[1]==0)
						break;
					direct2[0]=-1;
					direct2[1]=0;
					break;
			}
		}
		if(input==-32)
		{
			input=getch();
			switch(input)
			{
				case 72:
					if(forbiddirect[0]==0&&forbiddirect[1]==-1)
						break;
					direct[0]=0;
					direct[1]=-1;
					break;
				case 77:
					if(forbiddirect[0]==1&&forbiddirect[1]==0)
						break;
					direct[0]=1;
					direct[1]=0;
					break;
				case 80:
					if(forbiddirect[0]==0&&forbiddirect[1]==1)
						break;
					direct[0]=0;
					direct[1]=1;
					break;
				case 75:
					if(forbiddirect[0]==-1&&forbiddirect[1]==0)
						break;
					direct[0]=-1;
					direct[1]=0;
					break;
			}
		}
	}
}
void foodrevive()
{
	int flag=0;
	for(int i=0;i!=40;i++)
	{
		for(int j=0;j!=23;j++)
			if(s[i][j][0]==-1)
			{
				flag=1;
				break;
			}
		if(flag)
			break;
	}
	if(!flag)
	{
		food[0]=100;
		return;
	}
	while(s[(food[0]=rand()%40)][(food[1]=rand()%23)][0]!=-1);
	s[food[0]][food[1]][0]=-2;
	strout(food[0]*2,food[1]+1,"※");
}
void revive(int mode)
{
	if(mode==0)
	{
		length=4;
		int temp1[2];
		int temp2[2];
		temp1[0]=tail[0];
		temp1[1]=tail[1];
		for(int i=0;i!=3;i++)
		{
			temp2[0]=temp1[0];
			temp2[1]=temp1[1];
			temp1[0]=s[temp2[0]][temp2[1]][0];
			temp1[1]=s[temp2[0]][temp2[1]][1];
		}
		head[0]=temp1[0];
		head[1]=temp1[1];
		direct[0]=temp1[0]-temp2[0];
		direct[1]=temp1[1]-temp2[1];
		forbiddirect[0]=-direct[0];
		forbiddirect[1]=-direct[1];
		if(s[temp1[0]][temp1[1]][0]!=100)
		{
			temp2[0]=temp1[0];
			temp2[1]=temp1[1];
			temp1[0]=s[temp2[0]][temp2[1]][0];
			temp1[1]=s[temp2[0]][temp2[1]][1];
			while(s[temp1[0]][temp1[1]][0]!=100)
			{
				temp2[0]=temp1[0];
				temp2[1]=temp1[1];
				temp1[0]=s[temp2[0]][temp2[1]][0];
				temp1[1]=s[temp2[0]][temp2[1]][1];
				s[temp2[0]][temp2[1]][0]=-1;
				strout(temp2[0]*2,temp2[1]+1,"  ");
			}
			s[temp1[0]][temp1[1]][0]=-1;
			strout(temp1[0]*2,temp1[1]+1,"  ");
		}
		s[head[0]][head[1]][0]=100;
		strout(head[0]*2,head[1]+1,"◎");
	}
	else
	{
		length2=4;
		int temp1[2];
		int temp2[2];
		temp1[0]=tail2[0];
		temp1[1]=tail2[1];
		for(int i=0;i!=3;i++)
		{
			temp2[0]=temp1[0];
			temp2[1]=temp1[1];
			temp1[0]=s[temp2[0]][temp2[1]][0];
			temp1[1]=s[temp2[0]][temp2[1]][1];
		}
		head2[0]=temp1[0];
		head2[1]=temp1[1];
		direct2[0]=temp1[0]-temp2[0];
		direct2[1]=temp1[1]-temp2[1];
		forbiddirect2[0]=-direct2[0];
		forbiddirect2[1]=-direct2[1];
		if(s[temp1[0]][temp1[1]][0]!=100)
		{
			temp2[0]=temp1[0];
			temp2[1]=temp1[1];
			temp1[0]=s[temp2[0]][temp2[1]][0];
			temp1[1]=s[temp2[0]][temp2[1]][1];
			while(s[temp1[0]][temp1[1]][0]!=100)
			{
				temp2[0]=temp1[0];
				temp2[1]=temp1[1];
				temp1[0]=s[temp2[0]][temp2[1]][0];
				temp1[1]=s[temp2[0]][temp2[1]][1];
				s[temp2[0]][temp2[1]][0]=-1;
				strout(temp2[0]*2,temp2[1]+1,"  ");
			}
			s[temp1[0]][temp1[1]][0]=-1;
			strout(temp1[0]*2,temp1[1]+1,"  ");
		}
		s[head2[0]][head2[1]][0]=100;
		strout(head2[0]*2,head2[1]+1,"⊙");
	}
	if(food[0]==100)
		foodrevive();
}
void wait()
{
	strout(0,0,"Wait：");
	intout(6,0,3);
	Sleep(1000);
	intout(6,0,2);
	Sleep(1000);
	intout(6,0,1);
	Sleep(1000);
	strout(0,0,"       ");
}
void move()
{
	restart:
	while(1)
	{
		Sleep(speed);
		int th[4]={(head[0]+direct[0]+40)%40,(head[1]+direct[1]+23)%23,(head2[0]+direct2[0]+40)%40,(head2[1]+direct2[1]+23)%23};
		if(player==2&&(s[th[0]][th[1]][0]>=0&&s[th[2]][th[3]][0]>=0||(th[0]==th[2]&&th[1]==th[3])))
		{
			life--;
			life2--;
			score/=2;
			score2/=2;
			if(life==0||life2==0)
				return;
			strout(22,0,"             ");
			strout(22,24,"             ");
			intout(22,0,score);
			intout(22,24,score2);
			strout(43,0,"            ");
			strout(43,24,"            ");
			intout(43,0,4);
			intout(43,24,4);
			intout(61,0,life);
			intout(61,24,life2);
			revive(0);
			revive(1);
			wait();
			goto restart;
		}
		else if(s[th[0]][th[1]][0]>=0)
		{
			if(player==2)
			{
				score/=2;
				score2+=score;
				life--;
				if(life==0)
					return;
				strout(22,0,"             ");
				intout(22,0,score);
				intout(22,24,score2);
				strout(43,0,"            ");
				intout(43,0,4);
				intout(61,0,life);
				revive(0);
				wait();
				goto restart;
			}
			else
			{
				life--;
				if(life==0)
					return;
				score/=2;
				strout(22,0,"             ");
				intout(22,0,score);
				strout(43,0,"            ");
				intout(43,0,4);
				intout(61,0,life);
				revive(0);
				wait();
				goto restart;
			}
		}
		else if(player==2&&s[th[2]][th[3]][0]>=0)
		{
			score2/=2;
			score+=score2;
			life2--;
			if(life2==0)
				return;
			intout(22,0,score);
			strout(22,24,"             ");
			intout(22,24,score2);
			strout(43,24,"            ");
			intout(43,24,4);
			intout(61,24,life2);
			revive(1);
			wait();
			goto restart;
		}
		strout(head[0]*2,head[1]+1,"●");
		s[head[0]][head[1]][0]=(head[0]+direct[0]+40)%40;
		s[head[0]][head[1]][1]=(head[1]+direct[1]+23)%23;
		head[0]=(head[0]+direct[0]+40)%40;
		head[1]=(head[1]+direct[1]+23)%23;
		if(player==2)
		{
			strout(head2[0]*2,head2[1]+1,"●");
			s[head2[0]][head2[1]][0]=(head2[0]+direct2[0]+40)%40;
			s[head2[0]][head2[1]][1]=(head2[1]+direct2[1]+23)%23;
			head2[0]=(head2[0]+direct2[0]+40)%40;
			head2[1]=(head2[1]+direct2[1]+23)%23;
		}
		s[head[0]][head[1]][0]=100;
		strout(head[0]*2,head[1]+1,"◎");
		forbiddirect[0]=-direct[0];
		forbiddirect[1]=-direct[1];
		if(player==2)
		{
			s[head2[0]][head2[1]][0]=100;
			strout(head2[0]*2,head2[1]+1,"⊙");
			forbiddirect2[0]=-direct2[0];
			forbiddirect2[1]=-direct2[1];
		}
		if(grow)
		{
			grow--;
			length++;
			intout(43,0,length);
		}
		else
		{
			strout(tail[0]*2,tail[1]+1,"  ");
			int temp[2]={tail[0],tail[1]};
			tail[0]=s[temp[0]][temp[1]][0];
			tail[1]=s[temp[0]][temp[1]][1];
			s[temp[0]][temp[1]][0]=-1;
		}
		if(grow2)
		{
			grow2--;
			length2++;
			intout(43,24,length2);
		}
		else if(player==2)
		{
			strout(tail2[0]*2,tail2[1]+1,"  ");
			int temp[2]={tail2[0],tail2[1]};
			tail2[0]=s[temp[0]][temp[1]][0];
			tail2[1]=s[temp[0]][temp[1]][1];
			s[temp[0]][temp[1]][0]=-1;
		}
		if(head[0]==food[0]&&head[1]==food[1])
		{
			grow+=3;
	        score+=earn;
	        earn++;
	        intout(22,0,score);
			foodrevive();
		}
		if(player==2&&head2[0]==food[0]&&head2[1]==food[1])
		{
			grow2+=3;
	        score2+=earn;
	        earn++;
	        intout(22,24,score2);
			foodrevive();
		}
	}
}
void paint(char x,char y,char route[])
{
	head[0]=x;
	head[1]=y;
	strout(head[0]*2,head[1],"◎");
	for(int i=0;route[i]!='\0';i++)
	{
		Sleep(20);
		strout(head[0]*2,head[1],"●");
		switch(route[i])
		{
			case 'u':
				head[1]--;
				break;
			case 'd':
				head[1]++;
				break;
			case 'l':
				head[0]--;
				break;
			case 'r':
				head[0]++;
				break;
		}
		strout(head[0]*2,head[1],"◎");
	}
	Sleep(20);
	strout(head[0]*2,head[1],"●");
}
void gameover()
{
	score+=life*100;
	score2+=life2*100;
	strout(15,0,"Score：");
	intout(22,0,score);
	strout(35,0,"Length：");
	intout(43,0,length);
	strout(55,0,"Life：");
	intout(61,0,life);
	strout(62,0,"*");
	if(player==2)
	{
		strout(15,24,"Score：");
		intout(22,24,score2);
		strout(35,24,"Length：");
		intout(43,24,length2);
		strout(55,24,"Life：");
        intout(61,24,life2);
        strout(62,24,"*");
		if(score>score2)
			strout(36,2,"1P wins");
		else if(score==score2)
			strout(38,2,"Tie");
		else
			strout(36,2,"2P wins");
	}
	char g[]="lullldldlddldddddrdrrrrururuulll";
	char a[]="luuuuuulluldldldldddrdrrruru";
	char m1[]="drdddddd";
	char m2[]="urdrdddddd";
	char m3[]="rurdrddlddddrru";
	char e1[]="rrrruuulluldlldlddddrdrrrrrur";
	char o[]="ruruuruuuuluululllldldlddlddddrdrdrdrr";
	char v[]="ddrddddrdrruuruuruuru";
	char e2[]="rdrrruruululllldldlddddrdrrrrurr";
	char r1[]="rddddddd";
	char r2[]="rurrrdr";
	paint(9,2,g);
	paint(18,11,a);
	paint(19,4,m1);
	paint(21,5,m2);
	paint(24,5,m3);
	paint(31,8,e1);
	paint(9,22,o);
	paint(14,16,v);
	paint(25,19,e2);
	paint(32,16,r1);
	paint(34,17,r2);
}
void initialize()
{
	speed=50;
	life=3;
    for(int i=0; i!=23; i++)
        for(int j=0; j!=40; j++)
            s[j][i][0]=-1;

	s[18][9][0]=19;
	s[18][9][1]=9;
	s[19][9][0]=20;
	s[19][9][1]=9;
	s[20][9][0]=21;
	s[20][9][1]=9;
	s[21][9][0]=0;
	head[0]=21;
	head[1]=9;
	tail[0]=18;
	tail[1]=9;
	earn=1;
	over=0;
	score=0;
	direct[0]=1;
	direct[1]=0;
	forbiddirect[0]=-1;
	forbiddirect[1]=0;
	grow=0;
	length=4;
	if(player==2)
	{
		score2=0;
		s[18][12][0]=19;
		s[18][12][1]=12;
		s[19][12][0]=20;
		s[19][12][1]=12;
		s[20][12][0]=21;
		s[20][12][1]=12;
		s[21][12][0]=0;
		head2[0]=21;
		head2[1]=12;
		tail2[0]=18;
		tail2[1]=12;
		direct2[0]=1;
		direct2[1]=0;
		forbiddirect2[0]=-1;
		forbiddirect2[1]=0;
		grow2=0;
		length2=4;
	}
	srand(time(NULL));
	for(int i=0;i!=40;i++)
		for(int j=0;j!=23;j++)
			if(s[i][j][0]==0)
				strout(i*2,j+1,"█");
	strout(15,0,"Score：0");
	strout(35,0,"Length：4");
	strout(55,0,"Life：");
	intout(61,0,life);
	strout(62,0,"*");
	strout(36,10,"●●●◎");
	if(player==2)
	{
		strout(15,24,"Score：0");
		strout(35,24,"Length：4");
        strout(55,24,"Life：");
        intout(61,24,life2);
        strout(62,24,"*");
		strout(36,13,"●●●⊙");
	}
	foodrevive();
}
int main()
{
	CONSOLE_CURSOR_INFO structCursorInfo;
	GetConsoleCursorInfo(GetStdHandle(STD_OUTPUT_HANDLE),&structCursorInfo);
	structCursorInfo.bVisible=FALSE;
	SetConsoleCursorInfo(GetStdHandle(STD_OUTPUT_HANDLE),&structCursorInfo);
restart:
	initialize();
	strout(35,16,"Press Enter");
	while(getch()!=13);
	for(int i=17;i!=23;i++)
	{
		if(s[i][15][0]==0)
			strout(i*2,16,"█");
		else if(s[i][15][0]==-2)
			strout(i*2,16,"※");
		else
			strout(i*2,16,"  ");
	}
	CreateThread(NULL,0,(LPTHREAD_START_ROUTINE)turn,0,0,NULL);
	move();
	system("cls");
	gameover();
	over=1;
	keybd_event(VK_SPACE, 0, 0, 0);
	strout(34,14,"Play Again(Y/n)");
	again=getch();
	if(again=='n'||again=='N')
		return 0;
	system("cls");
	goto restart;
}