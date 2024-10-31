class AGDBoarPawn extends AGDAnimalPawn placeable;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

}

DefaultProperties
{
	ControllerClass=class'AGDBoarController'

	bBlocksNavigation = true;
	bBlockActors = true;

	Begin Object Name=CollisionCylinder
		CollisionRadius=+0034.000000
		CollisionHeight=+0048.000000
		BlockZeroExtent=FALSE
	End Object

	Components.Add(CollisionCylinder);

	Begin Object Name=InitialSkeletalMesh
		CastShadow=true
		bCastDynamicShadow=true
		bOwnerNoSee=false
		LightEnvironment=MyLightEnvironment;
        BlockRigidBody=true;
        CollideActors=true;
        BlockZeroExtent=true;
		BlockNonZeroExtent=TRUE
		bIgnoreControllersWhenNotRendered=TRUE
		bUpdateSkelWhenNotRendered=FALSE
		PhysicsAsset=PhysicsAsset'Animals.Boar_Physics'
		AnimSets(0)=AnimSet'Animals.Meshes.Boar_AnimSet'
		AnimTreeTemplate=AnimTree'Animals.Meshes.Boar_AnimTree'
		SkeletalMesh=SkeletalMesh'Animals.Meshes.Boar'
	End Object
	Mesh=InitialSkeletalMesh;
	Components.Add(InitialSkeletalMesh);

}
