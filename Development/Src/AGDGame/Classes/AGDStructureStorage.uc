/* The storage structure */

class AGDStructureStorage extends AGDStructure placeable;

struct EntityStorage
{
	var int Rock;
	var int Wood;
	var int Food;
};

var EntityStorage HugeStorage;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	StructureMeshes.AddItem(StaticMesh'Buildings.Meshes.Storage_Lv01_Shape');
	StructureMeshes.AddItem(StaticMesh'Buildings.Meshes.Storage_Lv02_Shape');
	StructureMeshes.AddItem(StaticMesh'Buildings.Meshes.Storage_Lv03_Shape');	
}

defaultproperties
{
	Type = Storage;
	Level = 1;
	FoodRq = 5;
	WoodRq = 10;
	RockRq = 10;

	HugeStorage = (Rock = 0, Wood = 0);
	Description = "Used to store large amounts of food, wood and rock. (Click to store resources in possesion."
	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent1
		StaticMesh=StaticMesh'Buildings.Meshes.Storage_Lv00_Shape'
	    BlockRigidBody=false
		LightEnvironment=MyLightEnvironment
		bUsePrecomputedShadows=FALSE
	End Object
	//CollisionComponent=StaticMeshComponent1
	StaticMeshComponent=StaticMeshComponent1
	Components.Add(StaticMeshComponent1)
}