/* The fire structure */

class AGDStructureFire extends AGDStructure placeable;


simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	StructureMeshes.AddItem(StaticMesh'Buildings.Meshes.Campfire_LV_2');
	StructureMeshes.AddItem(StaticMesh'Buildings.Meshes.Campfire_LV_3');
	StructureMeshes.AddItem(StaticMesh'Buildings.Meshes.Campfire_LV_4');
}

defaultproperties
{
	Type = Fire;
	Level = 1;
	FoodRq = 2;
	WoodRq = 15;
	RockRq = 10;
	Description = "As the centerpiece of the camp, the gang prefer to gather here to eat stored food. (Click to eat)"
	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent1
		StaticMesh=StaticMesh'Buildings.Meshes.Campfire_LV_1'
	    BlockRigidBody=false
		LightEnvironment=MyLightEnvironment
		bUsePrecomputedShadows=FALSE
	End Object
	//CollisionComponent=StaticMeshComponent1
	StaticMeshComponent=StaticMeshComponent1
	Components.Add(StaticMeshComponent1)
}