/**
 *
 * Copyright 2018-2019 Gears for Breakfast ApS. All Rights Reserved.
 */
class Hat_BubbleTalker_InputText_GhostParty_Chat extends Hat_BubbleTalker_InputText;

var Hat_HUDMenu_GhostParty_Chat LobbyMenu;
var Hat_HUD LobbyMenuHUD;

function DrawInputText(HUD H, Hat_BubbleTalkerQuestion element, float fTime, float fX, float fY) { return; }
function TickInputText(Hat_BubbleTalkerQuestion element, float d) { return; }

function bool InputKey( int ControllerId, name Key, EInputEvent EventType, float AmountDepressed = 1.f, bool bGamepad = FALSE )
{
	if (!Super.InputKey(ControllerId, Key, EventType, AmountDepressed, bGamepad) && (EventType == IE_Pressed || EventType == IE_Repeat)) return false;
	if (LobbyMenu == None) return true;

	if (Key == 'BackSpace' && Len(LobbyMenu.InputName) > 0 && (EventType == IE_Pressed || EventType == IE_Repeat))
	LobbyMenu.InputName = Left(LobbyMenu.InputName, Len(LobbyMenu.InputName)-1);
	
	return true;
}

function AddCharacter(string s)
{
	Result = "";
	Super.AddCharacter(s);
	if (LobbyMenu != None && Len(LobbyMenu.InputName) < CharacterLength)
		if (IsHoldingLeftShift || IsHoldingRightShift)
		{
			LobbyMenu.InputName $= Result;
		}
		else
		{
			LobbyMenu.InputName $= Locs(Result);
		}
}

function PlaySoundToPlayerControllers(SoundCue c) {}