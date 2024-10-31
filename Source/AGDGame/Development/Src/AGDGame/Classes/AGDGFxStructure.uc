// The object that will show the current skill levels and inventory of the double clicked character

class AGDGFxStructure extends GFxMoviePlayer;

var GFxClikWidget Upgrade;

var GFxObject Container;
var GFxObject Structure;
var GFxObject Description;
var GFxObject Requirements;

var GFxObject Food;
var GFxObject Wood;
var GFxObject Rock;

var bool bRollOver; // is the mouse cursor over a button?
var string FocusedButton; // what is the name of that button?
var string MouseState; //to check if mouse is inside the movie
var AGDStructure SelectedStructure; //current selected structure


function Init(optional LocalPlayer LocPlay)
{
	super.Init(LocPlay);

	Start();
	Advance(0.0f);

	Container = GetVariableObject("_root.container");

	Structure = GetVariableObject("_root.container.structure");
	Description = GetVariableObject("_root.container.description");
	Requirements = GetVariableObject("_root.container.requirements");

	Food = GetVariableObject("_root.container.food");
	Wood = GetVariableObject("_root.container.wood");
	Rock = GetVariableObject("_root.container.rock");
}

//Initialise widgets for buttons
event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{    
    switch(WidgetName)
    {                 
        case ('upgrade'): // Instance name of the CLIK button in Flash.
            Upgrade = GFxClikWidget(Widget);
			Upgrade.AddEventListener('CLIK_rollOver', OnRollOver);
			Upgrade.AddEventListener('CLIK_rollOut',  OnRollOut);
			Upgrade.AddEventListener('CLIK_press',  OnPress);

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
	case ("upgrade"):
		Upgrade.gotoAndPlay("down");

		SelectedStructure.Upgrade();
		break;
	default:
		break;
	}
}

function Update(AGDStructure structu)
{	
	local string sName;
	SelectedStructure = structu;

	Container.SetFloat("_x", 32);
	Container.SetFloat("_y", 32);

	if (structu.Type == Fire)
		sName = "Fire";
	else if (structu.Type == Home)
		sName = "Home";
	else if (structu.Type == Storage)
		sName = "Storage";
	else if (structu.Type == Study)
		sName = "Study";

	Requirements.SetText("Requirements for Level " $ structu.Level + 1);

	Structure.SetText(sName $ " : Level " $ structu.Level);
	Description.SetText(structu.Description);

    Food.SetText(structu.FoodRq);
	Rock.SetText(structu.RockRq);
	Wood.SetText(structu.WoodRq);

	MouseState = Container.GetString("hitState");
}

DefaultProperties
{
    WidgetBindings.Add((WidgetName="upgrade",WidgetClass=class'GFxClikWidget')) 

    bIgnoreMouseInput = false
    bPauseGameWhileActive = false
    bCaptureInput = false
	bDisplayWithHudOff = false	
	bEnableGammaCorrection=false

	MovieInfo = SwfMovie'AGDHUD.ObjectSelection'
}
