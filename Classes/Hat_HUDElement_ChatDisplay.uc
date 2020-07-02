class Hat_HUDElement_ChatDisplay extends Hat_HUDElement;

var array<string> DisplayedText, ChatLog;

function bool Render(HUD H)
{
	local float posx, posy, size, chatpos, logpos;
	local int i;

	posx = H.Canvas.ClipX / 8;
	posy = H.Canvas.ClipY;
	size = H.Canvas.ClipX * 0.26;
	
	chatpos = 0.5;
	logpos = 0.2;

	if (class'OnlineChat_Gamemod'.static.GetThisMod().RenderChat)
	{
		DisplayedText = class'OnlineChat_Gamemod'.static.GetThisMod().DisplayedText;
	}
	else
	{
		DisplayedText.Length = 0;
		DisplayedText[0] = "";
	}
	
	ChatLog = class'OnlineChat_Gamemod'.static.GetThisMod().ChatLog;
	
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

	if (class'OnlineChat_Gamemod'.static.GetThisMod().DisplayChatLog)
	{
		H.Canvas.SetDrawColor(255, 255, 255, 255);

		for (i = 0; i < ChatLog.Length; i++)
		{
			DrawBorderedText(H.Canvas, ChatLog[i] , posx-size*0.42, posy-size*logpos, size*0.001, false, TextAlign_Left);
			logpos = logpos + 0.1;
		}

		DrawBorderedText(H.Canvas, "Chat Log:", posx-size*0.42, posy-size*2.11, size*0.002, false, TextAlign_Left);
	}
	else
	{
		if (class'OnlineChat_Gamemod'.static.GetThisMod().TextTransparency == 0)
		{
			H.Canvas.SetDrawColor(255, 255, 255, 255);

			for (i = 0; i < DisplayedText.Length; i++)
			{
				DrawBorderedText(H.Canvas, DisplayedText[i] , posx-size*0.42, posy-size*chatpos, size*0.001, false, TextAlign_Left);
				chatpos = chatpos + 0.1;
			}
		}
		else
		{
			H.Canvas.SetDrawColor(255, 255, 255, 185);

			for (i = 0; i < DisplayedText.Length; i++)
			{
				DrawText(H.Canvas, DisplayedText[i] , posx-size*0.42, posy-size*chatpos, size*0.001, size*0.001, TextAlign_Left);
				chatpos = chatpos + 0.1;
			}
		}
	}

	return true;
}

defaultproperties
{
	RealTime = true;
	RenderIndex = 2;
	SharedInCoop = true;
	RenderInScreenshots = false;
}