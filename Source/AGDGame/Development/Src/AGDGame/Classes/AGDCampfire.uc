class AGDCampfire extends DynamicSMActor_spawnable;

var int _food;

function PostBeginPlay()
{

}

DefaultProperties
{
	bCollideActors = true;
	bStatic = false;

	begin object name=StaticMeshComponent0
			CastShadow=true
			bAcceptsLights=true
			AlwaysLoadOnClient=true
			AlwaysLoadOnServer=true
			CollideActors=false
			BlockActors=false
			StaticMesh=StaticMesh'Buildings.Meshes.Campfire_LV_1'
			Scale3D=(X=0.25,Y=0.25,Z=0.25)
			Rotation=(Pitch=-16384)
		end object
	Components.Add(StaticMeshComponent0);
	StaticMeshComponent=StaticMeshComponent0
	
	
	begin object class=CylinderComponent name=CollisionRadius
		CollisionRadius=+00128.000000
		CollisionHeight=+00128.000000
	end object
	Components.Add(CollisionRadius);
	CollisionComponent=CollisionRadius
}
