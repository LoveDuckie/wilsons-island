class AGDEntityMarker extends UDKPickupFactory placeable;

var () bool _random;
var () int _type;
var bool _assigned;

event Tick (float deltaTime)
{
	super.Tick(deltaTime);
}

defaultproperties
{
	_random = false;
	_type = 0;
	_assigned = false;

	// begin object class=SpriteComponent Name=DotSprite
		// Sprite=Texture2D'AGDPack.TestingMeshes.ResourceSpriteTwo'
		// HiddenGame=true;
		// AlwaysLoadOnClient=false;
		// AlwaysLoadOnServer=false;
	// end object
	// Components.Add(DotSprite)
}