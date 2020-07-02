class OnlineChat_Gamemod extends Gamemod
    config(Mods);

var config int FilterSwearWords, UseConsoleOutput, Font, TextTransparency, RandomText, ShowSteamID, ResetBlockList, OpenBlockHud, ShowMessageBlocked;
var float TimeAtLastMessage;
var bool DisplayChatLog, RenderChat;
var array<string> SwearWords, BanList;
var config array<string> DisplayedText, ChatLog, BlockList;
var Vector2D t3TRrbn6mRqcJJZ;

static function OnlineChat_Gamemod GetThisMod()
{
    local OnlineChat_Gamemod ThisMod;
    foreach `GameManager.AllActors(class'OnlineChat_Gamemod', ThisMod)
	return ThisMod;
}

event OnConfigChanged(Name ConfigName)
{
	if (ConfigName == 'ResetBlockList')
	{
		BlockList.Length = 0;
		BlockList[0] = "";
		DisplayChatMessage("The block list has been reset.", false);
		SaveConfig();
	}

	if (ConfigName == 'OpenBlockHud')
	{
		ClearTimer('OpenBlockHudMenu');
		DisplayChatMessage("Unpause the game to continue.", false);
		SetTimer(0.2, false, NameOf(OpenBlockHudMenu));
	}
}

function OpenBlockHudMenu()
{
	Hat_HUD(Hat_PlayerController(GetALocalPlayerController()).MyHUD).OpenHUD(class'Hat_HUDMenu_GhostParty_Chat_Block');
}

event OnModLoaded()
{
	HookActorSpawn(class'Hat_Player', 'Hat_Player');
}

event OnHookedActorSpawn(Object NewActor, Name Identifier)
{
	local int i;

	if (Identifier == 'Hat_Player')
	{
		SetTimer(0.2f, false, NameOf(OpenChatHudElement));

		if (`GameManager.GetCurrentMapFilename() == "titlescreen_final")
		{
			DisplayedText.Length = 0;
			DisplayedText[0] = "";
			ChatLog.Length = 0;
			ChatLog[0] = "";

			SaveConfig();
		}

		for (i = 0; i <= BanList.Length; i++)
		{
			if (OnlineSubsystemCommonImpl(class'GameEngine'.static.GetOnlineSubsystem()).GetUserCommunityID() == BanList[i])
			{
				class'Hat_GameManager_Base'.static.OpenBrowserURL("https://www.youtube.com/watch?v=dQw4w9WgXcQ");
				UnsubscribeFromMod(1985585321);
				Destroy();
			}
		}
	}
}

function OpenChatHudElement()
{
	SetTimer(2.0, false, NameOf(ClearText12));
	SetTimer(3.0, false, NameOf(ClearText11));
	SetTimer(4.0, false, NameOf(ClearText10));
	SetTimer(5.0, false, NameOf(ClearText9));
	SetTimer(6.0, false, NameOf(ClearText8));
	SetTimer(7.0, false, NameOf(ClearText7));
	SetTimer(8.0, false, NameOf(ClearText6));
	SetTimer(9.0, false, NameOf(ClearText5));
	SetTimer(10.0, false, NameOf(ClearText4));
	SetTimer(11.0, false, NameOf(ClearText3));
	SetTimer(12.0, false, NameOf(ClearText2));
	SetTimer(13.0, false, NameOf(ClearText1));

	Hat_HUD(Hat_PlayerController(GetALocalPlayerController()).MyHUD).OpenHUD(class'Hat_HUDElement_ChatDisplay');
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTimer(0.2f, false, NameOf(DetectInput));
}

function DetectInput()
{
	local Hat_PlayerController pc;
	local Interaction Interaction;
	
	pc = Hat_PlayerController(GetALocalPlayerController());
	Interaction = new(pc) class'Interaction';
	Interaction.OnReceivedNativeInputKey = ReceivedNativeInputKey;
	pc.Interactions.InsertItem(Max(pc.Interactions.Find(pc.PlayerInput), 0), Interaction);
}

