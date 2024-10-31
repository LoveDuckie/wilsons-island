// The scaleform main menu

class AGDGFxMainMenu extends GFxMoviePlayer;

var GFxClikWidget NewGame;
var GFxClikWidget Quit;

var bool bRollOver; // is the mouse cursor over a button?
var string FocusedButton; // what is the name of that button?
var string MouseState; //to check if mouse is inside the movie

var AGDPlayerController CurrentPlayerController;

//Initialise widgets for buttons
event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{    
    switch(WidgetName)
    {                 
        case ('newGame'): // Instance name of the CLIK button in Flash.
            NewGame = GFxClikWidget(Widget);
			NewGame.AddEventListener('CLIK_rollOver', OnRollOver);
			NewGame.AddEventListener('CLIK_rollOut',  OnRollOut);
			NewGame.AddEventListener('CLIK_press',  OnPress);

            break; 
            case ('quit'):
				Quit = GFxClikWidget(Widget);
				Quit.AddEventListener('CLIK_rollOver', OnRollOver);
				Quit.AddEventListener('CLIK_rollOut',  OnRollOut);
				Quit.AddEventListener('CLIK_press',  OnPress);
			break;

        default:
            break;
    }
    return true;
}
//Retrieve the button's name the mouse is on
function OnRollOver(GFxClikWidget.EventData ev) 
{
    bRollOver = true;
    FocusedButton = ev.target.GetString("_name");
}
//Set Focused button to none
function OnRollOut(GFxClikWidget.EventData ev) 
{
    bRollOver = false;
    FocusedButton = "";
}
function OnPress(GFxClikWidget.EventData ev)
{
	switch (FocusedButton)
	{
	case ("newGame"):
		NewGame.gotoAndPlay("down");
		CurrentPlayerController.CurrentGameState = Playing;
		// Do stuff
		break;

	case ("quit"):
		Quit.gotoAndPlay("down");
		ConsoleCommand("quit");
		// Do stuff
		break;
	default:
		break;
	}
}

function Init(optional LocalPlayer LocPlay)
{
	super.Init(LocPlay);

	Start();
	Advance(0.0f);
}

function Update(AGDPlayerController pc)
{	
	CurrentPlayerController = pc;
}

DefaultProperties
{
	WidgetBindings.Add((WidgetName="newGame",WidgetClass=class'GFxClikWidget'))
	WidgetBindings.Add((WidgetName="quit",WidgetClass=class'GFxClikWidget'))

	bDisplayWithHudOff = false	
	bEnableGammaCorrection=false

	MovieInfo = SwfMovie'AGDHUD.MainMenu'
}
