/******************************************************
 * Mesh for the Mouse Cursor
 * ****************************************************/


class AGDMeshMouseCursor extends Actor;

var() StaticMeshComponent Mesh;

DefaultProperties
{
        Begin Object Class=StaticMeshComponent Name=MarkerMesh
                BlockActors=false
                CollideActors=true
                BlockRigidBody=false
                StaticMesh=StaticMesh'WP_RocketLauncher.Mesh.S_WP_RocketLauncher_Exhaust'
                //Materials[0]=MaterialInterface'EngineMaterials.ScreenMaterial'
                Scale3D=(X=1.0,Y=1.0,Z=1.0)
                Rotation=(Pitch=-16384, Yaw=0, Roll=0)

        End Object
        Mesh=MarkerMesh
        CollisionComponent=MarkerMesh
        Components.Add(MarkerMesh)
}
