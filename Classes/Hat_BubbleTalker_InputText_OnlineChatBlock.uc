class Hat_BubbleTalker_InputText_OnlineChatBlock extends Hat_BubbleTalker_InputText;

var Hat_HUDMenu_OnlineChatInputBlock ChatInputHud;
var Hat_HUD ChatInputOverlay;

function DrawInputText(HUD H, Hat_BubbleTalkerQuestion Element, float fTime, float fX, float fY)
{
    return;
}

function TickInputText(Hat_BubbleTalkerQuestion Element, float D)
{
    return;  
}

function bool InputKey(int ControllerId, name Key, EInputEvent EventType, optional float AmountDepressed, optional bool bGamepad)
{
    AmountDepressed = 1.0;
    bGamepad = false;
    
    if(!super.InputKey(ControllerId, Key, EventType, AmountDepressed, bGamepad) && (EventType == 0) || EventType == 2)
    {
        return false;
    }
    
    if(ChatInputHud == none)
    {
        return true;
    }
    
    if(((Key == 'BackSpace') && Len(ChatInputHud.EnteredMessage) > 0) && (EventType == 0) || EventType == 2)
    {
        ChatInputHud.EnteredMessage = Left(ChatInputHud.EnteredMessage, Len(ChatInputHud.EnteredMessage) - 1);
    }

    return true;
}

function AddCharacter(string S)
{
    Result = "";
    super.AddCharacter(S);
    
    if(InStr("1234567890", Result) == -1)
    {
        return;
    }
    
    if((ChatInputHud != none) && Len(ChatInputHud.EnteredMessage) < CharacterLength)
    {
        ChatInputHud.EnteredMessage $= Result;
    }  
}

function PlaySoundToPlayerControllers(SoundCue C) {}