/**
 *
 * Copyright 2018-2019 Gears for Breakfast ApS. All Rights Reserved.
 */
class Hat_HUDMenu_GhostParty_Chat extends Hat_HUDMenu;

const CursorBlinkCycle = 1.6;
const LobbyNameMaxLength = 400;

var array<string> RandomText;
var string CurrentRandomText;

var string LobbyName;
var transient string InputName;

var Hat_BubbleTalker_InputText_GhostParty_Chat InputInstance;
var transient bool IsInputtingName;
var transient float InputCursorBlink;

function OnOpenHUD(HUD H, optional String command)
{
	Super.OnOpenHUD(H, command);

	LobbyName = "";
	InputName = LobbyName;

	class'OnlineChat_Gamemod'.static.GetThisMod().DisplayChatLog = true;

	if (!IsInputtingName)
	{
		IsInputtingName = true;
		InputName = LobbyName;
		InputCursorBlink = CursorBlinkCycle;

		InputInstance = new class'Hat_BubbleTalker_InputText_GhostParty_Chat';
		InputInstance.LobbyMenu = self;
		InputInstance.LobbyMenuHUD = Hat_Hud(H);
		InputInstance.AddToInteractions(H.PlayerOwner,'', LobbyNameMaxLength);
	}

	CurrentRandomText = RandomText[Rand(RandomText.Length)];
}

function bool Tick(HUD H, float d)
{
	if (IsInputtingName)
	{
		if (InputCursorBlink > 0) InputCursorBlink -= d;
		else InputCursorBlink = CursorBlinkCycle;
	}

	return true;
}

function bool DisablesMovement(HUD H) { return true; }
function bool DisablesCameraMovement(HUD H) { return true; }

function bool Render(HUD H)
{
	local float posx, posy, size;
	local string text;
	if (!Super.Render(H)) return false;

	posy = H.Canvas.ClipY * 0.908;
	size = H.Canvas.ClipX * 0.4;
	posx = H.Canvas.ClipX * 0.17;

	//	"GROUP NAME" LABEL

	H.Canvas.SetDrawColor(255,255,255,255);

	switch (class'OnlineChat_Gamemod'.static.GetThisMod().Font)
	{
		case 0:
			H.Canvas.Font = class'Hat_FontInfo'.static.GetDefaultFont("");
			break;
		case 1:
			H.Canvas.Font = class'Hat_FontInfo'.static.GetSignikaNegativeFont("");
			break;
		case 2:
			H.Canvas.Font = class'Hat_FontInfo'.static.GetPublicEnemyFont("");
			break;
		case 3:
			H.Canvas.Font = class'Hat_FontInfo'.static.GetDefaultSmallFont("");
			break;
		case 4:
			H.Canvas.Font = class'Engine'.Static.GetTinyFont();
			break;
		case 5:
			H.Canvas.Font = class'Engine'.Static.GetSmallFont();
			break;
	}

	if (class'OnlineChat_Gamemod'.static.GetThisMod().RandomText == 0)
	{
		DrawBorderedText(H.Canvas, "Random Text: "@CurrentRandomText, H.Canvas.ClipX / 2, H.Canvas.ClipY / 18, size*0.001, false, TextAlign_Center);
	}
	else if (class'OnlineChat_Gamemod'.static.GetThisMod().RandomText == 2)
	{
		DrawBorderedText(H.Canvas, CurrentRandomText, H.Canvas.ClipX / 2, H.Canvas.ClipY / 18, size*0.001, false, TextAlign_Center);
	}

	H.Canvas.SetPos(posx-size*0.425, posy+size*0.06, H.Canvas.CurZ);
	H.Canvas.SetDrawColor(0,0,0);
	H.Canvas.DrawRect(size*2.635,size*0.075);
		//	INNER SHADOW
	H.Canvas.SetPos(posx-size*0.42, posy+size*0.065, H.Canvas.CurZ);
	H.Canvas.SetDrawColor(185,185,185);
	H.Canvas.DrawRect(size*2.604,size*0.065);
		//	WHITE FILL
	H.Canvas.SetPos(posx-size*0.415, posy+size*0.07, H.Canvas.CurZ);
	H.Canvas.SetDrawColor(255,255,255);
	H.Canvas.DrawRect(size*2.58,size*0.057);
		//	LOBBY NAME TEXT
	if (IsInputtingName) H.Canvas.SetDrawColor(0,0,0);
	else H.Canvas.SetDrawColor(65,65,65);
	
	text = IsInputtingName ? InputName : LobbyName;
	if (IsInputtingName && InputCursorBlink >= CursorBlinkCycle/2) text $= "_";
	DrawText(H.Canvas, text, posx-size*0.4075, posy+size*0.0925, size*0.0008, size*0.0008, TextAlign_Left);

	return true;
}

