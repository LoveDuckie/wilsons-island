class AGDEntity extends DynamicSMActor_Spawnable placeable;

var () int _type;
var int _amount;
var string _name;
var Vector MeshPosition;

function PostBeginPlay()
{
	super.PostBeginPlay();
}

function RotateResource()
{
	
}

// What will happen when a character pawn touches the entity.
event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{


}

event PostRender()
{
	switch(_type)
	{
		case 0:
			StaticMeshComponent.SetStaticMesh(StaticMesh'Terrain.Meshes.SIM_BOLDER_01');
		break;
		
		case 1:
			StaticMeshComponent.SetStaticMesh(StaticMesh'Resources.Meshes.Palmtree');
		break;
		
		case 2:
			StaticMeshComponent.SetStaticMesh(StaticMesh'Resources.Meshes.Berry_Bush_Shape');
		break;	
	}
}

// Ensure that the right static mesh is loaded
event Tick (float deltaTime)
{
	super.Tick(deltaTime);
		
	switch(_type)
	{
		case 0:
			StaticMeshComponent.SetStaticMesh(StaticMesh'Terrain.Meshes.SIM_BOLDER_01');
		break;
		
		case 1:
			StaticMeshComponent.SetStaticMesh(StaticMesh'Resources.Meshes.Palmtree');
		break;
		
		case 2:
			StaticMeshComponent.SetStaticMesh(StaticMesh'Resources.Meshes.Berry_Bush_Shape');
		break;	
	}
}

defaultproperties
{
	_amount = 40;
	
	bBlockActors = true;
	bCollideActors = true;
	bStatic = false;
	bBlocksNavigation = true;

	begin object name=StaticMeshComponent0
			CastShadow=true
			bAcceptsLights=true
			AlwaysLoadOnClient=true
			AlwaysLoadOnServer=true
			CollideActors=true				// Setting CollideActors and BlockActors to true enables the
			BlockActors=true				// mouse to detect them and interact with them later
			StaticMesh=StaticMesh'Resources.Meshes.Palmtree'
			Scale3D=(X=1,Y=1,Z=1)
		end object
	Components.Add(StaticMeshComponent0);
	StaticMeshComponent=StaticMeshComponent0
	
	
	/*begin object class=CylinderComponent name=CollisionRadius
		CollisionRadius=+00128.000000
		CollisionHeight=+00128.000000
		BlockZeroExtent=FALSE
	end object
	Components.Add(CollisionRadius);
	CollisionComponent=CollisionRadius*/
}