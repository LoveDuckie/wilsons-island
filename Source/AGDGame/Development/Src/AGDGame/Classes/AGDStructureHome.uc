/* The home structure */

class AGDStructureHome extends AGDStructure placeable;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	StructureMeshes.AddItem(StaticMesh'NEC_Pillars.SM.Mesh.S_NEC_Pillars_SM_Techpillar01a');
	StructureMeshes.AddItem(StaticMesh'NEC_Pillars.SM.Mesh.S_NEC_Pillars_SM_Techpillar01a');
	StructureMeshes.AddItem(StaticMesh'NEC_Pillars.SM.Mesh.S_NEC_Pillars_SM_Techpillar01a');
	StructureMeshes.AddItem(StaticMesh'NEC_Pillars.SM.Mesh.S_NEC_Pillars_SM_Techpillar01a');
	StructureMeshes.AddItem(StaticMesh'NEC_Pillars.SM.Mesh.S_NEC_Pillars_SM_Techpillar01a');
}

defaultproperties
{
	Type = Home;
	Level = 1;
	
	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent1
		StaticMesh=StaticMesh'NEC_Pillars.SM.Mesh.S_NEC_Pillars_SM_Techpillar01a'
	    BlockRigidBody=false
		LightEnvironment=MyLightEnvironment
		bUsePrecomputedShadows=FALSE
	End Object
	CollisionComponent=StaticMeshComponent1
	StaticMeshComponent=StaticMeshComponent1
	Components.Add(StaticMeshComponent1)
}