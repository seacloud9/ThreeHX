
package three.math;
import three.extras.MathUtils;

/**
 * ...
 * @author dcm
 */

class Line3
{
	
	public var start:Vector3;
	public var end:Vector3;
	
	
	public function new(start:Vector3 = null, end:Vector3 = null) 
	{
		this.start = (start != null ? start : new Vector3());
		this.end = (end != null ? end : new Vector3());
	}
	
	
	public function set (start:Vector3, end:Vector3) : Line3
	{
		this.start.copy(start);
		this.end.copy(end);
		return this;
	}
	
	
	public function copy (line:Line3) : Line3
	{
		start.copy(line.start);
		end.copy(line.end);
		return this;
	}
	
	
	public function center (optTarget:Vector3 = null) : Vector3
	{
		var result = (optTarget != null ? optTarget : new Vector3());
		return result.addVectors(start, end).multiplyScalar(0.5);
	}
	
	
	public function delta (optTarget:Vector3 = null) : Vector3
	{
		var result = (optTarget != null ? optTarget : new Vector3());
		return result.subVectors(end, start);
	}
	
	
	public function distanceSq () : Float
	{
		return start.distanceToSquared(end);
	}
	
	
	public function distance () : Float
	{
		return start.distanceTo(end);
	}
	
	
	public function at (t:Float, optTarget:Vector3 = null) : Vector3
	{
		var result = (optTarget != null ? optTarget : new Vector3());
		return delta(result).multiplyScalar(t).add(start);
	}
	
	
	public function closestPointToPointParameter (point:Vector3, clampToLine:Bool = false) : Float
	{
		var startP = new Vector3();
		var startEnd = new Vector3();
		
		startP.subVectors(point, start);
		startEnd.subVectors(end, start);
		
		var startEnd2 = startEnd.dot(startEnd);
		var startEnd_startP = startEnd.dot(startP);
		
		var t = startEnd_startP / startEnd2;
		
		if (clampToLine == true) t = MathUtils.clamp(t, 0, 1);
		
		return t;
	}
	
	
	public function applyMatrix4 (m:Matrix4) : Line3
	{
		start.applyMatrix4(m);
		end.applyMatrix4(m);
		return this;
	}
	
	
	public function equals (line:Line3) : Bool
	{
		return line.start.equals(start) && line.end.equals(end);
	}
	
	
	public function clone () : Line3
	{
		return new Line3().copy(this);
	}
	
	
}


