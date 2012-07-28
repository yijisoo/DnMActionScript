package DustAndMagnet.MagnetClasses
{
	import DustAndMagnet.*;
	
	import flash.geom.Point;
	
	public class NominalMagnet extends Magnet
	{
		private var levels:Array = new Array();
		
		// Same length as levels array.  Entry for attractive levels is 0.  Entry for repulsive levels is 1.
		private var isLevelRepelled:Array = new Array();
		
		public function NominalMagnet(attributeKey:int, dataManager:DataManager, dataStatistics:Object)
		{
			super(attributeKey, dataManager, dataStatistics);
			
			//  Create an array of the possible levels for the nominal variable.
			var data:Array = dataManager.getData();
			var inArray:Boolean;
			for (var i:int = 0; i < data.length; i++)
			{
				inArray = false;
				for (var j:int = 0; j < levels.length; j++)
				{
					if (data[i][attributeKey] == levels[j])
					{
						inArray = true;
						break
					}
				}
				if (inArray == false)
				{
					levels.push(data[i][attributeKey]);
					isLevelRepelled.push(0);
				}
			}
			levels.sort();
		}
		
		public function getLevels():Array
		{
			return levels;
		}
		
		public function getIsLevelRepelled():Array
		{
			return isLevelRepelled;
		}
		
		public function toggleRepulsion(levelIndex:int):void
		{
			isLevelRepelled[levelIndex] = !isLevelRepelled[levelIndex];
		}
		
		override public function getAttraction(particle:Particle):Point
		{
			var attractionMagnitude:Number;
			var attractionDirection:Point = new Point();
			var attractionDirectionMagnitude:Number;
			var attraction:Point = new Point();
			var tupleKey:int = particle.getTupleKey();
			
			var levelIndex:int;
			for (var i:int = 0; i < levels.length; i++)
			{
				if (dataManager.getData()[tupleKey][attributeKey] == levels[i])
				{
					levelIndex = i;
					break;
				}
			}
			
			attractionMagnitude = magnitude/100*Math.pow(-1, isLevelRepelled[levelIndex])*levelIndex/(levels.length - 1);;
			attractionDirection.x = (x - particle.getPosition().x);
			attractionDirection.y = (y - particle.getPosition().y);
			attractionDirectionMagnitude = Math.sqrt(attractionDirection.x * attractionDirection.x + attractionDirection.y * attractionDirection.y);
			attraction.x = attractionMagnitude * attractionDirection.x / attractionDirectionMagnitude;
			attraction.y = attractionMagnitude * attractionDirection.y / attractionDirectionMagnitude;
			
			return attraction;
		}
	}
}