// The object that will show the current skill levels and inventory of the double clicked character

class AGDGFxCharacterInfo extends GFxMoviePlayer;

var GFxObject Container;

var GFxObject HuntingLVL;

var GFxObject GatheringLVL;

var GFxObject ExplorationLVL;

var GFxObject HuntingEXP;
var GFxObject GatheringEXP;
var GFxObject ExplorationEXP;

var GFxObject Food;
var GFxObject Wood;
var GFxObject Rock;

var string MouseState; //to check if mouse is inside the movie

function Init(optional LocalPlayer LocPlay)
{
	super.Init(LocPlay);

	Start();
	Advance(0.0f);

	Container = GetVariableObject("_root.container");

	HuntingLVL = GetVariableObject("_root.container.huntingLVL");
	GatheringLVL = GetVariableObject("_root.container.gatheringLVL");
	ExplorationLVL = GetVariableObject("_root.container.explorationLVL");

	HuntingEXP = GetVariableObject("_root.container.huntingEXP");
	GatheringEXP = GetVariableObject("_root.container.gatheringEXP");
	ExplorationEXP = GetVariableObject("_root.container.explorationEXP");

	Food = GetVariableObject("_root.container.food");
	Wood = GetVariableObject("_root.container.wood");
	Rock = GetVariableObject("_root.container.rock");
}

function Update(AGDCHController char)
{	
	Container.SetFloat("_x", 32);
	Container.SetFloat("_y", 32);

	HuntingLVL.SetText("Hunting: Level " $ char.skillHunting.lvl);
	GatheringLVL.SetText("Gathering: Level " $ char.skillGathering.lvl);
	ExplorationLVL.SetText("Exploration: Level " $ char.skillExploration.lvl);

	HuntingEXP.SetText(char.skillHunting.totalExperience $ " of " $ char.levelRequirements[char.skillHunting.lvl] $ " experience");
	GatheringEXP.SetText(char.skillGathering.totalExperience $ " of " $ char.levelRequirements[char.skillGathering.lvl] $ " experience");
	ExplorationEXP.SetText(char.skillExploration.totalExperience $ " of " $ char.levelRequirements[char.skillExploration.lvl] $ " experience");


	Food.SetText(char.CharacterStorage.Food);
	Wood.SetText(char.CharacterStorage.Wood);
	Rock.SetText(char.CharacterStorage.Rock);
	
	MouseState = Container.GetString("hitState");
}

DefaultProperties
{
	bDisplayWithHudOff = false	
	bEnableGammaCorrection=false

	MovieInfo = SwfMovie'AGDHUD.CharacterInfo'
}
