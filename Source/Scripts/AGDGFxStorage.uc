// The object that will show the current skill levels and inventory of the double clicked character

class AGDGFxStorage extends GFxMoviePlayer;

var GFxObject Container;

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

	Food = GetVariableObject("_root.container.food");
	Wood = GetVariableObject("_root.container.wood");
	Rock = GetVariableObject("_root.container.rock");
}

function Update(AGDStructureStorage storage)
{	
	Container.SetFloat("_x", 32);
	Container.SetFloat("_y", 32 + 32 + 319);

	Food.SetText(storage.HugeStorage.Food);
	Wood.SetText(storage.HugeStorage.Wood);
	Rock.SetText(storage.HugeStorage.Rock);
	
	MouseState = Container.GetString("hitState");
}

DefaultProperties
{
	bDisplayWithHudOff = false	
	bEnableGammaCorrection=false

	MovieInfo = SwfMovie'AGDHUD.StructureStorage'
}
