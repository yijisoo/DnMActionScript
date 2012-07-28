//  Assumptions:  Primary Key is in first column.
//                The location of data type information in the data schema is fixed and known
//                Data must either be a text or a number (Future: Nominal, ordinal, interval)

package DustAndMagnet
{
	import flash.events.IEventDispatcher;

	public class SizeCoder extends Encoder
	{
		public static const MIN_SIZE_CHANGED:String = "minSizeChanged";
		public static const MAX_SIZE_CHANGED:String = "maxSizeChanged";
		
		// The smallest and largest factor by which particle radii
		// can be scaled relative to standard size.
		private static const absoluteMin:Number = 0.25;
		private static const absoluteMax:Number = 4.00;
		
		// The smallest and largest numbers by which particle radii
		// are scaled to standard size according to user input.
		private var relativeMin:Number;
		private var relativeMax:Number;
		
		
		
		public function SizeCoder(visualization:VisualizationComponent, dataManager:DataManager)
		{
			super(visualization, dataManager);
		}
		
		public override function setEncodableAttributes():void
		{
			encodableAttributes = new Array();
			hashMap = new Array();
//  Assumption:  Primary Key is in first column.
			for (var i:int = 1; i < dataManager.getDataSchema().length; i++)
			{
				switch (dataManager.getDataSchema()[i][8])
				{
					case DataManager.INTERVAL:
					case DataManager.ORDINAL:
						encodableAttributes.push(dataManager.getDataSchema()[i][1]);
						hashMap.push(i);
				}	
			}
		}
		
		public function setRelativeMin(relativeMin:Number):void
		{
			this.relativeMin = relativeMin;
			updateEncoding();
		}
		
		public function setRelativeMax(relativeMax:Number):void
		{
			this.relativeMax = relativeMax;
			updateEncoding();
		}

		public override function encode(attribute:String):void
		{
			super.encode(attribute);
			
			attributeKey = hashMap[encodableAttributes.indexOf(attribute)];
			attributeType = dataManager.getDataSchema()[attributeKey][8];
			
			trace("sizeEncode");
			
			relativeMin = relativeMax = 1;
		}

		protected override function updateEncoding():void
		{
			var minRadius:Number = Particle.standardRadius * relativeMin;
			var rangeRadius:Number = Particle.standardRadius * (relativeMax - relativeMin);
			
			var data:Array = dataManager.getData();
			var particleList:Array = visualization.getParticleList();
			
			var i:int;
			
			switch (attributeType)
			{
				case DataManager.INTERVAL:
					var dataStatistics:Object = visualization.getDataStatistics();
					
					// Prevent possible division by zero
					var intervalRange:Number;
					switch (dataStatistics.range[attributeKey])
					{
						case 0:
							intervalRange = 1;
							break;
							
						default:
							intervalRange = dataStatistics.range[attributeKey];
					}
					
					for (i = 0; i < particleList.length; i++)
					{
						particleList[i].setRadius(rangeRadius * (data[i][attributeKey] -
							dataStatistics.min[attributeKey]) / intervalRange + minRadius);
					}
					
					break;
					
				case DataManager.ORDINAL:
					// Find the minimum and maximum values of the ordinal data
					var minLevel:int = dataManager.getDataSchema()[attributeKey][9][0][0];
					var maxLevel:int = minLevel;
					for	(i = 1; i < dataManager.getDataSchema()[attributeKey][9].length; i++)
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
					var nominalRange:int = maxLevel - minLevel;
					
					for (i = 0; i < particleList.length; i++)
					{
						var tupleKey:int = particleList[i].getTupleKey();
						
						var levelIndex:int;
						var dataSchema:Array = dataManager.getDataSchema();
						for (var j:int = 0; j < dataSchema[attributeKey][9].length; j++)
						{
							if (dataManager.getData()[tupleKey][attributeKey] == dataSchema[attributeKey][9][j][1])
							{
								levelIndex = dataSchema[attributeKey][9][j][0];
								break;
							}
						}
						
						particleList[i].setRadius(rangeRadius * (levelIndex - minLevel) / nominalRange + minRadius);
					}
				
					break;
					
				default:
					throw(new Error("Data type not found during ControlPanel.updateEncoding"));
			}
		}
		
		public override function removeEncoding():void
		{
			super.removeEncoding();
			
			trace("SizeCoder.removeEncoding");
			
			relativeMin = relativeMax = 1;
			
			var particleList:Array = visualization.getParticleList();
			for (var i:int = 0; i < particleList.length; i++)
			{
				particleList[i].setRadius(Particle.standardRadius);
			}
		}
	}
}