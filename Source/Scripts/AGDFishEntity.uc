class AGDFishEntity extends UDKPawn placeable;

// ** FishEntity ** // 

// Amount that is obtainable from that given fishing area
var () int _amount;
var bool _selected; // This will enable the selection mesh to appear.

var AGDMeshSelectedChar _selectedMesh;

function PostBeginPlay()
{
	
}

event Tick (float deltaTime)
{
	//local Vector SelectedCharMeshOffset;

	//if (_selected == true)
	//{

	//	// If the mesh has not been selected,
	//	if (_selectedMesh == none)
	//	{
	//		_selectedMesh = Spawn(class'AGDMeshSelectedChar', Pawn, 'SelectedCharMesh');

	//		SelectedCharMeshOffset = Pawn.Location;
	//		SelectedCharMeshOffset.Z -= 50;

	//		// Apply the newly created local variable to the location of the char.
	//		SelectedMesh.SetLocation(SelectedCharMeshOffset);
	//	}
	//}
	//else
	//{
	//	if (_selectedMesh != none)
	//	{
	//		_selectedMesh.Destroy();
	//		_selectedMesh = none;
	//	}
	//}
}

function Update()
{

}

DefaultProperties
{

	_amount = 100;

	bBlockActors = true;
	bCollideActors = true;
	bStatic = false;
	bBlocksNavigation = true;

	Begin Object Class=SkeletalMeshComponent Name=SkeletalMeshComponent0
		SkeletalMesh= SkeletalMesh'Animals.Meshes.Fish'
		PhysicsAsset=PhysicsAsset'Animals.Meshes.Fish_Physics'
		AnimSets(0) = AnimSet'Animals.Meshes.Fishset'
		AnimTreeTemplate = AnimTree'Animals.Meshes.Fish_Tree'
		CastShadow=true
		bCastDynamicShadow=true
		bOwnerNoSee=false
        BlockRigidBody=true;
        CollideActors=true;
        BlockZeroExtent=true;
		BlockNonZeroExtent=TRUE
		bIgnoreControllersWhenNotRendered=TRUE
		bUpdateSkelWhenNotRendered=FALSE
	end object
	Mesh=SkeletalMeshComponent0
	Components.Add(SkeletalMeshComponent0)
		
	//Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
	//	ModShadowFadeoutTime=0.25
	//	MinTimeBetweenFullUpdates=0.2
	//	AmbientGlow=(R=.01,G=.01,B=.01,A=1)
	//	AmbientShadowColor=(R=0.15,G=0.15,B=0.15)
	//	LightShadowMode=LightShadow_ModulateBetter
	//	ShadowFilterQuality=SFQ_High
	//	bSynthesizeSHLight=TRUE
	//End Object
	//Components.Add(MyLightEnvironment)

	Begin Object Name=CollisionCylinder
		CollisionRadius=+0044.000000
		CollisionHeight=+0044.000000
		BlockZeroExtent=FALSE
	End Object
	Components.Add(CollisionCylinder)


}