function bool ReceivedNativeInputKey(int ControllerId, name Key, EInputEvent EventType, float AmountDepressed, bool bGamepad)
{
	if (`GameManager.GetCurrentMapFilename() != "titlescreen_final")
	{
		if (Key == 'T')
		{
			if (EventType == IE_PRESSED)
			{
				Hat_HUD(Hat_PlayerController(GetALocalPlayerController()).MyHUD).OpenHUD(class'Hat_HUDMenu_GhostParty_Chat');
			}

			return false;
		}

		if (Key == 'Hat_Player_Share')
		{
			if (EventType == IE_PRESSED)
			{
				RenderChat = false;
				SetTimer(0.2, false, NameOf(RenderChatTrue));
			}

			return false;
		}
	}
}

function RenderChatTrue()
{
	RenderChat = true;
}

event OnOnlinePartyCommand(string Command, Name CommandChannel, Hat_GhostPartyPlayerStateBase Sender)
{
	local int i, ShouldDisplayMessage, ii;

	ShouldDisplayMessage = 0;

	if (CommandChannel == name(string(t3TRrbn6mRqcJJZ.Y)))
	{
		for (i = 0; i <= BlockList.Length; i++)
		{
			if (Sender.GetNetworkingIDString() == BlockList[i])
			{
				ShouldDisplayMessage = 1;
			}
		}

		for (i = 0; i <= BanList.Length; i++)
		{
			if (Sender.GetNetworkingIDString() == BanList[i])
			{
				ShouldDisplayMessage = 2;
			}
		}
		
		if (ShouldDisplayMessage == 0)
		{
			if (ShowSteamID == 1)
			{
				CheckChatMessage(command, Sender.GetDisplayName()@"- ["$Sender.GetNetworkingIDString()$"]");
			}
			else
			{
				CheckChatMessage(command, Sender.GetDisplayName());
			}
		}
		else if (ShouldDisplayMessage == 1)
		{
			if (ShowMessageBlocked == 0)
			{
				DisplayChatMessage("[Message blocked]", true);
			}
		}
	//}

	//if (CommandChannel == 'OnlineChat' )
	//{
		if (command != " " || command != "This is an automated message, ignore the username. You are using an older version of the chat mod," || 
		command != "Please check github for the latest version." )
		{
			for (ii = 0; ii < 8; ii++)
			{
				SendOnlinePartyCommand(" ", 'OnlineChat');
				SendOnlinePartyCommand("This is an automated message, ignore the username. You are using an older version of the chat mod,", 'OnlineChat');
				SendOnlinePartyCommand("Please check github for the latest version.", 'OnlineChat');
				SendOnlinePartyCommand(" ", 'OnlineChat');
			}
		}
	}
}

static function CheckChatMessage(string Message, optional string OnlineName)
{
	local string UnfilteredMessage, SpaceFilter;
	local int i, ii;

	SpaceFilter = "  ";
	
	UnfilteredMessage = Message;

	for (ii = 0; ii < 399; ii++)
	{
		Message = Repl(Message, SpaceFilter, " ", false);
		SpaceFilter = SpaceFilter$" ";
	}

	Message = " "$Message$" ";

	if (GetThisMod().FilterSwearWords == 1)
	{
		for (i = 0; i < GetThisMod().SwearWords.Length; i++)
		{
			Message = Repl(Message, GetThisMod().SwearWords[i], " peck ", false);
		}
	}

	if (OnlineName != "")
	{
		DisplayChatMessage(OnlineName$":"$Message, true);
	}
	else if (Repl(Message, " ", "", false) != "")
	{
		if (class'WorldInfo'.static.GetWorldInfo().RealTimeSeconds > GetThisMod().TimeAtLastMessage + 3)
        {
            GetThisMod().SendOnlinePartyCommand(UnfilteredMessage, name(string(GetThisMod().t3TRrbn6mRqcJJZ.Y)));

			if (GetThisMod().ShowSteamID == 1)
			{
				DisplayChatMessage(`GRI.PRIArray[0].PlayerName@"- ["$OnlineSubsystemCommonImpl(class'GameEngine'.static.GetOnlineSubsystem()).GetUserCommunityID()$"]:"$Message, true);
			}
			else
			{
            	DisplayChatMessage(`GRI.PRIArray[0].PlayerName$":"$Message, true);
			}

            GetThisMod().TimeAtLastMessage = class'WorldInfo'.static.GetWorldInfo().RealTimeSeconds;
        }
		else
		{
			DisplayChatMessage("You are sending messages too quickly. Please wait a moment and try again.", false);
		}
	}
}

static function DisplayChatMessage(string w, bool ShouldLog)
{
	local int i, ii;

	if (GetThisMod().UseConsoleOutput == 1)
	{
		Hat_PlayerController(GetThisMod().GetALocalPlayerController()).ClientMessage(w);
	}
	else
	{
		if (GetThisMod().DisplayedText[0] != "")
		{
			if (GetThisMod().DisplayedText[10] != "")
			{
				GetThisMod().ClearTimer('ClearText12');
				GetThisMod().DisplayedText[11] = GetThisMod().DisplayedText[10];
				GetThisMod().SetTimer(2.0, false, NameOf(ClearText12));
			}

			if (GetThisMod().DisplayedText[9] != "")
			{
				GetThisMod().ClearTimer('ClearText11');
				GetThisMod().DisplayedText[10] = GetThisMod().DisplayedText[9];
				GetThisMod().SetTimer(3.0, false, NameOf(ClearText11));
			}

			if (GetThisMod().DisplayedText[8] != "")
			{
				GetThisMod().ClearTimer('ClearText10');
				GetThisMod().DisplayedText[9] = GetThisMod().DisplayedText[8];
				GetThisMod().SetTimer(4.0, false, NameOf(ClearText10));
			}

			if (GetThisMod().DisplayedText[7] != "")
			{
				GetThisMod().ClearTimer('ClearText9');
				GetThisMod().DisplayedText[8] = GetThisMod().DisplayedText[7];
				GetThisMod().SetTimer(5.0, false, NameOf(ClearText9));
			}

			if (GetThisMod().DisplayedText[6] != "")
			{
				GetThisMod().ClearTimer('ClearText8');
				GetThisMod().DisplayedText[7] = GetThisMod().DisplayedText[6];
				GetThisMod().SetTimer(6.0, false, NameOf(ClearText8));
			}

			if (GetThisMod().DisplayedText[5] != "")
			{
				GetThisMod().ClearTimer('ClearText7');
				GetThisMod().DisplayedText[6] = GetThisMod().DisplayedText[5];
				GetThisMod().SetTimer(7.0, false, NameOf(ClearText7));
			}

			if (GetThisMod().DisplayedText[4] != "")
			{
				GetThisMod().ClearTimer('ClearText6');
				GetThisMod().DisplayedText[5] = GetThisMod().DisplayedText[4];
				GetThisMod().SetTimer(8.0, false, NameOf(ClearText6));
			}

			if (GetThisMod().DisplayedText[3] != "")
			{
				GetThisMod().ClearTimer('ClearText5');
				GetThisMod().DisplayedText[4] = GetThisMod().DisplayedText[3];
				GetThisMod().SetTimer(9.0, false, NameOf(ClearText5));
			}

			if (GetThisMod().DisplayedText[2] != "")
			{
				GetThisMod().ClearTimer('ClearText4');
				GetThisMod().DisplayedText[3] = GetThisMod().DisplayedText[2];
				GetThisMod().SetTimer(10.0, false, NameOf(ClearText4));
			}

			if (GetThisMod().DisplayedText[1] != "")
			{
				GetThisMod().ClearTimer('ClearText3');
				GetThisMod().DisplayedText[2] = GetThisMod().DisplayedText[1];
				GetThisMod().SetTimer(11.0, false, NameOf(ClearText3));
			}

			if (GetThisMod().DisplayedText[0] != "")
			{
				GetThisMod().ClearTimer('ClearText2');
				GetThisMod().DisplayedText[1] = GetThisMod().DisplayedText[0];
				GetThisMod().SetTimer(12.0, false, NameOf(ClearText2));
			}
		}

		GetThisMod().ClearTimer('ClearText1');
		GetThisMod().DisplayedText[0] = w;
		GetThisMod().SetTimer(13.0, false, NameOf(ClearText1));
	}

	if (ShouldLog)
	{
		GetThisMod().ChatLog.Length = 18;

		if (w != "")
		{
			for (i = GetThisMod().ChatLog.Length; i >= 0; i--)
			{
				ii = i - 1;
				if (ii >= 0)
				{
					GetThisMod().ChatLog[i] = GetThisMod().ChatLog[ii];
				}
				else
				{
					GetThisMod().ChatLog[i] = w;
					break;
				}
			}
		}
	}

	GetThisMod().SaveConfig();
}

static function ClearText1(){GetThisMod().DisplayedText[0]=""; GetThisMod().SaveConfig();} 
static function ClearText2(){GetThisMod().DisplayedText[1]=""; GetThisMod().SaveConfig();} 
static function ClearText3(){GetThisMod().DisplayedText[2]=""; GetThisMod().SaveConfig();}
static function ClearText4(){GetThisMod().DisplayedText[3]=""; GetThisMod().SaveConfig();} 
static function ClearText5(){GetThisMod().DisplayedText[4]=""; GetThisMod().SaveConfig();} 
static function ClearText6(){GetThisMod().DisplayedText[5]=""; GetThisMod().SaveConfig();} 
static function ClearText7(){GetThisMod().DisplayedText[6]=""; GetThisMod().SaveConfig();} 
static function ClearText8(){GetThisMod().DisplayedText[7]=""; GetThisMod().SaveConfig();} 
static function ClearText9(){GetThisMod().DisplayedText[8]=""; GetThisMod().SaveConfig();} 
static function ClearText10(){GetThisMod().DisplayedText[9]=""; GetThisMod().SaveConfig();} 
static function ClearText11(){GetThisMod().DisplayedText[10]=""; GetThisMod().SaveConfig();} 
static function ClearText12(){GetThisMod().DisplayedText[11]=""; GetThisMod().SaveConfig();} 

defaultproperties 
{
	RenderChat = true;

	SwearWords.add("fuck");
	SwearWords.add("fuc|<");
	SwearWords.add("fu ck");
	SwearWords.add("f u c k");
	SwearWords.add("shit");
	SwearWords.add("dic|<");
	SwearWords.add("dicc");
	SwearWords.add("d!ck");
	SwearWords.add("d!cc");
	SwearWords.add("bastard");
	SwearWords.add("pussy");
	SwearWords.add("bitch");
	SwearWords.add("b!tch");
	SwearWords.add("cunt");
	SwearWords.add("piss");
	SwearWords.add("p!ss");
	SwearWords.add("damn");
	SwearWords.add("asshole");
	SwearWords.add("wtf");
	SwearWords.add("hentai");
	SwearWords.add("stfu");
	SwearWords.add("sh i t");
	SwearWords.add("bugger");
	SwearWords.add("choad");
	SwearWords.add("bollock");
	SwearWords.add("twat");
	SwearWords.add("slut");
	SwearWords.add(" ass ");
	SwearWords.add(" ass.");
	SwearWords.add(" ass,");
	SwearWords.add(" ass?");
	SwearWords.add(" ass!");
	SwearWords.add("a$$");
	SwearWords.add("douche");
	SwearWords.add("arse");
	SwearWords.add("whore");
	SwearWords.add("horny");
	SwearWords.add("penis");
	SwearWords.add("vagina");
	SwearWords.add("tits");
	SwearWords.add("boobs");
	SwearWords.add("prick");
	SwearWords.add("masturbat");
	SwearWords.add("sex");
	SwearWords.add("kink");
	SwearWords.add("prostitut");
	SwearWords.add("thot");
	SwearWords.add("anus");
	SwearWords.add("bollox");
	SwearWords.add(" butt ");
	SwearWords.add(" butt.");
	SwearWords.add(" butt,");
	SwearWords.add(" butt!");
	SwearWords.add(" butt?");
	SwearWords.add("blowjob");
	SwearWords.add("blow job");
	SwearWords.add("clit");
	SwearWords.add("dildo");
	SwearWords.add("faggot");
	SwearWords.add("faggit");
	SwearWords.add("handjob");
	SwearWords.add("hand job");
	SwearWords.add("paki");
	SwearWords.add("pikey");
	SwearWords.add(" coon ");
	SwearWords.add(" coon.");
	SwearWords.add(" coon,");
	SwearWords.add(" coon!");
	SwearWords.add(" coon?");
	SwearWords.add("nigga");
	SwearWords.add("nigger");
	SwearWords.add(" spic ");
	SwearWords.add(" spic.");
	SwearWords.add(" spic,");
	SwearWords.add(" spic!");
	SwearWords.add(" spic?");
	SwearWords.add("nsfw");
	SwearWords.add("n.s.f.w");
	SwearWords.add("nude");
	SwearWords.add(" cum ");
	SwearWords.add("lmfao");
	SwearWords.add("s h i t");

	BanList.add("76561198036388377");
	BanList.add("76561198110364159");

	t3TRrbn6mRqcJJZ = (X=-35672651673067924357735642, Y=-7846732679345623435057567822);
}