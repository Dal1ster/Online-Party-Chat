class Hat_HUDMenu_OnlineChatInputBlock extends Hat_HUDMenu;

var string YourMessage;
var transient string EnteredMessage;
var Hat_BubbleTalker_InputText_OnlineChatBlock TextEnteringClass;
var transient bool CanEnterText;
var transient float appear_disappear_;

function OnOpenHUD(HUD H, optional string Command)
{
    super.OnOpenHUD(H, Command);
    YourMessage = "";
    EnteredMessage = YourMessage;
    
    if(!CanEnterText)
    {
        CanEnterText = true;
        EnteredMessage = YourMessage;
        appear_disappear_ = 1.60;
        TextEnteringClass = new class'Hat_BubbleTalker_InputText_OnlineChatBlock';
        TextEnteringClass.ChatInputHud = self;
        TextEnteringClass.ChatInputOverlay = Hat_HUD(H);
        TextEnteringClass.AddToInteractions(H.PlayerOwner, 'None', 17);
    }  
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

    PosX = H.Canvas.ClipX * 0.50;
    PosY = H.Canvas.ClipY * 0.350;
    Size = H.Canvas.ClipX * 0.40;
    H.Canvas.SetDrawColor(255, 255, 255, 255);
    Text = "Enter the steam ID of the user you want to block.";
    H.Canvas.Font = class'Hat_FontInfo'.static.GetDefaultFont(Text);
    DrawBorderedText(H.Canvas, Text, PosX - (Size * 0.420), PosY - (Size * 0.0050), Size * 0.0010, false, 0);
    H.Canvas.SetPos(PosX - (Size * 0.4250), PosY + (Size * 0.060), H.Canvas.CurZ);
    H.Canvas.SetDrawColor(0, 0, 0);
    H.Canvas.DrawRect(Size * 0.850, Size * 0.0750);
    H.Canvas.SetPos(PosX - (Size * 0.420), PosY + (Size * 0.0650), H.Canvas.CurZ);
    H.Canvas.SetDrawColor(185, 185, 185);
    H.Canvas.DrawRect(Size * 0.840, Size * 0.0650);
    H.Canvas.SetPos(PosX - (Size * 0.4150), PosY + (Size * 0.070), H.Canvas.CurZ);
    H.Canvas.SetDrawColor(255, 255, 255);
    H.Canvas.DrawRect(Size * 0.83250, Size * 0.0570);
    
    if(CanEnterText)
    {
        H.Canvas.SetDrawColor(0, 0, 0);
    }
    else
    {
        H.Canvas.SetDrawColor(65, 65, 65);
    }

    Text = ((CanEnterText) ? EnteredMessage : YourMessage);
    
    if((CanEnterText && Len(EnteredMessage) <= 16) && appear_disappear_ >= (1.60 / float(2)))
    {
        Text $= "_";
    }

    H.Canvas.Font = class'Hat_FontInfo'.static.GetDefaultFont(Text);
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
    
    if(Len(EnteredMessage) == 17)
    {
        class'OnlineChat_Gamemod'.static.GetThisMod().BlockList.AddItem(EnteredMessage);
        class'OnlineChat_Gamemod'.static.GetThisMod().SaveConfig();
        class'OnlineChat_Gamemod'.static.GetThisMod().DisplayChatMessage(("Added" @ EnteredMessage) @ "to the block list, messages from the user with this steam ID will no longer appear for you.", false);
    }
    else
    {
        class'OnlineChat_Gamemod'.static.GetThisMod().DisplayChatMessage("Error, Invalid steam ID.", false);
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
    Hat_HUD(H).CloseHUD(self.Class);

    return true;
}

defaultproperties
{
	RealTime = true;
	RenderIndex = 2;
	SharedInCoop = true;
}