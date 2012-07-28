package DustAndMagnet.MagnetClasses
{
	import DustAndMagnet.*;
	
	import flash.geom.Point;

	public class IntervalMagnet extends Magnet
	{
		public function IntervalMagnet(attributeKey:int, dataManager:DataManager, dataStatistics:Object)
		{
			super(attributeKey, dataManager, dataStatistics);
		}
		
		override public function getAttraction(particle:Particle):Point
		{
			var attractionMagnitude:Number;
			var attractionDirection:Point = new Point();
			var attractionDirectionMagnitude:Number;
			var attraction:Point = new Point();
			var tupleKey:int = particle.getTupleKey();
			
			attractionMagnitude = magnitude/100*(dataManager.getData()[tupleKey][this.attributeKey] -
				repulsionThreshold) / dataStatistics.range[this.attributeKey];
			attractionDirection.x = (x - particle.getPosition().x);
			attractionDirection.y = (y - particle.getPosition().y);
			attractionDirectionMagnitude = Math.sqrt(attractionDirection.x * attractionDirection.x + attractionDirection.y * attractionDirection.y);
			attraction.x = attractionMagnitude * attractionDirection.x / attractionDirectionMagnitude;
			attraction.y = attractionMagnitude * attractionDirection.y / attractionDirectionMagnitude;
			
			return attraction;
		}
	}
}