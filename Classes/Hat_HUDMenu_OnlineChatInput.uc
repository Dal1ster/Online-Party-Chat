class Hat_HUDMenu_OnlineChatInput extends Hat_HUDMenu;

var array<string> RandomText;
var string CurrentRandomText;
var string YourMessage;
var transient string EnteredMessage;
var Hat_BubbleTalker_InputText_OnlineChat TextEnteringClass;
var transient bool CanEnterText;
var transient float appear_disappear_;

function OnOpenHUD(HUD H, optional string Command)
{
    super.OnOpenHUD(H, Command);
    YourMessage = "";
    EnteredMessage = YourMessage;
    class'OnlineChat_Gamemod'.static.GetThisMod().DisplayChatLog = true;
    
    if(!CanEnterText)
    {
        CanEnterText = true;
        EnteredMessage = YourMessage;
        appear_disappear_ = 1.60;
        TextEnteringClass = new class'Hat_BubbleTalker_InputText_OnlineChat';
        TextEnteringClass.ChatInputHud = self;
        TextEnteringClass.ChatInputOverlay = Hat_HUD(H);
        TextEnteringClass.AddToInteractions(H.PlayerOwner, 'None', 400);
    }

    CurrentRandomText = RandomText[Rand(RandomText.Length)];  
}

function bool Tick(HUD H, float D)
{
    if(CanEnterText)
    {
        if(appear_disappear_ > float(0))
        {
            appear_disappear_ -= D;
        }
        else
        {
            appear_disappear_ = 1.60;
        }
    }

    return true;
}

function bool DisablesMovement(HUD H)
{
    return true;
}

function bool DisablesCameraMovement(HUD H)
{
    return true;
}

function bool Render(HUD H)
{
    local float PosX, PosY, Size;
    local string Text;

    if(!super(Hat_HUDElement).Render(H))
    {
        return false;
    }

    PosY = H.Canvas.ClipY * 0.9080;
    Size = H.Canvas.ClipX * 0.40;
    PosX = H.Canvas.ClipX * 0.170;
    H.Canvas.SetDrawColor(255, 255, 255, 255);

    switch(class'OnlineChat_Gamemod'.static.GetThisMod().Font)
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
            H.Canvas.Font = class'Engine'.static.GetTinyFont();
            break;
        case 5:
            H.Canvas.Font = class'Engine'.static.GetSmallFont();
            break;
    }

    if(class'OnlineChat_Gamemod'.static.GetThisMod().RandomText == 0)
    {
        DrawBorderedText(H.Canvas, "Random Text: " @ CurrentRandomText, H.Canvas.ClipX / float(2), H.Canvas.ClipY / float(18), Size * 0.0010, false, 1);
    }
    else
    {
        if(class'OnlineChat_Gamemod'.static.GetThisMod().RandomText == 2)
        {
            DrawBorderedText(H.Canvas, CurrentRandomText, H.Canvas.ClipX / float(2), H.Canvas.ClipY / float(18), Size * 0.0010, false, 1);
        }
    }

    H.Canvas.SetPos(PosX - (Size * 0.4250), PosY + (Size * 0.060), H.Canvas.CurZ);
    H.Canvas.SetDrawColor(0, 0, 0);
    H.Canvas.DrawRect(Size * 2.6350, Size * 0.0750);
    H.Canvas.SetPos(PosX - (Size * 0.420), PosY + (Size * 0.0650), H.Canvas.CurZ);
    H.Canvas.SetDrawColor(185, 185, 185);
    H.Canvas.DrawRect(Size * 2.6040, Size * 0.0650);
    H.Canvas.SetPos(PosX - (Size * 0.4150), PosY + (Size * 0.070), H.Canvas.CurZ);
    H.Canvas.SetDrawColor(255, 255, 255);
    H.Canvas.DrawRect(Size * 2.580, Size * 0.0570);
            
    if(CanEnterText)
    {
        H.Canvas.SetDrawColor(0, 0, 0);
    }
    else
    {
        H.Canvas.SetDrawColor(65, 65, 65);
    }
        
    Text = ((CanEnterText) ? EnteredMessage : YourMessage);
            
    if(CanEnterText && appear_disappear_ >= (1.60 / float(2)))
    {
        Text $= "_";
    }

    DrawText(H.Canvas, Text, PosX - (Size * 0.40750), PosY + (Size * 0.09250), Size * 0.00080, Size * 0.00080, 0);
        
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
    if(!CanEnterText)
    {
        return false;
    }
    
    if(TextEnteringClass == none)
    {
        return false;
    }

    TextEnteringClass.IsHoldingLeftShift = !release;

    return false;  
}

function bool OnRightShiftClick(HUD H, bool release)
{
    if(!CanEnterText)
    {
        return false;
    }
    
    if(TextEnteringClass == none)
    {
        return false;
    }

    TextEnteringClass.IsHoldingRightShift = !release;

    return false;  
}

function bool OnEnterClick(HUD H, bool release)
{
    if(release)
    {
        YourMessage = EnteredMessage;
    }
    
    if(EnteredMessage != "")
    {
        class'OnlineChat_Gamemod'.static.CheckChatMessage(EnteredMessage);
    }

    return DoClose(H);
}

function StopInputting(HUD H, optional bool DontSetName)
{
    DontSetName = false;
    CanEnterText = false;
    
    if(!DontSetName)
    {
        YourMessage = EnteredMessage;
    }
    
    if(TextEnteringClass != none)
    {
        TextEnteringClass.Detach(H.PlayerOwner);
        TextEnteringClass = none;
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