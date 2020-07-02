/**
 *
 * Copyright 2018-2019 Gears for Breakfast ApS. All Rights Reserved.
 */
class Hat_HUDMenu_GhostParty_Chat_Block extends Hat_HUDMenu;

const CursorBlinkCycle = 1.6;
const LobbyNameMaxLength = 17;

var string LobbyName;
var transient string InputName;

var Hat_BubbleTalker_InputText_GhostParty_Chat_Block InputInstance;
var transient bool IsInputtingName;
var transient float InputCursorBlink;

function OnOpenHUD(HUD H, optional String command)
{
	Super.OnOpenHUD(H, command);

	LobbyName = "";
	InputName = LobbyName;

	if (!IsInputtingName)
	{
		IsInputtingName = true;
		InputName = LobbyName;
		InputCursorBlink = CursorBlinkCycle;

		InputInstance = new class'Hat_BubbleTalker_InputText_GhostParty_Chat_Block';
		InputInstance.LobbyMenu = self;
		InputInstance.LobbyMenuHUD = Hat_Hud(H);
		InputInstance.AddToInteractions(H.PlayerOwner,'', LobbyNameMaxLength);
	}
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

	posx = H.Canvas.ClipX * 0.5;
	posy = H.Canvas.ClipY * 0.35;
	size = H.Canvas.ClipX * 0.4;

	H.Canvas.SetDrawColor(255,255,255,255);

	//	"GROUP NAME" LABEL
	text = "Enter the steam ID of the user you want to block.";
	H.Canvas.Font = class'Hat_FontInfo'.static.GetDefaultFont(text);
	DrawBorderedText(H.Canvas, text, posx-size*0.42, posy-size*0.005, size*0.001, false, TextAlign_Left);

	//	INPUT FIELD
		//	BLACK OUTLINE
	H.Canvas.SetPos(posx-size*0.425, posy+size*0.06, H.Canvas.CurZ);
	H.Canvas.SetDrawColor(0,0,0);
	H.Canvas.DrawRect(size*0.85,size*0.075);
		//	INNER SHADOW
	H.Canvas.SetPos(posx-size*0.42, posy+size*0.065, H.Canvas.CurZ);
	H.Canvas.SetDrawColor(185,185,185);
	H.Canvas.DrawRect(size*0.84,size*0.065);
		//	WHITE FILL
	H.Canvas.SetPos(posx-size*0.415, posy+size*0.07, H.Canvas.CurZ);
	H.Canvas.SetDrawColor(255,255,255);
	H.Canvas.DrawRect(size*0.8325,size*0.057);
		//	LOBBY NAME TEXT
	if (IsInputtingName) H.Canvas.SetDrawColor(0,0,0);
	else H.Canvas.SetDrawColor(65,65,65);
	text = IsInputtingName ? InputName : LobbyName;
	if (IsInputtingName && Len(InputName) <= 16 && InputCursorBlink >= CursorBlinkCycle/2) text $= "_";
	H.Canvas.Font = class'Hat_FontInfo'.static.GetDefaultFont(text);
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

	if (Len(InputName) == 17)
	{
		class'OnlineChat_Gamemod'.static.GetThisMod().BlockList.additem(InputName);
		class'OnlineChat_Gamemod'.static.GetThisMod().SaveConfig();
		class'OnlineChat_Gamemod'.static.GetThisMod().DisplayChatMessage("Added"@InputName@"to the block list, messages from the user with this steam ID will no longer appear for you.", false);
	}
	else
	{
		class'OnlineChat_Gamemod'.static.GetThisMod().DisplayChatMessage("Error, Invalid steam ID.", false);
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

	Hat_HUD(H).CloseHUD(self.Class);

	return true;
}

defaultproperties
{
	RealTime = true;
	RenderIndex = 2;
	SharedInCoop = true;
}