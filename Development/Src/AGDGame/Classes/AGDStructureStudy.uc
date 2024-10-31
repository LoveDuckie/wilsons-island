/* The study structure */

class AGDStructureStudy extends AGDStructure placeable;

struct Tools
{
	var StaticMeshComponent MeshComp;
	var array<StaticMesh> Meshes;
	var int Level;
	var int WoodRq;
	var int RockRq;
};

var Tools Axe;
var Tools Spear;
var Tools PickAxe;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	StructureMeshes.AddItem(StaticMesh'Buildings.Meshes.Upgrade_Station_Two');
	StructureMeshes.AddItem(StaticMesh'Buildings.Meshes.Upgrade_Station_Three');
	StructureMeshes.AddItem(StaticMesh'Buildings.Meshes.Upgrade_Station_Four');	

	//Axe Meshes
	Axe.Meshes.AddItem(StaticMesh'Tools.Meshes.AxeShape2');
	Axe.Meshes.AddItem(StaticMesh'Tools.Meshes.AxeShape3');
	//Spear Meshes
	Spear.Meshes.AddItem(StaticMesh'Tools.Meshes.Spear_Lv01_Shape');
	Spear.Meshes.AddItem(StaticMesh'Tools.Meshes.Spear_Lv02_Shape');
	//PickAxe Meshes
	PickAxe.Meshes.AddItem(StaticMesh'Tools.Meshes.PickaxeShape2');
	PickAxe.Meshes.AddItem(StaticMesh'Tools.Meshes.PickaxeShape3');
}

// Used to change the tool or upgrade it to a new one
function UpgradeTool(Tools tool)
{
	//Check if the tool can be upgraded depending on resources available
	if(structPC.HomeStorage.HugeStorage.Wood >= tool.WoodRq && structPC.HomeStorage.HugeStorage.Rock >= tool.RockRq)
	{
		//Check if not maximum level
		if(tool.Level < 2)
		{
			tool.Level++;
			
			//REduce storage ressources by number of ressources used.
			structPC.HomeStorage.HugeStorage.Wood -= tool.WoodRq;
			structPC.HomeStorage.HugeStorage.Rock -= tool.RockRq;
			
			//Increase ressources requirements for next level
			tool.WoodRq += Level * 2;
			tool.RockRq += Level * 2;

			//Change static mesh to newly upgraded building
			StaticMeshComponent.SetStaticMesh(tool.Meshes[Level - 1]);

			Selected = false;
			structPC.MouseMovieState = "out";
		}
		else
		{
			tool.WoodRq = 0;
			tool.RockRq = 0;
		}
	}
}

defaultproperties
{
	Type = Study;
	Level = 1;
	FoodRq = 3;
	WoodRq = 7;
	RockRq = 12;
	Description = "Summer heat in the shadow of a chimney pigeons gather. (Made to upgrade tools)"

	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent1
		StaticMesh=StaticMesh'Buildings.Meshes.Upgrade_Station_One'
	    BlockRigidBody=false
		LightEnvironment=MyLightEnvironment
		bUsePrecomputedShadows=FALSE
	End Object
	CollisionComponent=StaticMeshComponent1
	StaticMeshComponent=StaticMeshComponent1
	Components.Add(StaticMeshComponent1)

	
	Begin Object Class=StaticMeshComponent Name=AxeMesh
		CastShadow=true
		bAcceptsLights=true
		HiddenGame = true
		CollideActors=false				
		BlockActors=false				
		StaticMesh=StaticMesh'Tools.Meshes.AxeShape1'
	End Object
	Axe=(MeshComp=AxeMesh, Level = 1, WoodRq = 1, RockRq = 2);
	Components.Add(AxeMesh);	


	Begin Object Class=StaticMeshComponent Name=SpearMesh
		CastShadow=true
		bAcceptsLights= true
		HiddenGame = true
		CollideActors= false				
		BlockActors= false				
		StaticMesh=StaticMesh'Tools.Meshes.Spear_Lv00_Shape'
	End Object
	Spear=(MeshComp=SpearMesh, Level = 1, WoodRq = 2, RockRq = 1);
	Components.Add(SpearMesh);

	Begin Object Class=StaticMeshComponent Name=PickAxeMesh
		CastShadow= true
		bAcceptsLights= true
		HiddenGame = true
		CollideActors=false				
		BlockActors=false				
		StaticMesh=StaticMesh'Tools.Meshes.PickaxeShape1'
	End Object
	PickAxe=(MeshComp= PickAxeMesh, Level = 1, WoodRq = 1, RockRq = 3)
	Components.Add(PickAxeMesh);
}