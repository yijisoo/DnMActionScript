//  Assumptions:  Primary Key is in first column.
//                The location of data type information in the data schema is fixed and known
//                Data must either be a text or a number (Future: Nominal, ordinal, interval)

package DustAndMagnet
{
	import flash.events.EventDispatcher;
	
	public class ColorCoder extends Encoder
	{
		public static const MIN_COLOR_CHANGED:String = "minColorChanged";
		public static const MAX_COLOR_CHANGED:String = "maxColorChanged"; 
		public static const NOMINAL_COLOR_CHANGED:String = "nominalColorChanged"; 
		
		private var minColor:uint;
		private var maxColor:uint;
		
		// Assigns colors to the levels of nominal data
		private var colorMap:Array;
		

		
		public function ColorCoder(visualization:VisualizationComponent, dataManager:DataManager)
		{
			super(visualization, dataManager)
		}

		public override function setEncodableAttributes():void
		{
			encodableAttributes = new Array();
			hashMap = new Array();
//  Assumption:  Primary Key is in first column.
			for (var i:int = 1; i < dataManager.getDataSchema().length; i++)
			{
				encodableAttributes.push(dataManager.getDataSchema()[i][1]);
				hashMap.push(i);
			}
		}

		public function setMinColor(color:uint):void
		{
			minColor = color;
			updateEncoding();
		}
		
		public function setMaxColor(color:uint):void
		{
			maxColor = color;
			updateEncoding();
		}
		
		public function setColorAt(level:String, color:uint):void
		{
			var levelIndex:int;
			
			for (var i:int = 0; i < levels.length; i++)
			{
				if (level == levels[i])
				{
					levelIndex = i;
					break;
				}		
			}
			
			colorMap[levelIndex] = color;
			updateEncoding();
		}

		public override function encode(attribute:String):void
		{	
			super.encode(attribute);
			
			attributeKey = hashMap[encodableAttributes.indexOf(attribute)];
			attributeType = dataManager.getDataSchema()[attributeKey][8];
			
			trace("colorEncode");
			
			colorMap = new Array();
			switch (attributeType)
			{
				case DataManager.INTERVAL:
				case DataManager.ORDINAL:
					minColor = maxColor = Particle.standardColor;
					
					break
				
				case DataManager.NOMINAL:
					setLevels();
					
					colorMap.length = levels.length;
					for (var i:int = 0; i < levels.length; i++)
					{
						colorMap.push(Particle.standardColor);
					}
					
					break;

				default: 
					throw(new Error("Data Type not found during variableSelectionListener"));
			}
		}

		protected override function updateEncoding():void
		{
			trace("updateColorEncoding");
			
			var particleList:Array = visualization.getParticleList();
			
			var i:int;
			var j:int;
			
			var redRange:Number = 0;
			var greenRange:Number = 0;
			var blueRange:Number = 0;
			var range:int = 0;
			
			var red:int;
			var green:int;
			var blue:int;
			
			switch (attributeType)
			{
				case DataManager.INTERVAL:
					redRange = int(maxColor/65536) - int(minColor/65536);
					greenRange = int(maxColor%65536/256) - int(minColor%65536/256);
					blueRange = maxColor%256 - minColor%256;
		
					
					var dataStatistics:Object = visualization.getDataStatistics();
					for (i = 0; i < particleList.length; i++)
					{
						red = (dataManager.getData()[particleList[i].getTupleKey()][attributeKey] - dataStatistics.min[attributeKey]) /
							dataStatistics.range[attributeKey] * redRange + int(minColor/65536);
						green = (dataManager.getData()[particleList[i].getTupleKey()][attributeKey] - dataStatistics.min[attributeKey]) /
							dataStatistics.range[attributeKey] * greenRange + int(minColor%65536/256);
						blue = (dataManager.getData()[particleList[i].getTupleKey()][attributeKey] - dataStatistics.min[attributeKey]) /
							dataStatistics.range[attributeKey] * blueRange + minColor%256;
						particleList[i].setColor(int(red*65536) + int(green*256) + int(blue));
					}
					
					break;
					
				case DataManager.ORDINAL:
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
					
					range = maxLevel - minLevel;
					
					redRange = int(maxColor/65536) - int(minColor/65536);
					greenRange = int(maxColor%65536/256) - int(minColor%65536/256);
					blueRange = maxColor%256 - minColor%256;
							
					for (i = 0; i < particleList.length; i++)
					{
						var tupleKey:int = particleList[i].getTupleKey();
						
						var levelIndex:int;
						for (j = 0; j < dataManager.getDataSchema()[attributeKey][9].length; j++)
						{
							if (dataManager.getData()[tupleKey][attributeKey] == dataManager.getDataSchema()[attributeKey][9][j][1])
							{
								levelIndex = dataManager.getDataSchema()[attributeKey][9][j][0];
								break;
							}
						}
						
						red = (levelIndex - minLevel) / range * redRange + int(minColor/65536);
						green = (levelIndex - minLevel) / range * greenRange + int(minColor%65536/256);
						blue = (levelIndex - minLevel) / range * blueRange + minColor%256;
						particleList[i].setColor(int(red*65536) + int(green*256) + int(blue));
					}
					
					break;
					
				case DataManager.NOMINAL:
					for (i = 0; i < levels.length; i++)
					{
						for (j = 0; j < levelMaps[i].length; j++)
						{
							particleList[levelMaps[i][j]].setColor(colorMap[i]);
						}
					}
					
					break
					
				default:
					throw(new Error("Data Type not found during variableSelectionListener"));
			}
		}

		public override function removeEncoding():void
		{
			super.removeEncoding();
			
			var i:int;
			
			switch (attributeType)
			{
				case DataManager.INTERVAL:
				case DataManager.ORDINAL:
					minColor = maxColor = Particle.standardColor;
					
					break;
					
				case DataManager.NOMINAL:
					levels = null;
					levelMaps = null;
					colorMap = null;
					
					break;
			}
			
			var particleList:Array = visualization.getParticleList();
			for (i = 0; i < particleList.length; i++)
			{
				particleList[i].setColor(Particle.standardColor);
			}
		}

		public function assignDefaultColors():void
		{
			trace("assignDefaultColors");
			
			switch (attributeType)
			{
				case DataManager.INTERVAL:
				case DataManager.ORDINAL:
					minColor = 0x0000FF;					
					maxColor = 0xFF0000;
					
					dispatchEvent(new ColorCoderEvent(ColorCoder.MIN_COLOR_CHANGED, minColor));
					dispatchEvent(new ColorCoderEvent(ColorCoder.MAX_COLOR_CHANGED, maxColor));
					
					break;
				
				case DataManager.NOMINAL:
					for (var i:int = 0; i < levels.length; i++)
					{
						// Assign 12 colors recommended for coding ("Information Visualization: Perception for Design" p. 125)
						// Hex colors are based on the HTML color code
						// Note:  White has been excluded so only 11 colors are used.
		
						switch (i%11)
						{
							// Blue
							case 0:
							colorMap[i] = 0x0000FF;					
							break;
							
							// Red
							case 1:
							colorMap[i] = 0xFF0000;
							break;
							
							// Yellow
							case 2:
							colorMap[i] = 0xFFFF00;
							break;
							
							// Green
							case 3:
							colorMap[i] = 0x00FF00;
							break;
							
							// Black
							case 4:
							colorMap[i] = 0x000000;
							break;
							
							// Pink (Hot pink in HTML color code)
							case 5:
							colorMap[i] = 0xFF69B4;
							break;
							
							// Cyan
							case 6:
							colorMap[i] = 0x00FFFF;
							break;
							
							// Gray
							case 7:
							colorMap[i] = 0x808080;
							break;
							
							// Orange (Not from the HTML color code)
							case 8:
							colorMap[i] = 0xFF9900;
							break;
							
							// Brown (Saddle Brown in HTML color code)
							case 9:
							colorMap[i] = 0x8B4513;
							break;
							
							// Purple
							case 10:
							colorMap[i] = 0x800080;
							break;
						}
						
						dispatchEvent(new ColorCoderEvent(ColorCoder.NOMINAL_COLOR_CHANGED, colorMap[i], levels[i]));
					}
					break;
					
				default:
					throw(new Error("Datatype not found during ColorCoder.assignDefaultColors()"));
			}
			
			updateEncoding();
		}
	}
}