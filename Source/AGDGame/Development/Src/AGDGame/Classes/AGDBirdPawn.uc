class AGDBirdPawn extends AGDAnimalPawn;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	SetPhysics(PHYS_Flying);
}

event Tick (float DeltaTime)
{
	super.Tick(DeltaTime);
}

DefaultProperties
{
	ControllerClass=class'AGDBirdController'

	begin object class=StaticMeshComponent Name=InitialFlyingBird
		CastShadow=true
		bAcceptsLights=true
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		CollideActors=false
		BlockActors=false
		LightEnvironment=MyLightEnvironment
		StaticMesh=StaticMesh'Animals.Meshes.SeagullShape'
		Scale3D=(X=1.0,Y=1.0,Z=1.0)
	end object
	Components.Add(InitialFlyingBird)

	// Get rid of the skeletal mesh, we don't need that.
	Components.Remove(InitialSkeletalMesh);
}
