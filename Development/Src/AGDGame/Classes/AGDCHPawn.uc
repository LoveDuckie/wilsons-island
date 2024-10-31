/*******************************************************************************
	Character pawn
*******************************************************************************/

class AGDCHPawn extends UDKPawn placeable;


var DynamicLightEnvironmentComponent LightEnvironment;
var StaticMeshComponent Axe;
var StaticMeshComponent PickAxe;
var StaticMeshComponent Spear;

//Animations Node Variables
var AnimNodeBlendList   BlendListNode;
var AnimNodeBlendList   BlendWalkListNode;

// yay traits
var array<AGDCHTrait> _traits;

simulated event PostBeginPlay()
{
	local AGDCHTrait _traitTempOne;
	local AGDCHTrait _traitTempTwo;

	super.PostBeginPlay();

	_traitTempOne = Spawn(class'AGDCHTrait');
	_traitTempTwo = Spawn(class'AGDCHTrait');

	_traits.AddItem(_traitTempOne);
	_traits.AddItem(_traitTempTwo);

	SpawnDefaultController();
	InitTools();
	SetPhysics(PHYS_Walking);

	BlendListNode = AnimNodeBlendList(Mesh.FindAnimNode('BlendList'));
	BlendWalkListNode = AnimNodeBlendList(Mesh.FindAnimNode('BlendWalkList'));
}
function InitTools()
{
	//local AGDStructureStudy StudyBuilding;

	//foreach AllActors(class'AGDStructureStudy', StudyBuilding)
	//{
	//	Axe = StudyBuilding.Axe.MeshComp;
	//	PickAxe = StudyBuilding.PickAxe.MeshComp;
	//	Spear = StudyBuilding.Spear.MeshComp;
	//}	

	//Pawn Mesh Component Sockets
	Mesh.AttachComponentToSocket(Axe, 'Chop_Axe');
	Mesh.AttachComponentToSocket(Spear, 'Hunt');
	Mesh.AttachComponentToSocket(Spear, 'Fish');
	Mesh.AttachComponentToSocket(PickAxe, 'Mine');
}

event Touch(Actor Other, PrimitiveComponent OtherComp, vector HiLocation, vector HitNormal)
{
	`Log("I Touched iiiit");
	if(AGDCHController(Controller).IsMovingToActor)
	{
		if(Other.Tag == AGDCHController(Controller).CharacterTarget.Tag)
		{
				`Log("CheckPoint Reached");
			AGDCHController(Controller).bActorReached = true;
		}
	}
}
defaultproperties
{
	ControllerClass=class'AGDCHController'
	
	Begin Object Name=CollisionCylinder
		CollisionRadius=+0034.000000
		CollisionHeight=+0044.000000
		BlockZeroExtent=FALSE
	End Object
	
	Components.Remove(Sprite)
	
	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		ModShadowFadeoutTime=0.25
		MinTimeBetweenFullUpdates=0.2
		AmbientGlow=(R=.01,G=.01,B=.01,A=1)
		AmbientShadowColor=(R=0.15,G=0.15,B=0.15)
		LightShadowMode=LightShadow_ModulateBetter
		ShadowFilterQuality=SFQ_High
		bSynthesizeSHLight=TRUE
	End Object
	Components.Add(MyLightEnvironment)

	Begin Object Class=SkeletalMeshComponent Name=InitialSkeletalMesh
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
		PhysicsAsset=PhysicsAsset'Characters.Base_Mesh_Physics'
		AnimSets(0)=AnimSet'Characters.Char_Animset'
		AnimTreeTemplate=AnimTree'Characters.Basic_Tree'
		SkeletalMesh=SkeletalMesh'Characters.Base_Mesh'
	End Object
	Mesh=InitialSkeletalMesh;
	Components.Add(InitialSkeletalMesh);
		
	Begin Object Class=StaticMeshComponent Name=AxeMesh
		CastShadow=true
		bAcceptsLights=true
		HiddenGame = true
		CollideActors=false				
		BlockActors=false				
		StaticMesh=StaticMesh'Tools.Meshes.AxeShape2'
	End Object
	Axe=AxeMesh
	Components.Add(AxeMesh);	


	Begin Object Class=StaticMeshComponent Name=SpearMesh
		CastShadow=true
		bAcceptsLights= true
		HiddenGame = true
		CollideActors= false				
		BlockActors= false				
		StaticMesh=StaticMesh'Tools.Meshes.Spear_Lv01_Shape'
	End Object
	Spear=SpearMesh
	Components.Add(SpearMesh);

	Begin Object Class=StaticMeshComponent Name=PickAxeMesh
		CastShadow= true
		bAcceptsLights= true
		HiddenGame = true
		CollideActors=false				
		BlockActors=false				
		StaticMesh=StaticMesh'Tools.Meshes.PickaxeShape2'
	End Object
	PickAxe=PickAxeMesh
	Components.Add(PickAxeMesh);

	MaxJumpHeight=0;
	GroundSpeed = 295;
}