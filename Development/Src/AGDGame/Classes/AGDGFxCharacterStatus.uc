// The object that will show the happiness and hunger of the characters

class AGDGFxCharacterStatus extends GFxMoviePlayer;

var GFxObject Container;

var GFxObject HappinessBar;
var GFxObject HungerBar;

var string MouseState; //to check if mouse is inside the movie

function Init(optional LocalPlayer LocPlay)
{
	super.Init(LocPlay);

	Start();
	Advance(0.0f);

	Container = GetVariableObject("_root.container1");

	HappinessBar = GetVariableObject("_root.container1.happinessBar");
	HungerBar = GetVariableObject("_root.container1.hungerBar");
}

function Update(AGDCHController char)
{	
	Container.SetFloat("_x", 1024 / 2 - 140 / 2);
	Container.SetFloat("_y", 50);

	HappinessBar.SetFloat("_xscale", char.happyGauge * 100.0f);
	HungerBar.SetFloat("_xscale", char.hungerGauge * 100.0f);

	//HuntingBar.SetFloat("_xscale", (char.skillHunting.lvl >= 5) ? 100.0f : (float(char.skillHunting.totalExperience) - (char.levelRequirements[char.skillHunting.lvl - 1])) / ((float(char.levelRequirements[char.skillHunting.lvl])) - float(char.levelRequirements[char.skillHunting.lvl - 1])) * 100.0f);

	MouseState = Container.GetString("hitState");
}

DefaultProperties
{
	bDisplayWithHudOff = false	
	bEnableGammaCorrection=false

	MovieInfo = SwfMovie'AGDHUD.CharacterStatus'
}