function bool OnAltClick(HUD H, bool release)
{
	return DoClose(H);
}

function bool OnStartButton(HUD H)
{
	return DoClose(H);
}

function bool OnLeftShiftClick(HUD H, bool release)
{
	if (!IsInputtingName) return false;
	if (InputInstance == None) return false;
	InputInstance.IsHoldingLeftShift = !release;
	return false;
}

function bool OnRightShiftClick(HUD H, bool release)
{
	if (!IsInputtingName) return false;
	if (InputInstance == None) return false;
	InputInstance.IsHoldingRightShift = !release;
	return false;
}

function bool OnEnterClick(HUD H, bool release)
{
	if (release)

	LobbyName = InputName;

	if (InputName != "")
	{
		class'OnlineChat_Gamemod'.static.CheckChatMessage(InputName);
	}

	return DoClose(H);
}

function StopInputting(HUD H, optional bool DontSetName = false)
{
	IsInputtingName = false;
	if (!DontSetName)
	{
		LobbyName = InputName;
	}
	if (InputInstance != None)
	{
		InputInstance.Detach(H.PlayerOwner);
		InputInstance = None;
	}
}

function bool DoClose(HUD H)
{
	StopInputting(H, true);

	class'OnlineChat_Gamemod'.static.GetThisMod().DisplayChatLog = false;
	Hat_HUD(H).CloseHUD(self.Class);

	return true;
}

defaultproperties
{
	RealTime = true;
	RenderIndex = 2;
	SharedInCoop = true;

	RandomText.add("egg");
	RandomText.add("Say hello to every peck neck.");
	RandomText.add("What's in your mind?");
	RandomText.add("Shhhh... Snatcher can't read this:");
	RandomText.add("Did someone say something about a ... party?");
	RandomText.add("Keep talking and no one explode");
	RandomText.add("Insert your enquiry to [REDACTED BY C.A.W]");
	RandomText.add("Mafia heard voices... Hat Child say funny thing");
	RandomText.add("Hewwo, miss? Did chu say something?");
	RandomText.add("Sponsored by The Honking Observing Neighborhood Kleptocracy");
	RandomText.add("Boop!");
	RandomText.add("Shoutouts to n!");
	RandomText.add("Is that a Hat Child doing Hat Chat?");
	RandomText.add("Shoutouts to Minaline!");
	RandomText.add("Also try OneShot.");
	RandomText.add("The first thing ever sent in this mod is \"peck\".");
	RandomText.add("gg ez");
	RandomText.add("Use your keyboard to type.");
	RandomText.add("Get Dunked On!");
	RandomText.add("Hat Kid 4 Smash!");
	RandomText.add("Never gonna give you up, Never gonna let you down.");
	RandomText.add("SPEEEEEEEEN!");
	RandomText.add("Do the Mario");
	RandomText.add("Peace was Never an Option.");
	RandomText.add("HONK");
	RandomText.add("Say \"Peck\" to unlock luigi!");
	RandomText.add("Cat Crime!");
	RandomText.add("Doot!");
	RandomText.add("Press alt+f4 for a cookie!");
	RandomText.add("Mustache Girl was here.");
	RandomText.add("Hello fellow express owl");
	RandomText.add("Chat.exe has stopped responding");
	RandomText.add("Your contract has expired");
	RandomText.add("HUZZAH!");
	RandomText.add("Cooking is also considered art.");
	RandomText.add("spaghetti");
	RandomText.add("Error, Sleep is not allowed here");
	RandomText.add("You may not rest now, there are monsters nearby");
	RandomText.add("Shoutouts to Sunbro Dave");
	RandomText.add("The egg is a lie");
	RandomText.add("Shoutouts to Beatstart");
}