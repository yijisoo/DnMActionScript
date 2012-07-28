// Assumptions:  The location of the ordinal data levels in the schema is known.

// Problems:  Must find the max and min levels because dataStatistics does not work for ordinal data

package DustAndMagnet.MagnetClasses
{
	import DustAndMagnet.DataManager;
	import DustAndMagnet.Particle;
	
	import flash.geom.Point;

	public class OrdinalMagnet extends Magnet
	{
		private var maxLevel:int;
		private var minLevel:int;
		private var range:int;
		
		public function OrdinalMagnet(attributeKey:int, dataManager:DataManager, dataStatistics:Object)
		{
			super(attributeKey, dataManager, dataStatistics);
			
			// Find maximum and minimum levels
			minLevel = dataManager.getDataSchema()[attributeKey][9][0][0];
			maxLevel = minLevel;
			for	(var i:int = 1; i < dataManager.getDataSchema()[attributeKey][9].length; i++)
			{
				if (dataManager.getDataSchema()[attributeKey][9][i][0] < minLevel)
				{
					minLevel = dataManager.getDataSchema()[attributeKey][9][i][0];
				}
				else if (dataManager.getDataSchema()[attributeKey][9][i][0] > maxLevel)
				{
					maxLevel = dataManager.getDataSchema()[attributeKey][9][i][0];
				}
			}
			range = maxLevel - minLevel;
			
			repulsionThreshold = minLevel;
		}
	
		public function getMaxLevel():int
		{
			return maxLevel;
		}

		public function getMinLevel():int
		{
			return minLevel;
		}
	
		override public function getAttraction(particle:Particle):Point
		{
			var attractionMagnitude:Number;
			var attractionDirection:Point = new Point();
			var attractionDirectionMagnitude:Number;
			var attraction:Point = new Point();
			var tupleKey:int = particle.getTupleKey();
			
			var levelIndex:int;
			var dataSchema:Array = dataManager.getDataSchema();
			for (var i:int = 0; i < dataSchema[attributeKey][9].length; i++)
			{
				if (dataManager.getData()[tupleKey][attributeKey] == dataSchema[attributeKey][9][i][1])
				{
					levelIndex = dataSchema[attributeKey][9][i][0];
					break;
				}
			}
			
			attractionMagnitude = magnitude/100*(levelIndex - repulsionThreshold)/range;
			attractionDirection.x = (x - particle.getPosition().x);
			attractionDirection.y = (y - particle.getPosition().y);
			attractionDirectionMagnitude = Math.sqrt(attractionDirection.x * attractionDirection.x + attractionDirection.y * attractionDirection.y);
			attraction.x = attractionMagnitude * attractionDirection.x / attractionDirectionMagnitude;
			attraction.y = attractionMagnitude * attractionDirection.y / attractionDirectionMagnitude;
			
			return attraction;
			
			return attraction;
		}	
	}
}