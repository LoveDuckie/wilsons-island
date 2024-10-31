class AGDCHSpawnMarker extends UDKPickupFactory;

// If you're wondering why I use UDKPickupFactory, it's for the icon that appears within the Editor.

// Nothing more, nothing less.

enum SpawnType
{
	Campfire,
	Character
};

var SpawnType _spawnType;

function PostBeginPlay()
{
	_spawntype = Campfire;
}

DefaultProperties
{
}
