/* Base class for the interactable structures */

class AGDStructure extends DynamicSMActor_Spawnable notplaceable;

enum StructureType
{
	Fire<DisplayName=Fire>,
	Home<DisplayName=Home>,
	Storage<DisplayName=Storage>,
	Study<DisplayName=Study>,
};

var array<StaticMesh> StructureMeshes;

var StructureType Type;
var int Level;
var int WoodRq;
var int RockRq;
var int FoodRq;
var bool Selected;
var string Description;
var AGDPlayerController structPC;

var AGDGFxStructure GFxInfo;
var AGDGFxStorage GFxStorage;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
}
function SetPlayerController(AGDPlayerController PCOwner)
{
	structPC = PCOwner;
}
function Tick(float DeltaTime)
{
	if (Selected && GFxInfo == none)
		ShowSelection();
	else if (Selected && GFxInfo != none)
	{
		GFxInfo.Update(self);
		structPC.MouseMovieState = GFxInfo.MouseState;

		if (Type == StructureType.Storage)
		{
			GFxStorage.Update((AGDStructureStorage(self)));
			if(GFxStorage.MouseState == "over")
				structPC.MouseMovieState = "over";
		}
		else if (GFxStorage != none)
			CloseStorage();

		
	}
}

// Closes the scaleform movie for this object
function CloseSelection()
{
	if (GFxInfo != none)
	{
		GFxInfo.Close(true);
		GFxInfo = none;

		if (GFxStorage != none)
		{
			CloseStorage();
		}
	}
}

function CloseStorage()
{
	GFxStorage.Close(true);
	GFxStorage = none;
}
// Shows the scaleform movie for this object
function ShowSelection()
{
	CloseSelection();

	GFxInfo = new class'AGDGFxStructure';
	GFxInfo.SetTimingMode(TM_Real);
	GFxInfo.Init();		
	GFxInfo.SetPriority(0);

	if (Type == StructureType.Storage)
	{
		GFxStorage = new class'AGDGFxStorage';
		GFxStorage.SetTimingMode(TM_Real);
		GFxStorage.Init();		
		GFxStorage.SetPriority(0);
	}
}


// Used to change the structure or upgrade it to a new one
function Upgrade()
{
	//Check if the structure can be upgraded depending on resources available
	if(structPC.HomeStorage.HugeStorage.Wood >= WoodRq && structPC.HomeStorage.HugeStorage.Rock >= RockRq)
	{
		//Check if not maximum level
		if(Level < 4)
		{
			Level++;
			
			//Reduce storage ressources by number of ressources used.
			structPC.HomeStorage.HugeStorage.Wood -= WoodRq;
			structPC.HomeStorage.HugeStorage.Rock -= RockRq;
			
			//Increase ressources requirements for next level
			FoodRq += Level * 2;
			WoodRq += Level * 2;
			RockRq += Level * 2;

			//Change static mesh to newly upgraded building
			StaticMeshComponent.SetStaticMesh(StructureMeshes[Level - 1]);

			Selected = false;
			structPC.MouseMovieState = "out";
		}
		if(Level >= 4)
		{
			FoodRq = 0;
			WoodRq = 0;
			RockRq = 0;
		}
	}
}

defaultproperties
{
	begin object class=CylinderComponent name=CollisionRadius
		CollisionRadius=+00128.000000
		CollisionHeight=+00128.000000
	end object
	Components.Add(CollisionRadius);
	CollisionComponent=CollisionRadius
}

